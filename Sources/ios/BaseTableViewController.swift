import UIKit
import SwiftyJSON

open class BaseTableViewController: UITableViewController {
  open var CellIdentifier: String {
    return ""
  }

  public var localizer: Localizer!

  public let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)

  public var adapter: ServiceAdapter!

  public var items = [MediaItem]()

  var params = [String: Any]()

  let cellSelection = CellSelection()

  private var paginationEnabled = false

  open func enablePagination() {
    paginationEnabled = true
  }

  public func loadInitialData(_ onLoadCompleted: (([MediaItem]) -> Void)?=nil) {
    return adapter.loadData() { result in
      self.items = result

      if let onLoadCompleted = onLoadCompleted {
        onLoadCompleted(self.items)
      }

      self.tableView?.reloadData()
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

      self.tableView?.insertRows(at: indexPaths, with: .none)

      let step = min(result.count, self.adapter.rowSize!)

      self.tableView?.scrollToRow(at: indexPaths[step-1], at: .middle, animated: false)
    }
  }

  // MARK: UITableViewDataSource

  override open func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }

  override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath) as! MediaNameTableCell

    if paginationEnabled && adapter != nil && adapter.nextPageAvailable(dataCount: items.count, index: indexPath.row) {
      loadMoreData()
    }

    let item = items[indexPath.row]

    cell.configureCell(item: item, localizedName: getLocalizedName(item.name))

    return cell
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
        self.tableView?.reloadData()
      }
    }
  }

  public func getItem(for cell: UITableViewCell) -> MediaItem {
    let indexPath = tableView?.indexPath(for: cell)!

    return items[indexPath!.row]
  }

  override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    navigate(from: tableView.cellForRow(at: indexPath)!)
  }

  open func navigate(from view: UITableViewCell) {}

  open func getLocalizedName(_ name: String?) -> String {
    if let localizer = localizer, let name = name {
      return localizer.localize(name)
    }
    else {
      return ""
    }
  }

}
