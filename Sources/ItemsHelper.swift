import Foundation

open class ItemsHelper {
  private let pageLoader = PageLoader()
  
  private var items: [Item]
  private var tableView: UITableView
  
  public init(_ items: [Item], tableView: UITableView) {
    self.items = items
    self.tableView = tableView
  }
  
  public func loadInitialData(_ onLoadCompleted: (([Item]) -> Void)?=nil) {
//    pageLoader.load = {
//      return try self.adapter.load()
//    }
    
    return self.pageLoader.loadData { result in
      if let items = result as? [Item] {
        self.items = items
      }
      
      if let onLoadCompleted = onLoadCompleted {
        onLoadCompleted(self.items)
      }
      
      self.tableView.reloadData()
    }
  }
  
  public func loadMoreData() {
    pageLoader.loadData { result in
      var indexPaths: [IndexPath] = []
      
      for (index, _) in result.enumerated() {
        let indexPath = IndexPath(row: self.items.count + index, section: 0)
        
        indexPaths.append(indexPath)
      }
      
      if let items = result as? [Item] {
        self.items += items
        
        self.tableView.insertRows(at: indexPaths, with: .none)
        
        let step = min(result.count, self.pageLoader.rowSize)
        
        self.tableView.scrollToRow(at: indexPaths[step-1], at: .middle, animated: false)
      }
    }
  }
  
  public func nextPageAvailable(dataCount: Int, index: Int) -> Bool {
    return pageLoader.nextPageAvailable(dataCount: dataCount, index: index)
  }
  
}
