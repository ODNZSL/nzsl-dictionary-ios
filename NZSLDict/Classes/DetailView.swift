import UIKit

class DetailView: UIView {
    var glossView: UILabel!
    var minorView: UILabel!
    var maoriView: UILabel!
    var handshapeView: UIImageView!
    var locationView: UIImageView!

    static let height: CGFloat = 60

    // the designated initializer for a UIView requires a frame
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // the convenience initializer provides a default frame
    convenience init() {
        self.init(frame: CGRect.zero) // calls the designated initializer in this file!
    }

    func setupView() {
        self.backgroundColor = UIColor(named: "app-background")

        glossView = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width - 120, height: 20))
        glossView.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
        glossView.font = UIFont.boldSystemFont(ofSize: 18)
        self.addSubview(glossView)

        minorView = UILabel(frame: CGRect(x: 0, y: 20, width: self.bounds.size.width-120, height: 20))
        minorView.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
        minorView.font = UIFont.systemFont(ofSize: 15)
        self.addSubview(minorView)

        maoriView = UILabel(frame: CGRect(x: 0, y: 40, width: self.bounds.size.width-120, height: 20))
        maoriView.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
        maoriView.font = UIFont.italicSystemFont(ofSize: 15)
        self.addSubview(maoriView)

        handshapeView = UIImageView(frame: CGRect(x: self.frame.size.width-120, y: 0, width: 60, height: 60))
        handshapeView.autoresizingMask = UIView.AutoresizingMask.flexibleLeftMargin
        handshapeView.contentMode = UIView.ContentMode.scaleAspectFit
        self.addSubview(handshapeView)

        locationView = UIImageView(frame: CGRect(x: self.frame.size.width-60, y: 0, width: 60, height: 60))
        locationView.autoresizingMask = UIView.AutoresizingMask.flexibleLeftMargin
        locationView.contentMode = UIView.ContentMode.scaleAspectFit
        self.addSubview(locationView)
    }

    func showEntry(_ entry: DictEntry) {
        glossView.text = entry.gloss
        minorView.text = entry.minor
        maoriView.text = entry.maori
        handshapeView.image = UIImage(named: entry.handshapeImage())


        if let locationImageName = entry.locationImage() {
            locationView.image = UIImage(named: locationImageName)
        }
    }
}
