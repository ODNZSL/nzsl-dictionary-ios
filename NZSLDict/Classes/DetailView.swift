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
        self.init(frame: CGRectZero) // calls the designated initializer in this file!
    }

    func setupView() {
        self.backgroundColor = UIColor.whiteColor()

        glossView = UILabel(frame: CGRectMake(DetailView.inset, DetailView.inset, self.bounds.size.width - DetailView.inset * 2 - 120, 20))
        glossView.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        glossView.font = UIFont.boldSystemFontOfSize(18)
        self.addSubview(glossView)

        minorView = UILabel(frame: CGRectMake(DetailView.inset, DetailView.inset+20, self.bounds.size.width-DetailView.inset*2-120, 20))
        minorView.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        minorView.font = UIFont.systemFontOfSize(15)
        self.addSubview(minorView)

        maoriView = UILabel(frame: CGRectMake(DetailView.inset, DetailView.inset+40, self.bounds.size.width-DetailView.inset*2-120, 20))
        maoriView.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        maoriView.font = UIFont.italicSystemFontOfSize(15)
        self.addSubview(maoriView)

        handshapeView = UIImageView(frame: CGRectMake(self.bounds.size.width-DetailView.inset-120, DetailView.inset, 60, 60))
        handshapeView.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin
        handshapeView.contentMode = UIViewContentMode.ScaleAspectFit
        self.addSubview(handshapeView)

        locationView = UIImageView(frame: CGRectMake(self.bounds.size.width-DetailView.inset-60, DetailView.inset, 60, 60))
        locationView.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin
        locationView.contentMode = UIViewContentMode.ScaleAspectFit
        self.addSubview(locationView)
    }

    func showEntry(entry: DictEntry) {
        glossView.text = entry.gloss
        minorView.text = entry.minor
        maoriView.text = entry.maori
        handshapeView.image = UIImage(named: entry.handshapeImage())
        locationView.image = UIImage(named: entry.locationImage())
    }
}