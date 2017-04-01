import Foundation

open class CellSelection {
  var indexPath: IndexPath?

  func getIndexPath() -> IndexPath? {
    return indexPath
  }

  open func setIndexPath(_ indexPath: IndexPath) {
    self.indexPath = indexPath
  }

  func resetIndexPath() {
    self.indexPath = nil
  }

}
