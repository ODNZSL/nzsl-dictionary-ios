import Foundation
import AVKit
import AVFoundation

class VideoViewController: UIViewController, UISearchBarDelegate {
    var currentEntry: DictEntry!
    var detailView: DetailView!
    var videoBack: UIView!
    var networkErrorMessage: UIView!
    var activity: UIActivityIndicatorView!
    let playerView = AVPlayerViewController()
    var delegate: ViewControllerDelegate!
    var reachability: Reachability?
    var player: AVPlayer?
    private var playerItemContext = 0

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
        networkErrorMessageText.isEditable = false
        
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
    
    @objc func startPlayer(_ sender: AnyObject) {
        player = AVPlayer(url: URL(string: currentEntry.video)!);
        player!.currentItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.old, .new], context: &playerItemContext)
        playerView.player = player
        playerView.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        playerView.videoGravity = .resizeAspect
        playerView.view.frame = self.videoBack.bounds
        self.videoBack.addSubview(playerView.view)
        self.addChild(playerView)

        activity = UIActivityIndicatorView(style: .whiteLarge)
        self.videoBack.addSubview(activity)
        activity.frame = activity.frame.offsetBy(dx: (self.videoBack.bounds.width - activity.bounds.width) / 2, dy: (self.videoBack.bounds.height - activity.bounds.height) / 2)
        activity.startAnimating()
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {

        // Only handle observations for the playerItemContext
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
            return
        }

        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }

            // Switch over status value
            switch status {
            case .readyToPlay:
                activity?.stopAnimating()
                activity?.removeFromSuperview()
                activity = nil
                DispatchQueue.main.async {
                    
                    self.player!.play()
                }
                break
            case .failed:
                let alert = UIAlertController.init(title: "Network access required", message: "Playing videos requires access to the Internet.", preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))

            self.present(alert, animated: true, completion: nil)
                break
            case .unknown:
                break
                // No-op
            @unknown default:
                break
            }
        }
    }


    @objc func showEntry(_ notification: Notification) {
        currentEntry = notification.userInfo!["entry"] as? DictEntry
    }

    func showCurrentEntry() {
        detailView.showEntry(currentEntry)
        self.perform(#selector(VideoViewController.startPlayer), with: nil, afterDelay: 0)
    }
}
