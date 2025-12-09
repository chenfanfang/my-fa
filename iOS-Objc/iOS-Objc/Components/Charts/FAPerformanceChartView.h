#import <UIKit/UIKit.h>
#import "FAStrategy.h"

NS_ASSUME_NONNULL_BEGIN

@interface FAPerformanceChartView : UIView

- (instancetype)initWithDataPoints:(NSArray<FAStrategyPerformanceDataPoint *> *)dataPoints;

@end

NS_ASSUME_NONNULL_END
