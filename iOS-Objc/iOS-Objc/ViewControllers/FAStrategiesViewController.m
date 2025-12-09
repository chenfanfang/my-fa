#import "FAStrategiesViewController.h"
#import "iOS_Objc-Swift.h"

@interface FAStrategiesViewController () <StrategyCardDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIStackView *contentStackView;
@property (nonatomic, copy) NSArray<Strategy *> *strategies;

@end

@implementation FAStrategiesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self loadStrategies];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(languageDidChange) name:@"LanguageChanged" object:nil];
}

- (void)languageDidChange {
    self.title = [LocalizationHelper localized:@"strategies.title"];
    
    // Refresh content
    for (UIView *subview in self.contentStackView.arrangedSubviews) {
        [subview removeFromSuperview];
    }
    [self loadStrategies];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor colorWithWhite:0.05 alpha:1.0];
    
    self.title = [LocalizationHelper localized:@"strategies.title"];
    
    UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
    [appearance configureWithOpaqueBackground];
    appearance.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    appearance.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.navigationController.navigationBar.standardAppearance = appearance;
    self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
    
    // Header View
    UIView *headerView = [[UIView alloc] init];
    headerView.translatesAutoresizingMaskIntoConstraints = NO;
    headerView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    [self.view addSubview:headerView];
    
    UILabel *headerTitle = [[UILabel alloc] init];
    headerTitle.text = [LocalizationHelper localized:@"strategies.title"];
    headerTitle.font = [UIFont systemFontOfSize:28 weight:UIFontWeightBold];
    headerTitle.textColor = [UIColor whiteColor];
    headerTitle.translatesAutoresizingMaskIntoConstraints = NO;
    [headerView addSubview:headerTitle];
    
    UILabel *headerSubtitle = [[UILabel alloc] init];
    headerSubtitle.text = [LocalizationHelper localized:@"strategies.subtitle"];
    headerSubtitle.font = [UIFont systemFontOfSize:14];
    headerSubtitle.textColor = [UIColor grayColor];
    headerSubtitle.translatesAutoresizingMaskIntoConstraints = NO;
    [headerView addSubview:headerSubtitle];
    
    // ScrollView
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.showsVerticalScrollIndicator = YES;
    [self.view addSubview:self.scrollView];
    
    // Content Stack
    self.contentStackView = [[UIStackView alloc] init];
    self.contentStackView.axis = UILayoutConstraintAxisVertical;
    self.contentStackView.spacing = 0;
    self.contentStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.contentStackView];
    
    [NSLayoutConstraint activateConstraints:@[
        // Header
        [headerView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [headerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [headerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [headerView.heightAnchor constraintEqualToConstant:80],
        
        [headerTitle.leadingAnchor constraintEqualToAnchor:headerView.leadingAnchor constant:20],
        [headerTitle.topAnchor constraintEqualToAnchor:headerView.topAnchor constant:12],
        
        [headerSubtitle.leadingAnchor constraintEqualToAnchor:headerTitle.leadingAnchor],
        [headerSubtitle.topAnchor constraintEqualToAnchor:headerTitle.bottomAnchor constant:4],
        
        // ScrollView
        [self.scrollView.topAnchor constraintEqualToAnchor:headerView.bottomAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        
        // Content Stack
        [self.contentStackView.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor],
        [self.contentStackView.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor],
        [self.contentStackView.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor],
        [self.contentStackView.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor],
        [self.contentStackView.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor]
    ]];
}

- (void)loadStrategies {
    self.strategies = [[MockStrategyService shared] getStrategies];
    
    for (Strategy *strategy in self.strategies) {
        StrategyCardView *cardView = [[StrategyCardView alloc] initWithStrategy:strategy];
        cardView.delegate = self;
        cardView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentStackView addArrangedSubview:cardView];
    }
    
    UIView *spacer = [[UIView alloc] init];
    spacer.translatesAutoresizingMaskIntoConstraints = NO;
    [spacer.heightAnchor constraintEqualToConstant:80].active = YES;
    [self.contentStackView addArrangedSubview:spacer];
}

#pragma mark - StrategyCardDelegate

- (void)strategyCardDidTapTakeToChat:(StrategyCardView *)card strategy:(Strategy *)strategy {
    NSString *format = [LocalizationHelper localized:@"strategies.discuss"];
    NSString *message = [NSString stringWithFormat:format, strategy.title];
    NSDictionary *context = @{
        @"type": @"strategy",
        @"strategyId": strategy.id,
        @"strategyTitle": strategy.title
    };
    
    [[FAChatManager shared] navigateToChatWithMessage:message context:context from:self];
}

@end