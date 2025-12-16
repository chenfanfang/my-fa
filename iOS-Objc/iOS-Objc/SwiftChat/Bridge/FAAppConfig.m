#import "FAAppConfig.h"

@implementation FAAppConfig

+ (NSString *)defaultServerURL {
    return @"http://127.0.0.1:3000/agent";
}

+ (NSString *)defaultUserId {
    return @"demo-user";
}

+ (NSString *)defaultAgentId {
    return @"E1E72B3D-845D-4F5D-B6CA-5550F2643E6B";
}

+ (NSString *)defaultAgentName {
    return @"My Agent";
}

+ (NSString *)apiKey {
    return @"";
}

+ (NSString *)endpoint {
    return @"https://api.siliconflow.cn/v1/chat/completions";
}

@end
