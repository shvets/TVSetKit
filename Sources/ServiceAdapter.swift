import UIKit
import SwiftyJSON

open class ServiceAdapter {
  open class var StoryboardId: String { return "" }
  open class var BundleId: String { return "" }

//  public var requestType: String?
//  public var isContainer = false
//  public var parentId: String?
//  public var parentName: String?
//  public var query: String?
//  public var selectedItem: MediaItem?

  public let pageLoader = PageLoader()
  public var params = RequestParams()
  public var dataSource: DataSource!

  public var mobile: Bool!

  public init(dataSource: DataSource, mobile: Bool=false) {
    self.dataSource = dataSource
    self.mobile = mobile
  }
  
  open func clone() -> ServiceAdapter {
    return ServiceAdapter(dataSource: dataSource, mobile: mobile)
  }

  open func instantiateController(controllerId: String, storyboardId: String, bundleId: String) -> UIViewController {
    return UIViewController.instantiate(controllerId: controllerId, storyboardId: storyboardId, bundleId: bundleId)
  }

  open func clear() {
    pageLoader.clear()

    params.requestType = ""
    params.isContainer = false
    params.parentId = ""
    params.parentName = ""
    params.query = ""

    params.selectedItem = nil
  }

  open func load() throws -> [Any] {
//    if let requestType = requestType, let dataSource = dataSource {
//      return try dataSource.load(requestType, params: params, pageSize: pageLoader.pageSize!, currentPage: pageLoader.currentPage)
//    }
//    else {
      return []
    //}
  }

  open func buildLayout() -> UICollectionViewFlowLayout? {
    return nil
  }

  open func getDetailsImageFrame() -> CGRect? {
    return nil
  }

  open func getParentName() -> String? {
    return (params.parentName != nil) ? params.parentName : params.selectedItem?.name
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

