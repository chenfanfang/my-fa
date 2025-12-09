#import "FADrawerContainerViewController.h"
#import "iOS_Objc-Swift.h"

// Forward declare Swift classes/protocols if needed, but imported header handles it.
// We need to know MainChatViewController and DrawerViewController interface.
// Since they are Swift, they are in iOS_Objc-Swift.h IF they are @objc.

@interface FADrawerContainerViewController () <DrawerViewControllerDelegate>

@property (nonatomic, strong) id coordinator;
@property (nonatomic, strong) UIViewController *drawerViewController;
@property (nonatomic, strong) UIViewController *mainViewController;

@property (nonatomic, assign) CGFloat drawerGap;
@property (nonatomic, strong) NSLayoutConstraint *drawerLeadingConstraint;
@property (nonatomic, strong) NSLayoutConstraint *drawerWidthConstraint;
@property (nonatomic, assign) BOOL isDrawerOpen;
@property (nonatomic, strong) UIView *overlayView;

@end

@implementation FADrawerContainerViewController

- (instancetype)initWithCoordinator:(id)coordinator {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _coordinator = coordinator;
        _drawerGap = 80.0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    // Create VCs via Factory
    self.mainViewController = [FAChatViewControllerFactory createMainChatViewControllerWithCoordinator:self.coordinator];
    self.drawerViewController = [FAChatViewControllerFactory createDrawerViewControllerWithCoordinator:self.coordinator];
    
    // Set Delegate for Drawer
    // Assuming DrawerViewController is exposed as a class with 'drawerDelegate' property
    // Swift: weak var drawerDelegate: DrawerViewControllerDelegate?
    // ObjC: properties are exposed if class is @objc.
    // We need to cast to DrawerViewController (Swift class)
    // But we don't have the header for it unless we import -Swift.h. We did.
    // However, createDrawerViewController returns UIViewController. Cast it.
    
    if ([self.drawerViewController isKindOfClass:[DrawerViewController class]]) {
        ((DrawerViewController *)self.drawerViewController).drawerDelegate = self;
    }
    
    // Add Main View
    [self addChildViewController:self.mainViewController];
    [self.view addSubview:self.mainViewController.view];
    self.mainViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.mainViewController didMoveToParentViewController:self];
    
    // Overlay
    self.overlayView = [[UIView alloc] init];
    self.overlayView.translatesAutoresizingMaskIntoConstraints = NO;
    self.overlayView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    self.overlayView.alpha = 0;
    self.overlayView.hidden = YES;
    self.overlayView.userInteractionEnabled = NO;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(overlayTapped)];
    [self.overlayView addGestureRecognizer:tap];
    [self.view addSubview:self.overlayView];
    
    // Add Drawer
    [self addChildViewController:self.drawerViewController];
    [self.view addSubview:self.drawerViewController.view];
    self.drawerViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.drawerViewController didMoveToParentViewController:self];
    
    // Constraints
    CGFloat initialWidth = [UIScreen mainScreen].bounds.size.width - self.drawerGap;
    
    self.drawerLeadingConstraint = [self.drawerViewController.view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:-initialWidth];
    self.drawerWidthConstraint = [self.drawerViewController.view.widthAnchor constraintEqualToAnchor:self.view.widthAnchor constant:-self.drawerGap];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.mainViewController.view.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.mainViewController.view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.mainViewController.view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.mainViewController.view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        
        [self.overlayView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.overlayView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.overlayView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.overlayView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        
        self.drawerLeadingConstraint,
        self.drawerWidthConstraint,
        [self.drawerViewController.view.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.drawerViewController.view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
}

- (void)toggleDrawer {
    [self setDrawerOpen:!self.isDrawerOpen];
}

- (void)toggleDrawer:(BOOL)open {
    [self setDrawerOpen:open];
}

- (void)createNewConversationWithMessage:(nullable NSString *)message context:(nullable NSDictionary<NSString *, id> *)context {
    if ([self.mainViewController isKindOfClass:[MainChatViewController class]]) {
        [(MainChatViewController *)self.mainViewController createNewConversationWithMessage:message context:context];
    }
}

- (void)setDrawerOpen:(BOOL)open {
    if (open == self.isDrawerOpen) return;
    
    self.isDrawerOpen = open;
    if (open) {
        self.overlayView.hidden = NO;
        self.overlayView.userInteractionEnabled = YES;
    }
    
    self.drawerLeadingConstraint.constant = open ? 0 : -[self currentDrawerWidth];
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.view layoutIfNeeded];
        self.mainViewController.view.alpha = open ? 0.3 : 1.0;
        self.overlayView.alpha = open ? 1.0 : 0.0;
    } completion:^(BOOL finished) {
        if (!open) {
            self.overlayView.hidden = YES;
            self.overlayView.userInteractionEnabled = NO;
        }
    }];
}

- (void)overlayTapped {
    [self setDrawerOpen:NO];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.drawerLeadingConstraint.constant = self.isDrawerOpen ? 0 : -[self currentDrawerWidth];
}

- (CGFloat)currentDrawerWidth {
    return MAX(0, self.view.bounds.size.width - self.drawerGap);
}

#pragma mark - DrawerViewControllerDelegate

- (void)drawerDidRequestToggle {
    [self toggleDrawer];
}

- (void)drawerDidSelectConversationWithSessionId:(NSUUID *)sessionId {
    [self toggleDrawer];
    if ([self.mainViewController isKindOfClass:[MainChatViewController class]]) {
        [(MainChatViewController *)self.mainViewController switchToConversationWithSessionId:sessionId];
    }
}

- (void)drawerDidRequestNewConversation {
    [self toggleDrawer];
    if ([self.mainViewController isKindOfClass:[MainChatViewController class]]) {
        [(MainChatViewController *)self.mainViewController createNewConversationWithMessage:nil context:nil];
    }
}

@end
