#import "FAHolding.h"

@implementation FAHolding

- (instancetype)initWithId:(NSString *)holdingId
                     asset:(FAAsset *)asset
                  quantity:(double)quantity
               averageCost:(double)averageCost {
    self = [super init];
    if (self) {
        _holdingId = [holdingId copy];
        _asset = asset;
        _quantity = quantity;
        _averageCost = averageCost;
    }
    return self;
}

- (double)currentValueWithPrice:(double)price {
    return self.quantity * price;
}

- (double)returnAmountWithPrice:(double)price {
    return [self currentValueWithPrice:price] - (self.quantity * self.averageCost);
}

- (double)returnPercentageWithPrice:(double)price {
    if (self.averageCost <= 0) return 0;
    return ([self returnAmountWithPrice:price] / (self.quantity * self.averageCost)) * 100.0;
}

@end
