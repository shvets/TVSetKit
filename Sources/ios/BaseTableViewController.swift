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

  // MARK: UITableViewDataSource

  override open func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }

  override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath) as! MediaNameTableCell

    let item = items[indexPath.row]

    cell.configureCell(item: item, localizedName: getLocalizedName(item.name))

    return cell
  }

  open func getLocalizedName(_ name: String?) -> String {
    if let localizer = localizer, let name = name {
      return localizer.localize(name)
    }
    else {
      return ""
    }
  }

}
