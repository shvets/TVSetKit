import UIKit
import SwiftyJSON

open class BaseCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  public let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)

  public var adapter: ServiceAdapter!

  public var items = [MediaItem]()

  var params = [String: Any]()

  let cellSelection = CellSelection()

  func getSelectedItem() -> MediaItem? {
    var item: MediaItem?

    if let indexPath = cellSelection.getIndexPath() {
      item = items[indexPath.row]
    }

    return item
  }

  func removeCell() {
    if let indexPath = cellSelection.getIndexPath() {
      _ = items.remove(at: indexPath.row)

      cellSelection.resetIndexPath()

      navigationItem.title = ""

      DispatchQueue.main.async {
        self.collectionView?.reloadData()
      }
    }
  }

}
