import UIKit
import MediaPlayer

class DetailViewController: UIViewController, UISplitViewControllerDelegate, UINavigationBarDelegate {
    var navigationBar: UINavigationBar!
    var diagramView: DiagramView!
    var videoView: UIView!
    var navigationTitle: UINavigationItem!
    var player: MPMoviePlayerController!
    var activity: UIActivityIndicatorView!
    var aboutPopoverController: UIPopoverController!

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
    }

    override func loadView() {
        let view: UIView = UIView(frame: UIScreen.main.bounds)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        let top_offset: CGFloat = 20

        navigationBar = UINavigationBar(frame: CGRect(x: 0, y: top_offset, width: view.bounds.size.width, height: 44))
        navigationBar.autoresizingMask = .flexibleWidth
        navigationBar.delegate = self
        view.addSubview(navigationBar)

        diagramView = DiagramView(frame: CGRect(x: 0, y: top_offset + 44, width: view.bounds.size.width, height: view.bounds.size.height / 2))
        diagramView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleBottomMargin]
        view.addSubview(diagramView)

        videoView = UIView(frame: CGRect(x: 0, y: top_offset + 44 + view.bounds.size.height / 2, width: view.bounds.size.width, height: view.bounds.size.height - (top_offset + 44 + view.bounds.size.height / 2)))
        videoView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleTopMargin]
        videoView.backgroundColor = UIColor.black
        view.addSubview(videoView)

        let playButton: UIButton = UIButton(type: .roundedRect)
        playButton.frame = CGRect(x: (videoView.bounds.size.width - 100) / 2, y: (videoView.bounds.size.height - 40) / 2, width: 100, height: 40)
        playButton.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        playButton.setTitle("Play Video", for: UIControlState())
        playButton.titleLabel!.textColor = UIColor.black
        playButton.addTarget(self, action: #selector(DetailViewController.startPlayer(_:)), for: .touchUpInside)
        videoView.addSubview(playButton)
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationTitle = UINavigationItem(title: "")
        navigationTitle.rightBarButtonItem = UIBarButtonItem(title: "About", style: .plain, target: self, action: #selector(DetailViewController.showAbout(_:)))
        navigationBar.setItems([navigationTitle], animated: false)
    }

    override var shouldAutorotate : Bool {
        return true
    }

    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        player.view!.frame = videoView.bounds
    }

    func splitViewController(_ svc: UISplitViewController, shouldHide vc: UIViewController, in orientation: UIInterfaceOrientation) -> Bool {
        return false
    }

    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }

    func showEntry(_ notification: Notification) {
        currentEntry = notification.userInfo!["entry"] as! DictEntry
        navigationTitle.title = currentEntry.gloss
        diagramView.showEntry(currentEntry)
        player.view!.removeFromSuperview()
        player = nil
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

    func playerPlaybackStateDidChange(_ notification: Notification) {
        activity.stopAnimating()
        activity.removeFromSuperview()
        activity = nil
    }

    func playerPlaybackDidFinish(_ notification: Notification) {
        let reason = notification.userInfo![MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] as! MPMovieFinishReason

        if reason == .playbackError {
            let alert: UIAlertView = UIAlertView(title: "Network access required", message: "Playing videos requires access to the Internet.", delegate: nil, cancelButtonTitle: "Cancel", otherButtonTitles: "")
            alert.show()
        }
    }

    func showAbout(_ sender: AnyObject) {
        if aboutPopoverController == nil {
            let controller: AboutViewController = AboutViewController(nibName: "AboutViewController", bundle: nil)
            aboutPopoverController = UIPopoverController(contentViewController: controller)
        }

        if aboutPopoverController.isPopoverVisible {
            aboutPopoverController.dismiss(animated: true)
        }
        else {
            aboutPopoverController.present(from: sender as! UIBarButtonItem, permittedArrowDirections: .any, animated: true)
        }
    }
}
