#import <Foundation/Foundation.h>
#import "FAPortfolio.h"
#import "FAMarketData.h"
#import "FATransaction.h"
#import "FAAsset.h"

NS_ASSUME_NONNULL_BEGIN

@interface FAWealthService : NSObject

+ (instancetype)sharedService;

@property (nonatomic, strong, readonly) FAPortfolio *portfolio;
@property (nonatomic, strong, readonly) NSDictionary<NSString *, FAMarketData *> *marketData;
@property (nonatomic, strong, readonly) NSArray<FATransaction *> *transactions;

// Public API
- (nullable FAAsset *)getAssetWithSymbol:(NSString *)symbol;
- (nullable FAMarketData *)getMarketDataForAssetId:(NSString *)assetId;
- (double)getPriceForAssetId:(NSString *)assetId;
- (double)getTotalValue;

// Actions
- (BOOL)buyAssetId:(NSString *)assetId quantity:(double)quantity;
- (BOOL)sellAssetId:(NSString *)assetId quantity:(double)quantity;

@end

NS_ASSUME_NONNULL_END
