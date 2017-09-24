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

  public let cellSelection = CellSelection()

  open func loadInitialData(_ onLoadCompleted: (([MediaItem]) -> Void)?=nil) {
    return adapter.pageLoader.loadData { result in
      if let items = result as? [MediaItem] {
        self.items = items
      }

      if let onLoadCompleted = onLoadCompleted {
        onLoadCompleted(self.items)
      }

      self.collectionView?.reloadData()
    }
  }

  open func loadMoreData() {
    let pageLoader = adapter.pageLoader

    pageLoader.loadData { result in
      var indexPaths: [IndexPath] = []

      for (index, _) in result.enumerated() {
        let indexPath = IndexPath(row: self.items.count + index, section: 0)

        indexPaths.append(indexPath)
      }

      if let items = result as? [MediaItem] {
        self.items += items

        self.collectionView?.insertItems(at: indexPaths)

        let step = min(result.count, pageLoader.rowSize)

        self.collectionView?.scrollToItem(at: indexPaths[step-1], at: .left, animated: false)
      }
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
    if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier, for: indexPath) as? MediaNameCell {
      if adapter != nil && adapter.pageLoader.nextPageAvailable(dataCount: items.count, index: indexPath.row) {
        loadMoreData()
      }

      let item = items[indexPath.row]

      cell.configureCell(item: item, localizedName: getLocalizedName(item.name), target: self)

      CellHelper.shared.addTapGestureRecognizer(view: cell, target: self, action: #selector(self.tapped(_:)))

      return cell
    }
    else {
      return UICollectionViewCell()
    }
  }

  // MARK: UIScrollViewDelegate

  override open func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let currentOffset = scrollView.contentOffset.y
    let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
    let deltaOffset = maximumOffset - currentOffset

    if deltaOffset <= 1 { // approximately, close to zero
      if adapter != nil && adapter.pageLoader.nextPageAvailable(dataCount: items.count, index: items.count-1) {
        loadMoreData()
      }
    }
  }

  open func getSelectedItem() -> MediaItem? {
    var item: MediaItem?

    if let indexPath = cellSelection.getIndexPath() {
      item = items[indexPath.row]
    }

    return item
  }

  open func removeCell() {
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
    if let indexPath = collectionView?.indexPath(for: cell) {
      return items[indexPath.row]
    }
    else {
      return MediaItem(data: JSON.null)
    }
  }

  @objc open func tapped(_ gesture: UITapGestureRecognizer) {
    if let location = gesture.view as? UICollectionViewCell {
      navigate(from: location)
    }
  }

  override open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if let location = collectionView.cellForItem(at: indexPath) {
      navigate(from: location)
    }
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
