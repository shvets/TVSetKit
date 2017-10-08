import UIKit

open class MediaNameTableCell: UITableViewCell {
  @IBOutlet private weak var thumb: UIImageView!

  public func configureCell(item: Any, localizedName: String) {
    textLabel?.text = localizedName

    if let item = item as? MediaName, let imageName = item.imageName {
      imageView?.image = UIImage(named: imageName)
    }
  }

}
