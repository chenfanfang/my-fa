#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FAChatNavigationDelegate <NSObject>
- (void)navigateToChatWithMessage:(nullable NSString *)message context:(nullable NSDictionary<NSString *, id> *)context;
@end

NS_ASSUME_NONNULL_END
