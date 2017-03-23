import UIKit
import SwiftyJSON

open class BaseCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  open var CellIdentifier: String {
    return ""
  }

  public var localizer: Localizer!

  public let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)

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

  public func getItem(for cell: UICollectionViewCell) -> MediaItem {
    let indexPath = collectionView?.indexPath(for: cell)!

    return items[indexPath!.row]
  }

  open func tapped(_ gesture: UITapGestureRecognizer) {
    navigate(from: gesture.view as! UICollectionViewCell)
  }

  override open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    navigate(from: collectionView.cellForItem(at: indexPath)!)
  }

  open func navigate(from view: UICollectionViewCell, playImmediately: Bool=false) {}

  // MARK: UICollectionViewDataSource

  override open func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }

  override open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return items.count
  }

  override open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier, for: indexPath) as! MediaNameCell

    let item = items[indexPath.row]

    let localizedName = (localizer == nil) ? item.name! : localizer.localize(item.name!)

    cell.configureCell(item: item, localizedName: localizedName, target: self)

    CellHelper.shared.addTapGestureRecognizer(view: cell, target: self, action: #selector(self.tapped(_:)))

    return cell
  }
}
