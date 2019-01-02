//
//  TextPopover.swift
//  TextPopover
//
//  Created by GreenChiu on 2019/1/2.
//  Copyright © 2019 Green. All rights reserved.
//

import UIKit

// MARK: - Constants

private let kTextMargin: CGFloat = 10
private let kPopoverRadius: CGFloat = 5
private let kArrowHeight: CGFloat = 8

private var kDrawOptions: NSStringDrawingOptions {
    return [.usesLineFragmentOrigin, .usesFontLeading, .truncatesLastVisibleLine]
}

// MARK: - Enum, Protocol and Configuration

@objc enum TextPopoverArrowDirection: Int {
    case up
    case right
    case down
}

@objc protocol PopoverDelegate: class {
    @objc func popoverDidDismiss(_ popover: TextPopover) -> Void
}

struct PopoverConfiguration {
    var offset: CGFloat = 5
    var radius: CGFloat = kPopoverRadius
    var font: UIFont = .systemFont(ofSize: 14)
    var textColor: UIColor = .white
    var backgroundColor: UIColor = .gray
    var borderColor: UIColor?
}

class TextPopover: UIView {
    private var sourceRect: CGRect = .zero
    private var arrowStartPoint: CGPoint = .zero
    
    private let message: String
    private var messageSize = CGSize.zero
    private var preferredArrow: TextPopoverArrowDirection = .up
    private var config = PopoverConfiguration()
    
    // MARK: - Setter & Getter for config
    var offset: CGFloat {
        set { config.offset = newValue }
        get { return config.offset }
    }
    var radius: CGFloat {
        set { config.radius = newValue }
        get { return config.radius }
    }
    var font: UIFont {
        set { config.font = newValue }
        get { return config.font }
    }
    var textColor: UIColor {
        set { config.textColor = newValue }
        get { return config.textColor }
    }
    var popoverBackgroundColor: UIColor {
        set { config.backgroundColor = newValue }
        get { return config.backgroundColor }
    }
    var popoverBorderColor: UIColor? {
        set { config.borderColor = newValue }
        get { return config.borderColor }
    }
    
    var preferredWidth: CGFloat = 120.0 {
        didSet {
            messageSize = calculateMessageSize()
        }
    }
    var passthroughViews: [UIView] = []
    weak var delegate: PopoverDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc init( withMessage string: String) {
        message = string
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.clear
        messageSize = calculateMessageSize()
    }
    
    @objc final func show( inView: UIView, sourceRect rect: CGRect, preferredArrow arrow: TextPopoverArrowDirection) -> Void {
        preferredArrow = arrow
        
        var frameOfPopover = CGRect(origin: .zero, size: messageSize)
        frameOfPopover.size.width += kTextMargin * 2
        frameOfPopover.size.height += kTextMargin * 2
        
        switch arrow {
        case .up, .down:
            frameOfPopover.size.height += kArrowHeight
            frameOfPopover.origin.y = arrow == .up ? rect.maxY + offset : rect.minY - frameOfPopover.height - offset
            
            frameOfPopover.origin.x = rect.minX - (frameOfPopover.width - rect.width)/2
            if frameOfPopover.maxX > inView.bounds.width {
                frameOfPopover.origin.x = inView.bounds.width - frameOfPopover.width - 10
            }
            else if frameOfPopover.minX <= 10 {
                frameOfPopover.origin.x = 10
            }
            
            arrowStartPoint.y = arrow == .up ? 0 : frameOfPopover.height
            arrowStartPoint.x = rect.midX - frameOfPopover.minX
        default:
            frameOfPopover.size.width += kArrowHeight
            frameOfPopover.origin.y = rect.minY + (rect.height - frameOfPopover.height)/2
            frameOfPopover.origin.x = rect.minX - frameOfPopover.width - offset
            
            arrowStartPoint.y = frameOfPopover.height/2
            arrowStartPoint.x = frameOfPopover.width
        }
        
        frame = frameOfPopover
        setNeedsDisplay()
        inView.addSubview(self)
    }
    
