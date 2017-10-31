import Foundation
import PageLoader

open class Items {
  public var pageLoader = PageLoader()
  public var cellSelection: IndexPath?
  
  public var items: [Item] = []

  public init() {}

  public var count: Int {
    return items.count
  }

  public subscript(index: Int) -> Item {
    get {
      return items[index]
    }
    set(newValue) {
      items[index] = newValue
    }
  }

  public func loadInitialData(_ view: UIView?, onLoadCompleted: (([Item]) -> Void)?=nil) {
    self.pageLoader.loadData { result in
      if let items = result as? [Item] {
        self.items = items
      }

      if let onLoadCompleted = onLoadCompleted {
        onLoadCompleted(self.items)
      }

      if let view = view as? UITableView {
        view.reloadData()
      }
      else if let view = view as? UICollectionView {
        view.reloadData()
      }
    }
  }
  
  public func loadMoreData(_ view: UIView?, onLoadCompleted: (([Item]) -> Void)?=nil) {
    pageLoader.loadData { result in
      var indexPaths: [IndexPath] = []

      for (index, _) in result.enumerated() {
        let indexPath = IndexPath(row: self.items.count + index, section: 0)

        indexPaths.append(indexPath)
      }
      
      if let items = result as? [Item] {
        self.items += items

        if let view = view as? UITableView {
          view.insertRows(at: indexPaths, with: .none)

          let step = min(result.count, self.pageLoader.rowSize)

          view.scrollToRow(at: indexPaths[step-1], at: .middle, animated: false)
        }
        else if let view = view as? UICollectionView {
          view.insertItems(at: indexPaths)

          let step = min(result.count, self.pageLoader.rowSize)

          view.scrollToItem(at: indexPaths[step-1], at: .left, animated: false)
        }
      }

      if let onLoadCompleted = onLoadCompleted {
        onLoadCompleted(self.items)
      }
    }
  }
  
  public func nextPageAvailable(dataCount: Int, index: Int) -> Bool {
    return pageLoader.nextPageAvailable(dataCount: dataCount, index: index)
  }

  public func getSelectedItem() -> Item? {
    var item: Item?

    if let indexPath = cellSelection {
      item = items[indexPath.row]
    }

    return item
  }

  public func removeCell(_ onRemoveCompleted: (() -> Void)?=nil) {
    if let indexPath = cellSelection {
      _ = items.remove(at: indexPath.row)

      cellSelection = nil

      if let onRemoveCompleted = onRemoveCompleted {
        onRemoveCompleted()
      }
    }
  }

  public func getItem(for indexPath: IndexPath?) -> Item {
    if let indexPath = indexPath {
      return items[indexPath.row]
    }
    else {
      return Item()
    }
  }
  
}