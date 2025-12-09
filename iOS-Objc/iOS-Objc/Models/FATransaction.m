#import "FATransaction.h"

@implementation FATransaction

- (instancetype)initWithId:(NSUUID *)transactionId
                   assetId:(NSString *)assetId
                      type:(FATransactionType)type
                    amount:(double)amount
                     price:(double)price
                      date:(NSDate *)date {
    self = [super init];
    if (self) {
        _transactionId = transactionId;
        _assetId = [assetId copy];
        _type = type;
        _amount = amount;
        _price = price;
        _date = date;
    }
    return self;
}

@end
