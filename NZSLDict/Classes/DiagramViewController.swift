import UIKit

class DiagramViewController: UIViewController, UISearchBarDelegate {
    var delegate: ViewControllerDelegate!
    var currentEntry: DictEntry!
    var diagramView: DiagramView!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.tabBarItem = UITabBarItem(title: "Diagram", image: UIImage(named: "hands"), tag: 0)
        NotificationCenter.default.addObserver(self, selector: #selector(DiagramViewController.showEntry(_:)), name: .entrySelectedName, object: nil)
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
        view.backgroundColor = UIColor(named: "app-background")
        
        diagramView = DiagramView(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height).insetBy(dx: 16.0, dy: 16.0))
        view.addSubview(diagramView)
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if self.responds(to: #selector(getter: UIViewController.edgesForExtendedLayout)) {
            self.edgesForExtendedLayout = UIRectEdge()
        }
        
        if #available(iOS 15.0, *) {
            self.tabBarController?.tabBar.scrollEdgeAppearance = self.tabBarController?.tabBar.standardAppearance
        }
    }
    
    func selectSearchMode(_ sender: UISegmentedControl) {
            self.tabBarController?.selectedIndex = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        self.showCurrentEntry()
    }

    @objc func showEntry(_ notification: Notification) {
        currentEntry = (notification.userInfo!["entry"] as! DictEntry)
        if diagramView == nil {
            return
        }
        self.showCurrentEntry()
    }

    func showCurrentEntry() {
        diagramView.showEntry(currentEntry)
    }
}
