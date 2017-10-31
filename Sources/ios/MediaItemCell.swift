import UIKit

open class MediaItemCell: UICollectionViewCell {
  @IBOutlet weak var title: UILabel!
  @IBOutlet weak var thumb: UIImageView!

  public func configureCell(item: Any, localizedName: String) {
    if let item = item as? MediaItem {
      self.title.text = item.getDetailedName()
      
      CellHelper.shared.loadImage(path: item.getPosterPath(), name: localizedName, imageView: thumb)
    }
  }

#if os(tvOS)
  override open func didUpdateFocus(in inContext: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
    self.thumb.adjustsImageWhenAncestorFocused = self.isFocused
  }
#endif

  public func setTitle(title: String) {
    self.title.text = title
  }

}