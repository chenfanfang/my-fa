#import "FAAssetsViewController.h"
#import "iOS_Objc-Swift.h"
#import "FAWealthService.h"
#import "FAAsset.h"
#import "FAHolding.h"
#import "FAMarketData.h"
#import "FAPortfolio.h"

// MARK: - FAHoldingCell

@interface FAHoldingCell : UITableViewCell
+ (NSString *)identifier;
@property (nonatomic, copy) void (^onAskTapped)(void);
- (void)configureWithHolding:(FAHolding *)holding currentPrice:(double)price;
@end

@interface FAHoldingCell ()
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UILabel *symbolLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) UILabel *quantityLabel;
@property (nonatomic, strong) UIButton *askButton;
@end

@implementation FAHoldingCell

+ (NSString *)identifier { return @"FAHoldingCell"; }

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
    
    self.containerView = [[UIView alloc] init];
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.containerView.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
    self.containerView.layer.cornerRadius = 12;
    [self.contentView addSubview:self.containerView];
    
    self.symbolLabel = [[UILabel alloc] init];
    self.symbolLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    self.symbolLabel.textColor = [UIColor labelColor];
    self.symbolLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:self.symbolLabel];
    
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.font = [UIFont systemFontOfSize:14];
    self.nameLabel.textColor = [UIColor secondaryLabelColor];
    self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:self.nameLabel];
    
    self.valueLabel = [[UILabel alloc] init];
    self.valueLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    self.valueLabel.textColor = [UIColor labelColor];
    self.valueLabel.textAlignment = NSTextAlignmentRight;
    self.valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:self.valueLabel];
    
    self.quantityLabel = [[UILabel alloc] init];
    self.quantityLabel.font = [UIFont systemFontOfSize:13];
    self.quantityLabel.textColor = [UIColor secondaryLabelColor];
    self.quantityLabel.textAlignment = NSTextAlignmentRight;
    self.quantityLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:self.quantityLabel];
    
    self.askButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.askButton setImage:[UIImage systemImageNamed:@"bubble.left"] forState:UIControlStateNormal];
    self.askButton.tintColor = [UIColor systemBlueColor];
    self.askButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.askButton addTarget:self action:@selector(askButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.askButton];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.containerView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:4],
        [self.containerView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
        [self.containerView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
        [self.containerView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-4],
        
        [self.symbolLabel.topAnchor constraintEqualToAnchor:self.containerView.topAnchor constant:12],
        [self.symbolLabel.leadingAnchor constraintEqualToAnchor:self.containerView.leadingAnchor constant:16],
        
        [self.nameLabel.topAnchor constraintEqualToAnchor:self.symbolLabel.bottomAnchor constant:4],
        [self.nameLabel.leadingAnchor constraintEqualToAnchor:self.symbolLabel.leadingAnchor],
        [self.nameLabel.bottomAnchor constraintEqualToAnchor:self.containerView.bottomAnchor constant:-12],
        
        [self.askButton.centerYAnchor constraintEqualToAnchor:self.containerView.centerYAnchor],
        [self.askButton.trailingAnchor constraintEqualToAnchor:self.containerView.trailingAnchor constant:-16],
        [self.askButton.widthAnchor constraintEqualToConstant:32],
        [self.askButton.heightAnchor constraintEqualToConstant:32],
        
        [self.valueLabel.topAnchor constraintEqualToAnchor:self.containerView.topAnchor constant:12],
        [self.valueLabel.trailingAnchor constraintEqualToAnchor:self.askButton.leadingAnchor constant:-12],
        
        [self.quantityLabel.topAnchor constraintEqualToAnchor:self.valueLabel.bottomAnchor constant:4],
        [self.quantityLabel.trailingAnchor constraintEqualToAnchor:self.valueLabel.trailingAnchor],
        [self.quantityLabel.bottomAnchor constraintEqualToAnchor:self.containerView.bottomAnchor constant:-12]
    ]];
}

- (void)configureWithHolding:(FAHolding *)holding currentPrice:(double)price {
    self.symbolLabel.text = holding.asset.symbol;
    self.nameLabel.text = holding.asset.name;
    
    double value = holding.quantity * price;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    formatter.currencyCode = @"USD";
    
    self.valueLabel.text = [formatter stringFromNumber:@(value)];
    self.quantityLabel.text = [NSString stringWithFormat:[LocalizationHelper localized:@"portfolio.quantity.units"], holding.quantity];
}

