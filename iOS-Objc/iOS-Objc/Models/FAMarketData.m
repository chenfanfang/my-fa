#import "FAMarketData.h"

@implementation FAMarketData

- (instancetype)initWithAssetId:(NSString *)assetId
                          price:(double)price
          dailyChangePercentage:(double)change
                    lastUpdated:(NSDate *)date {
    self = [super init];
    if (self) {
        _assetId = [assetId copy];
        _price = price;
        _dailyChangePercentage = change;
        _lastUpdated = date;
    }
    return self;
}

@end
