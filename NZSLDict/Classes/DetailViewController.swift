import UIKit
import AVFoundation
import AVKit
import Network

class DetailViewController: UIViewController, UISplitViewControllerDelegate, UINavigationBarDelegate {
    var navigationBar: UINavigationBar!
    var diagramView: DiagramView!
    var videoView: UIView!
    var navigationTitle: UINavigationItem!
    var player: AVPlayer?
    let playerView = AVPlayerViewController()
    var activity: UIActivityIndicatorView!
    var playButton: UIButton!
    var networkMonitor: NWPathMonitor?
    var networkErrorMessage: UIView!
    private var playerItemContext = 0

    var currentEntry: DictEntry!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        NotificationCenter.default.addObserver(self, selector: #selector(DetailViewController.showEntry(_:)), name: .entrySelectedName, object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        networkMonitor?.cancel()
        networkMonitor = nil
    }

    override func loadView() {
        super.loadView()

        view.backgroundColor = .appBackground

        navigationBar = UINavigationBar()
        navigationBar.delegate = self

        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navigationBar)

        navigationBar.backgroundColor = .appThemePrimaryColor
        navigationBar.barTintColor = .appThemePrimaryColor

        let navTop = navigationBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 20)
        let navLead = navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let navTrailing = navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        let navHeight = navigationBar.heightAnchor.constraint(equalToConstant: 76)

        NSLayoutConstraint.activate([
            navTop, navLead, navTrailing, navHeight
        ])

        navigationBar.isTranslucent = false
        navigationBar.shadowImage = UIImage()
        navigationBar.setBackgroundImage(UIImage(), for: .default)

        navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationTitle = UINavigationItem(title: "NZSL Dictionary")
        navigationBar.setItems([navigationTitle], animated: false)


        diagramView = DiagramView()
        diagramView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(diagramView)

        let dvTop = diagramView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 16)
        let dvLead = diagramView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        let dvTrailing = diagramView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)

        videoView = UIView()
        videoView.translatesAutoresizingMaskIntoConstraints = false
        videoView.backgroundColor = .black
        view.addSubview(videoView)

        let vvTop = videoView.topAnchor.constraint(equalTo: diagramView.bottomAnchor, constant: 10)
        let vvLead = videoView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let vvTrailing = videoView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        let vvBottom = videoView.bottomAnchor.constraint(equalTo: view.bottomAnchor)

        let vvHeight = videoView.heightAnchor.constraint(equalTo: diagramView.heightAnchor, multiplier: 1)
        let dvHeight = diagramView.heightAnchor.constraint(equalTo: videoView.heightAnchor, multiplier: 1)

        NSLayoutConstraint.activate([
            dvTop, dvLead, dvTrailing, vvTop, vvLead, vvTrailing, vvBottom, vvHeight, dvHeight
        ])

        playButton = UIButton(type: .roundedRect)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        videoView.addSubview(playButton)

        playButton.setTitle("Play Video", for: .normal)
        playButton.setTitle("Playing videos requires access to the Internet", for: .disabled)

        playButton.setTitleColor(.white, for: .disabled)
        playButton.addTarget(self, action: #selector(startPlayer), for: .touchUpInside)

        let pbCenterX = playButton.centerXAnchor.constraint(equalTo: videoView.centerXAnchor)
        let pbCenterY = playButton.centerYAnchor.constraint(equalTo: videoView.centerYAnchor)

        NSLayoutConstraint.activate([
            pbCenterX, pbCenterY
        ])


//        view.insertSubview(videoView, belowSubview: diagramView)

        playerView.updatesNowPlayingInfoCenter = false
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
        networkMonitor = NWPathMonitor()

        networkMonitor?.pathUpdateHandler = { [weak self] path in
            guard let self else { return }

            DispatchQueue.main.async {
                self.playButton.isEnabled = path.status == .satisfied
            }
        }

        let queue = DispatchQueue.global(qos: .background)
        networkMonitor?.start(queue: queue)

        self.playButton.isEnabled = networkMonitor?.currentPath.status == .satisfied
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNetworkStatusMonitoring()
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
}
