#import "FAStrategyCardView.h"
#import "FAPerformanceChartView.h"
#import "iOS_Objc-Swift.h"

// Helper for hex color (internal)
@interface UIColor (Hex)
+ (UIColor *)colorWithHexString:(NSString *)hexString;
@end

@implementation UIColor (Hex)
+ (UIColor *)colorWithHexString:(NSString *)hexString {
    NSString *cleanString = [hexString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
    unsigned int rgbValue = 0;
    [[NSScanner scannerWithString:cleanString] scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0
                           green:((float)((rgbValue & 0xFF00) >> 8))/255.0
                            blue:((float)(rgbValue & 0xFF))/255.0
                           alpha:1.0];
}
@end

@interface FAStrategyCardView ()

@property (nonatomic, strong) FAStrategy *strategy;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *creatorAvatarView;
@property (nonatomic, strong) UILabel *creatorNameLabel;
@property (nonatomic, strong) UILabel *creatorRoleLabel;
@property (nonatomic, strong) UILabel *returnBadge;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) FAPerformanceChartView *chartView;
@property (nonatomic, strong) UIStackView *metricsStackView;
@property (nonatomic, strong) UIStackView *tagsStackView;
@property (nonatomic, strong) UIStackView *engagementStackView;
@property (nonatomic, strong) UIButton *takeToChatButton;
@property (nonatomic, strong) UIButton *followButton;

@end

@implementation FAStrategyCardView

