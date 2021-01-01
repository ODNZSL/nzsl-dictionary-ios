import UIKit

class DiagramView: UIView {
    var detailView: DetailView!
    var imageView: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]

        detailView = DetailView(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: DetailView.height))
        detailView.autoresizingMask = UIView.AutoresizingMask.flexibleWidth

        self.addSubview(detailView)

        imageView = UIImageView(frame: CGRect(x: 0, y: DetailView.height, width: self.bounds.size.width, height: self.bounds.size.height-DetailView.height))
        imageView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        imageView.backgroundColor = UIColor(named: "app-background")
        imageView.contentMode = UIView.ContentMode.scaleAspectFit

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
