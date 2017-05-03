import Foundation
import SwiftyJSON

open class Bookmarks: FileStorage {

  override public func load() {
    do {
      try super.load()
    }
    catch {
      print("Error loading bookmarks")
    }
  }

  override public func save() {
    do {
      try super.save()
    }
    catch {
      print("Error saving bookmarks")
    }
  }

  public func getBookmarks(pageSize: Int, page: Int) -> [Any] {
    var data: [Any] = []

    for (_, item) in items {
      var json = JSON(item)

      var item = json["item"]

      let parentName = item["parentName"]

      if parentName != JSON.null {
        item["name"] = JSON("\(parentName.rawString()!) (\(item["name"].rawString()!))")
      }

      data.append(item)
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

      do {
        try save()
      }
      catch {
        print("Error saving bookmarks")
      }

      return true
    }

    return false
  }

  public func removeBookmark(item: MediaItem) -> Bool {
    let result = remove(item.id!)

    if result {
      do {
        try save()
      }
      catch {
        print("Error saving bookmarks")
      }
    }

    return result
  }
  
}