- (instancetype)initWithStrategy:(FAStrategy *)strategy {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _strategy = strategy;
        _chartView = [[FAPerformanceChartView alloc] initWithDataPoints:strategy.historicalData];
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    // Container
    self.containerView = [[UIView alloc] init];
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.containerView.backgroundColor = [UIColor colorWithWhite:0.15 alpha:1.0];
    self.containerView.layer.cornerRadius = 12;
    [self addSubview:self.containerView];
    
    // Creator Avatar
    self.creatorAvatarView = [[UIView alloc] init];
    self.creatorAvatarView.translatesAutoresizingMaskIntoConstraints = NO;
    self.creatorAvatarView.backgroundColor = [UIColor colorWithHexString:self.strategy.creator.avatarColor];
    self.creatorAvatarView.layer.cornerRadius = 20;
    [self.containerView addSubview:self.creatorAvatarView];
    
    UILabel *avatarLabel = [[UILabel alloc] init];
    if (self.strategy.creator.name.length > 0) {
        avatarLabel.text = [self.strategy.creator.name substringToIndex:1];
    }
    avatarLabel.textColor = [UIColor whiteColor];
    avatarLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    avatarLabel.textAlignment = NSTextAlignmentCenter;
    avatarLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.creatorAvatarView addSubview:avatarLabel];
    
    // Creator Info
    self.creatorNameLabel = [[UILabel alloc] init];
    self.creatorNameLabel.text = self.strategy.creator.name;
    self.creatorNameLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    self.creatorNameLabel.textColor = [UIColor whiteColor];
    self.creatorNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:self.creatorNameLabel];
    
    self.creatorRoleLabel = [[UILabel alloc] init];
    self.creatorRoleLabel.text = self.strategy.creator.role;
    self.creatorRoleLabel.font = [UIFont systemFontOfSize:12];
    self.creatorRoleLabel.textColor = [UIColor grayColor];
    self.creatorRoleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:self.creatorRoleLabel];
    
    // Return Badge
    self.returnBadge = [[UILabel alloc] init];
    self.returnBadge.text = [NSString stringWithFormat:@"+%.1f%%", self.strategy.performance.annualReturn];
    self.returnBadge.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    self.returnBadge.textColor = [UIColor colorWithRed:0.3 green:0.8 blue:0.4 alpha:1.0];
    self.returnBadge.backgroundColor = [UIColor colorWithRed:0.2 green:0.4 blue:0.3 alpha:0.3];
    self.returnBadge.layer.cornerRadius = 12;
    self.returnBadge.clipsToBounds = YES;
    self.returnBadge.textAlignment = NSTextAlignmentCenter;
    self.returnBadge.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:self.returnBadge];
    
    // Title
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = self.strategy.title;
    self.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:self.titleLabel];
    
    // Description
    self.descriptionLabel = [[UILabel alloc] init];
    self.descriptionLabel.text = self.strategy.desc;
    self.descriptionLabel.font = [UIFont systemFontOfSize:14];
    self.descriptionLabel.textColor = [UIColor lightGrayColor];
    self.descriptionLabel.numberOfLines = 3;
    self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:self.descriptionLabel];
    
    // Chart
    self.chartView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:self.chartView];
    
    // Metrics
    [self setupMetrics];
    
    // Tags
    [self setupTags];
    
    // Engagement
    [self setupEngagement];
    
    // Buttons
    [self setupButtons];
    
    // Layout Constraints
    [NSLayoutConstraint activateConstraints:@[
        [self.containerView.topAnchor constraintEqualToAnchor:self.topAnchor constant:12],
        [self.containerView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16],
        [self.containerView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-16],
        [self.containerView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        
        [self.creatorAvatarView.topAnchor constraintEqualToAnchor:self.containerView.topAnchor constant:16],
        [self.creatorAvatarView.leadingAnchor constraintEqualToAnchor:self.containerView.leadingAnchor constant:16],
        [self.creatorAvatarView.widthAnchor constraintEqualToConstant:40],
        [self.creatorAvatarView.heightAnchor constraintEqualToConstant:40],
        
        [avatarLabel.centerXAnchor constraintEqualToAnchor:self.creatorAvatarView.centerXAnchor],
        [avatarLabel.centerYAnchor constraintEqualToAnchor:self.creatorAvatarView.centerYAnchor],
        
        [self.creatorNameLabel.leadingAnchor constraintEqualToAnchor:self.creatorAvatarView.trailingAnchor constant:12],
        [self.creatorNameLabel.topAnchor constraintEqualToAnchor:self.creatorAvatarView.topAnchor constant:4],
        
        [self.creatorRoleLabel.leadingAnchor constraintEqualToAnchor:self.creatorNameLabel.leadingAnchor],
        [self.creatorRoleLabel.topAnchor constraintEqualToAnchor:self.creatorNameLabel.bottomAnchor constant:2],
        
        [self.returnBadge.trailingAnchor constraintEqualToAnchor:self.containerView.trailingAnchor constant:-16],
        [self.returnBadge.centerYAnchor constraintEqualToAnchor:self.creatorAvatarView.centerYAnchor],
        [self.returnBadge.widthAnchor constraintEqualToConstant:80],
        [self.returnBadge.heightAnchor constraintEqualToConstant:24],
        
        [self.titleLabel.topAnchor constraintEqualToAnchor:self.creatorAvatarView.bottomAnchor constant:16],
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.containerView.leadingAnchor constant:16],
        [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.containerView.trailingAnchor constant:-16],
        
        [self.descriptionLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:8],
        [self.descriptionLabel.leadingAnchor constraintEqualToAnchor:self.titleLabel.leadingAnchor],
        [self.descriptionLabel.trailingAnchor constraintEqualToAnchor:self.titleLabel.trailingAnchor],
        
        [self.chartView.topAnchor constraintEqualToAnchor:self.descriptionLabel.bottomAnchor constant:16],
        [self.chartView.leadingAnchor constraintEqualToAnchor:self.containerView.leadingAnchor constant:16],
        [self.chartView.trailingAnchor constraintEqualToAnchor:self.containerView.trailingAnchor constant:-16],
        [self.chartView.heightAnchor constraintEqualToConstant:80],
        
        [self.metricsStackView.topAnchor constraintEqualToAnchor:self.chartView.bottomAnchor constant:16],
        [self.metricsStackView.leadingAnchor constraintEqualToAnchor:self.containerView.leadingAnchor constant:16],
        [self.metricsStackView.trailingAnchor constraintEqualToAnchor:self.containerView.trailingAnchor constant:-16],
        
        [self.tagsStackView.topAnchor constraintEqualToAnchor:self.metricsStackView.bottomAnchor constant:12],
        [self.tagsStackView.leadingAnchor constraintEqualToAnchor:self.containerView.leadingAnchor constant:16],
        
        [self.engagementStackView.topAnchor constraintEqualToAnchor:self.tagsStackView.bottomAnchor constant:12],
        [self.engagementStackView.leadingAnchor constraintEqualToAnchor:self.containerView.leadingAnchor constant:16],
        [self.engagementStackView.trailingAnchor constraintEqualToAnchor:self.containerView.trailingAnchor constant:-16],
        
        [self.takeToChatButton.topAnchor constraintEqualToAnchor:self.engagementStackView.bottomAnchor constant:16],
        [self.takeToChatButton.leadingAnchor constraintEqualToAnchor:self.containerView.leadingAnchor constant:16],
        [self.takeToChatButton.trailingAnchor constraintEqualToAnchor:self.containerView.centerXAnchor constant:-8],
        [self.takeToChatButton.heightAnchor constraintEqualToConstant:44],
        [self.takeToChatButton.bottomAnchor constraintEqualToAnchor:self.containerView.bottomAnchor constant:-16],
        
        [self.followButton.topAnchor constraintEqualToAnchor:self.takeToChatButton.topAnchor],
        [self.followButton.leadingAnchor constraintEqualToAnchor:self.containerView.centerXAnchor constant:8],
        [self.followButton.trailingAnchor constraintEqualToAnchor:self.containerView.trailingAnchor constant:-16],
        [self.followButton.heightAnchor constraintEqualToConstant:44]
    ]];
}

