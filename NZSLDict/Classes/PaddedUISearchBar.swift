class PaddedUISearchBar: UISearchBar {
    override func layoutSubviews() {
        super.layoutSubviews()
        let pad: CGFloat = 16
        for view: UIView in subviews {
            if (view is UITextField) {
                view.frame = CGRect(x: CGFloat(view.frame.origin.x + pad), y: CGFloat(view.frame.origin.y), width: CGFloat(view.frame.size.width - pad), height: CGFloat(view.frame.size.height))
            }
        }
    }
}