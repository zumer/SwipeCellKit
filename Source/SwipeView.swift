//
//  SwipeView.swift
//  SwipeCellKit
//
//  Created by Evgeny on 6/18/18.
//

import UIKit

open class SwipeView: UIView {
    /// The object that acts as the delegate of the `SwipeTableViewCell`.
    public weak var delegate: SwipeTableViewCellDelegate?
    
    var state = SwipeState.center
    //var actionsView: SwipeActionsView?
    var actionsView: (UIView & SwipeActionsViewProtocol)?
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
    
    let swipeView: UIView
    let actionsContainerView: UIView
    
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

    public init( swipeView: UIView, actionsContainerView: UIView ) {
        self.swipeView = swipeView
        self.actionsContainerView = actionsContainerView
        
        super.init(frame: .zero)

        configure()
    }
    
    /// :nodoc:
    required public init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
//        super.init(coder: aDecoder)
//
//        configure()
    }
    
    deinit {
        tableView?.panGestureRecognizer.removeTarget(self, action: nil)
    }
    
    func configure() {
        clipsToBounds = false
        
        swipeController = SwipeController(swipeable: self, actionsContainerView: self)
        swipeController.delegate = self
    }
    
    /////////////////
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        var view: UIView = self
        while let superview = view.superview {
            view = superview
            
            if let tableView = view as? UITableView {
                self.tableView = tableView
                
                swipeController.scrollView = tableView;
                
                tableView.panGestureRecognizer.removeTarget(self, action: nil)
                tableView.panGestureRecognizer.addTarget(self, action: #selector(handleTablePan(gesture:)))
                return
            }
        }
    }
    
    // Override so we can accept touches anywhere within the cell's minY/maxY.
    // This is required to detect touches on the `SwipeActionsView` sitting alongside the
    // `SwipeTableCell`.
    /// :nodoc:
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let superview = superview else { return false }
        
        let point = convert(point, to: superview)
        
        if !UIAccessibilityIsVoiceOverRunning() {
            for cell in tableView?.swipeCells ?? [] {
                if (cell.state == .left || cell.state == .right) && !cell.contains(point: point) {
                    tableView?.hideSwipeCell()
                    return false
                }
            }
        }
        
        return contains(point: point)
    }
    
    func contains(point: CGPoint) -> Bool {
        return point.y > frame.minY && point.y < frame.maxY
    }
    
    /// :nodoc:
    override open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return swipeController.gestureRecognizerShouldBegin(gestureRecognizer)
    }
    
    /// :nodoc:
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        swipeController.traitCollectionDidChange(from: previousTraitCollection, to: self.traitCollection)
    }
    
    @objc func handleTablePan(gesture: UIPanGestureRecognizer) {
        if gesture.state == .began {
            hideSwipe(animated: true)
        }
    }
    /////////////////
    
    func reset() {
        swipeController.reset()
        clipsToBounds = false
    }
    
    func resetSelectedState() {
        if isPreviouslySelected {
            if let tableView = tableView, let tableViewCell = tableViewCell, let indexPath = tableView.indexPath(for: tableViewCell) {
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            }
        }
        isPreviouslySelected = false
    }
}

extension SwipeView: Swipeable {}

extension SwipeView: SwipeControllerDelegate {
    func swipeController(_ controller: SwipeController, canBeginEditingSwipeableFor orientation: SwipeActionsOrientation) -> Bool {
        return false //self.isEditing == false
    }
    
    func swipeController(_ controller: SwipeController, editActionsForSwipeableFor orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard let tableView = tableView, let tableViewCell = tableViewCell, let indexPath = tableView.indexPath(for: tableViewCell) else { return nil }
        
        return delegate?.tableView(tableView, editActionsForRowAt: indexPath, for: orientation)
    }
    
    func swipeController(_ controller: SwipeController, editActionsOptionsForSwipeableFor orientation: SwipeActionsOrientation) -> SwipeOptions {
        guard let tableView = tableView, let tableViewCell = tableViewCell, let indexPath = tableView.indexPath(for: tableViewCell) else { return SwipeOptions() }
        
        return delegate?.tableView(tableView, editActionsOptionsForRowAt: indexPath, for: orientation) ?? SwipeOptions()
    }
    
    func swipeController(_ controller: SwipeController, visibleRectFor scrollView: UIScrollView) -> CGRect? {
        guard let tableView = tableView else { return nil }
        
        return delegate?.visibleRect(for: tableView)
    }
    
    func swipeController(_ controller: SwipeController, willBeginEditingSwipeableFor orientation: SwipeActionsOrientation) {
        guard let tableView = tableView, let tableViewCell = tableViewCell, let indexPath = tableView.indexPath(for: tableViewCell) else { return }
        
        // Remove highlight and deselect any selected cells
        tableViewCell.setHighlighted(false, animated: false)
        isPreviouslySelected = tableViewCell.isSelected
        tableView.deselectRow(at: indexPath, animated: false)
        
        delegate?.tableView(tableView, willBeginEditingRowAt: indexPath, for: orientation)
    }
    
    func swipeController(_ controller: SwipeController, didEndEditingSwipeableFor orientation: SwipeActionsOrientation) {
        guard let tableView = tableView, let tableViewCell = tableViewCell, let indexPath = tableView.indexPath(for: tableViewCell), let actionsView = self.actionsView else { return }
        
        resetSelectedState()
        
        delegate?.tableView(tableView, didEndEditingRowAt: indexPath, for: actionsView.orientation)
    }
    
    func swipeController(_ controller: SwipeController, didDeleteSwipeableAt indexPath: IndexPath) {
        tableView?.deleteRows(at: [indexPath], with: .none)
    }
}
