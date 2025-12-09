import UIKit
import FinClipChatKit
import ConvoUI
import NeuronKit

/// Simplified ChatViewController using ChatKitConversationViewController
///
/// This is now a thin wrapper that configures ChatKitConversationViewController
/// with app-specific settings (welcome message, tools, context providers).
final class ChatViewController: ChatKitConversationViewController {
    private var dsObserver: NSObjectProtocol?
    var starterId:Int = 0
    
  init(record: FinClipChatKit.ConversationRecord, conversation: NeuronKit.Conversation, coordinator: ChatKitCoordinator) {
      // Configure with app-specific settings
      var config = ChatKitConversationConfiguration.default
      config.showStatusBanner = true
      config.showWelcomeMessage = true
      config.welcomeMessageProvider = { LocalizationHelper.localized("app.welcome") }
      config.toolsProvider = { ComposerToolsExample.createExampleTools() }
      // Wrap in MainActor.assumeIsolated since this init is called from MainActor context
      config.contextProvidersProvider = {
          MainActor.assumeIsolated {
              ChatContextProviderFactory.makeDefaultProviders()
          }
      }
      config.statusBannerAutoHide = true
      config.statusBannerAutoHideDelay = 2.0
      //提示词
      config.onPromptStarterSelected = { starter in
          // 不自动发送
          return true
      }
      config.promptStarterInsertToComposerOnTap = true
      config.promptStarterBehaviorMode = .manual
      // 自定义样式
      let style = FinConvoPromptStarterStyle()
      style.titleFont = UIFont.systemFont(ofSize: 13)
      style.iconSize = CGSizeMake(0, 0)
      style.textColor = .white
      style.subtitleTextColor = .white
      style.backgroundColor = UIColor(red: 35.0 / 255.0, green: 36.0 / 255.0, blue: 57.0 / 255.0, alpha: 0.5)
      style.cornerRadius = 12.0
      style.contentInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
      style.minimumHeight = 30
      style.verticalSpacing = 6.0
      config.promptStarterStyle = style
    
      super.init(record: record, conversation: conversation, coordinator: coordinator, configuration: config)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  var sessionIdentifier: UUID {
    record.id
  }
  
  // Expose conversation for programmatic message sending
  var currentConversation: NeuronKit.Conversation {
    conversation
  }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dsObserver = NotificationCenter.default.addObserver(forName: .DSChatStartersReady, object: nil, queue: .main) { [weak self] n in
            guard let _ = self else { return }
            let starters = n.userInfo?["starters"] as? [String] ?? []
            let prompts = starters.enumerated().map { idx, title in
                self?.starterId += 1
                return FinConvoPromptStarter(starterId: "\(String(describing: self!.starterId))", title: title)
            }
            let promptsSnapshot = prompts
            self?.chatView.setPromptStarters(promptsSnapshot)
            self?.chatView.showPromptStarters()
            
            let name = n.userInfo?["name"] as? String ?? ""
            let symbol = n.userInfo?["symbol"] as? String ?? ""
            print("[ChatHome] DeepSeek starters for \(name)(\(symbol)):")
            starters.forEach { print("  • \($0)") }
        }
        
    }
    
    deinit {
        if let t = dsObserver { NotificationCenter.default.removeObserver(t) }
    }
}
