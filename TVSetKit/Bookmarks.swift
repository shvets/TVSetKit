import Foundation
import SwiftyJSON

open class Bookmarks: FileStorage {

  public func getBookmarks(pageSize: Int, page: Int) -> [Any] {
    var data: [Any] = []

    for (_, item) in items {
      var json = JSON(item)

      data.append(json["item"])
    }

    var newData: [Any] = []

    for index in (page-1)*pageSize ..< page*pageSize {
      if index < data.count {
        newData.append(data[index])
      }
    }

    return newData
  }

  public func addBookmark(item: MediaItem) -> Bool {
    let id = item.id!

    let found = items.filter { (key, _) in key == id }.first

    if found == nil {
      add(key: id, value: ["item": item.toJson()])

      save()

      return true
    }

    return false
  }

  public func removeBookmark(item: MediaItem) -> Bool {
    let result = remove(item.id!)

    if result {
      save()
    }

    return result
  }
  
}
