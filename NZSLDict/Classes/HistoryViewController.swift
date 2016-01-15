import Foundation
import UIKit

class HistoryViewController: UITableViewController {
    var delegate: SearchViewControllerDelegate!
    var history: [DictEntry] = []

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewStyle) {
        super.init(style: style)
        self.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.History, tag: 0)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addEntry:", name: EntrySelectedName, object: nil)
    }

    convenience init() {
        self.init(style: UITableViewStyle.Plain)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = false
        self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
    }

    func addEntry(notification: NSNotification) {

        guard let userInfo = notification.userInfo else {
            fatalError("Got not userInfo dictionary")
        }

        if userInfo.keys.contains("no_add_history") { return }

        guard let entry: DictEntry = userInfo["entry"] as? DictEntry else {
            fatalError("Failed to extract a DictEntry from userInfo")
        }

        // if the current entry is in the history array then remove it
        if let i = history.indexOf(entry) {
            history.removeAtIndex(i)
        }

        // insert the current entry at the start of the history array
        history.insert(entry, atIndex: 0)

        // Keep the history array to the desired maximum length
        while (history.count > 100) {
            history.removeLast()
        }

        self.tableView.reloadData()
    }

    // MARK: Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.count
    }


    // MARK: Table view delegate

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cellIdentifier = "Cell"
        let entry: DictEntry = history[indexPath.row]

        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)

        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: cellIdentifier)
            let iv: UIImageView = UIImageView(frame: CGRectMake(0, 2, tableView.rowHeight*2, tableView.rowHeight-4))
            iv.contentMode = UIViewContentMode.ScaleAspectFit
            cell!.accessoryView = iv
        }


        cell!.textLabel!.text = entry.gloss
        cell!.detailTextLabel!.text = entry.minor

        let iv: UIImageView = cell!.accessoryView as! UIImageView

        iv.image = UIImage(named: "50.\(entry.image)")

        iv.highlightedImage = transparent_image(iv.image) // TODO do I need this?

        return cell!
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let dictEntryFromHistory = history[indexPath.row]
        let userInfo = [
            "entry": dictEntryFromHistory,
            "no_add_history": "no_add"
        ]

        NSNotificationCenter.defaultCenter().postNotificationName(EntrySelectedName, object: self, userInfo: userInfo)
        self.delegate.didSelectEntry(dictEntryFromHistory)
    }
}