- (void)askButtonTapped {
    if (self.onAskTapped) {
        self.onAskTapped();
    }
}

@end

// MARK: - FAAssetsViewController

@interface FAAssetsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) BOOL isLoggedIn;

// Login UI
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *iconView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) AccountOpeningCardView *openingCard;
@property (nonatomic, strong) UIButton *startButton;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UILabel *loginLabel;

// Logged In UI
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *headerView;

// Data
@property (nonatomic, strong) FAWealthService *wealthService;

@end

@implementation FAAssetsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.wealthService = [FAWealthService sharedService];
    
    [self setupUI];
    [self updateViewState];
    [self bindData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(languageDidChange) name:@"LanguageChanged" object:nil];
}

- (void)languageDidChange {
    // Update Localized Strings
    self.title = [LocalizationHelper localized:@"assets.title"];
    self.titleLabel.text = [LocalizationHelper localized:@"assets.journey.title"];
    self.subtitleLabel.text = [LocalizationHelper localized:@"assets.journey.subtitle"];
    [self.startButton setTitle:[LocalizationHelper localized:@"assets.start.opening"] forState:UIControlStateNormal];
    self.loginLabel.text = [LocalizationHelper localized:@"assets.has.account"];
    [self.loginButton setTitle:[LocalizationHelper localized:@"assets.login.demo"] forState:UIControlStateNormal];
    
    if (self.isLoggedIn) {
        self.navigationItem.rightBarButtonItems[0].title = [LocalizationHelper localized:@"assets.trade"];
        self.navigationItem.rightBarButtonItems[1].title = [LocalizationHelper localized:@"assets.logout"];
    }
    
    [self.tableView reloadData];
    
    // Update Header
    UILabel *titleLabel = [self.headerView viewWithTag:99]; // Added tag 99 for title
    if (titleLabel) {
        titleLabel.text = [LocalizationHelper localized:@"assets.total.balance"];
    }
    [self updateHeader]; // Will re-format cash label
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];
    self.title = [LocalizationHelper localized:@"assets.title"];
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    
    [self setupLoginUI];
    [self setupPortfolioUI];
}

