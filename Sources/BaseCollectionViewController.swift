import UIKit
import SwiftyJSON

open class BaseCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  open var CellIdentifier: String { return "" }
  open var BundleId: String { return "" }

  public var localizer: Localizer!

#if os(iOS)
  public let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
#endif

#if os(tvOS)
  public let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
#endif

  public var adapter: ServiceAdapter!

  public var items = [MediaItem]()

  var params: [String: Any] = [:]

  let cellSelection = CellSelection()

  public func loadInitialData(_ onLoadCompleted: (([MediaItem]) -> Void)?=nil) {
    return adapter.loadData() { result in
      self.items = result

      if let onLoadCompleted = onLoadCompleted {
        onLoadCompleted(self.items)
      }

      self.collectionView?.reloadData()
    }
  }

  public func loadMoreData() {
    adapter.loadData() { result in
      var indexPaths: [IndexPath] = []

      for (index, _) in result.enumerated() {
        let indexPath = IndexPath(row: self.items.count + index, section: 0)

        indexPaths.append(indexPath)
      }

      self.items += result

      self.collectionView?.insertItems(at: indexPaths)

      let step = min(result.count, self.adapter.rowSize!)

      self.collectionView?.scrollToItem(at: indexPaths[step-1], at: .left, animated: false)
    }
  }

  // MARK: UICollectionViewDataSource

  override open func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }

  override open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return items.count
  }

  override open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier, for: indexPath) as! MediaNameCell

    if adapter != nil && adapter.nextPageAvailable(dataCount: items.count, index: indexPath.row) {
      loadMoreData()
    }

    let item = items[indexPath.row]

    cell.configureCell(item: item, localizedName: getLocalizedName(item.name), target: self)

    CellHelper.shared.addTapGestureRecognizer(view: cell, target: self, action: #selector(self.tapped(_:)))

    return cell
  }

  // MARK: UIScrollViewDelegate

  override open func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let currentOffset = scrollView.contentOffset.y
    let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
    let deltaOffset = maximumOffset - currentOffset

    if deltaOffset <= 1 { // approximately, close to zero
      if adapter != nil && adapter.nextPageAvailable(dataCount: items.count, index: items.count-1) {
        loadMoreData()
      }
    }
  }

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

  open func getLocalizedName(_ name: String?) -> String {
    if let localizer = localizer, let name = name {
      return localizer.localize(name)
    }
    else {
      return ""
    }
  }
}
