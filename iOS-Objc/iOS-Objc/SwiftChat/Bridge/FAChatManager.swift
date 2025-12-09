import UIKit
import FinClipChatKit

@objc public class FAChatManager: NSObject {
    private let coordinator: ChatKitCoordinator
    
    @objc public static let shared = FAChatManager()
    
    override private init() {
        let config = NeuronKitConfig.default(serverURL: URL(string: FAAppConfig.defaultServerURL())!)
            .withUserId(FAAppConfig.defaultUserId())
        self.coordinator = ChatKitCoordinator(config: config)
        super.init()
    }
    
    @objc public func createDrawerContainer() -> UIViewController {
        return FADrawerContainerViewController(coordinator: coordinator)
    }
    
    @objc public func navigateToChat(message: String?, context: [String: Any]?, from viewController: UIViewController) {
        if let tabBarController = viewController.tabBarController {
             tabBarController.selectedIndex = 0
             if let nav = tabBarController.viewControllers?.first as? UINavigationController,
                let drawer = nav.viewControllers.first as? FADrawerContainerViewController {
                 
                 drawer.toggleDrawer(false)
                 drawer.createNewConversation(withMessage: message, context: context)
             }
        }
    }
}
