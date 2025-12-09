#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FADrawerContainerViewController : UIViewController

- (instancetype)initWithCoordinator:(id)coordinator;

- (void)toggleDrawer;
- (void)toggleDrawer:(BOOL)open;
- (void)createNewConversationWithMessage:(nullable NSString *)message context:(nullable NSDictionary<NSString *, id> *)context;

@end

NS_ASSUME_NONNULL_END
