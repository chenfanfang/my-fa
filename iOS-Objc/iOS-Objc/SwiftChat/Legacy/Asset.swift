//
//  Asset.swift
//  MyFA
//
//  Unified Asset Model supporting Stocks, Crypto, Funds, etc.
//

import Foundation

enum AssetType: String, Codable, CaseIterable {
    case stock
    case crypto
    case fund
    case bond
    case cash
    
    var displayName: String {
        switch self {
        case .stock: return "Stock"
        case .crypto: return "Crypto"
        case .fund: return "Fund"
        case .bond: return "Bond"
        case .cash: return "Cash"
        }
    }
}

struct Asset: Identifiable, Codable, Hashable {
    let id: String
    let symbol: String
    let name: String
    let type: AssetType
    
    // Additional metadata could go here (e.g. sector, description)
}

struct MarketData: Codable {
    let assetId: String
    let price: Double
    let dailyChangePercentage: Double // e.g. 5.0 for +5%
    let lastUpdated: Date
}

struct Holding: Identifiable, Codable {
    let id: String
    let asset: Asset
    var quantity: Double
    var averageCost: Double
    
    // Calculated properties based on current market data
    func currentValue(price: Double) -> Double {
        return quantity * price
    }
    
    func returnAmount(price: Double) -> Double {
        return currentValue(price: price) - (quantity * averageCost)
    }
    
    func returnPercentage(price: Double) -> Double {
        guard averageCost > 0 else { return 0 }
        return (returnAmount(price: price) / (quantity * averageCost)) * 100
    }
}

struct Portfolio: Codable {
    var cashBalance: Double
    var holdings: [Holding]
    
    var totalValue: Double {
        // This needs market data to calculate accurately, 
        // so it's often better calculated in the Service or View Model
        return cashBalance // + sum of holdings * current_price
    }
}

enum TransactionType: String, Codable {
    case buy
    case sell
    case deposit
    case withdraw
}

struct Transaction: Identifiable, Codable {
    let id: UUID
    let assetId: String? // Nil for cash deposits/withdrawals
    let type: TransactionType
    let amount: Double
    let price: Double
    let date: Date
}

