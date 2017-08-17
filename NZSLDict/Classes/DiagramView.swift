import UIKit

class DiagramView: UIView {
    var detailView: DetailView!
    var imageView: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]

        detailView = DetailView(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: DetailView.height))
        detailView.autoresizingMask = UIViewAutoresizing.flexibleWidth

        self.addSubview(detailView)

        imageView = UIImageView(frame: CGRect(x: 0, y: DetailView.height, width: self.bounds.size.width, height: self.bounds.size.height-DetailView.height))
        imageView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        imageView.backgroundColor = UIColor.white
        imageView.contentMode = UIViewContentMode.scaleAspectFit

        self.addSubview(imageView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showEntry(_ entry: DictEntry) {
        detailView.showEntry(entry)
        imageView.image = UIImage(named: entry.image)
    }
}
