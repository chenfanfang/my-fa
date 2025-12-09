import Foundation
import UIKit
import ConvoUI

// Global caches (not main actor-isolated) to be safe in background URLSession callbacks
final class StockCaches {
    static let spark = NSCache<NSString, NSArray>()
    static let price = NSCache<NSString, NSNumber>()
}

// MARK: - Row Cell (Search List Style)

@available(iOS 15.0, *)
final class StockRowCell: UICollectionViewCell {
    static let reuseId = "StockRowCell"

    private let container = UIView()
    private let nameLabel = UILabel()
    private let exchangeBadge = UILabel()
    private let codeLabel = UILabel()
    private let priceLabel = UILabel()
    private let changeLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }

    private func setup() {
        contentView.backgroundColor = .clear
        container.translatesAutoresizingMaskIntoConstraints = false
        // Keep background clear, but add a subtle border as requested
        container.backgroundColor = .clear
        container.layer.cornerRadius = 12
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.separator.withAlphaComponent(0.35).cgColor
        contentView.addSubview(container)

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        nameLabel.textColor = .label

        exchangeBadge.translatesAutoresizingMaskIntoConstraints = false
        exchangeBadge.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        exchangeBadge.textColor = .secondarySystemBackground
        exchangeBadge.backgroundColor = .secondaryLabel.withAlphaComponent(0.6)
        exchangeBadge.textAlignment = .center
        exchangeBadge.layer.cornerRadius = 6
        exchangeBadge.clipsToBounds = true
        exchangeBadge.setContentHuggingPriority(.required, for: .horizontal)

        codeLabel.translatesAutoresizingMaskIntoConstraints = false
        codeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 13, weight: .regular)
        codeLabel.textColor = .secondaryLabel

        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 17, weight: .semibold)
        priceLabel.textColor = .label
        priceLabel.textAlignment = .right

        changeLabel.translatesAutoresizingMaskIntoConstraints = false
        changeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 13, weight: .medium)
        changeLabel.textAlignment = .right

        container.addSubview(nameLabel)
        container.addSubview(exchangeBadge)
        container.addSubview(codeLabel)
        container.addSubview(priceLabel)
        container.addSubview(changeLabel)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            nameLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 14),
            nameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 14),

            exchangeBadge.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            exchangeBadge.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 8),
            exchangeBadge.heightAnchor.constraint(equalToConstant: 20),
            exchangeBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 28),

            codeLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6),
            codeLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            codeLabel.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor, constant: -12),

            priceLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 14),
            priceLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -14),

            changeLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 6),
            changeLabel.trailingAnchor.constraint(equalTo: priceLabel.trailingAnchor),
            changeLabel.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor, constant: -12)
        ])
    }

    func configure(symbol: String, name: String, exchange: String, price: Double?, changePct: Double? = nil) {
        nameLabel.text = name
        exchangeBadge.text = " \(exchange) "
        codeLabel.text = symbol
        if let p = price {
            priceLabel.text = String(format: "¥%.2f", p)
        } else {
            priceLabel.text = "--"
        }
        if let pct = changePct {
            let sign = pct >= 0 ? "+" : ""
            let arrow = pct >= 0 ? "↗" : "↘"
            changeLabel.text = "\(arrow)  \(sign)\(String(format: "%.2f", pct))%"
            changeLabel.textColor = pct >= 0 ? UIColor.systemGreen : UIColor.systemRed
            changeLabel.isHidden = false
        } else {
            changeLabel.isHidden = true
        }
    }
}

// Non-isolated fallback price fetcher to avoid MainActor calls from background closures
enum StockPriceFallback {
    static func fetchPriceFromStooq(symbol: String, completion: @escaping (Double?) -> Void) {
        let lower = symbol.lowercased()
        let stooqSym = lower.contains(".") ? lower : lower + ".us"
        guard let url = URL(string: "https://stooq.com/q/l/?s=\(stooqSym)&f=sd2t2ohlcv&h&e=csv") else { completion(nil); return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let csv = String(data: data, encoding: .utf8) else { completion(nil); return }
            if let line = csv.split(separator: "\n").dropFirst().first {
                let cols = line.split(separator: ",")
                if cols.count >= 7, let close = Double(cols[6]) { completion(close); return }
            }
            completion(nil)
        }.resume()
    }
}

