#import "FAComposerToolsExample.h"
#import "FALocalizationHelper.h"

@implementation FAComposerToolsExample

+ (UIImage *)imageNamed:(NSString *)name {
    UIImage *image = [UIImage imageNamed:name];
    if (image) return image;
    return [UIImage imageNamed:name inBundle:[NSBundle mainBundle] compatibleWithTraitCollection:nil];
}

+ (NSArray<FinConvoComposerTool *> *)createExampleTools {
    NSMutableArray<FinConvoComposerTool *> *tools = [NSMutableArray array];
    
    // CoinGecko
    UIImage *coingeckoLogo = [self imageNamed:@"tool_coingecko"];
    if (!coingeckoLogo) {
        coingeckoLogo = [[UIImage systemImageNamed:@"bitcoinsign.circle.fill"] imageWithTintColor:[UIColor systemGreenColor] renderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    FinConvoComposerTool *coingeckoTool = [[FinConvoComposerTool alloc] initWithItemId:@"coingecko" displayName:@"CoinGecko" logoImage:coingeckoLogo];
    coingeckoTool.badgeColor = [UIColor systemGreenColor];
    coingeckoTool.metadata = @{
        @"endpoint": @"https://api.coingecko.com/api/v3",
        @"service": @"crypto_data",
        @"description": @"Real-time cryptocurrency prices, charts, and market data",
        @"capabilities": @[@"price", @"charts", @"market-cap", @"volume"]
    };
    [tools addObject:coingeckoTool];
    
    // Yahoo Finance
    UIImage *yahooLogo = [self imageNamed:@"tool_yahoo"];
    if (!yahooLogo) {
        yahooLogo = [[UIImage systemImageNamed:@"chart.line.uptrend.xyaxis.circle.fill"] imageWithTintColor:[UIColor systemPurpleColor] renderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    FinConvoComposerTool *yahooTool = [[FinConvoComposerTool alloc] initWithItemId:@"yahoo_finance" displayName:@"Yahoo Finance" logoImage:yahooLogo];
    yahooTool.badgeColor = [UIColor systemPurpleColor];
    yahooTool.metadata = @{
        @"endpoint": @"https://finance.yahoo.com/api",
        @"service": @"stock_data",
        @"description": @"Stock market data, news, and portfolio tracking",
        @"capabilities": @[@"quotes", @"news", @"analysis", @"options"]
    };
    [tools addObject:yahooTool];
    
    // Bloomberg
    UIImage *bloombergLogo = [self imageNamed:@"tool_bloomberg"];
    if (!bloombergLogo) {
        bloombergLogo = [[UIImage systemImageNamed:@"newspaper.circle.fill"] imageWithTintColor:[UIColor blackColor] renderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    FinConvoComposerTool *bloombergTool = [[FinConvoComposerTool alloc] initWithItemId:@"bloomberg" displayName:@"Bloomberg" logoImage:bloombergLogo];
    bloombergTool.badgeColor = [UIColor blackColor];
    bloombergTool.metadata = @{
        @"endpoint": @"https://api.bloomberg.com",
        @"service": @"financial_news",
        @"description": @"Global business and financial news, market analysis",
        @"capabilities": @[@"news", @"analysis", @"market-trends"]
    };
    [tools addObject:bloombergTool];
    
    // Morningstar
    UIImage *morningstarLogo = [self imageNamed:@"tool_morningstar"];
    if (!morningstarLogo) {
        morningstarLogo = [[UIImage systemImageNamed:@"star.circle.fill"] imageWithTintColor:[UIColor systemRedColor] renderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    FinConvoComposerTool *morningstarTool = [[FinConvoComposerTool alloc] initWithItemId:@"morningstar" displayName:@"Morningstar" logoImage:morningstarLogo];
    morningstarTool.badgeColor = [UIColor systemRedColor];
    morningstarTool.metadata = @{
        @"endpoint": @"https://api.morningstar.com",
        @"service": @"investment_research",
        @"description": @"Independent investment research and fund ratings",
        @"capabilities": @[@"ratings", @"funds", @"etfs", @"research"]
    };
    [tools addObject:morningstarTool];
    
    return [tools copy];
}

+ (void)handleComposerToolSelected:(FinConvoComposerTool *)tool {
    NSLog(@"✅ Tool selected for this message: %@ (ID: %@)", tool.displayName, tool.itemId);
    
    if ([tool.metadata isKindOfClass:[NSDictionary class]]) {
        NSDictionary *metadata = (NSDictionary *)tool.metadata;
        NSLog(@"   Service: %@", metadata[@"service"] ?: @"N/A");
        NSLog(@"   Endpoint: %@", metadata[@"endpoint"] ?: @"N/A");
        NSLog(@"   Description: %@", metadata[@"description"] ?: @"N/A");
        
        NSArray *capabilities = metadata[@"capabilities"];
        if ([capabilities isKindOfClass:[NSArray class]]) {
            NSLog(@"   Capabilities: %@", [capabilities componentsJoinedByString:@", "]);
        }
    }
}

@end
