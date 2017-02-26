import UIKit

open class InfiniteTableViewController: UITableViewController {
  let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)

  var adapter: ServiceAdapter!

  var items = [MediaItem]()

  var params = [String: Any]()

  public func getItem(for cell: UITableViewCell) -> MediaItem {
    let indexPath = tableView?.indexPath(for: cell)!

    return items[indexPath!.row]
  }

  func loadInitialData() {
    adapter.loadData() { result in
      self.items = result

      self.tableView?.reloadData()
    }
  }

  func loadMoreData(_ index: Int) {
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
