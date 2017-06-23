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
        self.delegate = detailController
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var shouldAutorotate : Bool {
        return true
    }
}