@available(iOS 15.0, *)
@MainActor
final class StockContextProvider: NSObject, @preconcurrency ConvoUIContextProvider {
    var id: String { "chatkit.stock" }
    var title: String { NSLocalizedString("stock.title", comment: "Stock provider title") }
    var iconName: String { "chart.line.uptrend.xyaxis" }
    var isAvailable: Bool { true }
    var priority: Int { 110 }
    var maximumAttachmentCount: Int { 1 }
    var shouldUseContainerPanel: Bool { true }

    func makeContext() async throws -> (any ConvoUIContextItem)? {
        // Fallback item when panel UI not available
        return StockContextItem(symbol: "AAPL", name: "Apple Inc.", exchange: "NASDAQ", price: nil)
    }

    func createCollectorView(onConfirm: @escaping ((any ConvoUIContextItem)?) -> Void) -> UIView? {
        let view = StockCollectorView()
        view.onConfirm = onConfirm
        return view
    }

    func createDetailView(for item: any ConvoUIContextItem, onDismiss: @escaping () -> Void) -> UIView? {
//        guard let stock = item as? StockContextItem else { return nil }
//        let detail = StockDetailView(item: stock)
//        detail.onDismiss = onDismiss
//        return detail
        return nil
    }

    func localizedDescription(for item: any ConvoUIContextItem) -> String {
        guard let stock = item as? StockContextItem else { return item.displayName }
        return stock.humanReadableDescription
    }

    fileprivate func fetchPriceIfNeeded(for symbol: String, completion: @escaping (Double?) -> Void) {
        if let cached = StockCaches.price.object(forKey: symbol as NSString)?.doubleValue {
            completion(cached)
            return
        }
        guard let url = URL(string: "https://query1.finance.yahoo.com/v7/finance/quote?symbols=\(symbol)&lang=en-US&region=US") else { completion(nil); return }
        var req = URLRequest(url: url)
        req.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile", forHTTPHeaderField: "User-Agent")
        URLSession.shared.dataTask(with: req) { data, resp, err in
            guard err == nil, let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode), let data = data else {
                // Fallback to Stooq CSV (no key)
                StockPriceFallback.fetchPriceFromStooq(symbol: symbol, completion: completion)
                return
            }
            struct QuoteResp: Decodable {
                struct Result: Decodable { let symbol: String?; let regularMarketPrice: Double? }
                struct R: Decodable { let result: [Result]? }
                let quoteResponse: R?
            }
            let decoded = try? JSONDecoder().decode(QuoteResp.self, from: data)
            let price = decoded?.quoteResponse?.result?.first?.regularMarketPrice
            if let p = price {
                StockCaches.price.setObject(NSNumber(value: p), forKey: symbol as NSString)
            }
            completion(price)
        }.resume()
    }

    // Removed instance fallback to avoid MainActor isolation issues
}

// MARK: - Collector View

@available(iOS 15.0, *)
@MainActor
final class StockCollectorView: UIView {
    var onConfirm: (((any ConvoUIContextItem)?) -> Void)?

    private let headerLabel = UILabel()
    private let searchBar = UISearchBar()
    private let sectionLabel = UILabel()
    private let hintLabel = UILabel()
    private var collectionView: UICollectionView!
    // Footer buttons removed per new UX (tap a row to confirm & close)

