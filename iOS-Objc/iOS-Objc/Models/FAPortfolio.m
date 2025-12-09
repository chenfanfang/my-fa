#import "FAPortfolio.h"

@implementation FAPortfolio

- (instancetype)initWithCashBalance:(double)cashBalance
                           holdings:(NSArray<FAHolding *> *)holdings {
    self = [super init];
    if (self) {
        _cashBalance = cashBalance;
        _holdings = [holdings mutableCopy];
    }
    return self;
}

- (double)totalValueAssumingCashOnly {
    return self.cashBalance;
}

@end
