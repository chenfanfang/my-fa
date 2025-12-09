//
//  Strategy.swift
//  MyFA
//
//  Investment strategy model
//

import Foundation

@objc public class Strategy: NSObject {
    @objc public let id: String
    @objc public let title: String
    @objc public let desc: String
    @objc public let creator: Creator
    @objc public let performance: Performance
    public let tags: [Tag]
    @objc public let engagement: Engagement
    public let historicalData: [PerformanceDataPoint]
    
    @objc public init(id: String, title: String, description: String, creator: Creator, performance: Performance, tags: [Tag], engagement: Engagement, historicalData: [PerformanceDataPoint]) {
        self.id = id
        self.title = title
        self.desc = description
        self.creator = creator
        self.performance = performance
        self.tags = tags
        self.engagement = engagement
        self.historicalData = historicalData
    }
    
    @objc public class Creator: NSObject {
        @objc public let name: String
        @objc public let avatarColor: String // Hex color for avatar background
        @objc public let role: String
        
        @objc public init(name: String, avatarColor: String, role: String) {
            self.name = name
            self.avatarColor = avatarColor
            self.role = role
        }
    }
    
    @objc public class Performance: NSObject {
        @objc public let annualReturn: Double // percentage
        @objc public let maxDrawdown: Double // percentage
        @objc public let sharpeRatio: Double
        @objc public let winRate: Double // percentage (0-100)
        
        @objc public init(annualReturn: Double, maxDrawdown: Double, sharpeRatio: Double, winRate: Double) {
            self.annualReturn = annualReturn
            self.maxDrawdown = maxDrawdown
            self.sharpeRatio = sharpeRatio
            self.winRate = winRate
        }
    }
    
    public class Tag: NSObject {
        public let text: String
        public let type: TagType
        
        public enum TagType {
            case risk
            case term
            case asset
        }
        
        public init(text: String, type: TagType) {
            self.text = text
            self.type = type
        }
    }
    
    @objc public class Engagement: NSObject {
        @objc public let likes: Int
        @objc public let comments: Int
        @objc public let followers: Int
        @objc public let recentFollowers: Int // followers in last 7 days
        
        @objc public init(likes: Int, comments: Int, followers: Int, recentFollowers: Int) {
            self.likes = likes
            self.comments = comments
            self.followers = followers
            self.recentFollowers = recentFollowers
        }
    }
    
    @objc public class PerformanceDataPoint: NSObject {
        @objc public let month: String
        @objc public let returnPercentage: Double // Can be negative
        
        @objc public init(month: String, returnPercentage: Double) {
            self.month = month
            self.returnPercentage = returnPercentage
        }
    }
}

