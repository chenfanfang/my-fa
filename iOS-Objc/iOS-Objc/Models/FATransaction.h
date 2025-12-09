#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, FATransactionType) {
    FATransactionTypeBuy,
    FATransactionTypeSell,
    FATransactionTypeDeposit,
    FATransactionTypeWithdraw
};

@interface FATransaction : NSObject

@property (nonatomic, strong) NSUUID *transactionId;
@property (nonatomic, copy, nullable) NSString *assetId;
@property (nonatomic, assign) FATransactionType type;
@property (nonatomic, assign) double amount;
@property (nonatomic, assign) double price;
@property (nonatomic, strong) NSDate *date;

- (instancetype)initWithId:(NSUUID *)transactionId
                   assetId:(nullable NSString *)assetId
                      type:(FATransactionType)type
                    amount:(double)amount
                     price:(double)price
                      date:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
