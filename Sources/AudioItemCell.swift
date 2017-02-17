import UIKit

class AudioItemCell: UITableViewCell {
  @IBOutlet weak var current: UILabel!
  @IBOutlet weak var title: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()

    // Initialization code
    self.layer.masksToBounds = true
    self.layer.borderWidth = 0.5
    self.layer.borderColor = UIColor( red: 0, green: 0, blue:0, alpha: 1.0 ).cgColor
  }

  public func configureCell(item: MediaItem, target: Any?, action: Selector?) {
    self.title.text = item.name

    CellHelper.shared.addGestureRecognizer(view: self, target: target, action: action)
  }

}
