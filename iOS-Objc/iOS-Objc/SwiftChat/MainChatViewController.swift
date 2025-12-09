import UIKit
import Combine
import FinClipChatKit

final class MainChatViewController: UIViewController {
  private let coordinator: ChatKitCoordinator
  private var currentChatVC: ChatViewController?
  private var cancellables = Set<AnyCancellable>()
  
  // Top bar
  private lazy var topBarView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .systemBackground
    return view
  }()
  
  private lazy var hamburgerButton: UIButton = {
    let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
    let image = UIImage(systemName: "line.3.horizontal", withConfiguration: config)
    let button = UIButton(type: .system)
    button.setImage(image, for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(hamburgerTapped), for: .touchUpInside)
    return button
  }()
  
  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.text = LocalizationHelper.localized("chat.agent.title")
    label.font = .systemFont(ofSize: 18, weight: .semibold)
    label.textAlignment = .center
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private lazy var addButton: UIButton = {
    let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
    let image = UIImage(systemName: "plus", withConfiguration: config)
    let button = UIButton(type: .system)
    button.setImage(image, for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    return button
  }()
  
  
  // Chat container
  private lazy var chatContainerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .systemBackground
    return view
  }()
  
  
  // Empty state
  private lazy var emptyStateView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .systemBackground
    
    let label = UILabel()
    label.text = LocalizationHelper.localized("chat.empty.state")
    label.numberOfLines = 0
    label.textAlignment = .center
    label.font = .systemFont(ofSize: 20, weight: .medium)
    label.textColor = .secondaryLabel
    label.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(label)
    NSLayoutConstraint.activate([
      label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
      label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
    ])
    
    return view
  }()
  
  init(coordinator: ChatKitCoordinator) {
    self.coordinator = coordinator
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    showEmptyState()
    observeLanguageChanges()
  }
  
  private func observeLanguageChanges() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(languageDidChange),
      name: NSNotification.Name("LanguageChanged"),
      object: nil
    )
  }
  
  @objc private func languageDidChange() {
    titleLabel.text = LocalizationHelper.localized("chat.agent.title")
    if let label = emptyStateView.viewWithTag(999) as? UILabel {
      label.text = LocalizationHelper.localized("chat.empty.state")
    }
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  private func setupUI() {
    view.backgroundColor = .systemBackground
    
    // Top bar setup
    topBarView.addSubview(hamburgerButton)
    topBarView.addSubview(titleLabel)
    topBarView.addSubview(addButton)
    
    view.addSubview(topBarView)
    view.addSubview(chatContainerView)
    
    NSLayoutConstraint.activate([
      // Top bar
      topBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      topBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      topBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      topBarView.heightAnchor.constraint(equalToConstant: 60),
      
      hamburgerButton.leadingAnchor.constraint(equalTo: topBarView.leadingAnchor, constant: 16),
      hamburgerButton.centerYAnchor.constraint(equalTo: topBarView.centerYAnchor),
      
      titleLabel.centerXAnchor.constraint(equalTo: topBarView.centerXAnchor),
      titleLabel.centerYAnchor.constraint(equalTo: topBarView.centerYAnchor),
      
      addButton.trailingAnchor.constraint(equalTo: topBarView.trailingAnchor, constant: -16),
      addButton.centerYAnchor.constraint(equalTo: topBarView.centerYAnchor),
      
      // Chat container
      chatContainerView.topAnchor.constraint(equalTo: topBarView.bottomAnchor),
      chatContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      chatContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      chatContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
  
  private func showEmptyState() {
    chatContainerView.subviews.forEach { $0.removeFromSuperview() }
    chatContainerView.addSubview(emptyStateView)
    
    NSLayoutConstraint.activate([
      emptyStateView.topAnchor.constraint(equalTo: chatContainerView.topAnchor),
      emptyStateView.leadingAnchor.constraint(equalTo: chatContainerView.leadingAnchor),
      emptyStateView.trailingAnchor.constraint(equalTo: chatContainerView.trailingAnchor),
      emptyStateView.bottomAnchor.constraint(equalTo: chatContainerView.bottomAnchor)
    ])
  }
  
  func switchToConversation(sessionId: UUID) {
    Task { @MainActor in
    guard let conversation = coordinator.conversation(for: sessionId),
          let record = coordinator.record(for: sessionId) else {
      print("[MainChatViewController] Failed to load conversation \(sessionId)")
      return
    }
    if currentChatVC?.sessionIdentifier == sessionId {
      return
    }
    
    embedChatViewController(record: record, conversation: conversation)
    }
  }
  
  func createNewConversation(withMessage message: String? = nil, context: [String: Any]? = nil) {
    Task { @MainActor in
      do {
        let (record, conversation) = try await coordinator.startConversation(
          agentId: AppConfig.defaultAgentId,
          title: nil,
          agentName: AppConfig.defaultAgentName
        )
        embedChatViewController(record: record, conversation: conversation)
        
        // If we have an initial message, send it after the chat view is embedded
        if let message = message {
          // Give the chat view a moment to set up before sending
          try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
          await sendInitialMessage(message, context: context)
        }
      } catch {
        print("[MainChatViewController] Failed to create conversation: \(error)")
        showAlert(title: LocalizationHelper.localized("app.error"), message: LocalizationHelper.localized("error.create.conversation"))
      }
    }
  }
  
  private func sendInitialMessage(_ message: String, context: [String: Any]?) async {
    guard let chatVC = currentChatVC else { return }
    
    print("[MainChatViewController] Sending initial message: \(message)")
    if let context = context {
      print("[MainChatViewController] With context: \(context)")
    }
    
    // Send the message through the conversation
    do {
      if let context = context, !context.isEmpty {
        // Convert context dictionary to ConversationContextItem using ChatKit factory
        // This provides a unified way to attach context regardless of content type
        let contextType = context["type"] as? String ?? "metadata"
        let contextItem = ChatKitContextItemFactory.metadata(context, type: contextType)
        
        try await chatVC.currentConversation.sendMessage(message, contextItems: [contextItem])
        print("[MainChatViewController] Initial message sent successfully with context")
      } else {
        // Fallback to simple message without context
        try await chatVC.currentConversation.sendMessage(message)
        print("[MainChatViewController] Initial message sent successfully")
      }
    } catch {
      print("[MainChatViewController] Failed to send initial message: \(error)")
    }
  }
  
  private func showAlert(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: LocalizationHelper.localized("app.ok"), style: .default))
    present(alert, animated: true)
  }
  
  private func embedChatViewController(record: FinClipChatKit.ConversationRecord, conversation: NeuronKit.Conversation) {
    // Remove existing chat
    if let existing = currentChatVC {
      existing.willMove(toParent: nil)
      existing.beginAppearanceTransition(false, animated: false)
      existing.view.removeFromSuperview()
      existing.endAppearanceTransition()
      existing.removeFromParent()
    }
    
    // Add new chat
    let chatVC = ChatViewController(record: record, conversation: conversation, coordinator: coordinator)
    addChild(chatVC)
    chatVC.beginAppearanceTransition(true, animated: false)
    chatContainerView.addSubview(chatVC.view)
    chatVC.view.translatesAutoresizingMaskIntoConstraints = false
    chatVC.didMove(toParent: self)
    
    NSLayoutConstraint.activate([
      chatVC.view.topAnchor.constraint(equalTo: chatContainerView.topAnchor),
      chatVC.view.leadingAnchor.constraint(equalTo: chatContainerView.leadingAnchor),
      chatVC.view.trailingAnchor.constraint(equalTo: chatContainerView.trailingAnchor),
      chatVC.view.bottomAnchor.constraint(equalTo: chatContainerView.bottomAnchor)
    ])
    chatVC.endAppearanceTransition()
    
    currentChatVC = chatVC
    emptyStateView.removeFromSuperview()
  }
  
  @objc private func hamburgerTapped() {
    if let container = parent as? DrawerContainerViewController {
      container.toggleDrawer()
    }
  }
  
  @objc private func addButtonTapped() {
    createNewConversation()
  }
}