- (void)setupLoginUI {
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.backgroundColor = [UIColor systemGroupedBackgroundColor];
    [self.view addSubview:self.scrollView];
    
    self.contentView = [[UIView alloc] init];
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.contentView];
    
    // Icon
    self.iconView = [[UIView alloc] init];
    self.iconView.translatesAutoresizingMaskIntoConstraints = NO;
    self.iconView.backgroundColor = [[UIColor systemBlueColor] colorWithAlphaComponent:0.15];
    self.iconView.layer.cornerRadius = 60;
    [self.contentView addSubview:self.iconView];
    
    UILabel *exclamationIcon = [[UILabel alloc] init];
    exclamationIcon.text = @"!";
    exclamationIcon.font = [UIFont systemFontOfSize:48 weight:UIFontWeightBold];
    exclamationIcon.textColor = [UIColor systemBlueColor];
    exclamationIcon.textAlignment = NSTextAlignmentCenter;
    exclamationIcon.translatesAutoresizingMaskIntoConstraints = NO;
    [self.iconView addSubview:exclamationIcon];
    
    // Labels
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = [LocalizationHelper localized:@"assets.journey.title"];
    self.titleLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightBold];
    self.titleLabel.textColor = [UIColor labelColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.titleLabel];
    
    self.subtitleLabel = [[UILabel alloc] init];
    self.subtitleLabel.text = [LocalizationHelper localized:@"assets.journey.subtitle"];
    self.subtitleLabel.font = [UIFont systemFontOfSize:16];
    self.subtitleLabel.textColor = [UIColor secondaryLabelColor];
    self.subtitleLabel.textAlignment = NSTextAlignmentCenter;
    self.subtitleLabel.numberOfLines = 0;
    self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.subtitleLabel];
    
    // Card
    NSArray *steps = [[MockAssetService shared] getAccountOpeningSteps];
    self.openingCard = [[AccountOpeningCardView alloc] initWithSteps:steps];
    self.openingCard.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.openingCard];
    
    // Start Button
    self.startButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.startButton setTitle:[LocalizationHelper localized:@"assets.start.opening"] forState:UIControlStateNormal];
    self.startButton.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
    [self.startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.startButton.backgroundColor = [UIColor systemBlueColor];
    self.startButton.layer.cornerRadius = 14;
    self.startButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.startButton addTarget:self action:@selector(startAccountOpening) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.startButton];
    
    // Login Label
    self.loginLabel = [[UILabel alloc] init];
    self.loginLabel.text = [LocalizationHelper localized:@"assets.has.account"];
    self.loginLabel.font = [UIFont systemFontOfSize:15];
    self.loginLabel.textColor = [UIColor secondaryLabelColor];
    self.loginLabel.textAlignment = NSTextAlignmentCenter;
    self.loginLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.loginLabel];
    
    // Login Button
    self.loginButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.loginButton setTitle:[LocalizationHelper localized:@"assets.login.demo"] forState:UIControlStateNormal];
    self.loginButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    [self.loginButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    self.loginButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.loginButton addTarget:self action:@selector(showLoginScreen) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.loginButton];
    
    // Constraints
    [NSLayoutConstraint activateConstraints:@[
        [exclamationIcon.centerXAnchor constraintEqualToAnchor:self.iconView.centerXAnchor],
        [exclamationIcon.centerYAnchor constraintEqualToAnchor:self.iconView.centerYAnchor],
        
        [self.scrollView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        
        [self.contentView.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor],
        [self.contentView.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor],
        [self.contentView.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor],
        [self.contentView.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor],
        [self.contentView.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor],
        
        [self.iconView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:60],
        [self.iconView.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor],
        [self.iconView.widthAnchor constraintEqualToConstant:120],
        [self.iconView.heightAnchor constraintEqualToConstant:120],
        
        [self.titleLabel.topAnchor constraintEqualToAnchor:self.iconView.bottomAnchor constant:32],
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:32],
        [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-32],
        
        [self.subtitleLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:12],
        [self.subtitleLabel.leadingAnchor constraintEqualToAnchor:self.titleLabel.leadingAnchor],
        [self.subtitleLabel.trailingAnchor constraintEqualToAnchor:self.titleLabel.trailingAnchor],
        
        [self.openingCard.topAnchor constraintEqualToAnchor:self.subtitleLabel.bottomAnchor constant:32],
        [self.openingCard.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:20],
        [self.openingCard.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-20],
        
        [self.startButton.topAnchor constraintEqualToAnchor:self.openingCard.bottomAnchor constant:32],
        [self.startButton.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:20],
        [self.startButton.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-20],
        [self.startButton.heightAnchor constraintEqualToConstant:54],
        
        [self.loginLabel.topAnchor constraintEqualToAnchor:self.startButton.bottomAnchor constant:24],
        [self.loginLabel.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor],
        
        [self.loginButton.topAnchor constraintEqualToAnchor:self.loginLabel.bottomAnchor constant:8],
        [self.loginButton.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor],
        [self.loginButton.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-40]
    ]];
}

- (void)setupPortfolioUI {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor systemGroupedBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[FAHoldingCell class] forCellReuseIdentifier:[FAHoldingCell identifier]];
    self.tableView.hidden = YES;
    [self.view addSubview:self.tableView];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
    
    [self setupHeaderView];
}

