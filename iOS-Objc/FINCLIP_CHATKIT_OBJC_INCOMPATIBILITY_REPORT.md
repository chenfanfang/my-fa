# FinClipChatKit 对 Objective-C 不兼容性详细分析报告

本报告旨在为 `FinClipChatKit` 的作者提供具体的修改建议，以提高该库对 Objective-C 的兼容性。目前，我们在尝试将现有 Swift 项目的部分 UI 层迁移到 Objective-C 时遇到了以下阻碍。

## 1. 核心控制器不支持 Objective-C 继承

目前的主要痛点是无法在 Objective-C 中创建 `FinClipChatKit` 核心控制器的子类。

### 问题描述
Objective-C 仅支持继承 `NSObject` 的子类，并且该类必须通过 Objective-C Runtime 暴露（通常使用 `@objc` 修饰）。目前 `FinClipChatKit` 的核心控制器似乎是纯 Swift 类，或者其指定初始化器 (Designated Initializer) 使用了 Objective-C 不支持的 Swift 类型。

### 具体类与问题

#### 1.1 `ChatKitConversationViewController`
在 `ChatViewController.swift` 中，我们需要继承此类：
```swift
final class ChatViewController: ChatKitConversationViewController { ... }
```
**不兼容点:**
*   **类定义**: 该类可能没有被声明为 `open` 或没有加上 `@objc` 修饰，导致 Objective-C 无法识别并继承它。
*   **初始化方法**:
    ```swift
    init(record: FinClipChatKit.ConversationRecord, 
         conversation: NeuronKit.Conversation, 
         coordinator: ChatKitCoordinator, 
         configuration: ChatKitConversationConfiguration)
    ```
    *   `ConversationRecord` (FinClipChatKit): 如果它是 `struct`，则 Objective-C 无法使用。
    *   `NeuronKit.Conversation` (NeuronKit): 如果它是 `struct` 或纯 Swift `class`，Objective-C 无法使用。
    *   `ChatKitConversationConfiguration` (FinClipChatKit): 这是一个配置对象，很可能是 `struct`，导致初始化方法对 Objective-C 不可见。

#### 1.2 `ChatKitConversationListViewController`
在 `DrawerViewController.swift` 中，我们需要继承此类：
```swift
@objc public final class DrawerViewController: ChatKitConversationListViewController { ... }
```
**不兼容点:**
*   同上，初始化方法依赖 Swift 类型：
    ```swift
    init(coordinator: ChatKitCoordinator, configuration: ChatKitConversationListConfiguration)
    ```
    *   `ChatKitConversationListConfiguration`: 极有可能是 `struct`。

### 建议修改方案
1.  **暴露基类**: 确保 `ChatKitConversationViewController` 和 `ChatKitConversationListViewController` 是 `open` 的，并且如果可能，添加 `@objc` 修饰（如果它们继承自 `UIViewController`，通常已经是 `@objc`，但初始化器是关键）。
2.  **提供 Objective-C 友好的初始化器**:
    *   如果配置对象是 `struct`，请提供一个使用默认配置的便利初始化器，或者提供一个 Objective-C 兼容的配置类 (`NSObject` 子类)。
    *   如果参数如 `ConversationRecord` 是 Swift 类型，请提供封装器或替代的初始化方法。

#### 1.3 `MainChatViewController`
虽然它继承自 `UIViewController`，但其业务逻辑严重依赖 Swift 异步运行时。
```swift
@objc public final class MainChatViewController: UIViewController { ... }
```
**不兼容点:**
*   **Swift Concurrency (`async/await`)**:
    ```swift
    Task { @MainActor in
        let (record, conversation) = try await coordinator.startConversation(...)
        try await chatVC.currentConversation.sendMessage(...)
    }
    ```
    Objective-C 完全不支持 `async/await` 语法。虽然可以通过 `completionHandler` 桥接，但如果底层库 (`FinClipChatKit`, `NeuronKit`) 的 API 仅提供 `async` 版本而无 ObjC 兼容的 Block 版本，Objective-C 调用者将寸步难行。
*   **API 返回值**:
    `coordinator.startConversation` 返回元组 `(ConversationRecord, NeuronKit.Conversation)`。Objective-C 不支持 Swift 元组。

## 2. 配置对象与数据模型不支持 Objective-C

配置 `FinClipChatKit` 行为严重依赖 Swift 的 `struct` 和闭包 (Closure)，这使得在 Objective-C 中进行配置变得不可能。

### 具体类型与问题

