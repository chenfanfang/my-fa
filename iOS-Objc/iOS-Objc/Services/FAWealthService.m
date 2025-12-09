#import "FAWealthService.h"

@interface FAWealthService ()

@property (nonatomic, strong, readwrite) FAPortfolio *portfolio;
@property (nonatomic, strong, readwrite) NSDictionary<NSString *, FAMarketData *> *marketData;
@property (nonatomic, strong, readwrite) NSMutableArray<FATransaction *> *mutableTransactions;
@property (nonatomic, strong) NSArray<FAAsset *> *availableAssets;

@end

@implementation FAWealthService

+ (instancetype)sharedService {
    static FAWealthService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _mutableTransactions = [NSMutableArray array];
        [self setupMockData];
    }
    return self;
}

- (NSArray<FATransaction *> *)transactions {
    return [self.mutableTransactions copy];
}

- (void)setupMockData {
    // 1. Define Assets
    FAAsset *btc = [[FAAsset alloc] initWithId:@"bitcoin" symbol:@"BTC" name:@"Bitcoin" type:FAAssetTypeCrypto];
    FAAsset *eth = [[FAAsset alloc] initWithId:@"ethereum" symbol:@"ETH" name:@"Ethereum" type:FAAssetTypeCrypto];
    FAAsset *sol = [[FAAsset alloc] initWithId:@"solana" symbol:@"SOL" name:@"Solana" type:FAAssetTypeCrypto];
    FAAsset *aapl = [[FAAsset alloc] initWithId:@"apple" symbol:@"AAPL" name:@"Apple Inc." type:FAAssetTypeStock];
    FAAsset *tsla = [[FAAsset alloc] initWithId:@"tesla" symbol:@"TSLA" name:@"Tesla Inc." type:FAAssetTypeStock];
    FAAsset *spy = [[FAAsset alloc] initWithId:@"spy" symbol:@"SPY" name:@"S&P 500 ETF" type:FAAssetTypeFund];
    FAAsset *bond = [[FAAsset alloc] initWithId:@"us_bond" symbol:@"US10Y" name:@"US Treasury 10Y" type:FAAssetTypeBond];
    
    self.availableAssets = @[btc, eth, sol, aapl, tsla, spy, bond];
    
    // 2. Setup Market Data
    self.marketData = @{
        @"bitcoin": [[FAMarketData alloc] initWithAssetId:@"bitcoin" price:65432.10 dailyChangePercentage:2.5 lastUpdated:[NSDate date]],
        @"ethereum": [[FAMarketData alloc] initWithAssetId:@"ethereum" price:3456.78 dailyChangePercentage:-1.2 lastUpdated:[NSDate date]],
        @"solana": [[FAMarketData alloc] initWithAssetId:@"solana" price:145.50 dailyChangePercentage:5.8 lastUpdated:[NSDate date]],
        @"apple": [[FAMarketData alloc] initWithAssetId:@"apple" price:189.50 dailyChangePercentage:0.5 lastUpdated:[NSDate date]],
        @"tesla": [[FAMarketData alloc] initWithAssetId:@"tesla" price:178.20 dailyChangePercentage:-3.4 lastUpdated:[NSDate date]],
        @"spy": [[FAMarketData alloc] initWithAssetId:@"spy" price:510.30 dailyChangePercentage:0.1 lastUpdated:[NSDate date]],
        @"us_bond": [[FAMarketData alloc] initWithAssetId:@"us_bond" price:98.50 dailyChangePercentage:0.05 lastUpdated:[NSDate date]]
    };
    
    // 3. Setup Initial Holdings
    FAHolding *h1 = [[FAHolding alloc] initWithId:[[NSUUID UUID] UUIDString] asset:btc quantity:0.5 averageCost:60000.0];
    FAHolding *h2 = [[FAHolding alloc] initWithId:[[NSUUID UUID] UUIDString] asset:aapl quantity:50 averageCost:150.0];
    FAHolding *h3 = [[FAHolding alloc] initWithId:[[NSUUID UUID] UUIDString] asset:spy quantity:20 averageCost:480.0];
    
    self.portfolio = [[FAPortfolio alloc] initWithCashBalance:50000.0 holdings:@[h1, h2, h3]];
}

