import UIKit

class DiagramViewController: UIViewController, UISearchBarDelegate {
    var delegate: ViewControllerDelegate!
    var currentEntry: DictEntry!
    var diagramView: DiagramView!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.tabBarItem = UITabBarItem(title: "Diagram", image: UIImage(named: "hands"), tag: 0)
        NotificationCenter.default.addObserver(self, selector: #selector(DiagramViewController.showEntry(_:)), name: NSNotification.Name(rawValue: EntrySelectedName), object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func loadView() {
        let view: UIView = UIView(frame: UIScreen.main.bounds)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        diagramView = DiagramView(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height))
        view.addSubview(diagramView)
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if self.responds(to: #selector(getter: UIViewController.edgesForExtendedLayout)) {
            self.edgesForExtendedLayout = UIRectEdge()
        }
    }
    
    func selectSearchMode(_ sender: UISegmentedControl) {
            self.tabBarController?.selectedIndex = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        self.showCurrentEntry()
    }

    func showEntry(_ notification: Notification) {
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
