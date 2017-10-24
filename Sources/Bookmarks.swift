import Foundation
import Files

public struct BookmarkItem: Codable {
  public var item: MediaItem
  public var type: String

  private enum CodingKeys: String, CodingKey {
    case item
    case type
  }

  public init(item: MediaItem, type: String) {
    self.item = item
    self.type = type
  }
  
  public init(from decoder: Decoder) throws {
    self.init(item: try MediaItem(from: decoder), type: "bookmark")
    
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    item = try container.decodeIfPresent(MediaItem.self, forKey: .item)!
    type = try container.decodeIfPresent(String.self, forKey: .type)!
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    
    try container.encode(item, forKey: .item)
    try container.encode(type, forKey: .type)
  }

  public func getName() -> String {
    if let name = item.name, let parentName = item.parentName {
      if parentName.isEmpty {
        return name
      }
      else {
        return "\(parentName) (\(name))"
      }
    }

    return ""
  }
}

open class Bookmarks {
  public var items: [BookmarkItem] = []

  var fileName: String = ""

  let encoder = JSONEncoder()
  let decoder = JSONDecoder()

  public init(_ fileName: String) {
    self.fileName = fileName
  }

  public func getMediaItems() -> [MediaItem] {
    var mediaItems = [MediaItem]()
    
    for item in items {
      mediaItems.append(item.item)
    }
    
    return mediaItems
  }
    
  public func clear() {
    items.removeAll()
  }

  public func exist() -> Bool {
    return File.exists(atPath: fileName)
  }

  public func load() {
    clear()

    do {
      let data = try File(path: fileName).read()
      
      items = try decoder.decode([BookmarkItem].self, from: data)
    }
    catch let e {
      print("Error: \(e)")
    }
  }

  public func save() {
    do {
      let data = try encoder.encode(items)

      try FileSystem().createFile(at: fileName, contents: data)
    }
    catch let e {
      print("Error: \(e)")
    }
  }

  public func getBookmarks(pageSize: Int, page: Int) -> [BookmarkItem] {
    var newData: [BookmarkItem] = []
    
      for index in (page-1)*pageSize ..< page*pageSize {
        if index < items.count {
          newData.append(items[index])
        }
      }

    return newData
  }

  public func addBookmark(item: MediaItem, type: String="bookmark") -> Bool {
    if let id = item.id {
      let found = items.filter { item in item.item.id! == id }.first

      if found == nil {
        items.append(BookmarkItem(item: item, type: type))

        save()

        return true
      }
    }

    return false
  }

  public func removeBookmark(id: String, type: String="bookmark") -> Bool {
    if let index = items.index(where: {$0.item.id == id && $0.type == type}) {
      items.remove(at: index)

      save()

      return true
    }
    
    return false
  }
  
}
