import Foundation

public class CellSelection {
  var indexPath: IndexPath?

  public init() {}

  open func getIndexPath() -> IndexPath? {
    return indexPath
  }

  open func setIndexPath(_ indexPath: IndexPath) {
    self.indexPath = indexPath
  }

  open func resetIndexPath() {
    self.indexPath = nil
  }

}
