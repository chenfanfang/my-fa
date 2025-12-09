//
//  WealthService.swift
//  MyFA
//
//  Mock Wealth Management Service
//  Manages portfolio state and simulated market data
//

import Foundation

class WealthService {
    static let shared = WealthService()
    
    private init() {
        // Initialize with mock data
        setupMockData()
    }
    
    // MARK: - State
    
    @Published var portfolio: Portfolio = Portfolio(cashBalance: 100000.0, holdings: [])
    @Published var marketData: [String: MarketData] = [:]
    private(set) var transactions: [Transaction] = []
    
    // MARK: - Mock Setup
    
    private func setupMockData() {
        // 1. Define Assets
        let assets = [
            Asset(id: "bitcoin", symbol: "BTC", name: "Bitcoin", type: .crypto),
            Asset(id: "ethereum", symbol: "ETH", name: "Ethereum", type: .crypto),
            Asset(id: "solana", symbol: "SOL", name: "Solana", type: .crypto),
            Asset(id: "apple", symbol: "AAPL", name: "Apple Inc.", type: .stock),
            Asset(id: "tesla", symbol: "TSLA", name: "Tesla Inc.", type: .stock),
            Asset(id: "spy", symbol: "SPY", name: "S&P 500 ETF", type: .fund),
            Asset(id: "us_bond", symbol: "US10Y", name: "US Treasury 10Y", type: .bond)
        ]
        
        // 2. Setup Market Data (Simulated Prices)
        marketData = [
            "bitcoin": MarketData(assetId: "bitcoin", price: 65432.10, dailyChangePercentage: 2.5, lastUpdated: Date()),
            "ethereum": MarketData(assetId: "ethereum", price: 3456.78, dailyChangePercentage: -1.2, lastUpdated: Date()),
            "solana": MarketData(assetId: "solana", price: 145.50, dailyChangePercentage: 5.8, lastUpdated: Date()),
            "apple": MarketData(assetId: "apple", price: 189.50, dailyChangePercentage: 0.5, lastUpdated: Date()),
            "tesla": MarketData(assetId: "tesla", price: 178.20, dailyChangePercentage: -3.4, lastUpdated: Date()),
            "spy": MarketData(assetId: "spy", price: 510.30, dailyChangePercentage: 0.1, lastUpdated: Date()),
            "us_bond": MarketData(assetId: "us_bond", price: 98.50, dailyChangePercentage: 0.05, lastUpdated: Date())
        ]
        
        // 3. Setup Initial Holdings
        let initialHoldings = [
            Holding(id: UUID().uuidString, asset: assets[0], quantity: 0.5, averageCost: 60000.0), // BTC
            Holding(id: UUID().uuidString, asset: assets[3], quantity: 50, averageCost: 150.0),   // AAPL
            Holding(id: UUID().uuidString, asset: assets[5], quantity: 20, averageCost: 480.0)    // SPY
        ]
        
        portfolio = Portfolio(cashBalance: 50000.0, holdings: initialHoldings)
    }
    
    // MARK: - Public API
    
    func getAsset(symbol: String) -> Asset? {
        // Simple linear search for demo
        for holding in portfolio.holdings {
            if holding.asset.symbol.uppercased() == symbol.uppercased() {
                return holding.asset
            }
        }
        // Check known assets (in a real app, this would query a DB)
        // For now, we just recreate from our mock setup list if needed, 
        // but let's assume we only trade what we defined in setupMockData.
        // Re-defining the list locally for lookup:
        let assets = [
            Asset(id: "bitcoin", symbol: "BTC", name: "Bitcoin", type: .crypto),
            Asset(id: "ethereum", symbol: "ETH", name: "Ethereum", type: .crypto),
            Asset(id: "solana", symbol: "SOL", name: "Solana", type: .crypto),
            Asset(id: "apple", symbol: "AAPL", name: "Apple Inc.", type: .stock),
            Asset(id: "tesla", symbol: "TSLA", name: "Tesla Inc.", type: .stock),
            Asset(id: "spy", symbol: "SPY", name: "S&P 500 ETF", type: .fund),
            Asset(id: "us_bond", symbol: "US10Y", name: "US Treasury 10Y", type: .bond)
        ]
        return assets.first { $0.symbol.uppercased() == symbol.uppercased() }
    }
    
    func getPrice(assetId: String) -> Double? {
        return marketData[assetId]?.price
    }
    
    func getTotalValue() -> Double {
        var total = portfolio.cashBalance
        for holding in portfolio.holdings {
            if let price = marketData[holding.asset.id]?.price {
                total += holding.quantity * price
            }
        }
        return total
    }
    
    // MARK: - Actions
    
    func buy(assetId: String, quantity: Double) -> Bool {
        guard let price = getPrice(assetId: assetId) else { return false }
        let cost = price * quantity
        
        guard portfolio.cashBalance >= cost else { return false }
        
        // Update Cash
        portfolio.cashBalance -= cost
        
        // Update Holding
        if let index = portfolio.holdings.firstIndex(where: { $0.asset.id == assetId }) {
            var holding = portfolio.holdings[index]
            let totalCost = (holding.quantity * holding.averageCost) + cost
            holding.quantity += quantity
            holding.averageCost = totalCost / holding.quantity
            portfolio.holdings[index] = holding
        } else {
            // Find asset definition
            // (Simplified: In real app we fetch Asset by ID. Here we search our hardcoded list again or assume we have it)
             let assets = [
                Asset(id: "bitcoin", symbol: "BTC", name: "Bitcoin", type: .crypto),
                Asset(id: "ethereum", symbol: "ETH", name: "Ethereum", type: .crypto),
                Asset(id: "solana", symbol: "SOL", name: "Solana", type: .crypto),
                Asset(id: "apple", symbol: "AAPL", name: "Apple Inc.", type: .stock),
                Asset(id: "tesla", symbol: "TSLA", name: "Tesla Inc.", type: .stock),
                Asset(id: "spy", symbol: "SPY", name: "S&P 500 ETF", type: .fund),
                Asset(id: "us_bond", symbol: "US10Y", name: "US Treasury 10Y", type: .bond)
            ]
            guard let asset = assets.first(where: { $0.id == assetId }) else { return false }
            
            let newHolding = Holding(id: UUID().uuidString, asset: asset, quantity: quantity, averageCost: price)
            portfolio.holdings.append(newHolding)
        }
        
        // Record Transaction
        let transaction = Transaction(id: UUID(), assetId: assetId, type: .buy, amount: quantity, price: price, date: Date())
        transactions.append(transaction)
        
        return true
    }
    
    func sell(assetId: String, quantity: Double) -> Bool {
        guard let index = portfolio.holdings.firstIndex(where: { $0.asset.id == assetId }) else { return false }
        guard let price = getPrice(assetId: assetId) else { return false }
        
        var holding = portfolio.holdings[index]
        guard holding.quantity >= quantity else { return false }
        
        let revenue = quantity * price
        
        // Update Cash
        portfolio.cashBalance += revenue
        
        // Update Holding
        holding.quantity -= quantity
        if holding.quantity <= 0.000001 {
            portfolio.holdings.remove(at: index)
        } else {
            portfolio.holdings[index] = holding
        }
        
        // Record Transaction
        let transaction = Transaction(id: UUID(), assetId: assetId, type: .sell, amount: quantity, price: price, date: Date())
        transactions.append(transaction)
        
        return true
    }
}

