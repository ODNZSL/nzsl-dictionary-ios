import UIKit

class DiagramView: UIView {
    var detailView: DetailView!
    var imageView: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(named: "app-background")

        detailView = DetailView()
        detailView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(detailView)

        let detailLeading = detailView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        let detailTrailing = detailView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        let detailTop = detailView.topAnchor.constraint(equalTo: self.topAnchor)
        let detailHeight = detailView.heightAnchor.constraint(equalToConstant: DetailView.height)

        NSLayoutConstraint.activate([
            detailLeading,detailTrailing,detailTop,detailHeight
        ])

        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        self.addSubview(imageView)

        let ivLeading = imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        let ivTrailing = imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        let ivTop = imageView.topAnchor.constraint(equalTo: detailView.bottomAnchor, constant: 10)
        let ivBottom = imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)

        NSLayoutConstraint.activate([
            ivLeading,ivTrailing,ivTop,ivBottom
        ])

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showEntry(_ entry: DictEntry) {
        detailView.showEntry(entry)


        if #available(iOS 13.0, *) {
            imageView.tintColor = UIColor(named: "diagram-tint")
            imageView.image = UIImage(named: entry.image)?.withRenderingMode(.alwaysOriginal)
        } else {
            imageView.image = UIImage(named: entry.image)
        }
    }
}
