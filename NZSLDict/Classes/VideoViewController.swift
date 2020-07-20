import Foundation
import MediaPlayer

class VideoViewController: UIViewController, UISearchBarDelegate {
    var currentEntry: DictEntry!
    var detailView: DetailView!
    var videoBack: UIView!
    var networkErrorMessage: UIView!
    var activity: UIActivityIndicatorView!
    var player: MPMoviePlayerController!
    var delegate: ViewControllerDelegate!
    var reachability: Reachability?

    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.tabBarItem = UITabBarItem(title: "Video", image: UIImage(named: "movie"), tag: 0)
        NotificationCenter.default.addObserver(self, selector: #selector(VideoViewController.showEntry(_:)), name: NSNotification.Name(rawValue: EntrySelectedName), object: nil)
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

        detailView = DetailView(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: DetailView.height))
        detailView.autoresizingMask = [.flexibleWidth]
        view.addSubview(detailView)
        videoBack = UIView(frame: CGRect(x: 0, y: DetailView.height, width: view.bounds.size.width, height: view.bounds.size.height - DetailView.height))
        videoBack.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(videoBack)
        
        networkErrorMessage = UIView.init(frame: videoBack.frame)
        networkErrorMessage.autoresizingMask = detailView.autoresizingMask
        networkErrorMessage.backgroundColor = UIColor.white
        let networkErrorMessageImage = UIImageView.init(frame: CGRect(x: 0, y: 24, width: networkErrorMessage.frame.width, height: 72))
        networkErrorMessageImage.image = UIImage.init(named: "ic_videocam_off")
        networkErrorMessageImage.contentMode = .center
        
        let networkErrorMessageText = UITextView.init(frame: CGRect(x: 0, y: 24 + networkErrorMessageImage.frame.height, width: networkErrorMessage.frame.width, height: 100))
        networkErrorMessageText.textAlignment = .center
        networkErrorMessageText.text = "Playing videos requires access to the Internet."
        
        networkErrorMessage.addSubview(networkErrorMessageImage)
        networkErrorMessage.addSubview(networkErrorMessageText)
        networkErrorMessage.autoresizesSubviews = true
        view.addSubview(networkErrorMessage)
        
        
        setupNetworkStatusMonitoring()

        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if self.responds(to: #selector(getter: UIViewController.edgesForExtendedLayout)) {
            self.edgesForExtendedLayout = UIRectEdge()
        }
        

       reachability!.startNotifier()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.showCurrentEntry()
        
    }
    
    func setupNetworkStatusMonitoring() {
        reachability = Reachability.forInternetConnection()
            
        
        reachability!.reachableBlock = { (reach: Reachability?) -> Void in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            DispatchQueue.main.async {
                self.networkErrorMessage.isHidden = true
                self.videoBack.isHidden = false
                
            }
        }
        
        reachability!.unreachableBlock = { (reach: Reachability?) -> Void in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            DispatchQueue.main.async {
                self.networkErrorMessage.isHidden = false
                self.videoBack.isHidden = true
            }
        }
        
        if reachability?.currentReachabilityStatus() != .NotReachable {
            reachability?.reachableBlock(reachability)
        }
        
    }


    @objc func showEntry(_ notification: Notification) {
        currentEntry = notification.userInfo!["entry"] as! DictEntry
        player = nil
    }

    func showCurrentEntry() {
        detailView.showEntry(currentEntry)
        self.perform(#selector(VideoViewController.startVideo), with: nil, afterDelay: 0)
    }

    @objc func startVideo() {
        player = MPMoviePlayerController(contentURL: URL(string: currentEntry.video)!)
        NotificationCenter.default.addObserver(self, selector: #selector(VideoViewController.playerPlaybackStateDidChange(_:)), name: NSNotification.Name.MPMoviePlayerPlaybackStateDidChange, object: player)
        NotificationCenter.default.addObserver(self, selector: #selector(VideoViewController.playerPlaybackDidFinish(_:)), name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish, object: player)
        player.prepareToPlay()
        player.view!.frame = videoBack.bounds
        player.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        videoBack.addSubview(player.view!)
        player.play()


        activity = UIActivityIndicatorView(style: .whiteLarge)
        videoBack.addSubview(activity)
        activity.frame = activity.frame.offsetBy(dx: (videoBack.bounds.size.width - activity.bounds.size.width) / 2, dy: (videoBack.bounds.size.height - activity.bounds.size.height) / 2)
        activity.startAnimating()
    }
    

    @objc func playerPlaybackStateDidChange(_ notification: Notification) {
        if activity == nil { return }

        activity.stopAnimating()
        activity.removeFromSuperview()
        activity = nil
    }

    @objc func playerPlaybackDidFinish(_ notification: Notification) {
        guard let userInfo: NSDictionary = notification.userInfo as! NSDictionary else { return }
        guard let rawReason = userInfo[MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] as? Int else { return }
        guard let reason: MPMovieFinishReason = MPMovieFinishReason(rawValue: rawReason) else { return }

        switch reason {
        case .playbackError:
            networkErrorMessage.isHidden = false
            videoBack.isHidden = true
        default: break
        }
    }
}
