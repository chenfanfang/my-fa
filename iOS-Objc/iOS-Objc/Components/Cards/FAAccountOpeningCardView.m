#import "FAAccountOpeningCardView.h"
#import "iOS_Objc-Swift.h"

@interface FAAccountOpeningCardView ()

@property (nonatomic, copy) NSArray<NSString *> *steps;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIStackView *stepsStackView;

@end

@implementation FAAccountOpeningCardView

- (instancetype)initWithSteps:(NSArray<NSString *> *)steps {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _steps = [steps copy];
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
    self.containerView.layer.borderWidth = 1;
    self.containerView.layer.borderColor = [UIColor colorWithWhite:0.25 alpha:1.0].CGColor;
    [self addSubview:self.containerView];
    
    // Title
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = [LocalizationHelper localized:@"assets.opening.title"];
    self.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    self.titleLabel.textColor = [UIColor lightGrayColor];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:self.titleLabel];
    
    // Steps Stack
    self.stepsStackView = [[UIStackView alloc] init];
    self.stepsStackView.axis = UILayoutConstraintAxisVertical;
    self.stepsStackView.spacing = 12;
    self.stepsStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:self.stepsStackView];
    
    for (NSUInteger i = 0; i < self.steps.count; i++) {
        UIView *stepView = [self createStepViewWithNumber:i + 1 text:self.steps[i]];
        [self.stepsStackView addArrangedSubview:stepView];
    }
    
    [NSLayoutConstraint activateConstraints:@[
        [self.containerView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.containerView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.containerView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.containerView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        
        [self.titleLabel.topAnchor constraintEqualToAnchor:self.containerView.topAnchor constant:16],
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.containerView.leadingAnchor constant:16],
        [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.containerView.trailingAnchor constant:-16],
        
        [self.stepsStackView.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:16],
        [self.stepsStackView.leadingAnchor constraintEqualToAnchor:self.containerView.leadingAnchor constant:16],
        [self.stepsStackView.trailingAnchor constraintEqualToAnchor:self.containerView.trailingAnchor constant:-16],
        [self.stepsStackView.bottomAnchor constraintEqualToAnchor:self.containerView.bottomAnchor constant:-16]
    ]];
}

- (UIView *)createStepViewWithNumber:(NSUInteger)number text:(NSString *)text {
    UIView *container = [[UIView alloc] init];
    container.translatesAutoresizingMaskIntoConstraints = NO;
    
    UILabel *numberLabel = [[UILabel alloc] init];
    numberLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)number];
    numberLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    numberLabel.textColor = [UIColor whiteColor];
    numberLabel.textAlignment = NSTextAlignmentCenter;
    numberLabel.backgroundColor = [UIColor colorWithWhite:0.25 alpha:1.0];
    numberLabel.layer.cornerRadius = 14;
    numberLabel.clipsToBounds = YES;
    numberLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [container addSubview:numberLabel];
    
    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.text = text;
    textLabel.font = [UIFont systemFontOfSize:14];
    textLabel.textColor = [UIColor whiteColor];
    textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [container addSubview:textLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [numberLabel.leadingAnchor constraintEqualToAnchor:container.leadingAnchor],
        [numberLabel.centerYAnchor constraintEqualToAnchor:container.centerYAnchor],
        [numberLabel.widthAnchor constraintEqualToConstant:28],
        [numberLabel.heightAnchor constraintEqualToConstant:28],
        
        [textLabel.leadingAnchor constraintEqualToAnchor:numberLabel.trailingAnchor constant:12],
        [textLabel.centerYAnchor constraintEqualToAnchor:container.centerYAnchor],
        [textLabel.trailingAnchor constraintEqualToAnchor:container.trailingAnchor],
        
        [container.heightAnchor constraintEqualToConstant:32]
    ]];
    
    return container;
}

@end
