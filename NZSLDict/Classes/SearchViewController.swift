import UIKit

// TODO these were static in theold obj C - TODO move them
let HandshapeAnyCellIdentifier: String = "CellAny"
let HandshapeIconCellIdentifier: String = "CellIcon"

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    var delegate: SearchViewControllerDelegate! // this was auto converted as 'weak var' TODO figure this out
    var dict: SignsDictionary!
    var wordOfTheDay: DictEntry!
    var modeSwitch: UISegmentedControl!
    var searchBar: UISearchBar!
    var searchTable: UITableView!
    var wotdView: UIView!
    var wotdLabel: UILabel!
    var wotdImageView: UIImageView!
    var searchSelectorView: UIView!
    var handshapeSelector: UICollectionView!
    var locationSelector: UICollectionView!
    var searchResults: [AnyObject] = [] // TODO tighten up the types here once SignsDictionary has been converted
    var swipeRecognizer: UISwipeGestureRecognizer!
    var subsequent_keyboard: Bool!

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

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "adjustForKeyboard:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "adjustForKeyboard:", name: UIKeyboardWillHideNotification, object: nil)
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
        let view: UIView = UIView(frame: UIScreen.mainScreen().bounds)
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        view.backgroundColor = UIColor(white: 0.9, alpha: 1)

        let top_offset: CGFloat = 20

        searchBar = UISearchBar(frame: CGRectMake(0, top_offset, view.bounds.size.width, 44))
        searchBar.autoresizingMask = .FlexibleWidth
        searchBar.placeholder = "Enter Word"
        searchBar.delegate = self
        view.addSubview(searchBar)

        modeSwitch = UISegmentedControl(items: ["Abc", UIImage(named: "hands")!])
        modeSwitch.autoresizingMask = .FlexibleLeftMargin
        modeSwitch.frame = CGRectMake(view.bounds.size.width - modeSwitch.bounds.size.width - 4, top_offset + 6, modeSwitch.bounds.size.width, 32)
        modeSwitch.selectedSegmentIndex = 0
        modeSwitch.addTarget(self, action: "selectSearchMode:", forControlEvents: .ValueChanged)

        view.addSubview(modeSwitch)
        searchTable = UITableView(frame: CGRectMake(0, top_offset + 44, view.bounds.size.width, view.bounds.size.height - (top_offset + 44)))
        searchTable.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        searchTable.rowHeight = 50
        searchTable.dataSource = self
        searchTable.delegate = self
        view.addSubview(searchTable)
        swipeRecognizer = UISwipeGestureRecognizer(target: self, action: "hideKeyboard")
        swipeRecognizer.direction = [.Up, .Down]
        swipeRecognizer.delegate = self
        searchTable.addGestureRecognizer(swipeRecognizer)

        wotdView = UIView(frame: searchTable.frame)
        wotdView.autoresizingMask = .FlexibleWidth
        wotdView.backgroundColor = UIColor.whiteColor()
        view.addSubview(wotdView)
        wotdLabel = UILabel(frame: CGRectMake(0, 0, wotdView.bounds.size.width, 20))
        wotdLabel.autoresizingMask = .FlexibleWidth
        wotdLabel.textAlignment = .Center
        wotdView.addSubview(wotdLabel)


        wotdImageView = UIImageView(frame: CGRectMake(0, 20, wotdView.bounds.size.width, wotdView.bounds.size.height - 20))
        wotdImageView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        wotdImageView.backgroundColor = UIColor.whiteColor()
        wotdImageView.contentMode = .ScaleAspectFit
        wotdImageView.userInteractionEnabled = true
        wotdImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "selectWotd:"))
        wotdView.addSubview(wotdImageView)
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
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if self.respondsToSelector("edgesForExtendedLayout") {
            self.edgesForExtendedLayout = .None
        }

        dict = SignsDictionary(file: "nzsl.dat")
        wordOfTheDay = dict.wordOfTheDay()

        if wotdLabel.respondsToSelector("setAttributedText:") {
            // iOS 6 supports attributed text in labels
            let xas: NSMutableAttributedString = NSMutableAttributedString(string: "Word of the day: ")
            xas.appendAttributedString(NSAttributedString(string: wordOfTheDay.gloss, attributes: [NSFontAttributeName: UIFont.boldSystemFontOfSize(18)]))
            wotdLabel.attributedText = xas
        }
        else {
            wotdLabel.text = "Word of the day: \(wordOfTheDay.gloss)"
        }

        wotdImageView.image = UIImage(named: wordOfTheDay.image)

        self.selectEntry(wordOfTheDay)

        handshapeSelector.selectItemAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: false, scrollPosition: .Left)
        locationSelector.selectItemAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: false, scrollPosition: .Left)
        self.selectSearchMode(modeSwitch)
    }

    func shrinkSearchBar() {
        let x: UIView = searchBar.subviews[0]
        let y: UIView = x.subviews[1]
        y.frame = CGRectMake(y.frame.origin.x, y.frame.origin.y, x.frame.size.width - (y.frame.origin.x * 2 + 100), y.frame.size.height)
    }

    override func viewDidLayoutSubviews() {
        self.shrinkSearchBar()
    }

    override func viewDidAppear(animated: Bool) {
        self.shrinkSearchBar()
        if modeSwitch.selectedSegmentIndex == 0 && searchBar.text!.characters.count == 0 {
            searchBar.becomeFirstResponder()
        }
    }


    // TODO: not sure this workaround required in ios7+ ???
    func adjustForKeyboard(notification: NSNotification) {
//        var v: NSValue = notification.userInfo![UIKeyboardFrameEndUserInfoKey as NSObject]
//        var kr: CGRect = v.CGRectValue()
//        // This workaround avoids a problem when launching on the iPad in non-portrait mode.
//        // On launch, the convertRect: call does not properly take into account the rotation
//        // from device coordinates to interface coordinates. We seem to be able to detect
//        // this when the following is true:
//        var interface_orientation: UIInterfaceOrientation = UIApplication.sharedApplication().statusBarOrientation
//        var device_orientation: UIDeviceOrientation = UIDevice.currentDevice().orientation
//        //NSLog(@"interface %d device %d", interface_orientation, device_orientation);
//        var fudge_rotation: Bool = Int(device_orientation) != Int(interface_orientation)
//
//        if fudge_rotation {
//            //NSLog(@"before fudge %g %g %g %g", kr.origin.x, kr.origin.y, kr.size.width, kr.size.height);
//            var screen: CGRect = UIScreen.mainScreen().bounds
//            switch interface_orientation {
//            case .LandscapeLeft:
//                kr = CGRectMake(screen.size.height - (kr.origin.y + kr.size.height), kr.origin.x, kr.size.height, kr.size.width)
//            case .LandscapeRight:
//                kr = CGRectMake(kr.origin.y, screen.size.width - (kr.origin.x + kr.size.width), kr.size.height, kr.size.width)
//            case .PortraitUpsideDown:
//                kr = CGRectMake(screen.size.width - (kr.origin.x + kr.size.width), screen.size.height - (kr.origin.y + kr.size.height), kr.size.width, kr.size.height)
//            default:
//                break
//            }
//
//            //NSLog(@"  after %g %g %g %g", kr.origin.x, kr.origin.y, kr.size.width, kr.size.height);
//        }
//        else {
//            //NSLog(@"  before convertRect %g %g %g %g", kr.origin.x, kr.origin.y, kr.size.width, kr.size.height);
//            kr = self.view!.convertRect(kr, fromView: nil)
//            //NSLog(@"  after %g %g %g %g", kr.origin.x, kr.origin.y, kr.size.width, kr.size.height);
//        }
//        subsequent_keyboard = true
    }

    func selectWotd(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            self.selectEntry(wordOfTheDay)
            searchBar.resignFirstResponder()
            self.delegate.didSelectEntry(wordOfTheDay)
        }
    }

    func selectSearchMode(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            searchBar.text = ""
            searchBar.userInteractionEnabled = true
            searchBar.becomeFirstResponder()
            wotdView.hidden = false
            searchTable.tableHeaderView = nil
            searchTable.reloadData()
        case 1:
            searchBar.text = "(handshape search)"
            searchBar.resignFirstResponder()
            searchBar.userInteractionEnabled = false
            wotdView.hidden = true
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
            wotdView.hidden = false
            return
        }
        wotdView.hidden = true
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
}



