import UIKit

class DiagramView: UIView {
    var detailView: DetailView!
    var imageView: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]

        detailView = DetailView(frame: CGRectMake(0, 0, self.bounds.size.width, DetailView.height))
        detailView.autoresizingMask = UIViewAutoresizing.FlexibleWidth

        self.addSubview(detailView)

        imageView = UIImageView(frame: CGRectMake(0, DetailView.height, self.bounds.size.width, self.bounds.size.height-DetailView.height))
        imageView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        imageView.backgroundColor = UIColor.whiteColor()
        imageView.contentMode = UIViewContentMode.ScaleAspectFit

        self.addSubview(imageView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showEntry(entry: DictEntry) {
        detailView.showEntry(entry)
        imageView.image = UIImage(named: entry.image)
    }
}
