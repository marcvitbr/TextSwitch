//
//  UITextSwitch.swift
//  UITextSwitch
//
//  Created by Marcelo Vitoria on 06/12/18.
//  Copyright © 2018 Marcelo Vitoria. All rights reserved.
//

public protocol UITextSwitchSwitchListener: AnyObject {
    func changedState(to newState: Bool, byTouch: Bool)
}

public class UITextSwitch: UIControl {
    private static let defaultControlWidth: CGFloat = 120
    private static let defaultControlHeight: CGFloat = 35
    private static let margin: CGFloat = 2
    private static let fontSize: CGFloat = 12

    private static let defaultOnText = "On"
    private static let defaultOffText = "Off"

    private var initialized = false
    private var hasTouched = false

    public weak var listener: UITextSwitchSwitchListener? {
        didSet {
            self.listener?.changedState(to: self.isOn,
                                        byTouch: self.hasTouched)
        }
    }

    public var isOn = false {
        didSet {
            self.changeState(animated: self.hasTouched)
            self.hasTouched = false
        }
    }

    public var textWhenOn: String? {
        didSet {
            self.layoutSubviews()

            if self.isOn {
                self.label.text = self.textWhenOn
            }
        }
    }

    public var textWhenOff: String? {
        didSet {
            self.layoutSubviews()

            if !self.isOn {
                self.label.text = self.textWhenOff
            }
        }
    }

    public var trailColorWhenOn: UIColor? {
        didSet {
            self.trailView.backgroundColor = self.trailColorWhenOn
        }
    }

    public var trailColorWhenOff: UIColor? {
        didSet {
            self.trailView.backgroundColor = self.trailColorWhenOff
        }
    }

    public var thumbColor: UIColor? {
        didSet {
            self.thumbView.backgroundColor = self.thumbColor
        }
    }

    public var textColorWhenOn: UIColor? {
        didSet {
            self.label.textColor = self.textColorWhenOn
        }
    }

    public var textColorWhenOff: UIColor? {
        didSet {
            self.label.textColor = self.textColorWhenOff
        }
    }

    private var thumbView: UIView!
    private var trailView: UIView!
    private var label: UILabel!

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.initialize()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

