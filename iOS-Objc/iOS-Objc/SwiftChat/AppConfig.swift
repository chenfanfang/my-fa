//
//  AppConfig.swift
//  MyFA
//
//  Application-specific configuration constants
//

import Foundation

struct AppConfig {
  /// Default agent ID for conversations
  static let defaultAgentId = UUID(uuidString: "E1E72B3D-845D-4F5D-B6CA-5550F2643E6B")!
  
  /// Default server URL for the agent endpoint
  /// Uses localhost for debug builds, production URL for release builds
  static var defaultServerURL: URL {
    // Check for environment override first
    if let urlString = ProcessInfo.processInfo.environment["SERVER_URL"],
       let url = URL(string: urlString) {
      return url
    }
    
    // Fall back to default based on build configuration
    #if DEBUG
    return URL(string: "http://127.0.0.1:3000/agent")!
    #else
    // TODO: Replace with your production server URL before App Store submission
    guard let url = URL(string: "https://your-production-server.example.com/agent") else {
      fatalError("Invalid production server URL configured. Please update AppConfig.swift with valid production URL.")
    }
    return url
    #endif
  }
  
  /// Default agent name for persistence
  static let defaultAgentName = "My Agent"
  
  /// Default user ID
  static let defaultUserId = "demo-user"
    
  //大模型apiKey，用来获取提示词
  static let apiKey = ""
  static let endpoint = "https://api.siliconflow.cn/v1/chat/completions"
    
}

