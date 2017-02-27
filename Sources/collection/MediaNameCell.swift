import UIKit

open class MediaNameCell: UICollectionViewCell {
  @IBOutlet weak var thumb: UIImageView!

  public func configureCell(item: MediaName, localizedName: String, target: Any?, action: Selector?) {
    thumb.backgroundColor = UIColor(rgb: 0x00BFFF)

    let itemSize = UIHelper.shared.getItemSize(target as! UICollectionViewController)

    thumb.image = UIHelper.shared.textToImage(drawText: localizedName, size: itemSize)

    CellHelper.shared.addGestureRecognizer(view: self, target: target, action: action)
  }

#if os(tvOS)
  override open func didUpdateFocus(in inContext: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
    self.thumb.adjustsImageWhenAncestorFocused = self.isFocused
  }
#endif
}
