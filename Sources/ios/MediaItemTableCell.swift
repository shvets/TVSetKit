import UIKit

open class MediaItemTableCell: UITableViewCell {
  @IBOutlet private weak var title: UILabel!
  @IBOutlet private weak var thumb: UIImageView!

  public func configureCell(item: MediaItem, localizedName: String) {
    self.title.text = item.getDetailedName()

    if thumb != nil {
      CellHelper.shared.loadImage(path: item.getPosterPath(), name: localizedName, imageView: thumb)
    }
  }

}