    private var results: [StockSearchResult] = [] {
        didSet {
            print("[Stock] results updated, count=\(results.count)")
            collectionView.reloadData()
        }
    }
    private var selected: StockSearchResult? {
        didSet { updateConfirmState() }
    }
    private var searchDebounceTimer: Timer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        loadDefaultList()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        loadDefaultList()
    }

    override var intrinsicContentSize: CGSize {
        // Provide a reasonable minimum height so the sheet lays out content
        return CGSize(width: UIView.noIntrinsicMetric, height: 520)
    }

    private func setupUI() {
        backgroundColor = .systemBackground
        print("[Stock] setupUI begin")

        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.text = NSLocalizedString("stock.search.title", comment: "Stock search title")
        headerLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        addSubview(headerLabel)

        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = NSLocalizedString("stock.search.placeholder", comment: "Search placeholder")
        searchBar.delegate = self
        searchBar.returnKeyType = .search
        addSubview(searchBar)

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(StockRowCell.self, forCellWithReuseIdentifier: StockRowCell.reuseId)
        addSubview(collectionView)
        print("[Stock] collectionView setup done")

        // Section title: 热门股票
        sectionLabel.translatesAutoresizingMaskIntoConstraints = false
        sectionLabel.text = NSLocalizedString("stock.section.hot", comment: "Hot stocks section title")
        sectionLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        sectionLabel.textColor = .secondaryLabel
        addSubview(sectionLabel)

        // Bottom hint
        hintLabel.translatesAutoresizingMaskIntoConstraints = false
        hintLabel.text = NSLocalizedString("stock.search.hint", comment: "Search hint")
        hintLabel.font = UIFont.systemFont(ofSize: 12)
        hintLabel.textAlignment = .center
        hintLabel.textColor = .tertiaryLabel
        addSubview(hintLabel)

        // Footer removed

        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),

            searchBar.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: trailingAnchor),

            sectionLabel.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 12),
            sectionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            sectionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),

            collectionView.topAnchor.constraint(equalTo: sectionLabel.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            collectionView.bottomAnchor.constraint(equalTo: hintLabel.topAnchor, constant: -8),

            hintLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            hintLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            hintLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
        print("[Stock] setupUI done")
    }

    private func updateConfirmState() { /* no-op in row-tap UX */ }

    @objc private func handleCancel() { onConfirm?(nil) }

    // MARK: Data

    private func loadDefaultList() {
        // 直接以东方财富热门/自选列表为默认数据（中国 A 股）
        // 预设 20 只常见大盘/热门股，格式：上证=1.XXXXXX 深证=0.XXXXXX
        print("[Stock] loadDefaultList start")
        let secids = [
            "1.600519", // 贵州茅台
            "1.601318", // 中国平安
            "1.600036", // 招商银行
            "1.600000", // 浦发银行
            "1.601166", // 兴业银行
            "1.600104", // 上汽集团
            "1.600028", // 中国石化
            "1.601398", // 工商银行
            "1.601988", // 中国银行
            "1.600887", // 伊利股份
            "1.600031", // 三一重工
            "1.601012", // 隆基绿能
            "0.300750", // 宁德时代
            "0.002594", // 比亚迪
            "0.000333", // 美的集团
            "0.000651", // 格力电器
            "0.000001", // 平安银行
            "0.000858", // 五粮液
            "1.600900", // 长江电力
            "1.600837"  // 海通证券
        ].joined(separator: ",")
        guard let url = URL(string: "https://push2.eastmoney.com/api/qt/ulist.np/get?secids=\(secids)&fields=f12,f14,f2,f3") else { print("[Stock] build url failed"); return }
        var req = URLRequest(url: url)
        req.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile", forHTTPHeaderField: "User-Agent")
        req.setValue("https://quote.eastmoney.com/", forHTTPHeaderField: "Referer")
        print("[Stock] request hot list: \(url.absoluteString)")
        let task = URLSession.shared.dataTask(with: req) { [weak self] data, resp, err in
            if let err = err { print("[Stock] hot list error: \(err)") }
            if let http = resp as? HTTPURLResponse { print("[Stock] hot list status=\(http.statusCode)") }
            guard let self = self, let data = data else {
                print("[Stock] hot list no data, fallback static")
                DispatchQueue.main.async { self?.applyStaticDefaultsCN() }
                return
            }
            print("[Stock] hot list bytes=\(data.count)")
            struct EMUListResp: Decodable {
                struct Data: Decodable {
                    struct Item: Decodable { let f12: String; let f14: String; let f2: Double?; let f3: Double? }
                    let diff: [Item]?
                }
                let data: Data?
            }
            let resp = try? JSONDecoder().decode(EMUListResp.self, from: data)
            if resp?.data?.diff == nil { print("[Stock] hot list decode diff=nil") }
            let mapped: [StockSearchResult] = (resp?.data?.diff ?? []).map { it in
                let code = it.f12
                let ex = code.hasPrefix("6") ? "SH" : "SZ"
                return StockSearchResult(symbol: code, name: it.f14, exchange: ex, price: it.f2, changePct: it.f3)
            }
            print("[Stock] hot list mapped count=\(mapped.count)")
            DispatchQueue.main.async {
                if !mapped.isEmpty {
                    print("[Stock] hot list applied")
                    self.results = mapped
                    self.selected = nil
                } else {
                    print("[Stock] hot list empty, apply static defaults")
                    self.applyStaticDefaultsCN()
                }
            }
        }
        task.resume()
    }

    private func applyStaticDefaultsCN() {
        self.results = [
            StockSearchResult(symbol: "600519", name: "贵州茅台", exchange: "SH", price: nil),
            StockSearchResult(symbol: "000001", name: "平安银行", exchange: "SZ", price: nil),
            StockSearchResult(symbol: "300750", name: "宁德时代", exchange: "SZ", price: nil),
            StockSearchResult(symbol: "601318", name: "中国平安", exchange: "SH", price: nil),
            StockSearchResult(symbol: "600036", name: "招商银行", exchange: "SH", price: nil)
        ]
        self.selected = nil
        self.collectionView.reloadData()
    }

    private func searchStocks(_ query: String) {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else {
            loadDefaultList()
            return
        }
        // 东方财富搜索接口
        guard let encoded = q.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://searchapi.eastmoney.com/api/suggest/get?input=\(encoded)&type=14&pageindex=1&pagesize=20") else { return }
        var req = URLRequest(url: url)
        req.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile", forHTTPHeaderField: "User-Agent")
        req.setValue("https://quote.eastmoney.com/", forHTTPHeaderField: "Referer")
        print("[Stock] search q=\(q), url=\(url.absoluteString)")
        URLSession.shared.dataTask(with: req) { [weak self] data, resp, err in
            if let err = err { print("[Stock] search error=\(err)") }
            if let http = resp as? HTTPURLResponse { print("[Stock] search status=\(http.statusCode)") }
            guard let self = self, let data = data else { return }
            if let snippet = String(data: data, encoding: .utf8)?.prefix(180) {
                print("[Stock] search resp snippet=\(snippet)...")
            }
            struct EMSuggest: Decodable {
                struct Table: Decodable {
                    struct Data: Decodable { let Code: String; let Name: String }
                    let Datas: [Data]?
                    let Data: [Data]? // Some responses use 'Data' key instead of 'Datas'
                }
                let QuotationCodeTable: Table?
            }
            struct EMSuggestLower: Decodable {
                struct Table: Decodable {
                    struct Data: Decodable { let code: String; let name: String }
                    let Datas: [Data]?
                    let Data: [Data]?
                }
                let QuotationCodeTable: Table?
            }
            var mapped: [StockSearchResult] = []
            if let resp = try? JSONDecoder().decode(EMSuggest.self, from: data) {
                let arr = resp.QuotationCodeTable?.Datas ?? resp.QuotationCodeTable?.Data ?? []
                mapped.append(contentsOf: arr.map { d in
                    let code = d.Code
                    let ex = code.hasPrefix("6") ? "SH" : "SZ"
                    return StockSearchResult(symbol: code, name: d.Name, exchange: ex, price: nil)
                })
            }
            if mapped.isEmpty, let resp2 = try? JSONDecoder().decode(EMSuggestLower.self, from: data) {
                let arr = resp2.QuotationCodeTable?.Datas ?? resp2.QuotationCodeTable?.Data ?? []
                mapped.append(contentsOf: arr.map { d in
                    let code = d.code
                    let ex = code.hasPrefix("6") ? "SH" : "SZ"
                    return StockSearchResult(symbol: code, name: d.name, exchange: ex, price: nil)
                })
            }
            // Fallback: manual parse via JSONSerialization to handle schema drift
            if mapped.isEmpty,
               let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let table = obj["QuotationCodeTable"] as? [String: Any] {
                let arr = (table["Data"] as? [[String: Any]]) ?? (table["Datas"] as? [[String: Any]]) ?? []
                let items: [StockSearchResult] = arr.compactMap { it in
                    if let code = (it["Code"] as? String) ?? (it["code"] as? String),
                       let name = (it["Name"] as? String) ?? (it["name"] as? String) {
                        let ex = code.hasPrefix("6") ? "SH" : "SZ"
                        return StockSearchResult(symbol: code, name: name, exchange: ex, price: nil)
                    }
                    return nil
                }
                mapped.append(contentsOf: items)
            }
            // 本地前缀/包含兜底：当线上返回为空时，使用热门列表或静态列表做过滤
            if mapped.isEmpty {
                print("[Stock] search mapped empty, try local fallback")
                let seed = self.results.isEmpty ? [
                    StockSearchResult(symbol: "600519", name: "贵州茅台", exchange: "SH", price: nil),
                    StockSearchResult(symbol: "601318", name: "中国平安", exchange: "SH", price: nil),
                    StockSearchResult(symbol: "600036", name: "招商银行", exchange: "SH", price: nil),
                    StockSearchResult(symbol: "600000", name: "浦发银行", exchange: "SH", price: nil),
                    StockSearchResult(symbol: "300750", name: "宁德时代", exchange: "SZ", price: nil)
                ] : self.results
                let filtered = seed.filter { $0.symbol.contains(q) || $0.name.contains(q) }
                mapped = filtered
            }
            DispatchQueue.main.async {
                // 始终更新结果，即使为空也清空列表，给用户明确反馈
                self.results = mapped
                self.selected = nil
            }
        }.resume()
    }

    // MARK: - Price helpers (inside class for easier access)
    fileprivate func fetchPriceIfNeeded(for symbol: String, completion: @escaping (Double?) -> Void) {
        if let cached = StockCaches.price.object(forKey: symbol as NSString)?.doubleValue {
            completion(cached)
            return
        }
        let secid = (symbol.hasPrefix("6") ? "1." : "0.") + symbol
        guard let url = URL(string: "https://push2.eastmoney.com/api/qt/stock/get?secid=\(secid)&fields=f43") else { completion(nil); return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            struct EMPriceResp: Decodable { struct Data: Decodable { let f43: Double? }; let data: Data? }
            guard let data = data, let resp = try? JSONDecoder().decode(EMPriceResp.self, from: data) else { completion(nil); return }
            var price = resp.data?.f43
            if let p = price, p > 1000 { price = p / 100.0 }
            if let p = price { StockCaches.price.setObject(NSNumber(value: p), forKey: symbol as NSString) }
            completion(price)
        }.resume()
    }

    private func fetchPriceFromStooq(symbol: String, completion: @escaping (Double?) -> Void) {
        let lower = symbol.lowercased()
        let stooqSym = lower.contains(".") ? lower : lower + ".us"
        guard let url = URL(string: "https://stooq.com/q/l/?s=\(stooqSym)&f=sd2t2ohlcv&h&e=csv") else { completion(nil); return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let csv = String(data: data, encoding: .utf8) else { completion(nil); return }
            if let line = csv.split(separator: "\n").dropFirst().first {
                let cols = line.split(separator: ",")
                if cols.count >= 7, let close = Double(cols[6]) { completion(close); return }
            }
            completion(nil)
        }.resume()
    }
}

