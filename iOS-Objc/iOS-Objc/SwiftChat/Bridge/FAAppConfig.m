#import "FAAppConfig.h"

@implementation FAAppConfig

+ (NSString *)defaultServerURL {
    return @"http://127.0.0.1:3000/agent";
}

+ (NSString *)defaultUserId {
    return @"user_demo_001";
}

+ (NSString *)defaultAgentId {
    return @"finance_agent_01";
}

+ (NSString *)defaultAgentName {
    return @"My Financial Agent";
}

@end
