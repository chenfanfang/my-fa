#import "FATabBarController.h"
#import "iOS_Objc-Swift.h"
#import "FAAssetsViewController.h"
#import "FAStrategiesViewController.h"
#import "FASettingsViewController.h"
#import "FAChatNavigationDelegate.h"
#import "FALocalizationHelper.h"

@interface FATabBarController () <FAChatNavigationDelegate>
@end

@implementation FATabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTabs];
    [self setupAppearance];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(languageDidChange) name:@"LanguageChanged" object:nil];
}

- (void)languageDidChange {
    [self updateTabBarTitles];
}

- (void)updateTabBarTitles {
    NSArray *vcs = self.viewControllers;
    if (vcs.count >= 4) {
        ((UIViewController *)vcs[0]).tabBarItem.title = [FALocalizationHelper localized:@"tab.chat"];
        ((UIViewController *)vcs[1]).tabBarItem.title = [FALocalizationHelper localized:@"tab.strategies"];
        ((UIViewController *)vcs[2]).tabBarItem.title = [FALocalizationHelper localized:@"tab.assets"];
        ((UIViewController *)vcs[3]).tabBarItem.title = [FALocalizationHelper localized:@"settings.title"];
    }
}

- (void)setupTabs {
    // 1. Chat Tab
    UIViewController *chatContainer = [[FAChatManager shared] createDrawerContainer];
    UINavigationController *chatNav = [[UINavigationController alloc] initWithRootViewController:chatContainer];
    [chatNav setNavigationBarHidden:YES animated:NO];
    chatNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:[FALocalizationHelper localized:@"tab.chat"]
                                                       image:[UIImage systemImageNamed:@"bubble.left.and.bubble.right"]
                                               selectedImage:[UIImage systemImageNamed:@"bubble.left.and.bubble.right.fill"]];
    
    // 2. Strategies Tab
    FAStrategiesViewController *strategiesVC = [[FAStrategiesViewController alloc] init];
    strategiesVC.navigationDelegate = self;
    UINavigationController *strategiesNav = [[UINavigationController alloc] initWithRootViewController:strategiesVC];
    strategiesNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:[FALocalizationHelper localized:@"tab.strategies"]
                                                             image:[UIImage systemImageNamed:@"chart.line.uptrend.xyaxis"]
                                                     selectedImage:[UIImage systemImageNamed:@"chart.line.uptrend.xyaxis.fill"]];
    
    // 3. Assets Tab
    FAAssetsViewController *assetsVC = [[FAAssetsViewController alloc] init];
    assetsVC.navigationDelegate = self;
    UINavigationController *assetsNav = [[UINavigationController alloc] initWithRootViewController:assetsVC];
    assetsNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:[FALocalizationHelper localized:@"tab.assets"]
                                                         image:[UIImage systemImageNamed:@"wallet.pass"]
                                                 selectedImage:[UIImage systemImageNamed:@"wallet.pass.fill"]];
    
    // 4. Settings Tab
    FASettingsViewController *settingsVC = [[FASettingsViewController alloc] init];
    UINavigationController *settingsNav = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    settingsNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:[FALocalizationHelper localized:@"settings.title"]
                                                           image:[UIImage systemImageNamed:@"gearshape"]
                                                   selectedImage:[UIImage systemImageNamed:@"gearshape.fill"]];
    
    self.viewControllers = @[chatNav, strategiesNav, assetsNav, settingsNav];
}

- (void)setupAppearance {
    self.tabBar.barStyle = UIBarStyleBlack;
    self.tabBar.translucent = YES;
    self.tabBar.tintColor = [UIColor colorWithRed:0.46 green:0.42 blue:1.00 alpha:1.00];
    self.tabBar.unselectedItemTintColor = [UIColor grayColor];
    
    UITabBarAppearance *appearance = [[UITabBarAppearance alloc] init];
    [appearance configureWithDefaultBackground];
    appearance.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    
    self.tabBar.standardAppearance = appearance;
    if (@available(iOS 15.0, *)) {
        self.tabBar.scrollEdgeAppearance = appearance;
    }
}

#pragma mark - FAChatNavigationDelegate

- (void)navigateToChatWithMessage:(NSString *)message context:(NSDictionary<NSString *,id> *)context {
    [[FAChatManager shared] navigateToChatWithMessage:message context:context from:self];
}

@end
