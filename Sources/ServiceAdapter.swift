import UIKit
import SwiftyJSON

open class ServiceAdapter {
  open class var StoryboardId: String { return "" }
  open class var BundleId: String { return "" }

  public var requestType: String?
  public var isContainer = false
  public var parentId: String?
  public var parentName: String?
  public var query: String?

  public var selectedItem: MediaItem?

  public let pageLoader = PageLoader()

  private var configName: String?

  public var mobile: Bool?

  public init(mobile: Bool=false) {
    self.mobile = mobile
  }
  
  open func clone() -> ServiceAdapter {
    return ServiceAdapter()
  }

  open func instantiateController(controllerId: String, storyboardId: String, bundleId: String) -> UIViewController {
    return UIViewController.instantiate(controllerId: controllerId, storyboardId: storyboardId, bundleId: bundleId)
  }

  open func clear() {
    pageLoader.clear()

    requestType = ""
    isContainer = false
    parentId = ""
    parentName = ""
    query = ""

    selectedItem = nil
  }

  open func load() throws -> [MediaItem] {
    return []
  }

  open func buildLayout() -> UICollectionViewFlowLayout? {
    return nil
  }

  open func getDetailsImageFrame() -> CGRect? {
    return nil
  }

  open func getParentName() -> String? {
    return (parentName != nil) ? parentName : selectedItem?.name
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

