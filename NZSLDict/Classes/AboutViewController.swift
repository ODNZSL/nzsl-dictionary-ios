import UIKit
import WebKit

class AboutViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        self.tabBarItem = UITabBarItem(title: "About", image: UIImage(named: "info"), tag: 0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        webView = WKWebView(frame: UIScreen.main.bounds)
        webView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        webView.navigationDelegate = self
        
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone {
            webView.scrollView.contentInset = UIEdgeInsets.init(top: 20, left: 0, bottom: 0, right: 0)
        }

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
        webView.load(request)
    }

    override var shouldAutorotate : Bool {
        return true
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        var action: WKNavigationActionPolicy?

        defer {
            decisionHandler(action ?? .allow)
        }

        guard let url = navigationAction.request.url else { return }
        print("decidePolicyFor - url: \(url)")
        
        if url.isFileURL { return }
        if url.scheme == "follow" {
            action = .cancel
            _ = openTwitterClientForUserName("NZSLDict")
            return
        }
        
        if #available(iOS 10, *) {
           UIApplication.shared.open(url, options: [:],
           completionHandler: {
              (success) in
              print("Open \(url): \(success)")
            })
         } else {
              let success = UIApplication.shared.openURL(url)
              print("Open \(url): \(success)")
         }
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


        for candidate in urls {
            let urlString = candidate.replacingOccurrences(of: "{username}", with:userName)
            if let url = URL(string: urlString) {
                if #available(iOS 10, *) {
                   UIApplication.shared.open(url, options: [:],
                   completionHandler: {
                      (success) in
                      print("Open \(url): \(success)")
                    })
                 } else {
                      let success = UIApplication.shared.openURL(url)
                      print("Open \(url): \(success)")
             }
        }
        }

        return false
    }
}
