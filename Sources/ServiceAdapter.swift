import UIKit
import SwiftyJSON

open class ServiceAdapter {
  open class var StoryboardId: String { return "" }
  open class var BundleId: String { return "" }

  public let pageLoader = PageLoader()
  public var params = Parameters()
  public var dataSource: DataSource!

  public var mobile: Bool!

  public init(dataSource: DataSource, mobile: Bool=false) {
    self.dataSource = dataSource
    self.mobile = mobile

    pageLoader.load = {
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
    //return (params["parentName"] != nil) ? params["parentName"] as! String : (params["selectedItem"] as! MediaItem).name
    return params["parentName"] as! String
  }

  open func getUrl(_ params: [String: Any]) throws -> String? {
    return ""
  }

  open func retrieveExtraInfo(_ item: MediaItem) throws {}
  
  @discardableResult open func addBookmark(item: MediaItem) -> Bool {
    return true
  }
  
  open func removeBookmark(item: MediaItem) -> Bool {
    return true
  }

  open func addHistoryItem(_ item: MediaItem) {}

}
