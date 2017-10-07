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
        let pname = parentName.rawString() ?? ""
        let name = item["name"].rawString() ?? ""

        if pname.isEmpty {
          item["name"] = JSON("\(name)")
        }
        else {
          item["name"] = JSON("\(pname) (\(name))")
        }
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
    if let id = item.id {
      let found = items.filter { (key, _) in key == id }.first

      if found == nil {
        add(key: id, value: ["item": item.toDictionary()])

        save()

        return true
      }
    }

    return false
  }

  public func removeBookmark(item: MediaItem) -> Bool {
    if let id = item.id {
      let result = remove(id)

      if result {
        save()
      }

      return result
    }

    return false
  }
  
  public func addChannel(name: String, id: String) -> Bool {
    let found = items.filter { (key, _) in key == id }.first
    
    if found == nil {
      add(key: id, value: ["item":["name": name,  "id": id]])
      
      save()
      
      return true
    }
    
    return false
  }
  
  public func removeChannel(id: String) -> Bool {
    let result = remove(id)
    
    if result {
      save()
    }
    
    return result
  }
  
}