@available(iOS 15.0, *)
extension StockCollectorView: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchDebounceTimer?.invalidate()
        let text = (searchBar.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { loadDefaultList(); return }
        searchStocks(text)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchDebounceTimer?.invalidate()
        if searchText.isEmpty {
            loadDefaultList()
            return
        }
        let text = searchText
        searchDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            if text.count >= 1 {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.searchStocks(text)
                }
            }
        }
    }
}

@available(iOS 15.0, *)
extension StockCollectorView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { results.count }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StockRowCell.reuseId, for: indexPath) as! StockRowCell
        let s = results[indexPath.item]
        cell.configure(symbol: s.symbol, name: s.name, exchange: s.exchange, price: s.price, changePct: s.changePct)
        if s.price == nil {
            self.fetchPriceIfNeeded(for: s.symbol) { [weak self, weak cell] price in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if let idx = self.results.firstIndex(where: { $0.symbol == s.symbol }) {
                        self.results[idx] = StockSearchResult(symbol: s.symbol, name: s.name, exchange: s.exchange, price: price, changePct: self.results[idx].changePct)
                    }
                    cell?.configure(symbol: s.symbol, name: s.name, exchange: s.exchange, price: price, changePct: s.changePct)
                }
            }
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Tap to confirm & close
        let s = results[indexPath.item]
        let item = StockContextItem(symbol: s.symbol, name: s.name, exchange: s.exchange, price: s.price)
        endEditing(true)
        onConfirm?(item)

        // Fire DeepSeek starters fetch after selection
        DSChatService.shared.fetchStartersForStock(name: s.name, symbol: s.symbol) { result in
            switch result {
            case .success(let starters):
                print("[DeepSeek] starters for \(s.name)(\(s.symbol)):")
                starters.forEach { print("  • \($0)") }
                NotificationCenter.default.post(name: .DSChatStartersReady, object: nil, userInfo: [
                    "starters": starters,
                    "symbol": s.symbol,
                    "name": s.name
                ])
            case .failure(let err):
                print("[DeepSeek] starters error: \(err)")
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        return CGSize(width: floor(width), height: 78)
    }
}

