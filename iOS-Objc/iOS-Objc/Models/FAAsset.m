#import "FAAsset.h"

@implementation FAAsset

- (instancetype)initWithId:(NSString *)assetId
                    symbol:(NSString *)symbol
                      name:(NSString *)name
                      type:(FAAssetType)type {
    self = [super init];
    if (self) {
        _assetId = [assetId copy];
        _symbol = [symbol copy];
        _name = [name copy];
        _type = type;
    }
    return self;
}

- (NSString *)typeDisplayName {
    switch (self.type) {
        case FAAssetTypeStock: return @"Stock";
        case FAAssetTypeCrypto: return @"Crypto";
        case FAAssetTypeFund: return @"Fund";
        case FAAssetTypeBond: return @"Bond";
        case FAAssetTypeCash: return @"Cash";
        default: return @"Unknown";
    }
}

@end
