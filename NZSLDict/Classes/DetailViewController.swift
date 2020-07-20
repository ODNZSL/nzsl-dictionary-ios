import UIKit
import MediaPlayer

class DetailViewController: UIViewController, UISplitViewControllerDelegate, UINavigationBarDelegate {
    var navigationBar: UINavigationBar!
    var diagramView: DiagramView!
    var videoView: UIView!
    var navigationTitle: UINavigationItem!
    var player: MPMoviePlayerController!
    var activity: UIActivityIndicatorView!
    var playButton: UIButton!
    var reachability: Reachability?
    var networkErrorMessage: UIView!

    var currentEntry: DictEntry!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        NotificationCenter.default.addObserver(self, selector: #selector(DetailViewController.showEntry(_:)), name: NSNotification.Name(rawValue: EntrySelectedName), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DetailViewController.playerPlaybackStateDidChange(_:)), name: NSNotification.Name.MPMoviePlayerPlaybackStateDidChange, object: player)
        NotificationCenter.default.addObserver(self, selector: #selector(DetailViewController.playerPlaybackDidFinish(_:)), name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish, object: player)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
       NotificationCenter.default.removeObserver(self)
        reachability?.stopNotifier()
        reachability = nil
    }

    override func loadView() {
        let view: UIView = UIView(frame: UIScreen.main.bounds)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        let top_offset: CGFloat = 20

        navigationBar = UINavigationBar(frame: CGRect(x: 0, y: top_offset, width: view.bounds.size.width, height: 96 - top_offset))
        navigationBar.barTintColor = AppThemePrimaryColor
        navigationBar.isOpaque = false
        navigationBar.autoresizingMask = .flexibleWidth
        navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        navigationBar.delegate = self
        view.addSubview(navigationBar)
        
        navigationTitle = UINavigationItem(title: "NZSL Dictionary")
        navigationBar.setItems([navigationTitle], animated: false)

        diagramView = DiagramView(frame: CGRect(x: 0, y: navigationBar.frame.maxY, width: view.bounds.size.width, height: view.bounds.size.height / 2))
        diagramView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleBottomMargin]
        view.addSubview(diagramView)

        videoView = UIView(frame: CGRect(x: 0, y: top_offset + 44 + view.bounds.size.height / 2, width: view.bounds.size.width, height: view.bounds.size.height - (top_offset + 44 + view.bounds.size.height / 2)))
        videoView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleTopMargin]
        videoView.backgroundColor = UIColor.black
        view.addSubview(videoView)

        playButton = UIButton(type: .roundedRect)
        playButton.frame = CGRect(x: 0, y: (videoView.bounds.size.height - 40) / 2, width: videoView.bounds.width, height: 40)
        playButton.titleLabel?.textAlignment = .center
        playButton.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        playButton.setTitle("Play Video", for: UIControlState())
        playButton.setTitle("Playing videos requires access to the Internet.", for: .disabled)
        playButton.setTitleColor(UIColor.white, for: .disabled)
        
        playButton.addTarget(self, action: #selector(DetailViewController.startPlayer(_:)), for: .touchUpInside)
        videoView.addSubview(playButton)
        
        setupNetworkStatusMonitoring()
        
        self.view = view
    }

     override var shouldAutorotate : Bool {
        return true
    }

    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        if player == nil { return }
        player.view!.frame = videoView.frame
    }

    func splitViewController(_ svc: UISplitViewController, shouldHide vc: UIViewController, in orientation: UIInterfaceOrientation) -> Bool {
        return false
    }

    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }

    @objc func showEntry(_ notification: Notification) {
        currentEntry = notification.userInfo?["entry"] as? DictEntry
        navigationTitle?.title = currentEntry.gloss
        diagramView?.showEntry(currentEntry)
        player?.view!.removeFromSuperview()
        player = nil
    }
    
    func setupNetworkStatusMonitoring() {
        reachability = Reachability.forInternetConnection()
        
        reachability!.reachableBlock = { (reach: Reachability?) -> Void in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            DispatchQueue.main.async {
                self.playButton.isEnabled = true
            }
        }
        
        reachability!.unreachableBlock = { (reach: Reachability?) -> Void in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            DispatchQueue.main.async {
                self.playButton.isEnabled = false
            }
        }
        
        self.playButton.isEnabled = reachability?.currentReachabilityStatus() != .NotReachable
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reachability!.startNotifier()
    }

    @IBAction func startPlayer(_ sender: AnyObject) {
        player = MPMoviePlayerController(contentURL: URL(string: currentEntry.video)!)
        player.prepareToPlay()
        player.view!.frame = videoView.bounds
        videoView.addSubview(player.view!)
        player.play()

        activity = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        videoView.addSubview(activity)
        activity.frame = activity.frame.offsetBy(dx: (videoView.bounds.width - activity.bounds.width) / 2, dy: (videoView.bounds.height - activity.bounds.height) / 2)
        activity.startAnimating()
    }

    @objc func playerPlaybackStateDidChange(_ notification: Notification) {
        activity?.stopAnimating()
        activity?.removeFromSuperview()
        activity = nil
    }

    @objc	 func playerPlaybackDidFinish(_ notification: Notification) {
        let reason = notification.userInfo![MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] as? MPMovieFinishReason

        if reason == .playbackError {
            let alert: UIAlertView = UIAlertView(title: "Network access required", message: "Playing videos requires access to the Internet.", delegate: nil, cancelButtonTitle: "Cancel", otherButtonTitles: "")
            alert.show()
        }
    }

}
