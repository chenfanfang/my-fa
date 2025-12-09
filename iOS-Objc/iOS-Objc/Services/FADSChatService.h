#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const FADSChatStartersReadyNotification;

@interface FADSChatService : NSObject

+ (instancetype)sharedService;

- (void)fetchStartersForStockName:(NSString *)name
                           symbol:(NSString *)symbol
                       completion:(void (^)(NSArray<NSString *> * _Nullable starters, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
