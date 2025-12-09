//
//  MockStrategyService.swift
//  MyFA
//
//  Mock data service for strategies
//

import Foundation

@objc public class MockStrategyService: NSObject {
    @objc public static let shared = MockStrategyService()
    
    private override init() {}
    
    @objc public func getStrategies() -> [Strategy] {
        return [
            Strategy(
                id: "strategy-1",
                title: LocalizationHelper.localized("strategy.sample1.title"),
                description: LocalizationHelper.localized("strategy.sample1.desc"),
                creator: Strategy.Creator(
                    name: LocalizationHelper.localized("strategy.sample1.creator"),
                    avatarColor: "#6B5CE7",
                    role: LocalizationHelper.localized("strategy.sample1.role")
                ),
                performance: Strategy.Performance(
                    annualReturn: 23.8,
                    maxDrawdown: -12.3,
                    sharpeRatio: 1.65,
                    winRate: 68.0
                ),
                tags: [
                    Strategy.Tag(text: LocalizationHelper.localized("strategies.risk.medium"), type: .risk),
                    Strategy.Tag(text: LocalizationHelper.localized("strategies.term.medium"), type: .term),
                    Strategy.Tag(text: LocalizationHelper.localized("strategies.type.etf.stock"), type: .asset)
                ],
                engagement: Strategy.Engagement(
                    likes: 1247,
                    comments: 89,
                    followers: 2136,
                    recentFollowers: 183
                ),
                historicalData: generateHistoricalData(
                    startMonth: "2023.05",
                    months: 18,
                    pattern: [
                        -8, -5, 3, 5, 4, 6, 8, 7, 10, 12, 11, 14, 16, 15, 18, 20, 22, 24
                    ]
                )
            ),
            Strategy(
                id: "strategy-2",
                title: LocalizationHelper.localized("strategy.sample2.title"),
                description: LocalizationHelper.localized("strategy.sample2.desc"),
                creator: Strategy.Creator(
                    name: LocalizationHelper.localized("strategy.sample2.creator"),
                    avatarColor: "#5B9FD7",
                    role: LocalizationHelper.localized("strategy.sample2.role")
                ),
                performance: Strategy.Performance(
                    annualReturn: 18.5,
                    maxDrawdown: -8.7,
                    sharpeRatio: 2.1,
                    winRate: 72.0
                ),
                tags: [
                    Strategy.Tag(text: LocalizationHelper.localized("strategies.risk.low"), type: .risk),
                    Strategy.Tag(text: LocalizationHelper.localized("strategies.term.long"), type: .term),
                    Strategy.Tag(text: "ETF", type: .asset)
                ],
                engagement: Strategy.Engagement(
                    likes: 892,
                    comments: 56,
                    followers: 1543,
                    recentFollowers: 94
                ),
                historicalData: generateHistoricalData(
                    startMonth: "2022.11",
                    months: 25,
                    pattern: Array(stride(from: 0.0, to: 45.0, by: 2.0))
                )
            )
        ]
    }
    
    private func generateHistoricalData(startMonth: String, months: Int, pattern: [Double]) -> [Strategy.PerformanceDataPoint] {
        var data: [Strategy.PerformanceDataPoint] = []
        
        let components = startMonth.split(separator: ".")
        guard let year = Int(components[0]), let month = Int(components[1]) else {
            return []
        }
        
        for i in 0..<min(months, pattern.count) {
            let currentMonth = month + i
            let currentYear = year + (currentMonth - 1) / 12
            let adjustedMonth = ((currentMonth - 1) % 12) + 1
            
            let monthString = String(format: "%04d.%02d", currentYear, adjustedMonth)
            data.append(Strategy.PerformanceDataPoint(
                month: monthString,
                returnPercentage: pattern[i]
            ))
        }
        
        return data
    }
}

