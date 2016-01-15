import Foundation
import UIKit

class AboutViewController: UIViewController, UIWebViewDelegate {
    var webView: UIWebView!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        self.tabBarItem = UITabBarItem(title: "About", image: UIImage(named: "info"), tag: 0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        webView = UIWebView(frame: UIScreen.mainScreen().bounds)
        webView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]

        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
            webView.scrollView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        }

        webView.delegate = self
        self.view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let aboutPath = NSBundle.mainBundle().pathForResource("about.html", ofType: nil) else {
            print("Failed to find about.html")
            return
        }

        let aboutUrl = NSURL(fileURLWithPath: aboutPath)
        let request = NSURLRequest(URL: aboutUrl)
        webView.loadRequest(request)
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if request.URL!.fileURL {
            return true
        }

        if request.URL!.scheme == "follow" {
            openTwitterClientForUserName("NZSLDict")
            return false
        }

        UIApplication.sharedApplication().openURL(request.URL!)
        return false
    }

    // https://gist.github.com/vhbit/958738
    func openTwitterClientForUserName(userName: String) -> Bool {
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

        let application: UIApplication = UIApplication.sharedApplication()

        for candidate in urls {
            let urlString = candidate.stringByReplacingOccurrencesOfString("{username}", withString:userName)
            if let url = NSURL(string: urlString) {
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