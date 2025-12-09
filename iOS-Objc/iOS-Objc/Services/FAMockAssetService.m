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
        [LocalizationHelper localized:@"assets.opening.step1"],
        [LocalizationHelper localized:@"assets.opening.step2"],
        [LocalizationHelper localized:@"assets.opening.step3"]
    ];
}

@end
