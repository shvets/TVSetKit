import UIKit
import SwiftyJSON
import Foundation

open class InfiniteCollectionViewController: BaseCollectionViewController {

  public func loadInitialData() {
    adapter.loadData() { result in
      self.items = result

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

      let step = min(result.count, self.adapter.rowSize)

      self.collectionView?.scrollToItem(at: indexPaths[step-1], at: .left, animated: false)
    }
  }

}