// MARK: - Sparkline fetching & cache

@available(iOS 15.0, *)
extension StockCollectorView {

    fileprivate func fetchSparklineIfNeeded(for symbol: String, completion: @escaping ([Double]) -> Void) {
        if let cached = StockCaches.spark.object(forKey: symbol as NSString) as? [Double] {
            completion(cached)
            return
        }
        // EastMoney kline: 日线近60根，取收盘价
        let secid = (symbol.hasPrefix("6") ? "1." : "0.") + symbol
        func fetch(klt: Int, limit: Int, attemptNext: Bool) {
            // 改为使用 beg/end 取最近一段，避免某些情况下 lmt 返回空
            guard let url = URL(string: "https://push2his.eastmoney.com/api/qt/stock/kline/get?secid=\(secid)&klt=\(klt)&fqt=1&beg=0&end=20500000&fields1=f1,f2,f3&fields2=f51,f52,f53,f54,f55") else {
                completion([]); return
            }
            var req = URLRequest(url: url)
            req.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile", forHTTPHeaderField: "User-Agent")
            req.setValue("https://quote.eastmoney.com/", forHTTPHeaderField: "Referer")
            URLSession.shared.dataTask(with: req) { data, _, _ in
                struct EMKlineResp: Decodable { struct Data: Decodable { let klines: [String]? }; let data: Data? }
                guard let data = data, let resp = try? JSONDecoder().decode(EMKlineResp.self, from: data) else {
                    print("[Sparkline] decode fail, symbol=\(symbol), klt=\(klt), try next=\(attemptNext)")
                    if attemptNext {
                        DispatchQueue.main.async { fetch(klt: 5, limit: 120, attemptNext: false) }
                    } else {
                        completion([])
                    }
                    return
                }
                let lines = resp.data?.klines ?? []
                var closes: [Double] = []
                closes.reserveCapacity(lines.count)
                for line in lines {
                    let cols = line.split(separator: ",")
                    // 优先解析收盘价（一般在索引2=收盘），若失败尝试索引1（开盘）做兜底，确保有曲线
                    if cols.count >= 3 {
                        if let v = Double(cols[2]) {
                            closes.append(v)
                        } else if let vAlt = Double(cols[1]) {
                            closes.append(vAlt)
                        }
                    }
                }
                if closes.isEmpty && attemptNext {
                    print("[Sparkline] empty closes, fallback to klt=5, symbol=\(symbol)")
                    DispatchQueue.main.async { fetch(klt: 5, limit: 120, attemptNext: false) }
                    return
                }
                print("[Sparkline] points=\(closes.count), symbol=\(symbol), klt=\(klt)")
                StockCaches.spark.setObject(closes as NSArray, forKey: symbol as NSString)
                completion(closes)
            }.resume()
        }
        // 先日线，再失败时尝试 5 分钟线
        fetch(klt: 101, limit: 60, attemptNext: true)
    }
}

