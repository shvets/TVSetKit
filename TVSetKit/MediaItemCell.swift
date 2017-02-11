import UIKit

open class MediaItemCell: UICollectionViewCell {
  public var item: MediaItem?

  @IBOutlet weak var title: UILabel!
  @IBOutlet weak var thumb: UIImageView!

  public func configureCell(item: MediaItem, localizedName: String, target: Any?, action: Selector?) {
    self.item = item

    self.title.text = item.getDetailedName()

    CellHelper.shared.loadImage(path: item.getPosterPath(), name: localizedName, imageView: thumb)

    CellHelper.shared.addGestureRecognizer(view: self, target: target, action: action)
  }

  override open func didUpdateFocus(in inContext: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
    self.thumb.adjustsImageWhenAncestorFocused = self.isFocused
  }
}
