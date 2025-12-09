#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FAMarketData : NSObject

@property (nonatomic, copy) NSString *assetId;
@property (nonatomic, assign) double price;
@property (nonatomic, assign) double dailyChangePercentage;
@property (nonatomic, strong) NSDate *lastUpdated;

- (instancetype)initWithAssetId:(NSString *)assetId
                          price:(double)price
          dailyChangePercentage:(double)change
                    lastUpdated:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