// MARK: - Card Cell

@available(iOS 15.0, *)
final class StockCardCell: UICollectionViewCell {
    static let reuseId = "StockCardCell"

    private let container = UIView()
    private let symbolLabel = UILabel()
    private let nameLabel = UILabel()
    private let priceLabel = UILabel()
    private let sparklineView = SparklineView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }

    private func setup() {
        contentView.backgroundColor = .clear
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .secondarySystemBackground
        container.layer.cornerRadius = 12
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.separator.withAlphaComponent(0.4).cgColor
        contentView.addSubview(container)

        symbolLabel.translatesAutoresizingMaskIntoConstraints = false
        symbolLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 13)
        nameLabel.textColor = .secondaryLabel
        nameLabel.numberOfLines = 2
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 15, weight: .medium)
        priceLabel.textColor = .label
        sparklineView.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(symbolLabel)
        container.addSubview(nameLabel)
        container.addSubview(priceLabel)
        container.addSubview(sparklineView)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            symbolLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
            symbolLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            symbolLabel.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -12),

            nameLabel.topAnchor.constraint(equalTo: symbolLabel.bottomAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),

            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            priceLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            priceLabel.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -12),

            sparklineView.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 8),
            sparklineView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            sparklineView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
            sparklineView.heightAnchor.constraint(equalToConstant: 44),
            sparklineView.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor, constant: -8)
        ])
    }

    func configure(symbol: String, name: String, exchange: String, price: Double?) {
        symbolLabel.text = "\(symbol) • \(exchange)"
        nameLabel.text = name
        if let p = price { priceLabel.text = String(format: "%.2f", p) } else { priceLabel.text = "--" }
    }

    func setSparkline(points: [Double]) {
        sparklineView.setPoints(points)
    }

    func setSelected(_ selected: Bool) {
        container.layer.borderColor = (selected ? UIColor.systemBlue : UIColor.separator.withAlphaComponent(0.4)).cgColor
    }
}

