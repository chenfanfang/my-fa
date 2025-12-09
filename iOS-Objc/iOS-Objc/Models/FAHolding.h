#import <Foundation/Foundation.h>
#import "FAAsset.h"

NS_ASSUME_NONNULL_BEGIN

@interface FAHolding : NSObject

@property (nonatomic, copy) NSString *holdingId;
@property (nonatomic, strong) FAAsset *asset;
@property (nonatomic, assign) double quantity;
@property (nonatomic, assign) double averageCost;

- (instancetype)initWithId:(NSString *)holdingId
                     asset:(FAAsset *)asset
                  quantity:(double)quantity
               averageCost:(double)averageCost;

- (double)currentValueWithPrice:(double)price;
- (double)returnAmountWithPrice:(double)price;
- (double)returnPercentageWithPrice:(double)price;

@end

NS_ASSUME_NONNULL_END
