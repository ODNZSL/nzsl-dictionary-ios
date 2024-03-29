import UIKit

class HistoryViewController: UITableViewController {
    var delegate: SearchViewControllerDelegate!
    var history: [DictEntry] = []

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    override init(style: UITableView.Style) {
        super.init(style: style)
        self.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarItem.SystemItem.mostRecent, tag: 0)
            
        NotificationCenter.default.addObserver(self, selector: #selector(HistoryViewController.addEntry(_:)), name: .entrySelectedName, object: nil)
    }

    convenience init() {
        self.init(style: UITableView.Style.plain)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = false
        self.tableView.contentInset = UIEdgeInsets.init(top: 20, left: 0, bottom: 0, right: 0)
    }

    @objc func addEntry(_ notification: Notification) {

        guard let userInfo = notification.userInfo else {
            fatalError("Got not userInfo dictionary")
        }

        if userInfo.keys.contains("no_add_history") { return }

        guard let entry: DictEntry = userInfo["entry"] as? DictEntry else {
            fatalError("Failed to extract a DictEntry from userInfo")
        }

        // if the current entry is in the history array then remove it
        if let i = history.firstIndex(of: entry) {
            history.remove(at: i)
        }

        // insert the current entry at the start of the history array
        history.insert(entry, at: 0)

        // Keep the history array to the desired maximum length
        while (history.count > 100) {
            history.removeLast()
        }

        self.tableView.reloadData()
    }

    // MARK: Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.count
    }


    // MARK: Table view delegate

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellIdentifier = "Cell"
        let entry: DictEntry = history[indexPath.row]

        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)

        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
            let iv = UIImageView(frame: CGRect(x: 0, y: 2, width: 40, height: 40))
            iv.contentMode = .scaleAspectFit
            cell?.accessoryView = iv
        }

        cell?.textLabel?.text = entry.gloss
        cell?.detailTextLabel?.text = entry.minor

        if let iv = cell?.accessoryView as? UIImageView {
            iv.image = UIImage(named: "50.\(entry.image!)")
            iv.highlightedImage = iv.image?.transparentImage() // TODO do I need this?
        }

        return cell!
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dictEntryFromHistory = history[indexPath.row]
        let userInfo = [
            "entry": dictEntryFromHistory,
            "no_add_history": "no_add"
        ] as [String : Any]

        NotificationCenter.default.post(name: .entrySelectedName, object: self, userInfo: userInfo)
        self.delegate?.didSelectEntry(dictEntryFromHistory)
    }
}