- (void)setupHeaderView {
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 180)];
    self.headerView.backgroundColor = [UIColor clearColor];
    
    UIView *card = [[UIView alloc] init];
    card.translatesAutoresizingMaskIntoConstraints = NO;
    card.backgroundColor = [[UIColor systemBlueColor] colorWithAlphaComponent:0.1];
    card.layer.cornerRadius = 20;
    [self.headerView addSubview:card];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.tag = 99;
    titleLabel.text = [LocalizationHelper localized:@"assets.total.balance"];
    titleLabel.textColor = [UIColor secondaryLabelColor];
    titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [card addSubview:titleLabel];
    
    UILabel *valueLabel = [[UILabel alloc] init];
    valueLabel.tag = 100;
    valueLabel.text = @"$0.00";
    valueLabel.textColor = [UIColor labelColor];
    valueLabel.font = [UIFont systemFontOfSize:42 weight:UIFontWeightBold];
    valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [card addSubview:valueLabel];
    
    UILabel *cashLabel = [[UILabel alloc] init];
    cashLabel.tag = 101;
    cashLabel.text = @"Cash: $0.00";
    cashLabel.textColor = [UIColor secondaryLabelColor];
    cashLabel.font = [UIFont systemFontOfSize:15];
    cashLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [card addSubview:cashLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [card.topAnchor constraintEqualToAnchor:self.headerView.topAnchor constant:16],
        [card.leadingAnchor constraintEqualToAnchor:self.headerView.leadingAnchor constant:20],
        [card.trailingAnchor constraintEqualToAnchor:self.headerView.trailingAnchor constant:-20],
        [card.bottomAnchor constraintEqualToAnchor:self.headerView.bottomAnchor constant:-16],
        
        [titleLabel.topAnchor constraintEqualToAnchor:card.topAnchor constant:20],
        [titleLabel.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:20],
        
        [valueLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:8],
        [valueLabel.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:20],
        
        [cashLabel.topAnchor constraintEqualToAnchor:valueLabel.bottomAnchor constant:8],
        [cashLabel.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:20],
        [cashLabel.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-20]
    ]];
    
    // Force layout to calculate height
    [self.headerView setNeedsLayout];
    [self.headerView layoutIfNeeded];
    CGSize size = [self.headerView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    CGRect frame = self.headerView.frame;
    frame.size.height = size.height;
    self.headerView.frame = frame;
    
    self.tableView.tableHeaderView = self.headerView;
}

- (void)bindData {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataDidUpdate) name:@"FAWealthServiceDidUpdate" object:nil];
    [self dataDidUpdate];
}

- (void)dataDidUpdate {
    [self updateHeader];
    [self.tableView reloadData];
}

- (NSString *)formatCurrency:(double)value {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    formatter.currencyCode = @"USD";
    return [formatter stringFromNumber:@(value)] ?: @"$0.00";
}

- (void)updateHeader {
    double totalValue = [self.wealthService getTotalValue];
    UILabel *valueLabel = [self.headerView viewWithTag:100];
    UILabel *cashLabel = [self.headerView viewWithTag:101];
    
    valueLabel.text = [self formatCurrency:totalValue];
    
    NSString *cashStr = [self formatCurrency:self.wealthService.portfolio.cashBalance];
    // Using localized string with format
    NSString *format = [LocalizationHelper localized:@"assets.cash"]; 
    // The format string in Swift is "Cash: %@" (or similar).
    // ObjC stringWithFormat might need check if format contains %@.
    // Assuming localized string returns "Cash: %@"
    @try {
        cashLabel.text = [NSString stringWithFormat:format, cashStr];
    } @catch (NSException *e) {
        cashLabel.text = [NSString stringWithFormat:@"Cash: %@", cashStr];
    }
}

- (void)updateViewState {
    self.scrollView.hidden = self.isLoggedIn;
    self.tableView.hidden = !self.isLoggedIn;
    
    if (self.isLoggedIn) {
        UIBarButtonItem *tradeButton = [[UIBarButtonItem alloc] initWithTitle:[LocalizationHelper localized:@"assets.trade"] style:UIBarButtonItemStylePlain target:self action:@selector(tradeButtonTapped)];
        UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:[LocalizationHelper localized:@"assets.logout"] style:UIBarButtonItemStylePlain target:self action:@selector(logoutTapped)];
        self.navigationItem.rightBarButtonItems = @[tradeButton, logoutButton];
    } else {
        self.navigationItem.rightBarButtonItems = nil;
    }
}

// MARK: - Actions

- (void)startAccountOpening {
    NSString *message = [LocalizationHelper localized:@"account.opening.request"];
    NSDictionary *context = @{
        @"type": @"account_opening",
        @"step": @"phone_verification"
    };
    [self.navigationDelegate navigateToChatWithMessage:message context:context];
}

