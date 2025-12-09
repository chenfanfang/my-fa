import UIKit
import FinClipChatKit

@objc public class FAChatViewControllerFactory: NSObject {
    
    @objc public static func createMainChatViewController(coordinator: Any) -> UIViewController {
        guard let coordinator = coordinator as? ChatKitCoordinator else {
            fatalError("Invalid coordinator type")
        }
        return MainChatViewController(coordinator: coordinator)
    }
    
    @objc public static func createDrawerViewController(coordinator: Any) -> UIViewController {
        guard let coordinator = coordinator as? ChatKitCoordinator else {
            fatalError("Invalid coordinator type")
        }
        let vc = DrawerViewController(coordinator: coordinator)
        // Note: The delegate must be set by the caller (DrawerContainer)
        // But DrawerContainer is now ObjC. 
        // DrawerViewController.drawerDelegate expects 'DrawerViewControllerDelegate' (Swift protocol).
        // Since we made the protocol @objc, ObjC can cast and set it.
        return vc
    }
}