// MARK: - Sparkline view

@available(iOS 15.0, *)
final class SparklineView: UIView {
    private let shape = CAShapeLayer()
    private let gradient = CAGradientLayer()
    private let fillLayer = CAShapeLayer()
    private var cachedPoints: [Double] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder: NSCoder) { super.init(coder: coder); commonInit() }

    private func commonInit() {
        backgroundColor = .clear
        shape.strokeColor = UIColor.systemGreen.cgColor
        shape.fillColor = UIColor.clear.cgColor
        shape.lineWidth = 2
        layer.addSublayer(shape)

        fillLayer.fillColor = UIColor.systemGreen.withAlphaComponent(0.15).cgColor
        layer.insertSublayer(fillLayer, below: shape)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        shape.frame = bounds
        fillLayer.frame = bounds
        // Redraw with cached points when bounds change
        if !cachedPoints.isEmpty {
            drawPath(with: cachedPoints)
        }
    }

    func setPoints(_ values: [Double]) {
        cachedPoints = values
        drawPath(with: values)
    }

    private func drawPath(with values: [Double]) {
        guard values.count >= 2, bounds.width > 0, bounds.height > 0 else { shape.path = nil; fillLayer.path = nil; return }
        let minV = values.min() ?? 0
        let maxV = values.max() ?? 1
        let span = max(maxV - minV, 0.0001)
        let w = bounds.width
        let h = bounds.height
        let step = w / CGFloat(values.count - 1)
        let path = UIBezierPath()
        for (i, v) in values.enumerated() {
            let x = CGFloat(i) * step
            let y = h - CGFloat((v - minV) / span) * h
            if i == 0 { path.move(to: CGPoint(x: x, y: y)) } else { path.addLine(to: CGPoint(x: x, y: y)) }
        }
        shape.path = path.cgPath
        let fill = UIBezierPath(cgPath: path.cgPath)
        fill.addLine(to: CGPoint(x: w, y: h))
        fill.addLine(to: CGPoint(x: 0, y: h))
        fill.close()
        fillLayer.path = fill.cgPath
    }
}

// MARK: - Detail View

@available(iOS 15.0, *)
final class StockDetailView: UIView {
    var onDismiss: (() -> Void)?

    private let titleLabel = UILabel()
    private let infoLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    private let item: StockContextItem

