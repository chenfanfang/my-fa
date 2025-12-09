#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, FAStrategyTagType) {
    FAStrategyTagTypeRisk,
    FAStrategyTagTypeTerm,
    FAStrategyTagTypeAsset
};

@interface FAStrategyCreator : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *avatarColor;
@property (nonatomic, copy) NSString *role;
@end

@interface FAStrategyPerformance : NSObject
@property (nonatomic, assign) double annualReturn;
@property (nonatomic, assign) double maxDrawdown;
@property (nonatomic, assign) double sharpeRatio;
@property (nonatomic, assign) double winRate;
@end

@interface FAStrategyTag : NSObject
@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) FAStrategyTagType type;
@end

@interface FAStrategyEngagement : NSObject
@property (nonatomic, assign) NSInteger likes;
@property (nonatomic, assign) NSInteger comments;
@property (nonatomic, assign) NSInteger followers;
@property (nonatomic, assign) NSInteger recentFollowers;
@end

@interface FAStrategyPerformanceDataPoint : NSObject
@property (nonatomic, copy) NSString *month;
@property (nonatomic, assign) double returnPercentage;
@end

@interface FAStrategy : NSObject

@property (nonatomic, copy) NSString *strategyId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, strong) FAStrategyCreator *creator;
@property (nonatomic, strong) FAStrategyPerformance *performance;
@property (nonatomic, copy) NSArray<FAStrategyTag *> *tags;
@property (nonatomic, strong) FAStrategyEngagement *engagement;
@property (nonatomic, copy) NSArray<FAStrategyPerformanceDataPoint *> *historicalData;

@end

NS_ASSUME_NONNULL_END