- (void)showLoginScreen {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[LocalizationHelper localized:@"assets.login.title"] message:[LocalizationHelper localized:@"assets.login.message"] preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = [LocalizationHelper localized:@"assets.login.username"];
        textField.text = @"johndoe";
    }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = [LocalizationHelper localized:@"assets.login.password"];
        textField.secureTextEntry = YES;
        textField.text = @"12345678";
    }];
    
    UIAlertAction *loginAction = [UIAlertAction actionWithTitle:[LocalizationHelper localized:@"assets.login.button"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *username = alert.textFields[0].text;
        NSString *password = alert.textFields[1].text;
        
        if ([username isEqualToString:@"johndoe"] && [password isEqualToString:@"12345678"]) {
            self.isLoggedIn = YES;
            [self updateViewState];
        } else {
            UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:[LocalizationHelper localized:@"app.error"] message:[LocalizationHelper localized:@"assets.login.error"] preferredStyle:UIAlertControllerStyleAlert];
            [errorAlert addAction:[UIAlertAction actionWithTitle:[LocalizationHelper localized:@"app.ok"] style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:errorAlert animated:YES completion:nil];
        }
    }];
    
    [alert addAction:loginAction];
    [alert addAction:[UIAlertAction actionWithTitle:[LocalizationHelper localized:@"app.cancel"] style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)logoutTapped {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[LocalizationHelper localized:@"assets.logout.confirm.title"] message:[LocalizationHelper localized:@"assets.logout.confirm.message"] preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:[LocalizationHelper localized:@"app.cancel"] style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:[LocalizationHelper localized:@"assets.logout"] style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        self.isLoggedIn = NO;
        [self updateViewState];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)tradeButtonTapped {
    NSString *message = [LocalizationHelper localized:@"trade.want"];
    [self.navigationDelegate navigateToChatWithMessage:message context:@{}];
    
    if (self.tabBarController) {
        self.tabBarController.selectedIndex = 0;
    }
}

- (void)askAboutAsset:(FAHolding *)holding {
    // Note: localized(@"assets.ask.about", arg1, arg2) not directly available via current bridge
    // We'll assume the format string is returned and we format it here.
    NSString *format = [LocalizationHelper localized:@"assets.ask.about"];
    NSString *message = [NSString stringWithFormat:format, holding.asset.name, holding.asset.symbol];
    [self.navigationDelegate navigateToChatWithMessage:message context:@{}];
    
    if (self.tabBarController) {
        self.tabBarController.selectedIndex = 0;
    }
}

// MARK: - UITableViewDataSource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5; // AssetType has 5 cases: Stock, Crypto, Fund, Bond, Cash
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    FAAssetType type = (FAAssetType)section;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"asset.type == %ld", (long)type];
    return [self.wealthService.portfolio.holdings filteredArrayUsingPredicate:predicate].count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    FAAssetType type = (FAAssetType)section;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"asset.type == %ld", (long)type];
    NSUInteger count = [self.wealthService.portfolio.holdings filteredArrayUsingPredicate:predicate].count;
    
    if (count > 0) {
        NSString *typeKey = @"";
        switch (type) {
            case FAAssetTypeStock: typeKey = @"stock"; break;
            case FAAssetTypeCrypto: typeKey = @"crypto"; break;
            case FAAssetTypeFund: typeKey = @"fund"; break;
            case FAAssetTypeBond: typeKey = @"bond"; break;
            case FAAssetTypeCash: typeKey = @"cash"; break;
        }
        return [LocalizationHelper localized:[NSString stringWithFormat:@"portfolio.%@", typeKey]];
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FAHoldingCell *cell = [tableView dequeueReusableCellWithIdentifier:[FAHoldingCell identifier] forIndexPath:indexPath];
    
    FAAssetType type = (FAAssetType)indexPath.section;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"asset.type == %ld", (long)type];
    NSArray<FAHolding *> *holdings = [self.wealthService.portfolio.holdings filteredArrayUsingPredicate:predicate];
    FAHolding *holding = holdings[indexPath.row];
    
    double price = [self.wealthService getPriceForAssetId:holding.asset.assetId];
    
    [cell configureWithHolding:holding currentPrice:price];
    
    __weak typeof(self) weakSelf = self;
    cell.onAskTapped = ^{
        [weakSelf askAboutAsset:holding];
    };
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    FAAssetType type = (FAAssetType)section;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"asset.type == %ld", (long)type];
    NSUInteger count = [self.wealthService.portfolio.holdings filteredArrayUsingPredicate:predicate].count;
    return count > 0 ? 44 : 0;
}

@end