#### 2.1 `ChatKitConversationConfiguration`
```swift
var config = ChatKitConversationConfiguration.default
config.welcomeMessageProvider = { "Welcome" } // Swift Closure
config.toolsProvider = { ... } // Swift Closure
config.promptStarterStyle = style // FinConvoPromptStarterStyle
```
**不兼容点:**
*   **Struct**: 如果这是一个 `struct`，Objective-C 完全不可见。
*   **闭包**: 即使是 Class，Swift 的闭包类型（如 `() -> String`）虽然可以桥接，但在 Objective-C 中配置属性通常期望 Block，且 `struct` 属性无法在 ObjC 中修改。
*   **`FinConvoPromptStarterStyle`**: 如果这也是 `struct`，则无法在 Objective-C 中创建和赋值。

#### 2.2 `NeuronKit` 类型
*   `NeuronKit.Conversation`: 核心模型，用于发送消息 (`sendMessage`)。如果这是纯 Swift 类或结构体，Objective-C 无法调用其方法。
*   `NeuronKitConfig`: 配置协调器时使用，使用了链式调用 (`.default(...).withUserId(...)`)。这种 Fluent Interface 在 Swift 中很常见，但如果返回类型不是 ObjC 对象，Objective-C 无法通过点语法调用。
*   `ChatKitContextItemFactory`: 用于创建上下文项 (`metadata` 等)。如果是 `enum` 命名空间或纯 Swift 静态方法，ObjC 无法使用。

#### 2.3 `ConvoUI` 类型
*   `FinConvoPromptStarterStyle`: 用于配置快捷指令样式。如果是 `struct`，无法在 ObjC 中初始化和设置属性。
*   `FinConvoPromptStarter`: 同样，如果是 `struct`，无法在 ObjC 中构建数组并传递。

### 建议修改方案
1.  **Objective-C 配置类**: 提供 `FNChatConfiguration` (继承自 `NSObject`) 类来镜像 `ChatKitConversationConfiguration` 的属性。
2.  **Builder 模式**: 如果链式调用很重要，请确保返回值是 Objective-C 兼容的对象。
3.  **异步桥接**: 为所有 `async` 方法提供带 `completionHandler` 的 `@objc` 版本。
    ```swift
    // Example
    @objc func startConversation(agentId: UUID, completion: @escaping (ConversationRecord?, Error?) -> Void)
    ```

## 3. 协议与委托 (Delegates & Protocols)

### 问题描述
`FinClipChatKit` 使用的协议可能包含了 Objective-C 不支持的特性。

#### 3.1 `ChatKitConversationListViewControllerDelegate`
```swift
func conversationListViewController(..., didSelectConversation record: ConversationRecord)
```
**不兼容点:**
*   参数 `ConversationRecord`: 如果是 `struct`，这个代理方法就无法在 Objective-C 中实现。Objective-C 的 Delegate 方法必须使用对象类型。

## 4. 扩展性接口 (Extensions & Plugins)

### 问题描述
`FinClipChatKit` 的插件系统（如 Context Providers, Tools）深度绑定 Swift 语言特性。

#### 4.1 Context Providers
`ChatViewController` 中配置了 `contextProvidersProvider`:
```swift
config.contextProvidersProvider = {
    [ConvoUIContextProviderBridge(provider: ...)]
}
```
*   `FinConvoComposerContextProvider`: 这是一个协议。如果它包含 `associatedtype` 或使用了 `async` 方法，则无法被 Objective-C 类实现。
*   `ConvoUIContextProviderBridge`: 这是一个泛型类或 Swift 类，用于桥接，Objective-C 可能无法直接实例化它。

### 建议修改方案
1.  **Type Erasure / AnyWrapper**: 为 Context Provider 提供一个非泛型的、Objective-C 兼容的基类或包装器。
2.  **Block-based API**: 允许通过 Objective-C Block 提供上下文数据，而不是强制实现复杂的 Swift 协议。

## 总结

要使 `FinClipChatKit` 支持 Objective-C，核心不仅仅是添加 `@objc`，而是需要解决以下架构层面的问题：

1.  **初始化入口**: 提供不依赖 Swift `struct` 的初始化方法 (`initWithCoordinator:config:`)。
2.  **配置对象**: 将配置结构体 (`struct`) 包装为类 (`class`) 或提供替代的 Objective-C 配置对象。
3.  **核心模型**: 确保 `ConversationRecord` 等核心数据模型是类 (`class`) 或者提供 Objective-C 包装器 (`wrapper`)。
4.  **异步/闭包**: 为 Swift 的闭包属性提供对应的 Block 属性设置器。

如果没有这些修改，现有的 Objective-C 项目（如本案例）只能通过编写复杂的 Swift 中间层（Wrapper/Bridge）来间接使用 `FinClipChatKit`，这增加了集成成本和维护难度。
