//
//  CircularProgressView.swift
//  BlueTechEKYCSDK
//
//  Created by Nguyen Bui Ly on 5/28/24.
//

import UIKit

import UIKit

class CircularProgressView: UIView {
    var progress: Double = 0.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var tickMarks: Int = 90
    var lineWidth: CGFloat = 10
    var circleColor: UIColor = .blue
    var completedTickColor: UIColor = .green
    var pendingTickColor: UIColor = .gray
    
    private var displayLink: CADisplayLink?
    private var startTime: CFTimeInterval?
    private var animationDuration: TimeInterval = 0
    private var fromProgress: Double = 0
    private var toProgress: Double = 0
    private var completion: (() -> Void)?
    private var pausedProgress: Double = 0.0
    private var pausedTime: CFTimeInterval?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let radius = min(bounds.width, bounds.height) / 2 - lineWidth / 2
        
        // Draw tick marks
        for i in 0..<tickMarks {
            let angle = CGFloat(3 * Double.pi / 2) + CGFloat(i) / CGFloat(tickMarks) * 2 * CGFloat.pi
            let tickLength: CGFloat = 10
            let tickStart = CGPoint(x: center.x + (radius - tickLength) * cos(angle), y: center.y + (radius - tickLength) * sin(angle))
            let tickEnd = CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
            
            let tickColor = CGFloat(i) / CGFloat(tickMarks) < CGFloat(progress) ? completedTickColor : pendingTickColor
            context.setStrokeColor(tickColor.cgColor)
            context.setLineWidth(lineWidth / 2)
            context.move(to: tickStart)
            context.addLine(to: tickEnd)
            context.strokePath()
        }
    }
    
    func setProgress(_ progress: Double, withDuration duration: TimeInterval, completion: (() -> Void)? = nil) {
        self.fromProgress = self.progress
        self.toProgress = progress
        self.animationDuration = duration
        self.completion = completion
        
        self.startTime = CACurrentMediaTime()
        
        // Invalidate any previous display links
        self.displayLink?.invalidate()
        
        // Create a new display link
        self.displayLink = CADisplayLink(target: self, selector: #selector(updateProgress))
        self.displayLink?.add(to: .main, forMode: .default)
    }
    
    @objc private func updateProgress() {
        guard let startTime = self.startTime else { return }
        
        let elapsedTime = CACurrentMediaTime() - startTime
        let progressRatio = min(elapsedTime / animationDuration, 1.0)
        
        self.progress = fromProgress + (toProgress - fromProgress) * progressRatio
        
        if progressRatio >= 1.0 {
            // Invalidate the display link when the animation is complete
            self.displayLink?.invalidate()
            self.displayLink = nil
            
            // Call the completion handler
            completion?()
        }
    }
    
    func cancelProgress() {
        // Invalidate the display link to stop the animation
        self.displayLink?.invalidate()
        self.displayLink = nil
    }
    
    func getRemainingDuration() -> TimeInterval {
        guard let startTime = self.startTime else {
            return 0
        }
        let elapsedTime = CACurrentMediaTime() - startTime
        let remainingDuration = animationDuration - elapsedTime
        return max(remainingDuration, 0)
    }
}


