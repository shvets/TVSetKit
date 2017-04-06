import UIKit

open class MediaNameTableCell: UITableViewCell {
  @IBOutlet weak var thumb: UIImageView!

  public func configureCell(item: MediaName, localizedName: String) {
    textLabel?.text = localizedName

    if let imageName = item.imageName {
      imageView?.image = UIImage(named: imageName)
    }
  }

}
