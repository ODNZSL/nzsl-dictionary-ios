import Foundation
import MediaPlayer

class VideoViewController: UIViewController, UISearchBarDelegate {
    var currentEntry: DictEntry!
    var detailView: DetailView!
    var videoBack: UIView!
    var activity: UIActivityIndicatorView!
    var player: MPMoviePlayerController!
    var delegate: ViewControllerDelegate!

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
    }

    override func loadView() {
        let view: UIView = UIView(frame: UIScreen.main.bounds)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        detailView = DetailView(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: DetailView.height))
        detailView.autoresizingMask = .flexibleWidth
        view.addSubview(detailView)
        videoBack = UIView(frame: CGRect(x: 0, y: DetailView.height, width: view.bounds.size.width, height: view.bounds.size.height - DetailView.height))
        videoBack.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(videoBack)

        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if self.responds(to: #selector(getter: UIViewController.edgesForExtendedLayout)) {
            self.edgesForExtendedLayout = UIRectEdge()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.showCurrentEntry()
    }

    func showEntry(_ notification: Notification) {
        currentEntry = notification.userInfo!["entry"] as! DictEntry
        player = nil
    }

    func showCurrentEntry() {
        detailView.showEntry(currentEntry)
        self.perform(#selector(VideoViewController.startVideo), with: nil, afterDelay: 0)
    }

    func startVideo() {
        player = MPMoviePlayerController(contentURL: URL(string: currentEntry.video)!)
        NotificationCenter.default.addObserver(self, selector: #selector(VideoViewController.playerPlaybackStateDidChange(_:)), name: NSNotification.Name.MPMoviePlayerPlaybackStateDidChange, object: player)
        NotificationCenter.default.addObserver(self, selector: #selector(VideoViewController.playerPlaybackDidFinish(_:)), name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish, object: player)
        player.prepareToPlay()
        player.view!.frame = videoBack.bounds
        player.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        videoBack.addSubview(player.view!)
        player.play()


        activity = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        videoBack.addSubview(activity)
        activity.frame = activity.frame.offsetBy(dx: (videoBack.bounds.size.width - activity.bounds.size.width) / 2, dy: (videoBack.bounds.size.height - activity.bounds.size.height) / 2)
        activity.startAnimating()
    }

    func playerPlaybackStateDidChange(_ notification: Notification) {
        if activity == nil { return }

        activity.stopAnimating()
        activity.removeFromSuperview()
        activity = nil
    }

    func playerPlaybackDidFinish(_ notification: Notification) {
        guard let userInfo: NSDictionary = notification.userInfo as NSDictionary?  else { return }
        guard let rawReason = userInfo[MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] as? Int else { return }
        guard let reason: MPMovieFinishReason = MPMovieFinishReason(rawValue: rawReason) else { return }

        switch reason {
        case .playbackError:
            let alert: UIAlertView = UIAlertView(title: "Network access required", message: "Playing videos requires access to the Internet.", delegate: nil, cancelButtonTitle: "Cancel", otherButtonTitles: "")
            alert.show()
        default: break
        }
    }

}
