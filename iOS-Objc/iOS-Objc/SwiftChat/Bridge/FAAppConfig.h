#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FAAppConfig : NSObject

+ (NSString *)defaultServerURL;
+ (NSString *)defaultUserId;
+ (NSString *)defaultAgentId;
+ (NSString *)defaultAgentName;

@end

NS_ASSUME_NONNULL_END
