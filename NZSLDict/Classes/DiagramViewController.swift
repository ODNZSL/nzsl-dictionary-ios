import UIKit

class DiagramViewController: UIViewController, UISearchBarDelegate {
    var delegate: ViewControllerDelegate!
    var currentEntry: DictEntry!
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
        
        diagramView = DiagramView(frame: CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height))
        view.addSubview(diagramView)
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if self.respondsToSelector("edgesForExtendedLayout") {
            self.edgesForExtendedLayout = .None
        }
    }
    
    func selectSearchMode(sender: UISegmentedControl) {
            self.tabBarController?.selectedIndex = 0
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
        diagramView.showEntry(currentEntry)
    }
}
