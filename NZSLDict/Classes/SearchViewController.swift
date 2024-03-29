import UIKit
import WebKit

// TODO these were static in theold obj C - TODO move them
let HandshapeAnyCellIdentifier: String = "CellAny"
let HandshapeIconCellIdentifier: String = "CellIcon"

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UICollectionViewDataSource, UICollectionViewDelegate , WKNavigationDelegate {

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
    var aboutContentWebView: WKWebView!

    // This is a fixed default in iOS
    var detailViewMasterWidth = CGFloat(320)
    var statusBarHeight = CGFloat(20)

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

    func onPad()-> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }

    // MARK View lifecycle


    override func loadView() {
        if (onPad()) {
            // Create search frame set to fit within the master frame of the
            // detail view controller;
            // @see DetailViewController
            self.view = UIView.init(frame: CGRect(x: 0, y: statusBarHeight, width: detailViewMasterWidth, height: UIScreen.main.bounds.height))
        } else {
            self.view = UIView.init(frame: UIScreen.main.bounds)
        }

        view.backgroundColor = UIColor(named: "app-background")
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.autoresizesSubviews = true

        let searchBarPadding = CGFloat(8.0)
        searchBar = UISearchBar(frame: CGRect(x: 0, y: onPad() ? statusBarHeight : searchBarPadding, width: view.bounds.size.width, height: onPad() ? 96 : 44 + (searchBarPadding * 2)))
        searchBar.autoresizingMask = [.flexibleWidth]
        searchBar.tintAdjustmentMode = .normal
        searchBar.isTranslucent = false
        searchBar.barTintColor = .appThemePrimaryColor
        if #available(iOS 13.0, *) { // Dark mode adjustments
            searchBar.searchTextField.leftView?.tintColor = .black
        }

        searchBar.delegate = self
        self.view.addSubview(searchBar)

        modeSwitch = UISegmentedControl(items: ["Abc", UIImage(named: "hands")!])
        modeSwitch.autoresizingMask = .flexibleLeftMargin
        modeSwitch.frame = CGRect(x: view.bounds.size.width -
                                  modeSwitch.bounds.size.width - 8, y: 0 + 16, width: modeSwitch.bounds.size.width, height: 32)
        modeSwitch.selectedSegmentIndex = 0
        modeSwitch.tintColor = UIColor.white;
        modeSwitch.addTarget(self, action: #selector(SearchViewController.selectSearchMode(_:)), for: .valueChanged)

        self.view.addSubview(modeSwitch)
        searchTable = UITableView(frame: CGRect(x: 0, y: onPad() ? 96 : 44 + (searchBarPadding * 2), width: view.frame.size.width, height: view.frame.size.height))
        searchTable.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        searchTable.estimatedRowHeight = 64
        searchTable.rowHeight = UITableView.automaticDimension
        searchTable.dataSource = self
        searchTable.delegate = self

        view.addSubview(searchTable)
        swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(SearchViewController.hideKeyboard))
        swipeRecognizer.direction = [.up, .down]
        swipeRecognizer.delegate = self
        searchTable.addGestureRecognizer(swipeRecognizer)

        scrollView = UIScrollView.init(frame: searchTable.frame);
        scrollView.contentSize = CGSize.init(width: self.view.frame.width, height: 600)
        scrollView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        scrollView.backgroundColor = .appThemePrimaryLightColor



        wotdView = UIView.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 125))
        wotdView.backgroundColor = UIColor(named: "app-background")
        wotdView.autoresizingMask = [.flexibleWidth]

        wotdLabel = UILabel(frame: CGRect(x: 16, y: 16, width: wotdView.bounds.size.width * 0.7, height: UIFont.preferredFont(forTextStyle: .subheadline).lineHeight))
        wotdLabel.autoresizingMask = .flexibleHeight
        wotdLabel.text = "Word of the day"
        wotdLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        wotdLabel.textColor = .appSecondaryTextColour
        wotdView.addSubview(wotdLabel)

        wotdGlossLabel = UILabel(frame: CGRect(x: 16, y: wotdLabel.frame.maxY, width: wotdView.bounds.size.width * 0.6, height: 24))
        wotdGlossLabel.autoresizingMask = .flexibleHeight
        wotdGlossLabel.numberOfLines = 0
        wotdGlossLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        wotdView.addSubview(wotdGlossLabel)



        wotdImageView = UIImageView(frame: CGRect(x: wotdView.bounds.width * 0.7, y: wotdView.bounds.minY + 16.0, width: wotdView.bounds.width * 0.3 - 16, height: wotdView.bounds.height - 32.0))
        wotdImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        wotdImageView.backgroundColor = UIColor(named: "app-background")
        wotdImageView.contentMode = .scaleAspectFit
        wotdImageView.isUserInteractionEnabled = true
        wotdView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SearchViewController.selectWotd(_:))))
        wotdView.addSubview(wotdImageView)

        aboutContentWebView = WKWebView.init(frame: CGRect(x: 0, y: wotdView.frame.maxY + 44, width: wotdView.frame.width, height: 400))
        if onPad() {
            aboutContentWebView.frame = aboutContentWebView.frame.insetBy(dx: 16.0, dy: 16.0)
        }
        aboutContentWebView.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        aboutContentWebView.navigationDelegate = self

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
        handshapeSelector.backgroundColor = UIColor(named: "app-background")
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
        locationSelector.backgroundColor = UIColor(named: "app-background")
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
        aboutContentWebView.load(request)


        dict = SignsDictionary(file: "nzsl.dat")
        wordOfTheDay = dict.wordOfTheDay()

        tabBarController?.title = nil
        let navbarTitleFirstSegment = UILabel()
        let navbarTitleSecondSegment = UILabel()

        navbarTitleFirstSegment.textColor = UIColor.white;
        navbarTitleSecondSegment.textColor = UIColor.white;

        if navbarTitleFirstSegment.responds(to: #selector(setter: UITextField.attributedText)) {

            let navbarTitleFirstSegmentText = NSMutableAttributedString(string: "NZSL", attributes: [NSAttributedString.Key.font: UIFont.init(name: "Montserrat-Bold", size: 22)!])
            let navbarTitleSecondSegmentText = NSMutableAttributedString(string: "dictionary", attributes: [NSAttributedString.Key.font: UIFont.init(name: "Montserrat-Italic", size: 22)!])

            navbarTitleFirstSegment.attributedText = navbarTitleFirstSegmentText
            navbarTitleSecondSegment.attributedText = navbarTitleSecondSegmentText
        }
        else {
            navbarTitleFirstSegment.text = "NZSL "
            navbarTitleSecondSegment.text = "dictionary"
        }

        navbarTitleFirstSegment.sizeToFit();
        navbarTitleSecondSegment.sizeToFit();

        self.tabBarController!.navigationItem.setLeftBarButtonItems([
            UIBarButtonItem.init(customView: navbarTitleFirstSegment),
            UIBarButtonItem.init(customView: navbarTitleSecondSegment)
        ], animated: false)


        let navigationBarRightButtonItem = UIBarButtonItem.init(customView: modeSwitch);
        self.tabBarController!.navigationItem.setRightBarButton(navigationBarRightButtonItem, animated: false)

        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .appThemePrimaryColor
            self.tabBarController!.navigationItem.scrollEdgeAppearance = appearance
            self.tabBarController!.navigationItem.standardAppearance = appearance
            
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            tabBarAppearance.backgroundColor = UIColor(named: "app-background")
            self.tabBarController!.tabBar.scrollEdgeAppearance = tabBarAppearance
            self.tabBarController!.tabBar.standardAppearance = tabBarAppearance
        }

        wotdGlossLabel.text = wordOfTheDay.gloss
        wotdGlossLabel.sizeToFit()

        wotdImageView.image = UIImage(named: wordOfTheDay.image)
        wotdImageView.backgroundColor = UIColor.white

        if #available(iOS 13.0, *) {
            wotdImageView.image = UIImage(named: wordOfTheDay.image)?.withRenderingMode(.alwaysOriginal)
        } else {
            wotdImageView.image = UIImage(named: wordOfTheDay.image)
        }
        self.selectEntry(wordOfTheDay)

        handshapeSelector.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .left)
        locationSelector.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .left)
        self.selectSearchMode(modeSwitch)
        searchBar.resignFirstResponder()
    }

    //    override func viewDidLayoutSubviews() {
    //        // Autosize the scrollview
    //        var contentRect = CGRect.zero
    //        for view: UIView in self.scrollView.subviews {
    //            contentRect = contentRect.union(view.frame)
    //        }
    //        self.scrollView.contentSize = contentRect.size
    //        self.scrollView.contentSize.height = contentRect.size.height + 150
    //    }

    // MARK: Callback functions
    @objc func selectWotd(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            self.selectEntry(wordOfTheDay)
            searchBar.resignFirstResponder()
            self.delegate?.didSelectEntry(wordOfTheDay)
        }
    }

    @objc func selectSearchMode(_ sender: UISegmentedControl) {
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
        if searchText.count == 0 {
            scrollView.isHidden = false
            return
        }
        scrollView.isHidden = true
        searchResults = dict.search(for: searchText)! as [AnyObject]
        searchTable.reloadData()
    }

    func selectEntry(_ entry: DictEntry) {
        NotificationCenter.default.post(name: .entrySelectedName, object: nil, userInfo: ["entry": entry])
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    @objc func hideKeyboard() {
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

        var cell = tableView.dequeueReusableCell(withIdentifier: cellId)

        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
            let cellImageView = UIImageView(frame: CGRect(x: 0,y: 0,width: 40, height: 40))
            cellImageView.contentMode = .scaleAspectFit
            cell?.accessoryView = cellImageView
        }

        let e: DictEntry = searchResults[indexPath.row] as! DictEntry
        cell?.textLabel?.text = e.gloss
        cell?.detailTextLabel?.text = e.minor

        if let iv = cell?.accessoryView as? UIImageView {
            let image = UIImage(named: e.image)
            iv.image = image
            iv.highlightedImage = image?.transparentImage()
        }

        return cell!
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entry: DictEntry = searchResults[indexPath.row] as! DictEntry
        self.selectEntry(entry)
        searchBar.resignFirstResponder()
        self.delegate?.didSelectEntry(entry)
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
            var label: UILabel! = cell.contentView.viewWithTag(1) as! UILabel?
            if label == nil {
                label = UILabel(frame: cell.contentView.bounds.insetBy(dx: 3, dy: 3))
                label.tag = 1
                label.text = "(any)"
                label.textAlignment = .center
                label.backgroundColor = UIColor(named: "app-background")
                cell.contentView.addSubview(label)
                cell.selectedBackgroundView = UIView(frame: cell.contentView.frame)
                cell.selectedBackgroundView!.backgroundColor = UIColor(named: "brand-accent")
            }
        }
        else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: HandshapeIconCellIdentifier, for: indexPath)

            var img: UIImageView! = cell.contentView.viewWithTag(1) as! UIImageView?
            if img == nil {
                img = UIImageView(frame: cell.contentView.bounds.insetBy(dx: 3, dy: 3))
                img.tag = 1
                img.contentMode = .scaleAspectFit
                cell.contentView.addSubview(img)
                cell.selectedBackgroundView = UIView(frame: cell.contentView.frame)
                cell.selectedBackgroundView!.backgroundColor = UIColor(named: "brand-accent")
            }
            if collectionView == handshapeSelector {
                img.image = UIImage(named: "handshape.\(handShapes[indexPath.row]).png")
            }
            else if collectionView == locationSelector {
                img.image = UIImage(named: Locations[indexPath.row][1])
            }

            img.backgroundColor = UIColor(named: "app-background")
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
        searchResults = dict.searchHandshape(targetHandshape, location: location)! as [AnyObject]
        searchTable.reloadData()
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        var action: WKNavigationActionPolicy?

        defer {
            decisionHandler(action ?? .allow)
        }

        guard let url = navigationAction.request.url else { return }
        print("decidePolicyFor - url: \(url)")

        if url.isFileURL { return }
        if url.scheme == "follow" {
            action = .cancel
            _ = openTwitterClientForUserName("NZSLDict")
            return
        }

        if #available(iOS 10, *) {
           UIApplication.shared.open(url, options: [:],
           completionHandler: {
              (success) in
              print("Open \(url): \(success)")
            })
         } else {
              let success = UIApplication.shared.openURL(url)
              print("Open \(url): \(success)")
         }
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

        for candidate in urls {
            let urlString = candidate.replacingOccurrences(of: "{username}", with:userName)
            if let url = URL(string: urlString) {
                    if #available(iOS 10, *) {
                       UIApplication.shared.open(url, options: [:],
                       completionHandler: {
                          (success) in
                          print("Open \(url): \(success)")
                        })
                     } else {
                          let success = UIApplication.shared.openURL(url)
                          print("Open \(url): \(success)")
                 }
            }
        }

        return false
    }

}



