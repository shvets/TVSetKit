import UIKit

open class MediaNameCell: UICollectionViewCell {
  public var item: MediaName?

  @IBOutlet weak var thumb: UIImageView!

  public func configureCell(item: MediaName, localizedName: String, target: Any?, action: Selector?) {
    self.item = item

    thumb.backgroundColor = UIColor(rgb: 0x00BFFF)

    let itemSize = UIHelper.shared.getItemSize(target as! UICollectionViewController)

    thumb.image = UIHelper.shared.textToImage(drawText: localizedName, size: itemSize)

    CellHelper.shared.addGestureRecognizer(view: self, target: target, action: action)
  }

  override open func didUpdateFocus(in inContext: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
    thumb.adjustsImageWhenAncestorFocused = isFocused
  }
}
