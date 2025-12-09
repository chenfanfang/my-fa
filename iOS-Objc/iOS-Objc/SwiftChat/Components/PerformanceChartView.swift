//
//  PerformanceChartView.swift
//  MyFA
//
//  Bar chart view for strategy performance visualization
//

import UIKit

@objc public class PerformanceChartView: UIView {
    
    private let dataPoints: [Strategy.PerformanceDataPoint]
    private let barSpacing: CGFloat = 4
    private let minBarHeight: CGFloat = 20
    
    @objc public init(dataPoints: [Strategy.PerformanceDataPoint]) {
        self.dataPoints = dataPoints
        super.init(frame: .zero)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard !dataPoints.isEmpty else { return }
        
        let maxValue = dataPoints.map { abs($0.returnPercentage) }.max() ?? 1
        let barWidth = (rect.width - CGFloat(dataPoints.count - 1) * barSpacing) / CGFloat(dataPoints.count)
        
        for (index, point) in dataPoints.enumerated() {
            let x = CGFloat(index) * (barWidth + barSpacing)
            let normalizedValue = point.returnPercentage / maxValue
            let barHeight = max(abs(normalizedValue) * rect.height * 0.8, minBarHeight)
            
            let y: CGFloat
            if point.returnPercentage >= 0 {
                y = rect.height - barHeight
            } else {
                y = rect.height - minBarHeight
            }
            
            let barRect = CGRect(x: x, y: y, width: barWidth, height: barHeight)
            
            let barColor: UIColor = point.returnPercentage >= 0 ?
                UIColor(red: 0.3, green: 0.7, blue: 0.4, alpha: 1.0) : // Green
                UIColor(red: 0.8, green: 0.3, blue: 0.3, alpha: 1.0)   // Red
            
            barColor.setFill()
            
            let path = UIBezierPath(roundedRect: barRect, cornerRadius: 2)
            path.fill()
        }
    }
}

