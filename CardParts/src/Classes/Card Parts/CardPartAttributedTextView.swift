//
//  CardPartAttributedTextView.swift
//  CardParts
//
//  Created by jloehr  on 12/9/19.
//

import UIKit
import RxSwift
import RxCocoa

public class CardPartUITextView: UITextView {
    
    public override var selectedTextRange: UITextRange? {
        get { return nil }
        set {}
    }
    
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIPanGestureRecognizer {
            return super.gestureRecognizerShouldBegin(gestureRecognizer)
        }
        if let tapGestureRecognizer = gestureRecognizer as? UITapGestureRecognizer,
            tapGestureRecognizer.numberOfTapsRequired == 1 {
            return super.gestureRecognizerShouldBegin(gestureRecognizer)
        }
        if let longPressGestureRecognizer = gestureRecognizer as? UILongPressGestureRecognizer,
            longPressGestureRecognizer.minimumPressDuration < 0.325 {
            return super.gestureRecognizerShouldBegin(gestureRecognizer)
        }
        gestureRecognizer.isEnabled = false
        return false
    }
    
    
    public var textInsets = UIEdgeInsets.zero {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    override public func frame(forAlignmentRect alignmentRect: CGRect) -> CGRect {
        var resultRect = super.frame(forAlignmentRect: alignmentRect)
        
        resultRect.origin.y = bounds.origin.y + (bounds.size.height - resultRect.size.height) / 2
        return resultRect
    }
    
    override public func draw(_ rect: CGRect) {
        let r = self.frame(forAlignmentRect: rect)
        super.draw(r)
    }
}

public enum CardPartAttributedTextType {
    case small
    case normal
    case title
    case header
    case detail
}

public class CardPartAttributedTextView: UIView, CardPartView {
    
    public var text: String? {
        didSet {
            textView.text = text
        }
    }
    
    public var attributedText: NSMutableAttributedString? {
        didSet {
            textView.attributedText = attributedText
        }
    }
    
    public var font: UIFont? {
        didSet {
            textView.font = font
        }
    }
    
    public var textColor: UIColor? {
        didSet {
            textView.textColor = textColor
        }
    }
    
    public var isEditable: Bool {
        didSet {
            textView.isEditable = isEditable
        }
    }
    
    public var dataDetectorTypes: UIDataDetectorTypes {
        didSet {
            textView.dataDetectorTypes = dataDetectorTypes
        }
    }
    
    public var textAlignment: NSTextAlignment {
        didSet {
            textView.textAlignment = textAlignment
        }
    }

    public var linkTextAttributes: [NSAttributedString.Key : Any] {
        didSet {
            textView.linkTextAttributes = linkTextAttributes
        }
    }
    
    // allows for exclusion paths to be added for text wrapping
    public var exclusionPath: [UIBezierPath]? {
        didSet {
            let imageFrame = updateExclusionPath()
            let exclusionPath = UIBezierPath(rect: imageFrame)
            self.textView.textContainer.exclusionPaths = [exclusionPath]
        }
    }
    
    public var lineSpacing: CGFloat = 1.0 {
        didSet {
            let style = NSMutableParagraphStyle()
            style.lineSpacing = lineSpacing
            
        }
    }

    public var lineHeightMultiple: CGFloat = 1.1 {
        didSet {
            let style = NSMutableParagraphStyle()
            style.lineHeightMultiple = lineHeightMultiple
        }
    }
    
    public var margins: UIEdgeInsets = CardParts.theme.cardPartMargins
    public var textView: CardPartUITextView
    
    public var textViewImage: CardPartImageView?
    
    public init(type: CardPartAttributedTextType) {
        
        
        textView = CardPartUITextView(frame: .zero)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textContainer.lineBreakMode = NSLineBreakMode.byWordWrapping
        textView.isScrollEnabled = false
        textView.text = text
        textView.font = font
        textView.textColor = textColor
        textView.isEditable = false
        self.textView.isSelectable = textView.isSelectable
        self.isEditable = textView.isEditable
        self.dataDetectorTypes = textView.dataDetectorTypes
        self.textAlignment = textView.textAlignment
        self.linkTextAttributes = textView.linkTextAttributes
        self.exclusionPath = textView.textContainer.exclusionPaths
        
        
        super.init(frame: CGRect.zero)

        addSubview(textView)
        setDefaultsForType(type)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func updateConstraints() {
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[textView]|", options: [], metrics: nil, views: ["textView" : textView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[textView]|", options: [], metrics: nil, views: ["textView" : textView]))
        
        super.updateConstraints()
    }
    
    func setDefaultsForType(_ type: CardPartAttributedTextType) {
        
        switch type {
        case .small:
            font = CardParts.theme.smallTextFont
            textColor = CardParts.theme.smallTextColor
        case .normal:
            font = CardParts.theme.normalTextFont
            textColor = CardParts.theme.normalTextColor
        case .title:
            font = CardParts.theme.titleTextFont
            textColor = CardParts.theme.titleTextColor
        case .header:
            font = CardParts.theme.headerTextFont
            textColor = CardParts.theme.headerTextColor
        case .detail:
            font = CardParts.theme.detailTextFont
            textColor = CardParts.theme.detailTextColor
        }
    }
        
    func updateExclusionPath() -> CGRect {
        let x = textViewImage?.frame.origin.x ?? 0
        let y = textViewImage?.frame.origin.y ?? 0
        let height = textViewImage?.frame.height ?? 0
        let width = textViewImage?.frame.width ?? 0
        let imageRect = CGRect(x: x, y: y, width: width, height: height)
        return imageRect
    }
    
}

extension Reactive where Base: CardPartAttributedTextView {
    
    public var text: Binder<String?> {
        return Binder<String?>(self.base) { (textView, text) -> () in
            textView.text = text
        }
    }
    
    public var attributedText: Binder<NSMutableAttributedString?> {
        return Binder<NSMutableAttributedString?>(self.base) { (textView, attributedText) -> () in
            textView.attributedText = attributedText
        }
    }
    
    public var font: Binder<UIFont> {
        return Binder(self.base) { (textView, font) -> () in
            textView.font = font
        }
    }
    
    public var textColor: Binder<UIColor> {
        return Binder(self.base) { (textView, textColor) -> () in
            textView.textColor = textColor
        }
    }
    
    public var isEditable: Binder<Bool> {
        return Binder(self.base) { (textView, isEditable) -> () in
            textView.isEditable = isEditable
        }
    }
    
    public var dataDetectorTypes: Binder<UIDataDetectorTypes> {
        return Binder(self.base) { (textView, dataDetectorTypes) -> () in
            textView.dataDetectorTypes = dataDetectorTypes
        }
    }
    
    public var textAlignment: Binder<NSTextAlignment> {
        return Binder(self.base) { (textView, textAlignment) -> () in
            textView.textAlignment = textAlignment
        }
    }
    
    public var exclusionPath: Binder<[UIBezierPath]?> {
        return Binder(self.base) { (textView, exclusionPath) -> () in
            textView.exclusionPath = exclusionPath
        }
    }
    
    public var lineSpacing: Binder<CGFloat> {
        return Binder(self.base) { (textView, lineSpacing) -> () in
            textView.lineSpacing = lineSpacing
        }
    }

    public var lineHeightMultiple: Binder<CGFloat> {
        return Binder(self.base) { (textView, lineHeightMultiple) -> () in
            textView.lineHeightMultiple = lineHeightMultiple
        }
    }
    
}

extension UITextView {
    func center() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }
}