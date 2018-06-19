//
//  SwipeView.swift
//  SwipeCellKit
//
//  Created by Evgeny on 6/18/18.
//

import UIKit

open class SwipeView: UIView {

//    var state: SwipeState { get set }
//
//    var actionsView: SwipeActionsView? { get set }
//
//    var frame: CGRect { get }
//
//    var scrollView: UIScrollView? { get }
//
//    var indexPath: IndexPath? { get }
//
//    var panGestureRecognizer: UIGestureRecognizer { get }

    
    /// The object that acts as the delegate of the `SwipeTableViewCell`.
    public weak var delegate: SwipeTableViewCellDelegate?
    
    var state = SwipeState.center
    var actionsView: SwipeActionsView?
    var scrollView: UIScrollView? {
        return tableView
    }
    var indexPath: IndexPath? {
        
        guard let cell = self.tableViewCell else {
            return IndexPath(row: 0, section: 0)
        }
        
        return tableView?.indexPath(for: cell)
    }
    var panGestureRecognizer: UIGestureRecognizer
    {
        return swipeController.panGestureRecognizer;
    }
    
    var swipeController: SwipeController!
    var isPreviouslySelected = false
    
    weak var tableViewCell: UITableViewCell?
    weak var tableView: UITableView?
    
    /// :nodoc:
    open override var frame: CGRect {
        set { super.frame = state.isActive ? CGRect(origin: CGPoint(x: frame.minX, y: newValue.minY), size: newValue.size) : newValue }
        get { return super.frame }
    }
    
    /// :nodoc:
    open override var layoutMargins: UIEdgeInsets {
        get {
            return frame.origin.x != 0 ? swipeController.originalLayoutMargins : super.layoutMargins
        }
        set {
            super.layoutMargins = newValue
        }
    }

}

extension SwipeView: Swipeable {}
