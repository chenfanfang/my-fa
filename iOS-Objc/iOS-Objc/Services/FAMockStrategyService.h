#import <Foundation/Foundation.h>
#import "FAStrategy.h"

NS_ASSUME_NONNULL_BEGIN

@interface FAMockStrategyService : NSObject

+ (instancetype)sharedService;

- (NSArray<FAStrategy *> *)getStrategies;

@end

NS_ASSUME_NONNULL_END
