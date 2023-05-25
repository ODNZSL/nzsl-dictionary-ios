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


        locationView = UIImageView()
        locationView.translatesAutoresizingMaskIntoConstraints = false
        locationView.contentMode = .scaleAspectFit
        self.addSubview(locationView)

        let lvTrailing = locationView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        let lvHeight = locationView.heightAnchor.constraint(equalToConstant: 60)
        let lvWidth = locationView.widthAnchor.constraint(equalToConstant: 60)

        NSLayoutConstraint.activate([
            lvTrailing, lvHeight, lvWidth
        ])

        handshapeView = UIImageView()
        handshapeView.translatesAutoresizingMaskIntoConstraints = false
        handshapeView.contentMode = .scaleAspectFit
        self.addSubview(handshapeView)

        let hsTrailing = handshapeView.trailingAnchor.constraint(equalTo: locationView.leadingAnchor, constant: 10)
        let hsHeight = handshapeView.heightAnchor.constraint(equalToConstant: 60)
        let hsWidth = handshapeView.widthAnchor.constraint(equalToConstant: 60)

        NSLayoutConstraint.activate([
            hsTrailing, hsHeight, hsWidth
        ])

        glossView = UILabel()
        glossView.translatesAutoresizingMaskIntoConstraints = false
        glossView.font = .boldSystemFont(ofSize: 18)
        self.addSubview(glossView)

        let gvLead = glossView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        let gvTop = glossView.topAnchor.constraint(equalTo: self.topAnchor)
        let gvTrail = glossView.trailingAnchor.constraint(equalTo: handshapeView.leadingAnchor, constant: 10)

        NSLayoutConstraint.activate([
            gvLead, gvTop, gvTrail
        ])

        minorView = UILabel()
        minorView.translatesAutoresizingMaskIntoConstraints = false
        minorView.font = .italicSystemFont(ofSize: 15)
        self.addSubview(minorView)

        let mvLead = minorView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        let mvTop = minorView.topAnchor.constraint(equalTo: glossView.bottomAnchor)
        let mvTrail = minorView.trailingAnchor.constraint(equalTo: handshapeView.leadingAnchor, constant: 10)

        NSLayoutConstraint.activate([
            mvLead, mvTop, mvTrail
        ])

        maoriView = UILabel()
        maoriView.translatesAutoresizingMaskIntoConstraints = false
        maoriView.font = .italicSystemFont(ofSize: 15)
        self.addSubview(maoriView)

        let mLead = maoriView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        let mTop = maoriView.topAnchor.constraint(equalTo: minorView.bottomAnchor)
        let mTrail = maoriView.trailingAnchor.constraint(equalTo: handshapeView.leadingAnchor, constant: 10)

        NSLayoutConstraint.activate([
            mLead, mTop, mTrail
        ])
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
