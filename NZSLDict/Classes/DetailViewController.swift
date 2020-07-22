import UIKit
import AVKit

class DetailViewController: UIViewController, UISplitViewControllerDelegate, UINavigationBarDelegate {
    var navigationBar: UINavigationBar!
    var diagramView: DiagramView!
    var videoView: UIView!
    var navigationTitle: UINavigationItem!
    var player: AVPlayer!
    var playerView = AVPlayerViewController()
    var activity: UIActivityIndicatorView!
    var playButton: UIButton!
    var reachability: Reachability?
    var networkErrorMessage: UIView!
    private var playerItemContext = 0

    var currentEntry: DictEntry!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        NotificationCenter.default.addObserver(self, selector: #selector(DetailViewController.showEntry(_:)), name: NSNotification.Name(rawValue: EntrySelectedName), object: nil)
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
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationBar.delegate = self
        view.addSubview(navigationBar)
        
        navigationTitle = UINavigationItem(title: "NZSL Dictionary")
        navigationBar.setItems([navigationTitle], animated: false)

        diagramView = DiagramView(frame: CGRect(x: 0, y: navigationBar.frame.maxY, width: view.bounds.size.width, height: view.bounds.size.height / 2))
        diagramView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleBottomMargin]
        view.addSubview(diagramView)

        videoView = UIView(frame: CGRect(x: 0, y: diagramView.frame.maxY, width: view.bounds.size.width, height: view.bounds.size.height / 2))
        videoView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleBottomMargin]
        videoView.backgroundColor = UIColor.black
        view.addSubview(videoView)

        playButton = UIButton(type: .roundedRect)
        playButton.frame = CGRect(x: 0, y: (videoView.bounds.size.height - 40) / 2, width: videoView.bounds.width, height: 40)
        playButton.titleLabel?.textAlignment = .center
        playButton.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        playButton.setTitle("Play Video", for: UIControl.State())
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
        playerView.view.removeFromSuperview()
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

    
       @objc func startPlayer(_ sender: AnyObject) {
           player = AVPlayer(url: URL(string: currentEntry.video)!);
           player!.currentItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.old, .new], context: &playerItemContext)
           player!.isMuted = true
           playerView.player = player
           playerView.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
           playerView.videoGravity = .resizeAspect
           playerView.view.frame = self.videoView.bounds
           self.videoView.addSubview(playerView.view)
           self.addChild(playerView)

           activity = UIActivityIndicatorView(style: .whiteLarge)
           self.videoView.addSubview(activity)
           activity.frame = activity.frame.offsetBy(dx: (self.videoView.bounds.width - activity.bounds.width) / 2, dy: (self.videoView.bounds.height - activity.bounds.height) / 2)
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
                   let alert: UIAlertView = UIAlertView(title: "Network access required", message: "Playing videos requires access to the Internet.", delegate: nil, cancelButtonTitle: "OK")
                   alert.show()
                   break
               case .unknown:
                   break
                   // No-op
               @unknown default:
                   break
               }
           }
       }
}
