#import "FAPerformanceChartView.h"

@interface FAPerformanceChartView ()

@property (nonatomic, copy) NSArray<FAStrategyPerformanceDataPoint *> *dataPoints;
@property (nonatomic, assign) CGFloat barSpacing;
@property (nonatomic, assign) CGFloat minBarHeight;

@end

@implementation FAPerformanceChartView

- (instancetype)initWithDataPoints:(NSArray<FAStrategyPerformanceDataPoint *> *)dataPoints {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _dataPoints = [dataPoints copy];
        _barSpacing = 4.0;
        _minBarHeight = 20.0;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (self.dataPoints.count == 0) return;
    
    double maxValue = 1.0;
    for (FAStrategyPerformanceDataPoint *point in self.dataPoints) {
        maxValue = MAX(maxValue, fabs(point.returnPercentage));
    }
    
    CGFloat barWidth = (rect.size.width - (self.dataPoints.count - 1) * self.barSpacing) / self.dataPoints.count;
    
    for (NSUInteger i = 0; i < self.dataPoints.count; i++) {
        FAStrategyPerformanceDataPoint *point = self.dataPoints[i];
        
        CGFloat x = i * (barWidth + self.barSpacing);
        double normalizedValue = point.returnPercentage / maxValue;
        CGFloat barHeight = MAX(fabs(normalizedValue) * rect.size.height * 0.8, self.minBarHeight);
        
        CGFloat y;
        if (point.returnPercentage >= 0) {
            y = rect.size.height - barHeight;
        } else {
            y = rect.size.height - self.minBarHeight;
        }
        
        CGRect barRect = CGRectMake(x, y, barWidth, barHeight);
        
        UIColor *barColor = point.returnPercentage >= 0 ?
            [UIColor colorWithRed:0.3 green:0.7 blue:0.4 alpha:1.0] : // Green
            [UIColor colorWithRed:0.8 green:0.3 blue:0.3 alpha:1.0];  // Red
        
        [barColor setFill];
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:barRect cornerRadius:2];
        [path fill];
    }
}

@end
