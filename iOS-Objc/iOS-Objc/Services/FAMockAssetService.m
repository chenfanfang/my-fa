#import "FAMockAssetService.h"
#import "iOS_Objc-Swift.h"

@implementation FAMockAssetService

+ (instancetype)sharedService {
    static FAMockAssetService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (NSArray<NSString *> *)getAccountOpeningSteps {
    return @[
        [FALocalizationHelper localized:@"assets.opening.step1"],
        [FALocalizationHelper localized:@"assets.opening.step2"],
        [FALocalizationHelper localized:@"assets.opening.step3"]
    ];
}

@end
