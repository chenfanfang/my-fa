import ConvoUI

enum ChatContextProviderFactory {
    @MainActor
    static func makeDefaultProviders() -> [FinConvoComposerContextProvider] {
        guard #available(iOS 15.0, *) else { return [] }
        return [
            ConvoUIContextProviderBridge(provider: StockContextProvider()),
            ConvoUIContextProviderBridge(provider: AttachmentContextProvider()),
            ConvoUIContextProviderBridge(provider: LocationContextProvider()),
            ConvoUIContextProviderBridge(provider: CalendarContextProvider()),
            ConvoUIContextProviderBridge(provider: PortfolioContextProvider())
        ]
    }
}
