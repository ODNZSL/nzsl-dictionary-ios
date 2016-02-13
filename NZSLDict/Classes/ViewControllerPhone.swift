import UIKit

class ViewControllerPhone: UITabBarController, ViewControllerDelegate, SearchViewControllerDelegate {
    var searchController: SearchViewController!
    var diagramController: DiagramViewController!
    var videoController: VideoViewController!
    var historyController: HistoryViewController!
    var aboutController: AboutViewController!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        searchController = SearchViewController()
        diagramController = DiagramViewController()
        videoController = VideoViewController()
        historyController = HistoryViewController()
        aboutController = AboutViewController()

        self.viewControllers = [
            searchController,
            diagramController,
            videoController,
            historyController,
            aboutController
        ]

        searchController.delegate = self
        diagramController.delegate = self
        videoController.delegate = self
        historyController.delegate = self
    }

    // TODO: I'm not 100% that this old implementation can be replaced by what I did below
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
//{
//    return toInterfaceOrientation == UIInterfaceOrientationPortrait
//        || UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
//}
//
//    override func shouldAutorotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation) -> Bool {
//            return toInterfaceOrientation == UIInterfaceOrientation.Portrait
//        || UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
//    }
    override func shouldAutorotate() -> Bool {
        return true
    }

    func didSelectEntry(entry: DictEntry) {
        self.selectedViewController = diagramController
    }

    func returnToSearchView() {
        self.selectedViewController = searchController
    }
}