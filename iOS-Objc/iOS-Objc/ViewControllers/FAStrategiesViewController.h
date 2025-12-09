#import <UIKit/UIKit.h>
#import "iOS_Objc-Swift.h"
#import "FAChatNavigationDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface FAStrategiesViewController : UIViewController

@property (nonatomic, weak) id<FAChatNavigationDelegate> navigationDelegate;

@end

NS_ASSUME_NONNULL_END