import UIKit
import SwiftyJSON
import Foundation

open class InfiniteCollectionViewController: BaseCollectionViewController {

  public func loadInitialData(_ onLoadCompleted: (([MediaItem]) -> Void)?=nil) {
    return adapter.loadData() { result in
      self.items = result

      if let onLoadCompleted = onLoadCompleted {
        onLoadCompleted(self.items)
      }

      self.collectionView?.reloadData()
    }
  }

  public func loadMoreData(_ index: Int) {
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

  override open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier, for: indexPath) as! MediaNameCell

    if adapter.nextPageAvailable(dataCount: items.count, index: indexPath.row) {
      loadMoreData(indexPath.row)
    }

    let item = items[indexPath.row]

    let localizedName = (localizer == nil) ? item.name! : localizer.localize(item.name!)

    cell.configureCell(item: item, localizedName: localizedName, target: self)

    CellHelper.shared.addGestureRecognizer(view: cell, target: self, action: #selector(self.tapped(_:)))

    return cell
  }

}
