import Foundation

class CellSelection {
  var indexPath: IndexPath?

  func getIndexPath() -> IndexPath? {
    return indexPath
  }

  func setIndexPath(_ indexPath: IndexPath) {
    self.indexPath = indexPath
  }

  func resetIndexPath() {
    self.indexPath = nil
  }

}
