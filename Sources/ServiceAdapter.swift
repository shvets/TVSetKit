import UIKit

open class ServiceAdapter {
  open class var StoryboardId: String { return "" }
  open class var BundleId: String { return "" }

  public var pageLoader = PageLoader()
  public var params = Parameters()
  public var dataSource: DataSource!

  public var mobile: Bool!

  public init(dataSource: DataSource, mobile: Bool=false) {
    self.dataSource = dataSource
    self.mobile = mobile

    self.pageLoader.load = {
      return try self.load()
    }
  }

  open func load() throws -> [Any] {
    if params["requestType"] as? String != nil {
      var newParams = Parameters()

      for (key, value) in params {
        newParams[key] = value
      }

      newParams["pageSize"] = pageLoader.pageSize
      newParams["currentPage"] = pageLoader.currentPage

      return try dataSource.load(params: newParams)
    }
    else {
      return []
    }
  }
  
  open func clone() -> ServiceAdapter {
    return ServiceAdapter(dataSource: dataSource, mobile: mobile)
  }

  open func instantiateController(controllerId: String, storyboardId: String, bundleId: String) -> UIViewController {
    return UIViewController.instantiate(controllerId: controllerId, storyboardId: storyboardId, bundleId: bundleId)
  }

  open func clear() {
    pageLoader.clear()

    params["requestType"] = ""
    params["isContainer"] = false
    params["parentId"] = ""
    params["parentName"] = ""
    params["query"] = ""
    params["selectedItem"] = nil
  }

  open func buildLayout() -> UICollectionViewFlowLayout? {
    return nil
  }

  open func getDetailsImageFrame() -> CGRect? {
    return nil
  }

  open func getParentName() -> String? {
    if let selectedItem = params["selectedItem"] as? Item {
      return selectedItem.name
    }
    else if let parentName = params["parentName"] as? String {
      return parentName
    }
    else {
      return ""
    }
  }

  @discardableResult open func addBookmark(item: MediaItem) -> Bool {
    return true
  }
  
  open func removeBookmark(item: MediaItem) -> Bool {
    return true
  }

  open func addHistoryItem(_ item: MediaItem) {}

  open func isBookmark(_ requestType: String) -> Bool {
    return requestType != "History" && requestType == "Bookmarks"
  }

}