    @objc final func hide( animated: Bool) -> Void {
        if !animated {
            removeFromSuperview()
            self.delegate?.popoverDidDismiss(self)
            return
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }, completion: { _ in
            defer {
                self.removeFromSuperview()
            }
            guard let delegate = self.delegate else { return }
            delegate.popoverDidDismiss(self)
        })
    }
    
    // MARK: - Override
    
    override func draw(_ rect: CGRect) {
        
        let width = bounds.width
        let height = bounds.height
        
        let startX: CGFloat = arrowStartPoint.x
        let startY: CGFloat = arrowStartPoint.y
        
        let path = UIBezierPath()
        path.lineWidth = 1
        path.move(to: CGPoint(x: startX, y: startY))
        switch preferredArrow {
        case .down:
            path.addLine(to: CGPoint(x: startX + kArrowHeight, y: startY - kArrowHeight))
            path.addLine(to: CGPoint(x: width - radius, y: startY - kArrowHeight))
            path.addQuadCurve(to: CGPoint(x: width, y: startY - kArrowHeight - radius), controlPoint: CGPoint(x: width, y: startY - kArrowHeight))
            path.addLine(to: CGPoint(x: width, y: radius))
            path.addQuadCurve(to: CGPoint(x: width - radius, y: 0), controlPoint: CGPoint(x: width, y: 0))
            path.addLine(to: CGPoint(x: radius, y: 0))
            path.addQuadCurve(to: CGPoint(x: 0, y: radius), controlPoint: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 0, y: startY - kArrowHeight - radius))
            path.addQuadCurve(to: CGPoint(x: radius, y: startY - kArrowHeight), controlPoint: CGPoint(x: 0, y: startY - kArrowHeight))
            path.addLine(to: CGPoint(x: startX - kArrowHeight, y: startY - kArrowHeight))
        case .up:
            path.addLine(to: CGPoint(x: startX - kArrowHeight, y: startY + kArrowHeight))
            path.addLine(to: CGPoint(x: radius, y: startY + kArrowHeight))
            path.addQuadCurve(to: CGPoint(x: 0, y: startY + kArrowHeight + radius), controlPoint: CGPoint(x: 0, y: startY + kArrowHeight))
            path.addLine(to: CGPoint(x: 0, y: height - radius))
            path.addQuadCurve(to: CGPoint(x: radius, y: height), controlPoint: CGPoint(x: 0, y: height))
            path.addLine(to: CGPoint(x: width - radius, y: height))
            path.addQuadCurve(to: CGPoint(x: width, y: height - radius), controlPoint: CGPoint(x: width, y: height))
            path.addLine(to: CGPoint(x: width, y: startY + kArrowHeight + radius))
            path.addQuadCurve(to: CGPoint(x: width - radius, y: startY + kArrowHeight), controlPoint: CGPoint(x: width, y: startY + kArrowHeight))
            path.addLine(to: CGPoint(x: startX + kArrowHeight, y: startY + kArrowHeight))
        case .right:
            path.addLine(to: CGPoint(x: startX - kArrowHeight, y: startY - kArrowHeight))
            path.addLine(to: CGPoint(x: startX - kArrowHeight, y: radius))
            path.addQuadCurve(to: CGPoint(x: startX - kArrowHeight - radius, y: 0), controlPoint: CGPoint(x: startX - kArrowHeight, y: 0))
            path.addLine(to: CGPoint(x: radius, y: 0))
            path.addQuadCurve(to: CGPoint(x: 0, y: radius), controlPoint: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 0, y: height - radius))
            path.addQuadCurve(to: CGPoint(x: radius, y: height), controlPoint: CGPoint(x: 0, y: height))
            path.addLine(to: CGPoint(x: startX - kArrowHeight - radius, y: height))
            path.addQuadCurve(to: CGPoint(x: startX - kArrowHeight, y: height - radius), controlPoint: CGPoint(x: startX - kArrowHeight, y: height))
            path.addLine(to: CGPoint(x: startX - kArrowHeight, y: startY + kArrowHeight))
        }
        path.addLine(to: CGPoint(x: startX, y: startY))
        path.close()
        
        popoverBackgroundColor.setFill()
        path.fill()
        if let borderColor = popoverBorderColor {
            borderColor.setStroke()
            path.stroke()
        }
        
        var frameOfMessage: CGRect = CGRect(origin: .zero, size: messageSize)
        switch preferredArrow {
        case .up:
            frameOfMessage.origin = CGPoint(x: kTextMargin, y: kTextMargin + kArrowHeight)
        case .down, .right:
            frameOfMessage.origin = CGPoint(x: kTextMargin, y: kTextMargin)
        }
        
        messageAttributedString().draw(with: frameOfMessage, options: kDrawOptions, context: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isUserInteractionEnabled = false
        hide(animated: true)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = super.hitTest(point, with: event) else {
            if let superview = superview {
                let pointAtSuperview = convert(point, to: superview)
                for passthroughView in passthroughViews {
                    if passthroughView.frame.contains(pointAtSuperview) {
                        hide(animated: false)
                        break
                    }
                }
            }
            return nil
        }
        
        return view
    }
    
    // MARK: - Private
    
    private final func messageAttributedString() -> NSAttributedString {
        var attributes: [NSAttributedString.Key: Any] = [:]
        attributes[.font] = font
        attributes[.foregroundColor] = textColor
        return NSAttributedString(string: message, attributes: attributes)
    }
    
    private final func calculateMessageSize() -> CGSize {
        if message.count == 0 {
            return .zero
        }
        return messageAttributedString().fullStringSize(withPreferredWidth: preferredWidth - kTextMargin * 2)
    }
}

private extension NSAttributedString {
    @objc func fullStringSize(withPreferredWidth width: CGFloat) -> CGSize {
        let bounds = self.boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude), options: kDrawOptions, context: nil)
        let result = CGSize(width: ceil(bounds.width), height: ceil(bounds.height))
        return result
    }
}
