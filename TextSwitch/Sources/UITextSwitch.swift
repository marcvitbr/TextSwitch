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
    private static let controlWidth: CGFloat = 120
    private static let controlHeight: CGFloat = 35
    private static let thumbWidth: CGFloat = 30
    private static let thumbHeight: CGFloat = 30
    private static let margin: CGFloat = 2
    private static let fontSize: CGFloat = 12

    private static let defaultOnText = "On"
    private static let defaultOffText = "Off"

    private var hasTouched = false

    public weak var listener: UITextSwitchSwitchListener? {
        didSet {
            self.listener?.changedState(to: self.on,
                                        byTouch: self.hasTouched)
        }
    }

    public var on = false {
        didSet {
            self.changeState(animated: self.hasTouched)
            self.hasTouched = false
        }
    }

    public var textWhenOn: String? {
        didSet {
            self.layoutSubviews()

            if self.on {
                self.label.text = self.textWhenOn
            }
        }
    }

    public var textWhenOff: String? {
        didSet {
            self.layoutSubviews()

            if !self.on {
                self.label.text = self.textWhenOff
            }
        }
    }

    private var thumbView: UIView!
    private var trailView: UIView!
    private var label: UILabel!

    private var initialized = false

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.initialize()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.initialize()
    }

    public convenience init() {
        self.init(frame: CGRect(origin: CGPoint.zero,
                                size: CGSize(width: UITextSwitch.controlWidth,
                                             height: UITextSwitch.controlHeight)))
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        if !self.initialized {
            return
        }

        let thumbSize = CGSize(width: UITextSwitch.thumbWidth,
                               height: UITextSwitch.thumbHeight)

        let thumbPosition = CGPoint(x: self.obtainXForThumbView(basedOnWidth: thumbSize.width),
                                    y: self.bounds.height / 2 - thumbSize.height / 2)

        self.thumbView.frame = CGRect(origin: thumbPosition, size: thumbSize)

        let trailSize = CGSize(width: UITextSwitch.controlWidth,
                               height: UITextSwitch.controlHeight)

        let trailPosition = CGPoint(x: self.bounds.width - trailSize.width, y: 0)

        self.trailView.frame = CGRect(origin: trailPosition, size: trailSize)

        let labelSize = CGSize(width: trailSize.width - thumbSize.width,
                               height: trailSize.height)

        self.label.frame = CGRect(origin: CGPoint(x: self.obtainXForLabel(basedOnWidth: labelSize.width),
                                                  y: self.bounds.height / 2 - labelSize.height / 2),
                                  size: labelSize)
    }

    public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)

        self.hasTouched = true

        self.on = !self.on

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
            self.listener?.changedState(to: self.on,
                                        byTouch: self.hasTouched)
        }

        let thumbPositionX = self.obtainXForThumbView(basedOnWidth: self.thumbView.frame.width)

        let trailBackgroundColor = self.on ? UIColor.green : UIColor.white

        let trailBorderColor = self.on ? UIColor.green.cgColor : UIColor.lightGray.cgColor

        let textColor = self.on ? UIColor.white : UIColor.lightGray

        let onText = self.textWhenOn ?? UITextSwitch.defaultOnText
        let offText = self.textWhenOff ?? UITextSwitch.defaultOffText
        let text = self.on ? onText : offText

        let labelPositionX = self.obtainXForLabel(basedOnWidth: self.label.frame.width)

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

    private func obtainXForThumbView(basedOnWidth thumbViewWidth: CGFloat) -> CGFloat {
        return self.on ? self.bounds.width - thumbViewWidth - 2 : UITextSwitch.margin
    }

    private func obtainXForLabel(basedOnWidth labelWidth: CGFloat) -> CGFloat {
        return self.on ? UITextSwitch.margin : self.bounds.width - labelWidth - UITextSwitch.margin
    }
}
