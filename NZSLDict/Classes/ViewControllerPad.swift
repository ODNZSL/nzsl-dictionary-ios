import Foundation
import UIKit

class ViewControllerPad: UISplitViewController {
    var searchController: SearchViewController!
    var historyController: HistoryViewController!
    var detailController: DetailViewController!

    // These were in the ObjC version but I don't think they are used now
    // var diagramController: UIViewController!
    // var videoController: UIViewController!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        searchController = SearchViewController()
        historyController = HistoryViewController()
        detailController = DetailViewController()

        let tabbar = UITabBarController()
        tabbar.viewControllers = [searchController, historyController]

        self.viewControllers = [tabbar, detailController]
        self.preferredDisplayMode = .allVisible
        self.delegate = detailController
    }
    
    override func viewDidLayoutSubviews() {
        let kMasterViewWidth: CGFloat = 320.0

        let masterViewController = viewControllers[0]
        let detailViewController = viewControllers[1]

        if detailViewController.view.frame.origin.x > 0.0 {
            // Adjust the width of the master view
            var masterViewFrame = masterViewController.view.frame
            let deltaX = masterViewFrame.size.width - kMasterViewWidth
            masterViewFrame.size.width -= deltaX
            masterViewController.view.frame = masterViewFrame

            // Adjust the width of the detail view
            var detailViewFrame = detailViewController.view.frame
            detailViewFrame.origin.x -= deltaX
            detailViewFrame.size.width += deltaX
            detailViewController.view.frame = detailViewFrame

            masterViewController.view.setNeedsLayout()
            detailViewController.view.setNeedsLayout()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var shouldAutorotate : Bool {
        return true
    }
}
