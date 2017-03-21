import UIKit

open class InfiniteTableViewController: BaseTableViewController {
  public func loadInitialData(_ onLoadCompleted: (([MediaItem]) -> Void)?=nil) {
    return adapter.loadData() { result in
      self.items = result

      if let onLoadCompleted = onLoadCompleted {
        onLoadCompleted(self.items)
      }

      self.tableView?.reloadData()
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

      self.tableView?.insertRows(at: indexPaths, with: .none)

      let step = min(result.count, self.adapter.rowSize!)

      self.tableView?.scrollToRow(at: indexPaths[step-1], at: .middle, animated: false)
    }
  }
}
