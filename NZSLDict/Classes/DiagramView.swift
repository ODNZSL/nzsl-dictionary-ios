import UIKit

class DiagramView: UIView {
    var detailView: DetailView!
    var imageView: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(named: "app-background")
        self.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]

        detailView = DetailView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: DetailView.height))
        detailView.autoresizingMask = UIView.AutoresizingMask.flexibleWidth

        self.addSubview(detailView)

        imageView = UIImageView(frame: CGRect(x: 0, y: detailView.frame.maxY, width: self.frame.size.width, height: self.frame.height-detailView.frame.maxY))
        imageView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth]
        imageView.backgroundColor = UIColor(named: "app-background")
        imageView.contentMode = UIView.ContentMode.scaleAspectFit

        self.addSubview(imageView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showEntry(_ entry: DictEntry) {
        detailView.showEntry(entry)
        
        if #available(iOS 13.0, *) {
            imageView.tintColor = UIColor(named: "diagram-tint")
            imageView.image = UIImage(named: entry.image)?.withRenderingMode(.alwaysTemplate)
        } else {
            imageView.image = UIImage(named: entry.image)
        }
    }
}
