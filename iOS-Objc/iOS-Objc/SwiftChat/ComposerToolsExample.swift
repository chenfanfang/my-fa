//
//  ComposerToolsExample.swift
//  MyFA
//
//  Example showing how to register and use composer tools with logos
//  Tools represent external services that can be invoked to fulfill user requests
//

import UIKit
import ConvoUI

/// Example: Register tools/services with logos in the composer
/// Tools are external services (APIs, platforms) that the LLM can use to answer user queries
class ComposerToolsExample {
    
    static func image(named name: String) -> UIImage? {
        return UIImage(named: name) ?? UIImage(named: name, in: LocalizationHelper.resourceBundle, compatibleWith: nil)
    }

    /// Create example composer tools with logos
    /// These represent real services that can be called to fulfill user requests
    static func createExampleTools() -> [FinConvoComposerTool] {
        var tools: [FinConvoComposerTool] = []
        
        // Example 1: CoinGecko - Crypto Market Data
        // Using generic "bitcoinsign.circle.fill" if custom image not found
        let coingeckoLogo = image(named: "tool_coingecko") ?? UIImage(systemName: "bitcoinsign.circle.fill")?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal)
        let coingeckoTool = FinConvoComposerTool(
            itemId: "coingecko",
            displayName: "CoinGecko",
            logoImage: coingeckoLogo
        )
        coingeckoTool.badgeColor = .systemGreen
        coingeckoTool.metadata = [
            "endpoint": "https://api.coingecko.com/api/v3",
            "service": "crypto_data",
            "description": "Real-time cryptocurrency prices, charts, and market data",
            "capabilities": ["price", "charts", "market-cap", "volume"]
        ]
        tools.append(coingeckoTool)
        
        // Example 2: Yahoo Finance - Stock Market Data
        let yahooLogo = image(named: "tool_yahoo") ?? UIImage(systemName: "chart.line.uptrend.xyaxis.circle.fill")?.withTintColor(.systemPurple, renderingMode: .alwaysOriginal)
        let yahooTool = FinConvoComposerTool(
            itemId: "yahoo_finance",
            displayName: "Yahoo Finance",
            logoImage: yahooLogo
        )
        yahooTool.badgeColor = .systemPurple
        yahooTool.metadata = [
            "endpoint": "https://finance.yahoo.com/api",
            "service": "stock_data",
            "description": "Stock market data, news, and portfolio tracking",
            "capabilities": ["quotes", "news", "analysis", "options"]
        ]
        tools.append(yahooTool)
        
        // Example 3: Bloomberg - Financial News
        let bloombergLogo = image(named: "tool_bloomberg") ?? UIImage(systemName: "newspaper.circle.fill")?.withTintColor(.black, renderingMode: .alwaysOriginal)
        let bloombergTool = FinConvoComposerTool(
            itemId: "bloomberg",
            displayName: "Bloomberg",
            logoImage: bloombergLogo
        )
        bloombergTool.badgeColor = .black
        bloombergTool.metadata = [
            "endpoint": "https://api.bloomberg.com",
            "service": "financial_news",
            "description": "Global business and financial news, market analysis",
            "capabilities": ["news", "analysis", "market-trends"]
        ]
        tools.append(bloombergTool)
        
        // Example 4: Morningstar - Investment Research
        let morningstarLogo = image(named: "tool_morningstar") ?? UIImage(systemName: "star.circle.fill")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal)
        let morningstarTool = FinConvoComposerTool(
            itemId: "morningstar",
            displayName: "Morningstar",
            logoImage: morningstarLogo
        )
        morningstarTool.badgeColor = .systemRed
        morningstarTool.metadata = [
            "endpoint": "https://api.morningstar.com",
            "service": "investment_research",
            "description": "Independent investment research and fund ratings",
            "capabilities": ["ratings", "funds", "etfs", "research"]
        ]
        tools.append(morningstarTool)
        
        return tools
    }
    
    
    /// Example: Handle composer tool selection
    /// When a user selects a tool, it will be included with their message
    static func handleComposerToolSelected(_ tool: FinConvoComposerTool) {
        print("✅ Tool selected for this message: \(tool.displayName) (ID: \(tool.itemId))")
        
        if let metadata = tool.metadata as? [String: Any] {
            print("   Service: \(metadata["service"] ?? "N/A")")
            print("   Endpoint: \(metadata["endpoint"] ?? "N/A")")
            print("   Description: \(metadata["description"] ?? "N/A")")
            if let capabilities = metadata["capabilities"] as? [String] {
                print("   Capabilities: \(capabilities.joined(separator: ", "))")
            }
        }
        
        // The selected tool will be sent with the user's message to the backend
        // The LLM can then use this tool to fulfill the user's request
        // Example: User says "How is BTC doing?" + selects CoinGecko
        //          → Backend/LLM uses CoinGecko API to get BTC price
    }
    
    /// Example: Update a composer tool dynamically
    static func updateComposerTool(_ chatView: FinConvoChatView, itemId: String, newDisplayName: String) {
        let updatedTool = FinConvoComposerTool(
            itemId: itemId,
            displayName: newDisplayName,
            logoImage: UIImage(systemName: "star.fill")?.withTintColor(.systemYellow, renderingMode: .alwaysOriginal)
        )
        updatedTool.badgeColor = .systemYellow
        
        chatView.update(updatedTool)
        print("✅ Updated composer tool: \(itemId) → \(newDisplayName)")
    }
    
    /// Example: Remove a composer tool
    static func removeComposerTool(_ chatView: FinConvoChatView, itemId: String) {
        chatView.removeComposerTool(withId: itemId)
        print("✅ Removed composer tool: \(itemId)")
    }
    
    /// Example: Get all registered tools
    static func listComposerTools(_ chatView: FinConvoChatView) {
        let tools = chatView.registeredComposerTools()
        print("📋 Registered composer tools (\(tools.count)):")
        for tool in tools {
            print("   - \(tool.displayName) (ID: \(tool.itemId))")
        }
    }
}
