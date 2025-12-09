import Foundation

@objc public protocol ChatNavigationDelegate: AnyObject {
    func navigateToChat(message: String?, context: [String : Any]?)
}

