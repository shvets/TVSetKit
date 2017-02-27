import UIKit

open class MediaItemTableCell: UITableViewCell {
  @IBOutlet weak var title: UILabel!
  @IBOutlet weak var thumb: UIImageView!

  public func configureCell(item: MediaItem, localizedName: String, target: Any?, action: Selector?) {
    self.title.text = item.getDetailedName()

    CellHelper.shared.loadImage(path: item.getPosterPath(), name: localizedName, imageView: thumb)

    CellHelper.shared.addGestureRecognizer(view: self, target: target, action: action)
  }

}
