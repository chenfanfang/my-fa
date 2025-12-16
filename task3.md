- Objective-C 项目是执行了task.md和 task2.md的任务生成的。
- 下面的代码崩溃
  ```
    @objc public func createNewConversation(withMessage message: String? = nil, context: [String: Any]? = nil) {
    Task { @MainActor in
      do {
        let (record, conversation) = try await coordinator.startConversation(
          agentId: UUID(uuidString: FAAppConfig.defaultAgentId())!,
          title: nil,
          agentName: FAAppConfig.defaultAgentName()
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
        showAlert(title: FALocalizationHelper.localized("app.error"), message: FALocalizationHelper.localized("error.create.conversation"))
      }
    }
  }

  崩溃在: UUID(uuidString: FAAppConfig.defaultAgentId())!
  崩溃原因: Task 5: Swift runtime failure: Unexpectedly found nil while unwrapping an Optional value
  ```
  
- 请你分析上下文和 task.md、task2.md 中的任务内容。帮我解决此崩溃