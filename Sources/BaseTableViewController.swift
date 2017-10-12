import UIKit

open class BaseTableViewController: UITableViewController {
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

  public var items = [Item]()

  var params: [String: Any] = [:]

  public let cellSelection = CellSelection()

  override open func viewDidLoad() {
    super.viewDidLoad()

    localizer = Localizer(BundleId, bundleClass: TVSetKit.self)
  }

  public func loadInitialData(_ onLoadCompleted: (([Item]) -> Void)?=nil) {
    return adapter.pageLoader.loadData { result in
      if let items = result as? [Item] {
        self.items = items
      }

      if let onLoadCompleted = onLoadCompleted {
        onLoadCompleted(self.items)
      }

      self.tableView?.reloadData()
    }
  }

  public func loadMoreData() {
    let pageLoader = adapter.pageLoader

    pageLoader.loadData { result in
      var indexPaths: [IndexPath] = []

      for (index, _) in result.enumerated() {
        let indexPath = IndexPath(row: self.items.count + index, section: 0)

        indexPaths.append(indexPath)
      }

      if let items = result as? [Item] {
        self.items += items

        self.tableView?.insertRows(at: indexPaths, with: .none)

        let step = min(result.count, pageLoader.rowSize)

        self.tableView?.scrollToRow(at: indexPaths[step-1], at: .middle, animated: false)
      }
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
    if let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath) as? MediaNameTableCell {
      if adapter != nil && adapter.pageLoader.nextPageAvailable(dataCount: items.count, index: indexPath.row) {
        loadMoreData()
      }

      let item = items[indexPath.row]

      cell.configureCell(item: item, localizedName: getLocalizedName(item.name))

#if os(tvOS)
      CellHelper.shared.addTapGestureRecognizer(view: cell, target: self, action: #selector(self.tapped(_:)))
#endif

      return cell
    }
    else {
      return UITableViewCell()
    }
  }

  // MARK: UIScrollViewDelegate

//  override open func scrollViewDidScroll(_ scrollView: UIScrollView) {
//    let currentOffset = scrollView.contentOffset.y
//    let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
//    let deltaOffset = maximumOffset - currentOffset
//
//    if deltaOffset <= 0 {
//      if adapter != nil && adapter.nextPageAvailable(dataCount: items.count, index: items.count-1) {
//        loadMoreData()
//      }
//    }
//  }

  open func getSelectedItem() -> Item? {
    var item: Item?

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
        self.tableView?.reloadData()
      }
    }
  }

  public func getItem(for cell: UITableViewCell) -> Item {
    if let indexPath = tableView?.indexPath(for: cell) {
      return items[indexPath.row]
    }
    else {
      return Item()
    }
  }

#if os(tvOS)
  @objc open func tapped(_ gesture: UITapGestureRecognizer) {
    if let location = gesture.view as? UITableViewCell {
      navigate(from: location)
    }
  }
#endif

  override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let location = tableView.cellForRow(at: indexPath) {
      navigate(from: location)
    }
  }

  open func navigate(from view: UITableViewCell) {}

  open func getLocalizedName(_ name: String?) -> String {
    if let name = name {
      return localizer.localize(name)
    }
    else {
      return ""
    }
  }
}
