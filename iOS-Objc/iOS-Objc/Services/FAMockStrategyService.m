#import "FAMockStrategyService.h"
#import "iOS_Objc-Swift.h"

@implementation FAMockStrategyService

+ (instancetype)sharedService {
    static FAMockStrategyService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (NSArray<FAStrategy *> *)getStrategies {
    // Strategy 1
    FAStrategyCreator *creator1 = [[FAStrategyCreator alloc] init];
    creator1.name = [LocalizationHelper localized:@"strategy.sample1.creator"];
    creator1.avatarColor = @"#6B5CE7";
    creator1.role = [LocalizationHelper localized:@"strategy.sample1.role"];
    
    FAStrategyPerformance *perf1 = [[FAStrategyPerformance alloc] init];
    perf1.annualReturn = 23.8;
    perf1.maxDrawdown = -12.3;
    perf1.sharpeRatio = 1.65;
    perf1.winRate = 68.0;
    
    FAStrategyTag *tag1_1 = [[FAStrategyTag alloc] init]; tag1_1.text = [LocalizationHelper localized:@"strategies.risk.medium"]; tag1_1.type = FAStrategyTagTypeRisk;
    FAStrategyTag *tag1_2 = [[FAStrategyTag alloc] init]; tag1_2.text = [LocalizationHelper localized:@"strategies.term.medium"]; tag1_2.type = FAStrategyTagTypeTerm;
    FAStrategyTag *tag1_3 = [[FAStrategyTag alloc] init]; tag1_3.text = [LocalizationHelper localized:@"strategies.type.etf.stock"]; tag1_3.type = FAStrategyTagTypeAsset;
    
    FAStrategyEngagement *eng1 = [[FAStrategyEngagement alloc] init];
    eng1.likes = 1247;
    eng1.comments = 89;
    eng1.followers = 2136;
    eng1.recentFollowers = 183;
    
    NSArray *hist1 = [self generateHistoricalDataWithStartMonth:@"2023.05" months:18 pattern:@[@(-8), @(-5), @3, @5, @4, @6, @8, @7, @10, @12, @11, @14, @16, @15, @18, @20, @22, @24]];
    
    FAStrategy *s1 = [[FAStrategy alloc] init];
    s1.strategyId = @"strategy-1";
    s1.title = [LocalizationHelper localized:@"strategy.sample1.title"];
    s1.desc = [LocalizationHelper localized:@"strategy.sample1.desc"];
    s1.creator = creator1;
    s1.performance = perf1;
    s1.tags = @[tag1_1, tag1_2, tag1_3];
    s1.engagement = eng1;
    s1.historicalData = hist1;
    
    // Strategy 2
    FAStrategyCreator *creator2 = [[FAStrategyCreator alloc] init];
    creator2.name = [LocalizationHelper localized:@"strategy.sample2.creator"];
    creator2.avatarColor = @"#5B9FD7";
    creator2.role = [LocalizationHelper localized:@"strategy.sample2.role"];
    
    FAStrategyPerformance *perf2 = [[FAStrategyPerformance alloc] init];
    perf2.annualReturn = 18.5;
    perf2.maxDrawdown = -8.7;
    perf2.sharpeRatio = 2.1;
    perf2.winRate = 72.0;
    
    FAStrategyTag *tag2_1 = [[FAStrategyTag alloc] init]; tag2_1.text = [LocalizationHelper localized:@"strategies.risk.low"]; tag2_1.type = FAStrategyTagTypeRisk;
    FAStrategyTag *tag2_2 = [[FAStrategyTag alloc] init]; tag2_2.text = [LocalizationHelper localized:@"strategies.term.long"]; tag2_2.type = FAStrategyTagTypeTerm;
    FAStrategyTag *tag2_3 = [[FAStrategyTag alloc] init]; tag2_3.text = @"ETF"; tag2_3.type = FAStrategyTagTypeAsset;
    
    FAStrategyEngagement *eng2 = [[FAStrategyEngagement alloc] init];
    eng2.likes = 892;
    eng2.comments = 56;
    eng2.followers = 1543;
    eng2.recentFollowers = 94;
    
    NSMutableArray *pattern2 = [NSMutableArray array];
    for (double d = 0.0; d <= 45.0; d += 2.0) { [pattern2 addObject:@(d)]; }
    NSArray *hist2 = [self generateHistoricalDataWithStartMonth:@"2022.11" months:25 pattern:pattern2];
    
    FAStrategy *s2 = [[FAStrategy alloc] init];
    s2.strategyId = @"strategy-2";
    s2.title = [LocalizationHelper localized:@"strategy.sample2.title"];
    s2.desc = [LocalizationHelper localized:@"strategy.sample2.desc"];
    s2.creator = creator2;
    s2.performance = perf2;
    s2.tags = @[tag2_1, tag2_2, tag2_3];
    s2.engagement = eng2;
    s2.historicalData = hist2;
    
    return @[s1, s2];
}

- (NSArray<FAStrategyPerformanceDataPoint *> *)generateHistoricalDataWithStartMonth:(NSString *)startMonth months:(NSInteger)months pattern:(NSArray<NSNumber *> *)pattern {
    NSMutableArray *data = [NSMutableArray array];
    NSArray *components = [startMonth componentsSeparatedByString:@"."];
    if (components.count != 2) return @[];
    
    NSInteger year = [components[0] integerValue];
    NSInteger month = [components[1] integerValue];
    
    NSInteger count = MIN(months, pattern.count);
    
    for (NSInteger i = 0; i < count; i++) {
        NSInteger currentMonth = month + i;
        NSInteger currentYear = year + (currentMonth - 1) / 12;
        NSInteger adjustedMonth = ((currentMonth - 1) % 12) + 1;
        
        NSString *monthString = [NSString stringWithFormat:@"%04ld.%02ld", (long)currentYear, (long)adjustedMonth];
        
        FAStrategyPerformanceDataPoint *point = [[FAStrategyPerformanceDataPoint alloc] init];
        point.month = monthString;
        point.returnPercentage = [pattern[i] doubleValue];
        
        [data addObject:point];
    }
    return data;
}

@end
