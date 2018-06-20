//
//  SwipeFeedback.swift
//
//  Created by Jeremy Koch
//  Copyright © 2017 Jeremy Koch. All rights reserved.
//

import UIKit

public final class SwipeFeedback {
    public enum Style {
        case light
        case medium
        case heavy
    }
    
    @available(iOS 10.0.1, *)
    private var feedbackGenerator: UIImpactFeedbackGenerator? {
        get {
            return _feedbackGenerator as? UIImpactFeedbackGenerator
        }
        set {
            _feedbackGenerator = newValue
        }
    }
    
    private var _feedbackGenerator: Any?
    
    public init(style: Style) {
        if #available(iOS 10.0.1, *) {
            switch style {
            case .light:
                feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
            case .medium:
                feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
            case .heavy:
                feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
            }
        } else {
            _feedbackGenerator = nil
        }
    }
    
    public func prepare() {
        if #available(iOS 10.0.1, *) {
            feedbackGenerator?.prepare()
        }
    }
    
    public func impactOccurred() {
        if #available(iOS 10.0.1, *) {
            feedbackGenerator?.impactOccurred()
        }
    }
}

