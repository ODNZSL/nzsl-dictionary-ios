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
    let playerPromptLabel = UILabel()
    var delegate: ViewControllerDelegate!
    var reachability: Reachability?
    var player: AVPlayer?
    var padding = CGFloat(16.0)
    private var playerItemContext = 0
    private var slowPlaybackRate = Float(0.25)
    
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
        view.backgroundColor = UIColor(named: "app-background")
        
        detailView = DetailView(frame: CGRect(x: padding, y: padding, width: view.bounds.size.width - (padding * 2), height: DetailView.height + padding))
        detailView.autoresizingMask = [.flexibleWidth]
        view.addSubview(detailView)
        videoBack = UIView(frame: CGRect(x: 0, y: detailView.frame.maxY , width: view.bounds.size.width, height: view.bounds.size.height - DetailView.height))
        videoBack.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(videoBack)
        
        networkErrorMessage = UIView.init(frame: videoBack.frame)
        networkErrorMessage.autoresizingMask = detailView.autoresizingMask
        networkErrorMessage.backgroundColor = UIColor(named: "app-background")
        let networkErrorMessageImage = UIImageView.init(frame: CGRect(x: 0, y: 24, width: networkErrorMessage.frame.width, height: 72))
        networkErrorMessageImage.image = UIImage.init(named: "ic_videocam_off")?.withRenderingMode(.alwaysTemplate)
        networkErrorMessageImage.tintColor = UIColor(named: "diagram-tint")
        networkErrorMessageImage.contentMode = .center
        
        let networkErrorMessageText = UITextView.init(frame: CGRect(x: 0, y: 24 + networkErrorMessageImage.frame.height, width: networkErrorMessage.frame.width, height: 100))
        networkErrorMessageText.textAlignment = .center
        networkErrorMessageText.backgroundColor = UIColor(named: "app-background")
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
        player = AVPlayer(url: URL(string: currentEntry.video)!)
        player!.currentItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.old, .new], context: &playerItemContext)
        playerView.player = player
        
        let playerLayer = AVPlayerLayer(player: player)
        playerView.view.layer.addSublayer(playerLayer)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapPlayerView))
        playerView.view.addGestureRecognizer(tapGesture)
        playerView.showsPlaybackControls = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: player!.currentItem)
        
        playerPromptLabel.textAlignment = .right
        playerPromptLabel.textColor = .white
        playerPromptLabel.font = UIFont.systemFont(ofSize: 14)
        playerPromptLabel.translatesAutoresizingMaskIntoConstraints = false
        playerPromptLabel.text = ""
        
        playerView.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        playerView.videoGravity = .resizeAspect
        playerView.view.frame = self.videoBack.bounds
        self.videoBack.addSubview(playerView.view)
        self.videoBack.addSubview(playerPromptLabel)
        NSLayoutConstraint.activate([
            playerPromptLabel.leadingAnchor.constraint(equalTo: videoBack.leadingAnchor, constant: 16),
            playerPromptLabel.topAnchor.constraint(equalTo: videoBack.topAnchor, constant: 16),
        ])
        playerPromptLabel.sizeToFit()
        self.addChild(playerView)
        
        activity = UIActivityIndicatorView(style: .whiteLarge)
        self.videoBack.addSubview(activity)
        activity.frame = activity.frame.offsetBy(dx: (self.videoBack.bounds.width - activity.bounds.width) / 2, dy: (self.videoBack.bounds.height - activity.bounds.height) / 2)
        activity.startAnimating()
    }
    
    @objc func playerDidFinishPlaying() {
        playerPromptLabel.text = "Tap to play"
        player?.seek(to: .zero)
    }
    
    @objc func didTapPlayerView() {
        if (self.player == nil) {
            return
        }
        
        if player!.rate == slowPlaybackRate || player!.rate == 0.0 {
            playerPromptLabel.text = "Tap to slow down"
            player!.rate = 1.0
        } else {
            playerPromptLabel.text = "Tap to speed up"
            player!.rate = slowPlaybackRate
        }
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
                    self.playerPromptLabel.text = "Tap to slow down"
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
