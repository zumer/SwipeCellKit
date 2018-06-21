//
//  SwipeTransitionLayout.swift
//
//  Created by Jeremy Koch
//  Copyright © 2017 Jeremy Koch. All rights reserved.
//

import UIKit

// MARK: - Layout Protocol

public protocol SwipeTransitionLayout {
    func container(view: UIView, didChangeVisibleWidthWithContext context: ActionsViewLayoutContext)
    func layout(view: UIView, atIndex index: Int, with context: ActionsViewLayoutContext)
    func visibleWidthsForViews(with context: ActionsViewLayoutContext) -> [CGFloat]
    
    init()
}

// MARK: - Layout Context 

public struct ActionsViewLayoutContext {
    let numberOfActions: Int
    let orientation: SwipeActionsOrientation
    let contentSize: CGSize
    let visibleWidth: CGFloat
    let minimumButtonWidth: CGFloat
    
    public init(numberOfActions: Int, orientation: SwipeActionsOrientation, contentSize: CGSize = .zero, visibleWidth: CGFloat = 0, minimumButtonWidth: CGFloat = 0) {
        self.numberOfActions = numberOfActions
        self.orientation = orientation
        self.contentSize = contentSize
        self.visibleWidth = visibleWidth
        self.minimumButtonWidth = minimumButtonWidth
    }
    
    public static func newContext(for actionsView: SwipeActionsViewProtocol) -> ActionsViewLayoutContext {
        return ActionsViewLayoutContext(numberOfActions: actionsView.actions.count,
                                        orientation: actionsView.orientation,
                                        contentSize: actionsView.contentSize,
                                        visibleWidth: actionsView.visibleWidth,
                                        minimumButtonWidth: actionsView.minimumButtonWidth)
    }
}

// MARK: - Supported Layout Implementations 

public class BorderTransitionLayout: SwipeTransitionLayout {
    public func container(view: UIView, didChangeVisibleWidthWithContext context: ActionsViewLayoutContext) {
    }
    
    public func layout(view: UIView, atIndex index: Int, with context: ActionsViewLayoutContext) {
        let diff = context.visibleWidth - context.contentSize.width
        view.frame.origin.x = (CGFloat(index) * context.contentSize.width / CGFloat(context.numberOfActions) + diff) * context.orientation.scale
    }
    
    public func visibleWidthsForViews(with context: ActionsViewLayoutContext) -> [CGFloat] {
        let diff = context.visibleWidth - context.contentSize.width
        let visibleWidth = context.contentSize.width / CGFloat(context.numberOfActions) + diff

        // visible widths are all the same regardless of the action view position
        return (0..<context.numberOfActions).map({ _ in visibleWidth })
    }
    
    public required init() {
        
    }
}

public class DragTransitionLayout: SwipeTransitionLayout {
    public func container(view: UIView, didChangeVisibleWidthWithContext context: ActionsViewLayoutContext) {
        view.bounds.origin.x = (context.contentSize.width - context.visibleWidth) * context.orientation.scale
    }
    
    public func layout(view: UIView, atIndex index: Int, with context: ActionsViewLayoutContext) {
        view.frame.origin.x = (CGFloat(index) * context.minimumButtonWidth) * context.orientation.scale
    }
    
    public func visibleWidthsForViews(with context: ActionsViewLayoutContext) -> [CGFloat] {
        return (0..<context.numberOfActions)
            .map({ max(0, min(context.minimumButtonWidth, context.visibleWidth - (CGFloat($0) * context.minimumButtonWidth))) })
    }
    
    public required init() {
        
    }
}

public class RevealTransitionLayout: DragTransitionLayout {
    override public func container(view: UIView, didChangeVisibleWidthWithContext context: ActionsViewLayoutContext) {
        let width = context.minimumButtonWidth * CGFloat(context.numberOfActions)
        view.bounds.origin.x = (width - context.visibleWidth) * context.orientation.scale
    }
    
    override public func visibleWidthsForViews(with context: ActionsViewLayoutContext) -> [CGFloat] {
        return super.visibleWidthsForViews(with: context).reversed()
    }
    
    public required init() {
        
    }
}

public class RevealVerticalTransitionLayout: DragTransitionLayout {
    
    override public func container(view: UIView, didChangeVisibleWidthWithContext context: ActionsViewLayoutContext) {
        let width = context.minimumButtonWidth //* CGFloat(context.numberOfActions)
        view.bounds.origin.x = (width - context.visibleWidth) * context.orientation.scale
        //view.bounds.origin.x = (context.contentSize.width - context.visibleWidth) * context.orientation.scale
    }
    
    override public func layout(view: UIView, atIndex index: Int, with context: ActionsViewLayoutContext) {
        let height = context.contentSize.height / CGFloat(context.numberOfActions)
        //view.frame.origin.x = context.visibleWidth / 2 //(CGFloat(index) * context.minimumButtonWidth) * context.orientation.scale
        view.frame.origin.y = CGFloat(index-1) * height
        
        //view.frame.origin.x = context.minimumButtonWidth * context.orientation.scale
        //view.frame.origin.y = (CGFloat(index) * 30) * context.orientation.scale
    }
    
    //    override func visibleWidthsForViews(with context: ActionsViewLayoutContext) -> [CGFloat] {
    //        return super.visibleWidthsForViews(with: context).reversed()
    //    }
    
    override public func visibleWidthsForViews(with context: ActionsViewLayoutContext) -> [CGFloat] {
        //print ("", context.contentSize.width)
        return (0..<context.numberOfActions)
            .map({ _ in return CGFloat(max(0, min(context.minimumButtonWidth, context.visibleWidth))) })
    }
    
    public required init() {
        
    }
}
