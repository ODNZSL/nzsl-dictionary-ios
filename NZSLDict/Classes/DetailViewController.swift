import UIKit
import MediaPlayer

class DetailViewController: UIViewController, UISplitViewControllerDelegate, UINavigationBarDelegate {
    var navigationBar: UINavigationBar!
    var diagramView: DiagramView!
    var videoView: UIView!
    var navigationTitle: UINavigationItem!
    var player: MPMoviePlayerController!
    var activity: UIActivityIndicatorView!

    var currentEntry: DictEntry!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DetailViewController.showEntry(_:)), name: EntrySelectedName, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerPlaybackStateDidChange:", name: MPMoviePlayerPlaybackStateDidChangeNotification, object: player)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerPlaybackDidFinish:", name: MPMoviePlayerPlaybackDidFinishNotification, object: player)
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

        let top_offset: CGFloat = 20

        navigationBar = UINavigationBar(frame: CGRectMake(0, top_offset, view.bounds.size.width, 96 - top_offset))
        navigationBar.barTintColor = AppThemePrimaryColor
        navigationBar.opaque = false
        navigationBar.autoresizingMask = .FlexibleWidth
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationBar.delegate = self
        view.addSubview(navigationBar)
        
        navigationTitle = UINavigationItem(title: "")
        navigationBar.setItems([navigationTitle], animated: false)

        diagramView = DiagramView(frame: CGRectMake(0, top_offset + 44, view.bounds.size.width, view.bounds.size.height / 2))
        diagramView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight, .FlexibleBottomMargin]
        view.addSubview(diagramView)

        videoView = UIView(frame: CGRectMake(0, top_offset + 44 + view.bounds.size.height / 2, view.bounds.size.width, view.bounds.size.height - (top_offset + 44 + view.bounds.size.height / 2)))
        videoView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight, .FlexibleTopMargin]
        videoView.backgroundColor = UIColor.blackColor()
        view.addSubview(videoView)

        let playButton: UIButton = UIButton(type: .RoundedRect)
        playButton.frame = CGRectMake((videoView.bounds.size.width - 100) / 2, (videoView.bounds.size.height - 40) / 2, 100, 40)
        playButton.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleTopMargin, .FlexibleBottomMargin]
        playButton.setTitle("Play Video", forState: .Normal)
        playButton.titleLabel!.textColor = UIColor.blackColor()
        playButton.addTarget(self, action: "startPlayer:", forControlEvents: .TouchUpInside)
        videoView.addSubview(playButton)
        self.view = view
    }

     override func shouldAutorotate() -> Bool {
        return true
    }

    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        player.view!.frame = videoView.bounds
    }

    func splitViewController(svc: UISplitViewController, shouldHideViewController vc: UIViewController, inOrientation orientation: UIInterfaceOrientation) -> Bool {
        return false
    }

    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }

    func showEntry(notification: NSNotification) {
        currentEntry = notification.userInfo?["entry"] as? DictEntry
        navigationTitle?.title = currentEntry.gloss
        diagramView?.showEntry(currentEntry)
        player?.view!.removeFromSuperview()
        player = nil
    }

    @IBAction func startPlayer(sender: AnyObject) {
        player = MPMoviePlayerController(contentURL: NSURL(string: currentEntry.video)!)
        player.prepareToPlay()
        player.view!.frame = videoView.bounds
        videoView.addSubview(player.view!)
        player.play()

        activity = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        videoView.addSubview(activity)
        activity.frame = CGRectOffset(activity.frame, (CGRectGetWidth(videoView.bounds) - CGRectGetWidth(activity.bounds)) / 2, (CGRectGetHeight(videoView.bounds) - CGRectGetHeight(activity.bounds)) / 2)
        activity.startAnimating()
    }

    func playerPlaybackStateDidChange(notification: NSNotification) {
        activity.stopAnimating()
        activity.removeFromSuperview()
        activity = nil
    }

    func playerPlaybackDidFinish(notification: NSNotification) {
        let reason = notification.userInfo![MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] as! MPMovieFinishReason

        if reason == .PlaybackError {
            let alert: UIAlertView = UIAlertView(title: "Network access required", message: "Playing videos requires access to the Internet.", delegate: nil, cancelButtonTitle: "Cancel", otherButtonTitles: "")
            alert.show()
        }
    }

}
