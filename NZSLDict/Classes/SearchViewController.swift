import UIKit

// TODO these were static in theold obj C - TODO move them
let HandshapeAnyCellIdentifier: String = "CellAny"
let HandshapeIconCellIdentifier: String = "CellIcon"

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UICollectionViewDataSource, UICollectionViewDelegate , UIWebViewDelegate {

    var delegate: SearchViewControllerDelegate! // this was auto converted as 'weak var' TODO figure this out
    var dict: SignsDictionary!
    var wordOfTheDay: DictEntry!
    var modeSwitch: UISegmentedControl!
    var searchBar: UISearchBar!
    var searchTable: UITableView!
    var wotdView: UIView!
    var wotdLabel: UILabel!
    var wotdGlossLabel: UILabel!
    var wotdImageView: UIImageView!
    var searchSelectorView: UIView!
    var handshapeSelector: UICollectionView!
    var locationSelector: UICollectionView!
    var searchResults: [AnyObject] = [] // TODO tighten up the types here once SignsDictionary has been converted
    var swipeRecognizer: UISwipeGestureRecognizer!
    var subsequent_keyboard: Bool!
    var scrollView: UIScrollView!
    var aboutContentWebView: UIWebView!

    // MARK: Fixed datasource initialization
    // why do they leave the first element blank?
    // to match up with something thtat starts indexes at 1?
    let handShapes: [String] = [
        // nil,
        "1.1.1",
        "1.1.2",
        "1.1.3",
        "1.2.1",
        "1.2.2",
        "1.3.1",
        "1.3.2",
        "1.4.1",
        "2.1.1",
        "2.1.2",
        "2.2.1",
        "2.2.2",
        "2.3.1",
        "2.3.2",
        "2.3.3",
        "3.1.1",
        "3.2.1",
        "3.3.1",
        "3.4.1",
        "3.4.2",
        "3.5.1",
        "3.5.2",
        "4.1.1",
        "4.1.2",
        "4.2.1",
        "4.2.2",
        "4.3.1",
        "4.3.2",
        "5.1.1",
        "5.1.2",
        "5.2.1",
        "5.3.1",
        "5.3.2",
        "5.4.1",
        "6.1.1",
        "6.1.2",
        "6.1.3",
        "6.1.4",
        "6.2.1",
        "6.2.2",
        "6.2.3",
        "6.2.4",
        "6.3.1",
        "6.3.2",
        "6.4.1",
        "6.4.2",
        "6.5.1",
        "6.5.2",
        "6.6.1",
        "6.6.2",
        "7.1.1",
        "7.1.2",
        "7.1.3",
        "7.1.4",
        "7.2.1",
        "7.3.1",
        "7.3.2",
        "7.3.3",
        "7.4.1",
        "7.4.2",
        "8.1.1",
        "8.1.2",
        "8.1.3",
    ]

    let Locations: [[String]] = [
    //[nil, nil,
    ["in front of body", "location.1.1.in_front_of_body.png"],
    ["in front of face", "location.2.2.in_front_of_face.png"],
    ["head", "location.3.3.head.png"],
    ["top of head", "location.3.4.top_of_head.png"],
    ["eyes", "location.3.5.eyes.png"],
    ["nose", "location.3.6.nose.png"],
    ["ear", "location.3.7.ear.png"],
    ["cheek", "location.3.8.cheek.png"],
    ["lower head", "location.3.9.lower_head.png"],
    ["neck/throat", "location.4.10.neck_throat.png"],
    ["shoulders", "location.4.11.shoulders.png"],
    ["chest", "location.4.12.chest.png"],
    ["abdomen", "location.4.13.abdomen.png"],
    ["hips/pelvis/groin", "location.4.14.hips_pelvis_groin.png"],
    ["upper leg", "location.4.15.upper_leg.png"],
    ["upper arm", "location.5.16.upper_arm.png"],
    ["elbow", "location.5.17.elbow.png"],
    ["lower arm", "location.5.18.lower_arm.png"],
    ["wrist", "location.6.19.wrist.png"],
    ["fingers/thumb", "location.6.20.fingers_thumb.png"],
    ["back of hand", "location.6.22.back_of_hand.png"],
    //"palm",
    //"blades",
    ]

    // MARK: Initializers

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // In the old ObjC codebase this function was dispose() but did not seem to be called
    // from anywhere - converted it to deinit here as that seemed to make sense
    // func dispose() {
    //     NSNotificationCenter.defaultCenter().removeObserver(self)
    // }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK View lifecycle

    override func loadView() {
        self.view = UIView.init(frame: UIScreen.main.applicationFrame)
        searchBar = PaddedUISearchBar(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 44))
        searchBar.autoresizingMask = .flexibleWidth
        searchBar.barTintColor = AppThemePrimaryColor
        searchBar.delegate = self
        self.view.addSubview(searchBar)

        modeSwitch = UISegmentedControl(items: ["Abc", UIImage(named: "hands")!])
        modeSwitch.autoresizingMask = .flexibleLeftMargin
        modeSwitch.frame = CGRect(x: view.bounds.size.width - modeSwitch.bounds.size.width - 4, y: 0 + 6, width: modeSwitch.bounds.size.width, height: 32)
        modeSwitch.selectedSegmentIndex = 0
        modeSwitch.tintColor = UIColor.white;
        modeSwitch.addTarget(self, action: #selector(SearchViewController.selectSearchMode(_:)), for: .valueChanged)
      
        self.view.addSubview(modeSwitch)
        searchTable = UITableView(frame: CGRect(x: 0, y: 0 + 44, width: view.bounds.size.width, height: view.bounds.size.height - (0 + 44)))
        searchTable.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        searchTable.rowHeight = 50
        searchTable.dataSource = self
        searchTable.delegate = self
        
        view.addSubview(searchTable)
        swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(SearchViewController.hideKeyboard))
        swipeRecognizer.direction = [.up, .down]
        swipeRecognizer.delegate = self
        searchTable.addGestureRecognizer(swipeRecognizer)
        
        scrollView = UIScrollView.init(frame: searchTable.frame);
        scrollView.contentSize = CGSize.init(width: self.view.bounds.width, height: 600)
        scrollView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        scrollView.backgroundColor = UIColor.white
        
        
        
        wotdView = UIView.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 125))
        wotdView.autoresizingMask = .flexibleWidth
        wotdView.backgroundColor = UIColor.white
        
        wotdLabel = UILabel(frame: CGRect(x: 16, y: 16, width: wotdView.bounds.size.width * 0.7, height: 20))
        wotdLabel.autoresizingMask = .flexibleHeight
        wotdLabel.text = "Word of the day"
        wotdLabel.font = UIFont.systemFont(ofSize: 14)
        wotdLabel.textColor = AppSecondaryTextColour
        wotdView.addSubview(wotdLabel)
        
        wotdGlossLabel = UILabel(frame: CGRect(x: 16, y: 40, width: wotdView.bounds.size.width * 0.6, height: 24))
        wotdGlossLabel.autoresizingMask = .flexibleHeight
        wotdGlossLabel.numberOfLines = 0
        wotdGlossLabel.font = UIFont.systemFont(ofSize: 20)
        wotdGlossLabel.textColor = UIColor.black;
        wotdView.addSubview(wotdGlossLabel)



        wotdImageView = UIImageView(frame: CGRect(x: wotdView.bounds.width * 0.7, y: 0, width: wotdView.bounds.width * 0.3 - 16, height: 125))
        wotdImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        wotdImageView.backgroundColor = UIColor.white
        wotdImageView.contentMode = .scaleAspectFit
        wotdImageView.isUserInteractionEnabled = true
        wotdView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SearchViewController.selectWotd(_:))))
        wotdView.addSubview(wotdImageView)
        
        
        aboutContentWebView = UIWebView.init(frame: CGRect(x: 0, y: wotdView.bounds.maxY + 44, width: wotdView.frame.width, height: 500))
        aboutContentWebView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        aboutContentWebView.delegate = self
        
        scrollView.insertSubview(aboutContentWebView, belowSubview: wotdView)
        scrollView.addSubview(wotdView)
        
        self.view.addSubview(scrollView)

        
        searchSelectorView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 200))
        searchSelectorView.autoresizingMask = .flexibleWidth

        let handshapeLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 20))
        handshapeLabel.autoresizingMask = .flexibleWidth
        handshapeLabel.backgroundColor = UIColor.lightGray
        handshapeLabel.textColor = UIColor.white
        handshapeLabel.shadowColor = UIColor.gray
        handshapeLabel.shadowOffset = CGSize(width: 0, height: 1)
        handshapeLabel.font = UIFont.boldSystemFont(ofSize: 16)
        handshapeLabel.text = "  Handshape"
        searchSelectorView.addSubview(handshapeLabel)

        let hslayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        hslayout.scrollDirection = .horizontal
        hslayout.itemSize = CGSize(width: 80, height: 80)
        handshapeSelector = UICollectionView(frame: CGRect(x: 0, y: 20, width: view.bounds.size.width, height: 80), collectionViewLayout: hslayout)
        handshapeSelector.autoresizingMask = .flexibleWidth
        handshapeSelector.register(UICollectionViewCell.self, forCellWithReuseIdentifier: HandshapeAnyCellIdentifier)
        handshapeSelector.register(UICollectionViewCell.self, forCellWithReuseIdentifier: HandshapeIconCellIdentifier)
        handshapeSelector.backgroundColor = UIColor.white
        handshapeSelector.scrollsToTop = false
        handshapeSelector.dataSource = self
        handshapeSelector.delegate = self
        searchSelectorView.addSubview(handshapeSelector)

        let locationLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 100, width: view.bounds.size.width, height: 20))
        locationLabel.autoresizingMask = .flexibleWidth
        locationLabel.backgroundColor = UIColor.lightGray
        locationLabel.textColor = UIColor.white
        locationLabel.shadowColor = UIColor.gray
        locationLabel.shadowOffset = CGSize(width: 0, height: 1)
        locationLabel.font = UIFont.boldSystemFont(ofSize: 16)
        locationLabel.text = "  Location"
        searchSelectorView.addSubview(locationLabel)

        let loclayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        loclayout.scrollDirection = .horizontal
        loclayout.itemSize = CGSize(width: 80, height: 80)
        locationSelector = UICollectionView(frame: CGRect(x: 0, y: 120, width: view.bounds.size.width, height: 80), collectionViewLayout: loclayout)
        locationSelector.autoresizingMask = .flexibleWidth
        locationSelector.register(UICollectionViewCell.self, forCellWithReuseIdentifier: HandshapeAnyCellIdentifier)
        locationSelector.register(UICollectionViewCell.self, forCellWithReuseIdentifier: HandshapeIconCellIdentifier)
        locationSelector.backgroundColor = UIColor.white
        locationSelector.scrollsToTop = false
        locationSelector.dataSource = self
        locationSelector.delegate = self
        searchSelectorView.addSubview(locationSelector)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if self.responds(to: #selector(getter: UIViewController.edgesForExtendedLayout)) {
            self.edgesForExtendedLayout = UIRectEdge()
        }
        
        guard let aboutPath = Bundle.main.path(forResource: "about.html", ofType: nil) else {
            print("Failed to find about.html")
            return
        }
        
        let aboutUrl = URL(fileURLWithPath: aboutPath)
        let request = URLRequest(url: aboutUrl)
        aboutContentWebView.loadRequest(request)


        dict = SignsDictionary(file: "nzsl.dat")
        wordOfTheDay = dict.wordOfTheDay()
        
        tabBarController?.title = nil
        let navbarTitleFirstSegment = UILabel()
        let navbarTitleSecondSegment = UILabel()
        navbarTitleFirstSegment.textColor = UIColor.white;
        navbarTitleSecondSegment.textColor = UIColor.white;
        
        if navbarTitleFirstSegment.responds(to: #selector(setter: UITextField.attributedText)) {
            let navbarTitleFirstSegmentText = NSMutableAttributedString(string: "NZSL", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 22)])
            let navbarTitleSecondSegmentText = NSMutableAttributedString(string: "dictionary", attributes: [NSFontAttributeName: UIFont.italicSystemFont(ofSize: 22)])
        
            navbarTitleFirstSegment.attributedText = navbarTitleFirstSegmentText
            navbarTitleSecondSegment.attributedText = navbarTitleSecondSegmentText
        }
        else {
            navbarTitleFirstSegment.text = "NZSL "
            navbarTitleSecondSegment.text = "dictionary"
        }
        
        navbarTitleFirstSegment.sizeToFit();
        navbarTitleSecondSegment.sizeToFit();
        
        self.tabBarController?.navigationItem.setLeftBarButtonItems([
            UIBarButtonItem.init(customView: navbarTitleFirstSegment),
            UIBarButtonItem.init(customView: navbarTitleSecondSegment)
        ], animated: false)
        
        
        let navigationBarRightButtonItem = UIBarButtonItem.init(customView: modeSwitch);
        self.tabBarController?.navigationItem.setRightBarButton(navigationBarRightButtonItem, animated: false)
        
        wotdGlossLabel.text = wordOfTheDay.gloss
        wotdGlossLabel.sizeToFit()
        wotdImageView.image = UIImage(named: wordOfTheDay.image)

        self.selectEntry(wordOfTheDay)

        handshapeSelector.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .left)
        locationSelector.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .left)
        self.selectSearchMode(modeSwitch)
    }

    override func viewDidAppear(_ animated: Bool) {
        if modeSwitch.selectedSegmentIndex == 0 && searchBar.text!.characters.count == 0 {
            searchBar.becomeFirstResponder()
        }
    }
    
    override func viewDidLayoutSubviews() {
        // Autosize the scrollview
        var contentRect = CGRect.zero
        for view: UIView in self.scrollView.subviews {
            contentRect = contentRect.union(view.frame)
        }
        self.scrollView.contentSize = contentRect.size
        self.scrollView.contentSize.height = contentRect.size.height + 150
    }

    // MARK: Callback functions
    func selectWotd(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            self.selectEntry(wordOfTheDay)
            searchBar.resignFirstResponder()
            self.delegate.didSelectEntry(wordOfTheDay)
        }
    }

    func selectSearchMode(_ sender: UISegmentedControl) {
        self.tabBarController?.selectedIndex = 0
        switch sender.selectedSegmentIndex {
        case 0:
            searchBar.text = ""
            searchBar.isUserInteractionEnabled = true
            searchBar.becomeFirstResponder()
            scrollView.isHidden = false
            searchTable.tableHeaderView = nil
            searchTable.reloadData()
        case 1:
            searchBar.text = "(handshape search)"
            searchBar.resignFirstResponder()
            searchBar.isUserInteractionEnabled = false
            scrollView.isHidden = true
            searchTable.tableHeaderView = searchSelectorView

            // The UICollectionViewDelegate protocol requires that we provide an NSIndexPath instance
            // and prevents us from making it optional but the NSIndexPath we provide here is ignored
            // by our implementation
            self.collectionView(handshapeSelector, didSelectItemAt: IndexPath(index: 0))
        default: break
        }

        if searchResults.count > 0 {
            searchTable.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: false)
        }
    }

    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count == 0 {
            scrollView.isHidden = false
            return
        }
        scrollView.isHidden = true
        searchResults = dict.search(for: searchText) as! [AnyObject]
        searchTable.reloadData()
    }

    func selectEntry(_ entry: DictEntry) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: EntrySelectedName), object: self, userInfo: ["entry": entry])
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func hideKeyboard() {
        searchBar.resignFirstResponder()
    }

    // MARK: UITableViewDataSource methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(searchResults.count) sign\(searchResults.count == 1 ? "" : "s")"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "Cell"

        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellId)

        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
            let iv: UIImageView = UIImageView(frame: CGRect(x: 0, y: 2, width: tableView.rowHeight * 2, height: tableView.rowHeight - 4))
            iv.contentMode = .scaleAspectFit
            cell!.accessoryView = iv
        }

        let e: DictEntry = searchResults[indexPath.row] as! DictEntry
        cell!.textLabel!.text = e.gloss
        cell!.detailTextLabel!.text = e.minor
        let iv: UIImageView = cell!.accessoryView as! UIImageView
        iv.image = UIImage(named: "50.\(e.image)")
        iv.highlightedImage = transparent_image(iv.image)
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entry: DictEntry = searchResults[indexPath.row] as! DictEntry
        self.selectEntry(entry)
        searchBar.resignFirstResponder()
        self.delegate.didSelectEntry(entry)
    }


    // MARK: UICollectionViewDelegate methods

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == handshapeSelector {
            return handShapes.count
        }
        if collectionView == locationSelector {
            return Locations.count
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell
        if indexPath.row == 0 {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: HandshapeAnyCellIdentifier, for: indexPath)
            var label: UILabel! = cell.contentView.viewWithTag(1) as! UILabel!
            if label == nil {
                label = UILabel(frame: cell.contentView.bounds.insetBy(dx: 3, dy: 3))
                label.tag = 1
                label.text = "(any)"
                label.textAlignment = .center
                label.backgroundColor = UIColor.white
                cell.contentView.addSubview(label)
                cell.selectedBackgroundView = UIView(frame: cell.contentView.frame)
                cell.selectedBackgroundView!.backgroundColor = UIColor.blue
            }
        }
        else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: HandshapeIconCellIdentifier, for: indexPath)
            
            var img: UIImageView! = cell.contentView.viewWithTag(1) as! UIImageView!
            if img == nil {
                img = UIImageView(frame: cell.contentView.bounds.insetBy(dx: 3, dy: 3))
                img.tag = 1
                img.contentMode = .scaleAspectFit
                cell.contentView.addSubview(img)
                cell.selectedBackgroundView = UIView(frame: cell.contentView.frame)
                cell.selectedBackgroundView!.backgroundColor = UIColor.blue
            }
            if collectionView == handshapeSelector {
                img.image = UIImage(named: "handshape.\(handShapes[indexPath.row]).png")
            }
            else if collectionView == locationSelector {
                img.image = UIImage(named: Locations[indexPath.row][1])
            }
            
            img.backgroundColor = UIColor.white
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt _indexPath: IndexPath) {
        guard let handshapeIndexPath: [IndexPath] = handshapeSelector.indexPathsForSelectedItems else { return }
        guard let locationIndexPath: [IndexPath] = locationSelector.indexPathsForSelectedItems else { return }

        // empty arrays => no selected items
        if handshapeIndexPath.isEmpty || locationIndexPath.isEmpty { return }

        // if the NSIndexPath actually has something selected then we set that as the target
        // otherwise we
        var targetHandshape: String?
        var location: String?

        if handshapeIndexPath[0].row > 0 {
            targetHandshape = handShapes[handshapeIndexPath[0].row]
        }

        if locationIndexPath[0].row > 0 {
            location = Locations[locationIndexPath[0].row][0]
        }

        // searchHandshape(targetHandshape: String?, location: String?) -> [AnyObject]
        searchResults = dict.searchHandshape(targetHandshape, location: location) as! [AnyObject]
        searchTable.reloadData()
    }
    
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        var frame = webView.frame
        frame.size.height = 5.0
        webView.frame = frame
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        let mWebViewTextSize = webView.sizeThatFits(CGSize(width: 1.0, height: 1.0))
        // Pass about any size
        var mWebViewFrame = webView.frame
        mWebViewFrame.size.height = mWebViewTextSize.height
        webView.frame = mWebViewFrame
        //Disable bouncing in webview
        webView.scrollView.bounces = false
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if request.url!.isFileURL {
            return true
        }
        
        if request.url!.scheme == "follow" {
            openTwitterClientForUserName("NZSLDict")
            return false
        }
        
        UIApplication.shared.openURL(request.url!)
        return false
    }
    
    // https://gist.github.com/vhbit/958738
    func openTwitterClientForUserName(_ userName: String) -> Bool {
        let urls = [
            "twitter:@{username}", // Twitter
            "tweetbot:///user_profile/{username}", // TweetBot
            "echofon:///user_timeline?{username}", // Echofon
            "twit:///user?screen_name={username}", // Twittelator Pro
            "x-seesmic://twitter_profile?twitter_screen_name={username}", // Seesmic
            "x-birdfeed://user?screen_name={username}", // Birdfeed
            "tweetings:///user?screen_name={username}", // Tweetings
            "simplytweet:?link=http://twitter.com/{username}", // SimplyTweet
            "icebird://user?screen_name={username}", // IceBird
            "fluttr://user/{username}", // Fluttr
            /** uncomment if you don't have a special handling for no registered twitter clients */
            "http://twitter.com/{username}", // Web fallback,
        ]
        
        let application: UIApplication = UIApplication.shared
        
        for candidate in urls {
            let urlString = candidate.replacingOccurrences(of: "{username}", with:userName)
            if let url = URL(string: urlString) {
                print("testing \(url)")
                if application.canOpenURL(url) {
                    print("we can open \(url)")
                    application.openURL(url)
                    return true
                }
            }
        }
        
        return false
    }

}