    init(item: StockContextItem) {
        self.item = item
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        backgroundColor = .systemBackground

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        titleLabel.text = "Stock"
        addSubview(titleLabel)

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setTitle("Close", for: .normal)
        closeButton.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
        addSubview(closeButton)

        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.numberOfLines = 0
        infoLabel.font = UIFont.systemFont(ofSize: 16)
        infoLabel.text = "\(item.symbol)\n\(item.name)\n\(item.exchange)\nPrice: \(item.price.map { "\($0)" } ?? "-")"
        addSubview(infoLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),

            closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            infoLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            infoLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            infoLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }

    @objc private func handleClose() { onDismiss?() }
}

// MARK: - Context Item & Models

@available(iOS 15.0, *)
struct StockContextItem: ConvoUIContextItem {
    let id = UUID()
    let providerId = "chatkit.stock"
    let type = "stock"
    var displayName: String { symbol }

    let symbol: String
    let name: String
    let exchange: String
    let price: Double?

    var codablePayload: Encodable? {
        StockPayload(symbol: symbol, name: name, exchange: exchange, price: price, timestamp: Date().timeIntervalSince1970)
    }

    func encodeForTransport() throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        return try encoder.encode(codablePayload as? StockPayload)
    }

    var encodingRepresentation: ConvoUIEncodingType { .json }

    var encodingMetadata: [String: String]? {
        [
            "provider": providerId,
            "type": type,
            "symbol": symbol,
            "name": name,
            "exchange": exchange,
            "price": price.map { String($0) } ?? "",
            "localizedDescription": humanReadableDescription
        ]
    }

    var descriptionTemplates: [ContextDescriptionTemplate] {
        [
            ContextDescriptionTemplate(locale: "en", template: "{symbol} - {name} ({exchange})"),
            ContextDescriptionTemplate(locale: "zh-CN", template: "{symbol} - {name}（{exchange}）")
        ]
    }

    var humanReadableDescription: String {
        return "\(name)(\(symbol))"
    }

    func createPreviewView(onRemove: @escaping () -> Void) -> UIView? {
        // Pill style, green border, dynamic width based on text, with close (x) button
        let text = humanReadableDescription
        let font = UIFont.systemFont(ofSize: 13, weight: .regular)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let textSize = (text as NSString).size(withAttributes: attributes)

        let h: CGFloat = 34
        let horizontalPadding: CGFloat = 14
        let spacing: CGFloat = 8
        let closeSize: CGFloat = 16

        let width = ceil(horizontalPadding + textSize.width + spacing + closeSize + horizontalPadding)
        let container = UIView(frame: CGRect(x: 0, y: 0, width: max(width, 72), height: h))
        container.backgroundColor = .clear
        container.layer.cornerRadius = h / 2
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.systemGreen.cgColor

        let title = UILabel()
        title.text = text
        title.font = font
        title.textColor = UIColor.systemGreen
        title.sizeToFit()
        let titleY = (h - title.bounds.height) / 2
        title.frame = CGRect(x: horizontalPadding, y: titleY, width: min(title.bounds.width, width), height: title.bounds.height)
        container.addSubview(title)

        let close = UIButton(type: .system)
        if let img = UIImage(systemName: "xmark") {
            close.setImage(img, for: .normal)
        } else {
            close.setTitle("×", for: .normal)
        }
        close.tintColor = UIColor.systemGreen
        close.setTitleColor(UIColor.systemGreen, for: .normal)
        close.contentEdgeInsets = .zero
        close.frame = CGRect(x: container.bounds.width - horizontalPadding - closeSize, y: (h - closeSize) / 2, width: closeSize, height: closeSize)
        close.addAction(UIAction { _ in onRemove() }, for: .touchUpInside)
        container.addSubview(close)

        return container
    }
}

struct StockPayload: Codable {
    let symbol: String
    let name: String
    let exchange: String
    let price: Double?
    let timestamp: TimeInterval
}

struct StockSearchResult {
    let symbol: String
    let name: String
    let exchange: String
    let price: Double?
    let changePct: Double? // percentage, e.g. 0.92 means +0.92%

    init(symbol: String, name: String, exchange: String, price: Double?, changePct: Double? = nil) {
        self.symbol = symbol
        self.name = name
        self.exchange = exchange
        self.price = price
        self.changePct = changePct
    }
}
