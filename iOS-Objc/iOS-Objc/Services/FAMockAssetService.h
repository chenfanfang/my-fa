#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FAMockAssetService : NSObject

+ (instancetype)sharedService;

- (NSArray<NSString *> *)getAccountOpeningSteps;

@end

NS_ASSUME_NONNULL_END
