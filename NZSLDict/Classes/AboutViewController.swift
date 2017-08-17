import UIKit

class AboutViewController: UIViewController, UIWebViewDelegate {
    var webView: UIWebView!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        self.tabBarItem = UITabBarItem(title: "About", image: UIImage(named: "info"), tag: 0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        webView = UIWebView(frame: UIScreen.main.bounds)
        webView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]

        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone {
            webView.scrollView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        }

        webView.delegate = self
        self.view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let aboutPath = Bundle.main.path(forResource: "about.html", ofType: nil) else {
            print("Failed to find about.html")
            return
        }

        let aboutUrl = URL(fileURLWithPath: aboutPath)
        let request = URLRequest(url: aboutUrl)
        webView.loadRequest(request)
    }

    override var shouldAutorotate : Bool {
        return true
    }

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if request.url!.isFileURL {
            return true
        }

        if request.url!.scheme == "follow" {
            openTwitterClientForUserName("NZSLDict")
            return false
        }

        UIApplication.shared.openURL(request.url!)
        return false
    }

    // https://gist.github.com/vhbit/958738
    func openTwitterClientForUserName(_ userName: String) -> Bool {
        let urls = [
            "twitter:@{username}", // Twitter
            "tweetbot:///user_profile/{username}", // TweetBot
            "echofon:///user_timeline?{username}", // Echofon
            "twit:///user?screen_name={username}", // Twittelator Pro
            "x-seesmic://twitter_profile?twitter_screen_name={username}", // Seesmic
            "x-birdfeed://user?screen_name={username}", // Birdfeed
            "tweetings:///user?screen_name={username}", // Tweetings
            "simplytweet:?link=http://twitter.com/{username}", // SimplyTweet
            "icebird://user?screen_name={username}", // IceBird
            "fluttr://user/{username}", // Fluttr
            /** uncomment if you don't have a special handling for no registered twitter clients */
            "http://twitter.com/{username}", // Web fallback,
        ]

        let application: UIApplication = UIApplication.shared

        for candidate in urls {
            let urlString = candidate.replacingOccurrences(of: "{username}", with:userName)
            if let url = URL(string: urlString) {
                print("testing \(url)")
                if application.canOpenURL(url) {
                    print("we can open \(url)")
                    application.openURL(url)
                    return true
                }
            }
        }

        return false
    }
}