- (void)setupMetrics {
    self.metricsStackView = [[UIStackView alloc] init];
    self.metricsStackView.axis = UILayoutConstraintAxisHorizontal;
    self.metricsStackView.distribution = UIStackViewDistributionFillEqually;
    self.metricsStackView.spacing = 12;
    self.metricsStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:self.metricsStackView];
    
    NSArray *metrics = @[
        @{@"label": [LocalizationHelper localized:@"strategies.annual.return"], @"value": [NSString stringWithFormat:@"+%.1f%%", self.strategy.performance.annualReturn]},
        @{@"label": [LocalizationHelper localized:@"strategies.max.drawdown"], @"value": [NSString stringWithFormat:@"%.1f%%", self.strategy.performance.maxDrawdown]},
        @{@"label": [LocalizationHelper localized:@"strategies.sharpe.ratio"], @"value": [NSString stringWithFormat:@"%.2f", self.strategy.performance.sharpeRatio]},
        @{@"label": [LocalizationHelper localized:@"strategies.win.rate"], @"value": [NSString stringWithFormat:@"%.0f%%", self.strategy.performance.winRate]}
    ];
    
    for (NSDictionary *metric in metrics) {
        UIView *view = [self createMetricViewWithLabel:metric[@"label"] value:metric[@"value"]];
        [self.metricsStackView addArrangedSubview:view];
    }
}

- (UIView *)createMetricViewWithLabel:(NSString *)label value:(NSString *)value {
    UIView *container = [[UIView alloc] init];
    container.translatesAutoresizingMaskIntoConstraints = NO;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = label;
    titleLabel.font = [UIFont systemFontOfSize:11];
    titleLabel.textColor = [UIColor grayColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    UILabel *valueLabel = [[UILabel alloc] init];
    valueLabel.text = value;
    valueLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    
    if ([value hasPrefix:@"+"]) {
        valueLabel.textColor = [UIColor colorWithRed:0.3 green:0.8 blue:0.4 alpha:1.0];
    } else if ([value hasPrefix:@"-"]) {
        valueLabel.textColor = [UIColor colorWithRed:0.8 green:0.3 blue:0.3 alpha:1.0];
    } else {
        valueLabel.textColor = [UIColor whiteColor];
    }
    
    valueLabel.textAlignment = NSTextAlignmentCenter;
    valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [container addSubview:valueLabel];
    [container addSubview:titleLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [valueLabel.topAnchor constraintEqualToAnchor:container.topAnchor],
        [valueLabel.centerXAnchor constraintEqualToAnchor:container.centerXAnchor],
        
        [titleLabel.topAnchor constraintEqualToAnchor:valueLabel.bottomAnchor constant:4],
        [titleLabel.centerXAnchor constraintEqualToAnchor:container.centerXAnchor],
        [titleLabel.bottomAnchor constraintEqualToAnchor:container.bottomAnchor]
    ]];
    
    return container;
}

- (void)setupTags {
    self.tagsStackView = [[UIStackView alloc] init];
    self.tagsStackView.axis = UILayoutConstraintAxisHorizontal;
    self.tagsStackView.spacing = 8;
    self.tagsStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:self.tagsStackView];
    
    for (FAStrategyTag *tag in self.strategy.tags) {
        UILabel *tagLabel = [self createTagLabelWithText:tag.text type:tag.type];
        [self.tagsStackView addArrangedSubview:tagLabel];
    }
}

