//
//  MockAssetService.swift
//  MyFA
//
//  Mock data service for assets and account opening
//

import Foundation

@objc public class MockAssetService: NSObject {
    @objc public static let shared = MockAssetService()
    
    private override init() {}
    
    enum AccountStatus {
        case notOpened
        case inProgress(step: Int)
        case opened
    }
    
    func getAccountStatus() -> AccountStatus {
        // For now, always return not opened
        return .notOpened
    }
    
    @objc public func getAccountOpeningSteps() -> [String] {
        return [
            LocalizationHelper.localized("assets.opening.step1"),
            LocalizationHelper.localized("assets.opening.step2"),
            LocalizationHelper.localized("assets.opening.step3")
        ]
    }
}

