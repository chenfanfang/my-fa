#import <Foundation/Foundation.h>
#import "FAHolding.h"

NS_ASSUME_NONNULL_BEGIN

@interface FAPortfolio : NSObject

@property (nonatomic, assign) double cashBalance;
@property (nonatomic, strong) NSMutableArray<FAHolding *> *holdings;

- (instancetype)initWithCashBalance:(double)cashBalance
                           holdings:(NSArray<FAHolding *> *)holdings;

// Helper to get total value if we pass in a price provider (or just cash for now)
- (double)totalValueAssumingCashOnly; 

@end

NS_ASSUME_NONNULL_END
