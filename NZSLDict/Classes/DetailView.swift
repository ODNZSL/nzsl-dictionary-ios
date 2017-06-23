import UIKit

class DetailView: UIView {
    var glossView: UILabel!
    var minorView: UILabel!
    var maoriView: UILabel!
    var handshapeView: UIImageView!
    var locationView: UIImageView!

    static let inset: CGFloat = 2
    static let height: CGFloat = 60 + inset * 2

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
        self.backgroundColor = UIColor.white

        glossView = UILabel(frame: CGRect(x: DetailView.inset, y: DetailView.inset, width: self.bounds.size.width - DetailView.inset * 2 - 120, height: 20))
        glossView.autoresizingMask = UIViewAutoresizing.flexibleWidth
        glossView.font = UIFont.boldSystemFont(ofSize: 18)
        self.addSubview(glossView)

        minorView = UILabel(frame: CGRect(x: DetailView.inset, y: DetailView.inset+20, width: self.bounds.size.width-DetailView.inset*2-120, height: 20))
        minorView.autoresizingMask = UIViewAutoresizing.flexibleWidth
        minorView.font = UIFont.systemFont(ofSize: 15)
        self.addSubview(minorView)

        maoriView = UILabel(frame: CGRect(x: DetailView.inset, y: DetailView.inset+40, width: self.bounds.size.width-DetailView.inset*2-120, height: 20))
        maoriView.autoresizingMask = UIViewAutoresizing.flexibleWidth
        maoriView.font = UIFont.italicSystemFont(ofSize: 15)
        self.addSubview(maoriView)

        handshapeView = UIImageView(frame: CGRect(x: self.bounds.size.width-DetailView.inset-120, y: DetailView.inset, width: 60, height: 60))
        handshapeView.autoresizingMask = UIViewAutoresizing.flexibleLeftMargin
        handshapeView.contentMode = UIViewContentMode.scaleAspectFit
        self.addSubview(handshapeView)

        locationView = UIImageView(frame: CGRect(x: self.bounds.size.width-DetailView.inset-60, y: DetailView.inset, width: 60, height: 60))
        locationView.autoresizingMask = UIViewAutoresizing.flexibleLeftMargin
        locationView.contentMode = UIViewContentMode.scaleAspectFit
        self.addSubview(locationView)
    }

    func showEntry(_ entry: DictEntry) {
        glossView.text = entry.gloss
        minorView.text = entry.minor
        maoriView.text = entry.maori
        handshapeView.image = UIImage(named: entry.handshapeImage())
        locationView.image = UIImage(named: entry.locationImage())
    }
}
