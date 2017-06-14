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

    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.tabBarItem = UITabBarItem(title: "Video", image: UIImage(named: "movie"), tag: 0)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showEntry:", name: EntrySelectedName, object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func loadView() {
        let view: UIView = UIView(frame: UIScreen.mainScreen().bounds)
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]

        detailView = DetailView(frame: CGRectMake(0, 0, view.bounds.size.width, DetailView.height))
        detailView.autoresizingMask = .FlexibleWidth
        view.addSubview(detailView)
        videoBack = UIView(frame: CGRectMake(0, DetailView.height, view.bounds.size.width, view.bounds.size.height - DetailView.height))
        videoBack.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        view.addSubview(videoBack)
        
        networkErrorMessage = UIView.init(frame: videoBack.frame)
        networkErrorMessage.autoresizingMask = detailView.autoresizingMask
        networkErrorMessage.backgroundColor = UIColor.whiteColor()
        let networkErrorMessageImage = UIImageView.init(frame: CGRectMake(0, 24, networkErrorMessage.frame.width, 72))
        networkErrorMessageImage.image = UIImage.init(named: "ic_videocam_off")
        networkErrorMessageImage.contentMode = .Center
        
        let networkErrorMessageText = UITextView.init(frame: CGRectMake(0, 24 + networkErrorMessageImage.frame.height, networkErrorMessage.frame.width, 100))
        networkErrorMessageText.textAlignment = .Center
        networkErrorMessageText.text = "Playing videos requires access to the Internet."
        
        networkErrorMessage.addSubview(networkErrorMessageImage)
        networkErrorMessage.addSubview(networkErrorMessageText)
        networkErrorMessage.autoresizesSubviews = true
        view.addSubview(networkErrorMessage)

        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if self.respondsToSelector("edgesForExtendedLayout") {
            self.edgesForExtendedLayout = .None
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.showCurrentEntry()
    }

    func showEntry(notification: NSNotification) {
        currentEntry = notification.userInfo!["entry"] as! DictEntry
        player = nil
    }

    func showCurrentEntry() {
        detailView.showEntry(currentEntry)
        self.performSelector("startVideo", withObject: nil, afterDelay: 0)
    }

    func startVideo() {
        player = MPMoviePlayerController(contentURL: NSURL(string: currentEntry.video)!)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerPlaybackStateDidChange:", name: MPMoviePlayerPlaybackStateDidChangeNotification, object: player)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerPlaybackDidFinish:", name: MPMoviePlayerPlaybackDidFinishNotification, object: player)
        player.prepareToPlay()
        player.view!.frame = videoBack.bounds
        player.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        videoBack.addSubview(player.view!)
        player.play()


        activity = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        videoBack.addSubview(activity)
        activity.frame = CGRectOffset(activity.frame, (videoBack.bounds.size.width - activity.bounds.size.width) / 2, (videoBack.bounds.size.height - activity.bounds.size.height) / 2)
        activity.startAnimating()
    }
    

    func playerPlaybackStateDidChange(notification: NSNotification) {
        if activity == nil { return }

        activity.stopAnimating()
        activity.removeFromSuperview()
        activity = nil
    }

    func playerPlaybackDidFinish(notification: NSNotification) {
        guard let userInfo: NSDictionary = notification.userInfo else { return }
        guard let rawReason = userInfo[MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] as? Int else { return }
        guard let reason: MPMovieFinishReason = MPMovieFinishReason(rawValue: rawReason) else { return }

        switch reason {
        case .PlaybackError:
            networkErrorMessage.hidden = false
            videoBack.hidden = true
        default: break
        }
    }
}
