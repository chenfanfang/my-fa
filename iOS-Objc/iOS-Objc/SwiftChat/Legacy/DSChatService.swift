import Foundation

public enum DSChatAPIError: Error { case missingKey, badURL, http(Int), decode }

// API 配置：API Key 通过宏 / 常量 DEEPSEEK_API_KEY 提供（不要在此文件明文写入）
private enum DSChatConfig {
    static let apiKey: String = AppConfig.apiKey
    static let endpoint = URL(string: AppConfig.endpoint)
    static let model = "deepseek-ai/DeepSeek-V3.1-Terminus"
}

public extension Notification.Name {
    static let DSChatStartersReady = Notification.Name("DSChatStartersReady")
}

public final class DSChatService {
    public static let shared = DSChatService()
    private init() {}

    /// 调用 DeepSeek Chat 完成接口，生成与股票相关的中文提问建议（约 5 条）。
    /// - Parameters:
    ///   - name: 股票名称，例如 “贵州茅台”
    ///   - symbol: 股票代码，例如 “600519”
    ///   - completion: 主线程回调，返回建议问题数组或错误
    public func fetchStartersForStock(name: String, symbol: String, completion: @escaping (Result<[String], Error>) -> Void) {
        let apiKey = DSChatConfig.apiKey
        guard !apiKey.isEmpty else { completion(.failure(DSChatAPIError.missingKey)); return }
        guard let url = DSChatConfig.endpoint else {
            completion(.failure(DSChatAPIError.badURL)); return
        }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let systemPrompt = """
你是一个「精简版证券投顾提问生成器」。

【任务】
我会给你一行或多行「关键词」，可能是：
- 时间或时间范围（如：近 6 个月、今年以来）
- 标的物（如：平安银行、贵州茅台、沪深 300）
- 新闻或事件名称（如：美联储降息、业绩大幅下滑）

请你围绕这些关键词，发散 2–3 个与「证券投资」高度相关的问题。

【风格要求（很重要）】
- 问题要「极简」，像普通投资者随口会问的那种。
- 每个问题只问一件事。
- 尽量不要用逗号，一个问题只用一句话说完。
- 不要出现「结合…」「基于…」「从…角度」「综合分析」等复杂表达。
- 不要解释背景，不要复述条件，只抛出核心疑问（涨跌、买卖、风险、仓位等）。
- 可以用第一人称「我」，让问题更自然。

【长度要求】
- 每个问题尽量不超过 18 个汉字。
- 句式简单直接，例如：
  - 「平安银行还能继续持有吗？」
  - 「近半年贵州茅台走势怎么样？」
  - 「这条新闻利好还是利空？」

【输出格式】
- 只输出问题本身，每行一个问题。
- 不要加序号、标点前缀或任何说明文字。
"""

        let userKeywords = """
【现在的输入关键词】：
标的物：\(name)（\(symbol)）
"""

        let body: [String: Any] = [
            "model": DSChatConfig.model,
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userKeywords]
            ],
            "stream": false,
            "temperature": 0.2
        ]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: req) { data, resp, err in
            if let err = err { DispatchQueue.main.async { completion(.failure(err)) }; return }
            guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode), let data = data else {
                let code = (resp as? HTTPURLResponse)?.statusCode ?? -1
                DispatchQueue.main.async { completion(.failure(DSChatAPIError.http(code))) }
                return
            }
            struct Resp: Decodable { struct Choice: Decodable { struct Msg: Decodable { let content: String }; let message: Msg }; let choices: [Choice] }
            if let decoded = try? JSONDecoder().decode(Resp.self, from: data), let content = decoded.choices.first?.message.content {
                let starters = DSChatService.parseStarters(from: content)
                DispatchQueue.main.async { completion(.success(starters)) }
            } else {
                DispatchQueue.main.async { completion(.failure(DSChatAPIError.decode)) }
            }
        }.resume()
    }

    // MARK: - Helpers
    private static func parseStarters(from content: String) -> [String] {
        if let data = content.data(using: .utf8), let arr = try? JSONSerialization.jsonObject(with: data) as? [String] { return arr }
        let lines = content
            .replacingOccurrences(of: "\r", with: "")
            .components(separatedBy: "\n")
            .compactMap { line -> String? in
                let t = line.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !t.isEmpty else { return nil }
                let stripped = t.replacingOccurrences(of: "^-?\\s*\\d+[\\)\\.]*\\s*", with: "", options: .regularExpression)
                return stripped
            }
        if !lines.isEmpty { return lines }
        return ["基本面如何？", "估值是否合理？", "近期走势怎么看？", "行业景气度？", "核心风险是什么？"]
    }
}
