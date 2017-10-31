import UIKit

open class MediaNameCell: UICollectionViewCell {
  @IBOutlet private weak var thumb: UIImageView!

  public func configureCell(item: MediaName, localizedName: String, target: Any?) {
    thumb.backgroundColor = UIColor(rgb: 0x00BFFF)

    if let controller = target as? UICollectionViewController {
      let itemSize = UIHelper.shared.getItemSize(controller)

      var icon: UIImage?

      if let imageName = item.imageName {
        icon = UIImage(named: imageName)
      }

      let image = UIHelper.shared.textToImage(drawText: localizedName, size: itemSize, drawImage: icon)

      thumb.image = image
    }
  }

#if os(tvOS)
  override open func didUpdateFocus(in inContext: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
    self.thumb.adjustsImageWhenAncestorFocused = self.isFocused
  }
#endif
}
