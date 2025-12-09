#import "FASettingsViewController.h"
#import "iOS_Objc-Swift.h"
#import "FALocalizationHelper.h"

@interface FASettingsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation FASettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(languageDidChange) name:@"LanguageChanged" object:nil];
}

- (void)languageDidChange {
    self.title = [FALocalizationHelper localized:@"settings.title"];
    [self.tableView reloadData];
}

- (void)setupUI {
    self.title = [FALocalizationHelper localized:@"settings.title"];
    self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.view addSubview:self.tableView];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    UIListContentConfiguration *config = [cell defaultContentConfiguration];
    config.text = [FALocalizationHelper localized:@"settings.language"];
    // Note: To get current language display name in ObjC, we might need a helper method or access the enum wrapper
    // For simplicity, we just check the current code
    NSString *code = [FALocalizationHelper currentLanguageCode];
    NSString *displayName = [code isEqualToString:@"en"] ? @"English" : @"简体中文";
    
    config.secondaryText = displayName;
    cell.contentConfiguration = config;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self showLanguageSelector];
}

- (void)showLanguageSelector {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[FALocalizationHelper localized:@"settings.language.change"] message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *english = [UIAlertAction actionWithTitle:@"English" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [FALocalizationHelper setLanguageWithCode:@"en"];
        [self showLanguageChangedAlert];
    }];
    
    UIAlertAction *chinese = [UIAlertAction actionWithTitle:@"简体中文" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [FALocalizationHelper setLanguageWithCode:@"zh-Hans"];
        [self showLanguageChangedAlert];
    }];
    
    [alert addAction:english];
    [alert addAction:chinese];
    [alert addAction:[UIAlertAction actionWithTitle:[FALocalizationHelper localized:@"app.cancel"] style:UIAlertActionStyleCancel handler:nil]];
    
    if (alert.popoverPresentationController) {
        alert.popoverPresentationController.sourceView = self.tableView;
        alert.popoverPresentationController.sourceRect = self.tableView.bounds;
    }
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showLanguageChangedAlert {
    NSString *code = [FALocalizationHelper currentLanguageCode];
    NSString *displayName = [code isEqualToString:@"en"] ? @"English" : @"简体中文";
    
    NSString *message = [NSString stringWithFormat:[FALocalizationHelper localized:@"settings.language.current"], displayName];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[FALocalizationHelper localized:@"settings.language.change"] message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:[FALocalizationHelper localized:@"app.ok"] style:UIAlertActionStyleDefault handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end