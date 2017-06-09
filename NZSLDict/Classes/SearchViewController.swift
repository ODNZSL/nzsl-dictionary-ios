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

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.tabBarItem = UITabBarItem(tabBarSystemItem: .Search, tag: 0)
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
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK View lifecycle

    override func loadView() {
        self.view = UIView.init(frame: UIScreen.mainScreen().applicationFrame)
        searchBar = PaddedUISearchBar(frame: CGRectMake(0, 0, view.bounds.size.width, 44))
        searchBar.autoresizingMask = .FlexibleWidth
        searchBar.barTintColor = AppThemePrimaryColor
        searchBar.delegate = self
        self.view.addSubview(searchBar)

        modeSwitch = UISegmentedControl(items: ["Abc", UIImage(named: "hands")!])
        modeSwitch.autoresizingMask = .FlexibleLeftMargin
        modeSwitch.frame = CGRectMake(view.bounds.size.width - modeSwitch.bounds.size.width - 4, 0 + 6, modeSwitch.bounds.size.width, 32)
        modeSwitch.selectedSegmentIndex = 0
        modeSwitch.tintColor = UIColor.whiteColor();
        modeSwitch.addTarget(self, action: #selector(SearchViewController.selectSearchMode(_:)), forControlEvents: .ValueChanged)
      
        self.view.addSubview(modeSwitch)
        searchTable = UITableView(frame: CGRectMake(0, 0 + 44, view.bounds.size.width, view.bounds.size.height - (0 + 44)))
        searchTable.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        searchTable.rowHeight = 50
        searchTable.dataSource = self
        searchTable.delegate = self
        
        view.addSubview(searchTable)
        swipeRecognizer = UISwipeGestureRecognizer(target: self, action: "hideKeyboard")
        swipeRecognizer.direction = [.Up, .Down]
        swipeRecognizer.delegate = self
        searchTable.addGestureRecognizer(swipeRecognizer)
        
        scrollView = UIScrollView.init(frame: searchTable.frame);
        scrollView.contentSize = CGSize.init(width: self.view.bounds.width, height: 600)
        scrollView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        scrollView.backgroundColor = UIColor.whiteColor()
        
        
        
        wotdView = UIView.init(frame: CGRectMake(0, 0, self.view.frame.width, 125))
        wotdView.autoresizingMask = .FlexibleWidth
        wotdView.backgroundColor = UIColor.whiteColor()
        
        wotdLabel = UILabel(frame: CGRectMake(16, 16, wotdView.bounds.size.width * 0.7, 20))
        wotdLabel.autoresizingMask = .FlexibleHeight
        wotdLabel.text = "Word of the day"
        wotdLabel.font = UIFont.systemFontOfSize(14)
        wotdLabel.textColor = AppSecondaryTextColour
        wotdView.addSubview(wotdLabel)
        
        wotdGlossLabel = UILabel(frame: CGRectMake(16, 40, wotdView.bounds.size.width * 0.6, 24))
        wotdGlossLabel.autoresizingMask = .FlexibleHeight
        wotdGlossLabel.numberOfLines = 0
        wotdGlossLabel.font = UIFont.systemFontOfSize(20)
        wotdGlossLabel.textColor = UIColor.blackColor();
        wotdView.addSubview(wotdGlossLabel)



        wotdImageView = UIImageView(frame: CGRectMake(wotdView.bounds.width * 0.7, 0, wotdView.bounds.width * 0.3 - 16, 125))
        wotdImageView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        wotdImageView.backgroundColor = UIColor.whiteColor()
        wotdImageView.contentMode = .ScaleAspectFit
        wotdImageView.userInteractionEnabled = true
        wotdView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "selectWotd:"))
        wotdView.addSubview(wotdImageView)
        
        
        aboutContentWebView = UIWebView.init(frame: CGRectMake(0, wotdView.bounds.maxY + 44, wotdView.frame.width, 500))
        aboutContentWebView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        aboutContentWebView.delegate = self
        
        scrollView.insertSubview(aboutContentWebView, belowSubview: wotdView)
        scrollView.addSubview(wotdView)
        
        self.view.addSubview(scrollView)

        
        searchSelectorView = UIView(frame: CGRectMake(0, 0, view.bounds.size.width, 200))
        searchSelectorView.autoresizingMask = .FlexibleWidth

        let handshapeLabel: UILabel = UILabel(frame: CGRectMake(0, 0, view.bounds.size.width, 20))
        handshapeLabel.autoresizingMask = .FlexibleWidth
        handshapeLabel.backgroundColor = UIColor.lightGrayColor()
        handshapeLabel.textColor = UIColor.whiteColor()
        handshapeLabel.shadowColor = UIColor.grayColor()
        handshapeLabel.shadowOffset = CGSizeMake(0, 1)
        handshapeLabel.font = UIFont.boldSystemFontOfSize(16)
        handshapeLabel.text = "  Handshape"
        searchSelectorView.addSubview(handshapeLabel)

        let hslayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        hslayout.scrollDirection = .Horizontal
        hslayout.itemSize = CGSizeMake(80, 80)
        handshapeSelector = UICollectionView(frame: CGRectMake(0, 20, view.bounds.size.width, 80), collectionViewLayout: hslayout)
        handshapeSelector.autoresizingMask = .FlexibleWidth
        handshapeSelector.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: HandshapeAnyCellIdentifier)
        handshapeSelector.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: HandshapeIconCellIdentifier)
        handshapeSelector.backgroundColor = UIColor.whiteColor()
        handshapeSelector.scrollsToTop = false
        handshapeSelector.dataSource = self
        handshapeSelector.delegate = self
        searchSelectorView.addSubview(handshapeSelector)

        let locationLabel: UILabel = UILabel(frame: CGRectMake(0, 100, view.bounds.size.width, 20))
        locationLabel.autoresizingMask = .FlexibleWidth
        locationLabel.backgroundColor = UIColor.lightGrayColor()
        locationLabel.textColor = UIColor.whiteColor()
        locationLabel.shadowColor = UIColor.grayColor()
        locationLabel.shadowOffset = CGSizeMake(0, 1)
        locationLabel.font = UIFont.boldSystemFontOfSize(16)
        locationLabel.text = "  Location"
        searchSelectorView.addSubview(locationLabel)

        let loclayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        loclayout.scrollDirection = .Horizontal
        loclayout.itemSize = CGSizeMake(80, 80)
        locationSelector = UICollectionView(frame: CGRectMake(0, 120, view.bounds.size.width, 80), collectionViewLayout: loclayout)
        locationSelector.autoresizingMask = .FlexibleWidth
        locationSelector.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: HandshapeAnyCellIdentifier)
        locationSelector.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: HandshapeIconCellIdentifier)
        locationSelector.backgroundColor = UIColor.whiteColor()
        locationSelector.scrollsToTop = false
        locationSelector.dataSource = self
        locationSelector.delegate = self
        searchSelectorView.addSubview(locationSelector)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if self.respondsToSelector("edgesForExtendedLayout") {
            self.edgesForExtendedLayout = .None
        }
        
        guard let aboutPath = NSBundle.mainBundle().pathForResource("about.html", ofType: nil) else {
            print("Failed to find about.html")
            return
        }
        
        let aboutUrl = NSURL(fileURLWithPath: aboutPath)
        let request = NSURLRequest(URL: aboutUrl)
        aboutContentWebView.loadRequest(request)


        dict = SignsDictionary(file: "nzsl.dat")
        wordOfTheDay = dict.wordOfTheDay()
        
        tabBarController?.title = nil
        let navbarTitleFirstSegment = UILabel()
        let navbarTitleSecondSegment = UILabel()
        navbarTitleFirstSegment.textColor = UIColor.whiteColor();
        navbarTitleSecondSegment.textColor = UIColor.whiteColor();
        
        if navbarTitleFirstSegment.respondsToSelector("setAttributedText:") {
            let navbarTitleFirstSegmentText = NSMutableAttributedString(string: "NZSL", attributes: [NSFontAttributeName: UIFont.boldSystemFontOfSize(22)])
            let navbarTitleSecondSegmentText = NSMutableAttributedString(string: "dictionary", attributes: [NSFontAttributeName: UIFont.italicSystemFontOfSize(22)])
        
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
        self.tabBarController?.navigationItem.setRightBarButtonItem(navigationBarRightButtonItem, animated: false)
        
        wotdGlossLabel.text = wordOfTheDay.gloss
        wotdGlossLabel.sizeToFit()
        wotdImageView.image = UIImage(named: wordOfTheDay.image)

        self.selectEntry(wordOfTheDay)

        handshapeSelector.selectItemAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: false, scrollPosition: .Left)
        locationSelector.selectItemAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: false, scrollPosition: .Left)
        self.selectSearchMode(modeSwitch)
    }

    override func viewDidAppear(animated: Bool) {
        if modeSwitch.selectedSegmentIndex == 0 && searchBar.text!.characters.count == 0 {
            searchBar.becomeFirstResponder()
        }
    }
    
    override func viewDidLayoutSubviews() {
        // Autosize the scrollview
        var contentRect = CGRectZero
        for view: UIView in self.scrollView.subviews {
            contentRect = CGRectUnion(contentRect, view.frame)
        }
        self.scrollView.contentSize = contentRect.size
        self.scrollView.contentSize.height = contentRect.size.height + 150
    }

    func selectWotd(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            self.selectEntry(wordOfTheDay)
            searchBar.resignFirstResponder()
            self.delegate.didSelectEntry(wordOfTheDay)
        }
    }

    func selectSearchMode(sender: UISegmentedControl) {
        self.tabBarController?.selectedIndex = 0
        switch sender.selectedSegmentIndex {
        case 0:
            searchBar.text = ""
            searchBar.userInteractionEnabled = true
            searchBar.becomeFirstResponder()
            scrollView.hidden = false
            searchTable.tableHeaderView = nil
            searchTable.reloadData()
        case 1:
            searchBar.text = "(handshape search)"
            searchBar.resignFirstResponder()
            searchBar.userInteractionEnabled = false
            scrollView.hidden = true
            searchTable.tableHeaderView = searchSelectorView

            // The UICollectionViewDelegate protocol requires that we provide an NSIndexPath instance
            // and prevents us from making it optional but the NSIndexPath we provide here is ignored
            // by our implementation
            self.collectionView(handshapeSelector, didSelectItemAtIndexPath: NSIndexPath(index: 0))
        default: break
        }

        if searchResults.count > 0 {
            searchTable.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Bottom, animated: false)
        }
    }

    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count == 0 {
            scrollView.hidden = false
            return
        }
        scrollView.hidden = true
        searchResults = dict.searchFor(searchText)
        searchTable.reloadData()
    }

    func selectEntry(entry: DictEntry) {
        NSNotificationCenter.defaultCenter().postNotificationName(EntrySelectedName, object: self, userInfo: ["entry": entry])
    }

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func hideKeyboard() {
        searchBar.resignFirstResponder()
    }

    // MARK: UITableViewDataSource methods

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(searchResults.count) sign\(searchResults.count == 1 ? "" : "s")"
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "Cell"

        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(cellId)

        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
            let iv: UIImageView = UIImageView(frame: CGRectMake(0, 2, tableView.rowHeight * 2, tableView.rowHeight - 4))
            iv.contentMode = .ScaleAspectFit
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

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let entry: DictEntry = searchResults[indexPath.row] as! DictEntry
        self.selectEntry(entry)
        searchBar.resignFirstResponder()
        self.delegate.didSelectEntry(entry)
    }


    // MARK: UICollectionViewDelegate methods

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == handshapeSelector {
            return handShapes.count
        }
        if collectionView == locationSelector {
            return Locations.count
        }
        return 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell
        if indexPath.row == 0 {
            cell = collectionView.dequeueReusableCellWithReuseIdentifier(HandshapeAnyCellIdentifier, forIndexPath: indexPath)
            var label: UILabel! = cell.contentView.viewWithTag(1) as! UILabel!
            if label == nil {
                label = UILabel(frame: CGRectInset(cell.contentView.bounds, 3, 3))
                label.tag = 1
                label.text = "(any)"
                label.textAlignment = .Center
                label.backgroundColor = UIColor.whiteColor()
                cell.contentView.addSubview(label)
                cell.selectedBackgroundView = UIView(frame: cell.contentView.frame)
                cell.selectedBackgroundView!.backgroundColor = UIColor.blueColor()
            }
        }
        else {
            cell = collectionView.dequeueReusableCellWithReuseIdentifier(HandshapeIconCellIdentifier, forIndexPath: indexPath)
            
            var img: UIImageView! = cell.contentView.viewWithTag(1) as! UIImageView!
            if img == nil {
                img = UIImageView(frame: CGRectInset(cell.contentView.bounds, 3, 3))
                img.tag = 1
                img.contentMode = .ScaleAspectFit
                cell.contentView.addSubview(img)
                cell.selectedBackgroundView = UIView(frame: cell.contentView.frame)
                cell.selectedBackgroundView!.backgroundColor = UIColor.blueColor()
            }
            if collectionView == handshapeSelector {
                img.image = UIImage(named: "handshape.\(handShapes[indexPath.row]).png")
            }
            else if collectionView == locationSelector {
                img.image = UIImage(named: Locations[indexPath.row][1])
            }
            
            img.backgroundColor = UIColor.whiteColor()
        }
        return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath _indexPath: NSIndexPath) {
        guard let handshapeIndexPath: [NSIndexPath] = handshapeSelector.indexPathsForSelectedItems() else { return }
        guard let locationIndexPath: [NSIndexPath] = locationSelector.indexPathsForSelectedItems() else { return }

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
        searchResults = dict.searchHandshape(targetHandshape, location: location)
        searchTable.reloadData()
    }
    
    
    func webViewDidStartLoad(webView: UIWebView) {
        var frame = webView.frame
        frame.size.height = 5.0
        webView.frame = frame
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        let mWebViewTextSize = webView.sizeThatFits(CGSizeMake(1.0, 1.0))
        // Pass about any size
        var mWebViewFrame = webView.frame
        mWebViewFrame.size.height = mWebViewTextSize.height
        webView.frame = mWebViewFrame
        //Disable bouncing in webview
        webView.scrollView.bounces = false
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if request.URL!.fileURL {
            return true
        }
        
        if request.URL!.scheme == "follow" {
            openTwitterClientForUserName("NZSLDict")
            return false
        }
        
        UIApplication.sharedApplication().openURL(request.URL!)
        return false
    }
    
    // https://gist.github.com/vhbit/958738
    func openTwitterClientForUserName(userName: String) -> Bool {
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
        
        let application: UIApplication = UIApplication.sharedApplication()
        
        for candidate in urls {
            let urlString = candidate.stringByReplacingOccurrencesOfString("{username}", withString:userName)
            if let url = NSURL(string: urlString) {
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



