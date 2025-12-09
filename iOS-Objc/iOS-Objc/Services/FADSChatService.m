#import "FADSChatService.h"
#import "FAAppConfig.h"

NSString *const FADSChatStartersReadyNotification = @"DSChatStartersReady";

@implementation FADSChatService

+ (instancetype)sharedService {
    static FADSChatService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)fetchStartersForStockName:(NSString *)name
                           symbol:(NSString *)symbol
                       completion:(void (^)(NSArray<NSString *> * _Nullable, NSError * _Nullable))completion {
    
    NSString *apiKey = [FAAppConfig apiKey];
    NSString *endpoint = [FAAppConfig endpoint];
    
    if (apiKey.length == 0) {
        NSError *error = [NSError errorWithDomain:@"FADSChatServiceError" code:1 userInfo:@{NSLocalizedDescriptionKey: @"Missing API Key"}];
        if (completion) completion(nil, error);
        return;
    }
    
    NSURL *url = [NSURL URLWithString:endpoint];
    if (!url) {
        NSError *error = [NSError errorWithDomain:@"FADSChatServiceError" code:2 userInfo:@{NSLocalizedDescriptionKey: @"Bad URL"}];
        if (completion) completion(nil, error);
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"Bearer %@", apiKey] forHTTPHeaderField:@"Authorization"];
    
    NSString *systemPrompt = @"你是一个「精简版证券投顾提问生成器」。\n\n" 
    "【任务】\n" 
    "我会给你一行或多行「关键词」，可能是：\n" 
    "- 时间或时间范围（如：近 6 个月、今年以来）\n" 
    "- 标的物（如：平安银行、贵州茅台、沪深 300）\n" 
    "- 新闻或事件名称（如：美联储降息、业绩大幅下滑）\n\n" 
    "请你围绕这些关键词，发散 2–3 个与「证券投资」高度相关的问题。\n\n" 
    "【风格要求（很重要）】\n" 
    "- 问题要「极简」，像普通投资者随口会问的那种。\n" 
    "- 每个问题只问一件事。\n" 
    "- 尽量不要用逗号，一个问题只用一句话说完。\n" 
    "- 不要出现「结合…」「基于…」「从…角度」「综合分析」等复杂表达。\n" 
    "- 不要解释背景，不要复述条件，只抛出核心疑问（涨跌、买卖、风险、仓位等）。\n" 
    "- 可以用第一人称「我」，让问题更自然。\n\n" 
    "【长度要求】\n" 
    "- 每个问题尽量不超过 18 个汉字。\n" 
    "- 句式简单直接，例如：\n" 
    "  - 「平安银行还能继续持有吗？」\n" 
    "  - 「近半年贵州茅台走势怎么样？」\n" 
    "  - 「这条新闻利好还是利空？」\n\n" 
    "【输出格式】\n" 
    "- 只输出问题本身，每行一个问题。\n" 
    "- 不要加序号、标点前缀或任何说明文字。";
    
    NSString *userKeywords = [NSString stringWithFormat:@"【现在的输入关键词】：\n标的物：%@（%@）", name, symbol];
    
    NSDictionary *body = @{
        @"model": @"deepseek-ai/DeepSeek-V3.1-Terminus",
        @"messages": @[
            @{@"role": @"system", @"content": systemPrompt},
            @{@"role": @"user", @"content": userKeywords}
        ],
        @"stream": @NO,
        @"temperature": @0.2
    };
    
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:body options:0 error:nil];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(nil, error);
            });
            return;
        }
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode < 200 || httpResponse.statusCode >= 300) {
            NSError *httpError = [NSError errorWithDomain:@"FADSChatServiceError" code:httpResponse.statusCode userInfo:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(nil, httpError);
            });
            return;
        }
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if (!json) {
            NSError *decodeError = [NSError errorWithDomain:@"FADSChatServiceError" code:3 userInfo:@{NSLocalizedDescriptionKey: @"Decode Error"}];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(nil, decodeError);
            });
            return;
        }
        
        NSArray *choices = json[@"choices"];
        if (choices.count > 0) {
            NSDictionary *choice = choices.firstObject;
            NSDictionary *message = choice[@"message"];
            NSString *content = message[@"content"];
            
            NSArray *starters = [self parseStartersFromContent:content];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(starters, nil);
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(nil, [NSError errorWithDomain:@"FADSChatServiceError" code:4 userInfo:nil]);
            });
        }
        
    }] resume];
}

- (NSArray<NSString *> *)parseStartersFromContent:(NSString *)content {
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    if (data) {
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if ([json isKindOfClass:[NSArray class]]) {
            return (NSArray *)json;
        }
    }
    
    NSString *cleanContent = [content stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    NSArray *lines = [cleanContent componentsSeparatedByString:@"\n"];
    NSMutableArray *results = [NSMutableArray array];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^-?\\s*\\d+[\\)\\.]*\\s*" options:0 error:nil];
    
    for (NSString *line in lines) {
        NSString *trimmed = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (trimmed.length == 0) continue;
        
        NSString *stripped = [regex stringByReplacingMatchesInString:trimmed options:0 range:NSMakeRange(0, trimmed.length) withTemplate:@""];
        [results addObject:stripped];
    }
    
    if (results.count > 0) {
        return [results copy];
    }
    
    return @[@"基本面如何？", @"估值是否合理？", @"近期走势怎么看？", @"行业景气度？", @"核心风险是什么？"];
}

@end