- (FAAsset *)getAssetWithSymbol:(NSString *)symbol {
    for (FAAsset *asset in self.availableAssets) {
        if ([asset.symbol caseInsensitiveCompare:symbol] == NSOrderedSame) {
            return asset;
        }
    }
    return nil;
}

- (FAMarketData *)getMarketDataForAssetId:(NSString *)assetId {
    return self.marketData[assetId];
}

- (double)getPriceForAssetId:(NSString *)assetId {
    FAMarketData *data = self.marketData[assetId];
    return data ? data.price : 0.0;
}

- (double)getTotalValue {
    double total = self.portfolio.cashBalance;
    for (FAHolding *holding in self.portfolio.holdings) {
        double price = [self getPriceForAssetId:holding.asset.assetId];
        total += holding.quantity * price;
    }
    return total;
}

- (BOOL)buyAssetId:(NSString *)assetId quantity:(double)quantity {
    double price = [self getPriceForAssetId:assetId];
    if (price <= 0) return NO;
    
    double cost = price * quantity;
    if (self.portfolio.cashBalance < cost) return NO;
    
    // Update Cash
    self.portfolio.cashBalance -= cost;
    
    // Update Holding
    FAHolding *existingHolding = nil;
    NSUInteger existingIndex = NSNotFound;
    
    for (NSUInteger i = 0; i < self.portfolio.holdings.count; i++) {
        FAHolding *h = self.portfolio.holdings[i];
        if ([h.asset.assetId isEqualToString:assetId]) {
            existingHolding = h;
            existingIndex = i;
            break;
        }
    }
    
    if (existingHolding) {
        double totalCost = (existingHolding.quantity * existingHolding.averageCost) + cost;
        existingHolding.quantity += quantity;
        existingHolding.averageCost = totalCost / existingHolding.quantity;
        // In ObjC, if holdings is NSMutableArray of objects, modifying the object works if it's mutable. 
        // FAHolding properties are assign/readwrite, so it works.
    } else {
        FAAsset *asset = nil;
        for (FAAsset *a in self.availableAssets) {
            if ([a.assetId isEqualToString:assetId]) {
                asset = a;
                break;
            }
        }
        if (!asset) return NO;
        
        FAHolding *newHolding = [[FAHolding alloc] initWithId:[[NSUUID UUID] UUIDString] asset:asset quantity:quantity averageCost:price];
        [self.portfolio.holdings addObject:newHolding];
    }
    
    // Record Transaction
    FATransaction *transaction = [[FATransaction alloc] initWithId:[NSUUID UUID] assetId:assetId type:FATransactionTypeBuy amount:quantity price:price date:[NSDate date]];
    [self.mutableTransactions addObject:transaction];
    
    // Post Notification for updates
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FAWealthServiceDidUpdate" object:nil];
    
    return YES;
}

- (BOOL)sellAssetId:(NSString *)assetId quantity:(double)quantity {
    FAHolding *holding = nil;
    NSUInteger index = NSNotFound;
    
    for (NSUInteger i = 0; i < self.portfolio.holdings.count; i++) {
        FAHolding *h = self.portfolio.holdings[i];
        if ([h.asset.assetId isEqualToString:assetId]) {
            holding = h;
            index = i;
            break;
        }
    }
    
    if (!holding) return NO;
    if (holding.quantity < quantity) return NO;
    
    double price = [self getPriceForAssetId:assetId];
    double revenue = quantity * price;
    
    // Update Cash
    self.portfolio.cashBalance += revenue;
    
    // Update Holding
    holding.quantity -= quantity;
    if (holding.quantity <= 0.000001) {
        [self.portfolio.holdings removeObjectAtIndex:index];
    }
    
    // Record Transaction
    FATransaction *transaction = [[FATransaction alloc] initWithId:[NSUUID UUID] assetId:assetId type:FATransactionTypeSell amount:quantity price:price date:[NSDate date]];
    [self.mutableTransactions addObject:transaction];
    
    // Post Notification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FAWealthServiceDidUpdate" object:nil];
    
    return YES;
}

@end
