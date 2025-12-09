#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, FAAssetType) {
    FAAssetTypeStock,
    FAAssetTypeCrypto,
    FAAssetTypeFund,
    FAAssetTypeBond,
    FAAssetTypeCash
};

@interface FAAsset : NSObject

@property (nonatomic, copy) NSString *assetId;
@property (nonatomic, copy) NSString *symbol;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) FAAssetType type;

- (instancetype)initWithId:(NSString *)assetId
                    symbol:(NSString *)symbol
                      name:(NSString *)name
                      type:(FAAssetType)type;

- (NSString *)typeDisplayName;

@end

NS_ASSUME_NONNULL_END
