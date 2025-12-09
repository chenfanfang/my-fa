#import <UIKit/UIKit.h>
#import "FAStrategy.h"

NS_ASSUME_NONNULL_BEGIN

@class FAStrategyCardView;

@protocol FAStrategyCardDelegate <NSObject>
- (void)strategyCardDidTapTakeToChat:(FAStrategyCardView *)card strategy:(FAStrategy *)strategy;
@end

@interface FAStrategyCardView : UIView

@property (nonatomic, weak) id<FAStrategyCardDelegate> delegate;

- (instancetype)initWithStrategy:(FAStrategy *)strategy;

@end

NS_ASSUME_NONNULL_END
