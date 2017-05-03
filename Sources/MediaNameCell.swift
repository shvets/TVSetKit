import UIKit

open class MediaNameCell: UICollectionViewCell {
  @IBOutlet private weak var thumb: UIImageView!

  public func configureCell(item: MediaName, localizedName: String, target: Any?) {
    thumb.backgroundColor = UIColor(rgb: 0x00BFFF)

    let itemSize = UIHelper.shared.getItemSize(target as! UICollectionViewController)

    var icon: UIImage?

    if item.imageName != nil {
      icon = UIImage(named: item.imageName!)
    }

    let image = UIHelper.shared.textToImage(drawText: localizedName, size: itemSize, drawImage: icon)

    thumb.image = image
  }

#if os(tvOS)
  override open func didUpdateFocus(in inContext: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
    self.thumb.adjustsImageWhenAncestorFocused = self.isFocused
  }
#endif
}
