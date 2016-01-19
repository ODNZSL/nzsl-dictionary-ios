import UIKit

class DiagramViewController: UIViewController, UISearchBarDelegate {
    var delegate: ViewControllerDelegate!
    var currentEntry: DictEntry!
    var searchBar: UISearchBar!
    var diagramView: DiagramView!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.tabBarItem = UITabBarItem(title: "Diagram", image: UIImage(named: "hands"), tag: 0)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showEntry:", name: EntrySelectedName, object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func loadView() {
        let view: UIView = UIView(frame: UIScreen.mainScreen().bounds)
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        let top_offset: CGFloat = 20
        searchBar = UISearchBar(frame: CGRectMake(0, top_offset, view.bounds.size.width, 44))
        searchBar.autoresizingMask = .FlexibleWidth
        searchBar.delegate = self
        view.addSubview(searchBar)
        diagramView = DiagramView(frame: CGRectMake(0, top_offset + 44, view.bounds.size.width, view.bounds.size.height - (top_offset + 44)))
        view.addSubview(diagramView)
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if self.respondsToSelector("edgesForExtendedLayout") {
            self.edgesForExtendedLayout = .None
        }
    }

    override func viewDidAppear(animated: Bool) {
        self.showCurrentEntry()
    }

    func showEntry(notification: NSNotification) {
        currentEntry = notification.userInfo!["entry"] as! DictEntry
        if diagramView == nil {
            return
        }
        self.showCurrentEntry()
    }

    func showCurrentEntry() {
        searchBar.text = currentEntry.gloss
        diagramView.showEntry(currentEntry)
    }

    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }

    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        self.delegate.returnToSearchView()
        return false
    }
}