        self.initialize()
    }

    public convenience init() {
        self.init(frame: CGRect(origin: CGPoint.zero,
                                size: CGSize(width: UITextSwitch.defaultControlWidth,
                                             height: UITextSwitch.defaultControlHeight)))
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        if !self.initialized {
            return
        }

        let thumbSize = self.obtainThumbSize()
        let thumbPosition = self.obtainThumbPosition(for: thumbSize)
        let trailSize = self.obtainTrailSize()
        let trailPosition = self.obtainTrailPosition(for: trailSize)
        let labelSize = self.obtainLabelSizeBasedOn(trailSize, thumbSize)

        self.thumbView.frame = CGRect(origin: thumbPosition, size: thumbSize)
        self.thumbView.layer.cornerRadius = thumbSize.height / 2

        self.trailView.frame = CGRect(origin: trailPosition, size: trailSize)
        self.trailView.layer.cornerRadius = trailSize.height / 2

        self.label.frame = CGRect(origin: CGPoint(x: self.obtainXForLabel(basedOnWidth: labelSize.width),
                                                  y: self.bounds.height / 2 - labelSize.height / 2),
                                  size: labelSize)
    }

    public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)

        self.hasTouched = true

        self.isOn = !self.isOn

        return true
    }

    private func initialize() {
        self.clear()

        self.createTrailView()
        self.createStateLabel()
        self.createThumbView()

        self.initialized = true
        self.setNeedsLayout()
    }

    private func clear() {
        for view in self.subviews {
            view.removeFromSuperview()
        }
    }

    private func createTrailView() {
        self.trailView = UIView(frame: CGRect.zero)
        self.trailView.isUserInteractionEnabled = false
        self.trailView.backgroundColor = UIColor.white
        self.trailView.layer.borderColor = UIColor.lightGray.cgColor
        self.trailView.layer.borderWidth = 1.0
        self.trailView.layer.cornerRadius = 18
        self.trailView.center = self.center

        self.addSubview(self.trailView)
    }

    private func createThumbView() {
        self.thumbView = UIView(frame: CGRect.zero)
        self.thumbView.isUserInteractionEnabled = false
        self.thumbView.backgroundColor = UIColor.white
        self.thumbView.layer.cornerRadius = 15
        self.thumbView.layer.shadowColor = UIColor.black.cgColor
        self.thumbView.layer.shadowRadius = 2
        self.thumbView.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.thumbView.layer.shadowOpacity = 0.75
        self.thumbView.center = self.center

        self.addSubview(self.thumbView)
    }

    private func createStateLabel() {
        self.label = UILabel(frame: CGRect.zero)
        self.label.isUserInteractionEnabled = false
        self.label.font = UIFont.systemFont(ofSize: UITextSwitch.fontSize)
        self.label.textColor = UIColor.lightGray
        self.label.textAlignment = .center
        self.label.text = self.textWhenOff ?? UITextSwitch.defaultOffText

        self.addSubview(self.label)
    }

    private func changeState(animated: Bool) {
        defer {
            self.listener?.changedState(to: self.isOn,
                                        byTouch: self.hasTouched)
        }

        let thumbPositionX = self.obtainXForThumbView(basedOnWidth: self.thumbView.frame.width)
        let labelPositionX = self.obtainXForLabel(basedOnWidth: self.label.frame.width)

        let trailBackgroundColor = self.obtainTrailBackgroundColor()
        let trailBorderColor = self.obtainTrailBorderColor()
        let textColor = self.obtainTextColor()

        let onText = self.textWhenOn ?? UITextSwitch.defaultOnText
        let offText = self.textWhenOff ?? UITextSwitch.defaultOffText
        let text = self.isOn ? onText : offText

        let stateChangeActions = {
            self.thumbView.frame.origin.x = thumbPositionX

            self.trailView.backgroundColor = trailBackgroundColor
            self.trailView.layer.borderColor = trailBorderColor

            self.label.textColor = textColor
            self.label.text = text
            self.label.frame.origin.x = labelPositionX
        }

        if !animated {
            stateChangeActions()
            return
        }

        UIView.animate(withDuration: 0.2, animations: stateChangeActions)
    }

    private func obtainThumbPosition(for thumbSize: CGSize) -> CGPoint {
        return CGPoint(x: self.obtainXForThumbView(basedOnWidth: thumbSize.width),
                       y: self.bounds.height / 2 - thumbSize.height / 2)
    }

    private func obtainTrailPosition(for trailSize: CGSize) -> CGPoint {
        return CGPoint(x: self.bounds.width - trailSize.width, y: 0)
    }

    private func obtainXForThumbView(basedOnWidth thumbViewWidth: CGFloat) -> CGFloat {
        return self.isOn ? self.bounds.width - thumbViewWidth - 2 : UITextSwitch.margin
    }

    private func obtainXForLabel(basedOnWidth labelWidth: CGFloat) -> CGFloat {
        return self.isOn ? UITextSwitch.margin : self.bounds.width - labelWidth - UITextSwitch.margin
    }

    private func obtainTrailBackgroundColor() -> UIColor {
        let colorWhenOn = self.trailColorWhenOn ?? UIColor.green

        let colorWhenOff = self.trailColorWhenOff ?? UIColor.white

        return self.isOn ? colorWhenOn : colorWhenOff
    }

    private func obtainTrailBorderColor() -> CGColor {
        let colorWhenOn = self.trailColorWhenOn?.cgColor ?? UIColor.green.cgColor

        let colorWhenOff = self.trailColorWhenOff?.cgColor ?? UIColor.white.cgColor

        return self.isOn ? colorWhenOn : colorWhenOff
    }

    private func obtainTextColor() -> UIColor {
        let colorWhenOn = self.textColorWhenOn ?? UIColor.white

        let colorWhenOff = self.textColorWhenOff ?? UIColor.lightGray

        return self.isOn ? colorWhenOn : colorWhenOff
    }

    private func obtainTrailSize() -> CGSize {
        return CGSize(width: self.bounds.width,
                      height: self.bounds.height)
    }

    private func obtainThumbSize() -> CGSize {
        return CGSize(width: self.bounds.height,
                      height: self.bounds.height)
    }

    private func obtainLabelSizeBasedOn(_ trailSize: CGSize, _ thumbSize: CGSize) -> CGSize {
        return CGSize(width: trailSize.width - thumbSize.width,
                      height: trailSize.height)
    }
}
