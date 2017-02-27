import UIKit

open class MediaNameTableCell: UITableViewCell {
  @IBOutlet weak var thumb: UIImageView!

  public func configureCell(item: MediaName, localizedName: String, target: Any?, action: Selector?) {
    //thumb.backgroundColor = UIColor(rgb: 0x00BFFF)

//    let itemSize = UIHelper.shared.getItemSize(target as! UITableViewController)
//
//    thumb.image = UIHelper.shared.textToImage(drawText: localizedName, size: itemSize)

    textLabel?.text = localizedName

    CellHelper.shared.addGestureRecognizer(view: self, target: target, action: action)
  }

}