- (UILabel *)createTagLabelWithText:(NSString *)text type:(FAStrategyTagType)type {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.layer.cornerRadius = 12;
    label.clipsToBounds = YES;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    
    switch (type) {
        case FAStrategyTagTypeRisk:
            label.backgroundColor = [UIColor colorWithRed:0.6 green:0.3 blue:0.3 alpha:0.3];
            break;
        case FAStrategyTagTypeTerm:
            label.backgroundColor = [UIColor colorWithRed:0.3 green:0.4 blue:0.6 alpha:0.3];
            break;
        case FAStrategyTagTypeAsset:
            label.backgroundColor = [UIColor colorWithRed:0.5 green:0.3 blue:0.7 alpha:0.3];
            break;
    }
    
    [label.widthAnchor constraintGreaterThanOrEqualToConstant:60].active = YES;
    [label.heightAnchor constraintEqualToConstant:24].active = YES;
    
    return label;
}

- (void)setupEngagement {
    self.engagementStackView = [[UIStackView alloc] init];
    self.engagementStackView.axis = UILayoutConstraintAxisHorizontal;
    self.engagementStackView.spacing = 16;
    self.engagementStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:self.engagementStackView];
    
    // Likes
    UIView *likes = [self createEngagementLabelWithIcon:@"heart" count:self.strategy.engagement.likes];
    [self.engagementStackView addArrangedSubview:likes];
    
    // Comments
    UIView *comments = [self createEngagementLabelWithIcon:@"message" count:self.strategy.engagement.comments];
    [self.engagementStackView addArrangedSubview:comments];
    
    // Followers
    UIImageView *followersIcon = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"person.2"]];
    followersIcon.tintColor = [UIColor grayColor];
    followersIcon.translatesAutoresizingMaskIntoConstraints = NO;
    [followersIcon.widthAnchor constraintEqualToConstant:16].active = YES;
    
    UILabel *followersLabel = [[UILabel alloc] init];
    NSString *format = [LocalizationHelper localized:@"strategies.recent.followers"];
    followersLabel.text = [NSString stringWithFormat:format, (long)self.strategy.engagement.recentFollowers];
    followersLabel.font = [UIFont systemFontOfSize:12];
    followersLabel.textColor = [UIColor grayColor];
    followersLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.engagementStackView addArrangedSubview:followersIcon];
    [self.engagementStackView addArrangedSubview:followersLabel];
    
    UIView *spacer = [[UIView alloc] init];
    [spacer setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.engagementStackView addArrangedSubview:spacer];
}

- (UIView *)createEngagementLabelWithIcon:(NSString *)icon count:(NSInteger)count {
    UIView *container = [[UIView alloc] init];
    container.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:icon]];
    iconView.tintColor = [UIColor grayColor];
    iconView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UILabel *label = [[UILabel alloc] init];
    label.text = [NSString stringWithFormat:@"%ld", (long)count];
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [UIColor grayColor];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    
    [container addSubview:iconView];
    [container addSubview:label];
    
    [NSLayoutConstraint activateConstraints:@[
        [iconView.leadingAnchor constraintEqualToAnchor:container.leadingAnchor],
        [iconView.centerYAnchor constraintEqualToAnchor:container.centerYAnchor],
        [iconView.widthAnchor constraintEqualToConstant:16],
        
        [label.leadingAnchor constraintEqualToAnchor:iconView.trailingAnchor constant:4],
        [label.centerYAnchor constraintEqualToAnchor:container.centerYAnchor],
        [label.trailingAnchor constraintEqualToAnchor:container.trailingAnchor]
    ]];
    
    return container;
}

- (void)setupButtons {
    self.takeToChatButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.takeToChatButton setTitle:[LocalizationHelper localized:@"strategies.take.to.chat"] forState:UIControlStateNormal];
    self.takeToChatButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    [self.takeToChatButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.takeToChatButton.backgroundColor = [UIColor colorWithRed:0.46 green:0.42 blue:1.00 alpha:1.00];
    self.takeToChatButton.layer.cornerRadius = 8;
    self.takeToChatButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.takeToChatButton addTarget:self action:@selector(takeToChatTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.takeToChatButton];
    
    self.followButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.followButton setTitle:[LocalizationHelper localized:@"strategies.follow"] forState:UIControlStateNormal];
    self.followButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    [self.followButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.followButton.backgroundColor = [UIColor colorWithWhite:0.25 alpha:1.0];
    self.followButton.layer.cornerRadius = 8;
    self.followButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:self.followButton];
}

- (void)takeToChatTapped {
    if (self.delegate && [self.delegate respondsToSelector:@selector(strategyCardDidTapTakeToChat:strategy:)]) {
        [self.delegate strategyCardDidTapTakeToChat:self strategy:self.strategy];
    }
}

@end
