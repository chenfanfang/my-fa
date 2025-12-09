import UIKit
import FinClipChatKit

@objc public class FAChatManager: NSObject {
    private let coordinator: ChatKitCoordinator
    
    @objc public static let shared = FAChatManager()
    
    override private init() {
        let config = NeuronKitConfig.default(serverURL: AppConfig.defaultServerURL)
            .withUserId(AppConfig.defaultUserId)
        self.coordinator = ChatKitCoordinator(config: config)
        super.init()
    }
    
    @objc public func createDrawerContainer() -> UIViewController {
        return DrawerContainerViewController(coordinator: coordinator)
    }
    
    @objc public func navigateToChat(message: String?, context: [String: Any]?, from viewController: UIViewController) {
        if let tabBarController = viewController.tabBarController {
             tabBarController.selectedIndex = 0
             if let nav = tabBarController.viewControllers?.first as? UINavigationController,
                let drawer = nav.viewControllers.first as? DrawerContainerViewController {
                 
                 drawer.toggleDrawer(open: false)
                 drawer.createNewConversation(withMessage: message, context: context)
             }
        }
    }
}
