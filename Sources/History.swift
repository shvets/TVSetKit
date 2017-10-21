import Foundation
import Files

public struct HistoryItem: Codable {
  public let time: String
  public let item: MediaItem
}

open class History {
  let HistorySize = 60
  
  public var items: [HistoryItem] = []
  
  var fileName: String
  
  let encoder = JSONEncoder()
  let decoder = JSONDecoder()
  
  public init(_ fileName: String) {
    self.fileName = fileName
  }
  
  public func clear() {
    items.removeAll()
  }

  public func exist() -> Bool {
    return File.exists(atPath: fileName)
  }
  
  public func add(item: MediaItem) {
    if let id = item.id {
      let found = items.filter { item in item.item.id == id }.first
      
      if found == nil {
        let time = String(Int(Date().timeIntervalSince1970))

        items.append(HistoryItem(time: time, item: item))

        if items.count > HistorySize {
          let _ = items.sorted { value1, value2 in
            let time1 = Double(value1.time)!
            let time2 = Double(value2.time)!

            return time1 < time2
          }

          //print(sortedItems)

          //[String: Any]

          //items = sortedItems[0 ..< HistorySize]
        }
        
        save()
      }
    }
  }
  
  public func remove(_ id: String) -> Bool {
    if let index = items.index(where: {$0.item.id == id}) {
      items.remove(at: index)
      
      return true
    }
    
    return false
  }
  
  public func load() {
    clear()
    
    do {
      let data = try File(path: fileName).read()
      
      items = try decoder.decode([HistoryItem].self, from: data)
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
  
  public func getHistoryItems(pageSize: Int, page: Int) -> [HistoryItem] {
    var newData: [HistoryItem] = []
    
      for index in (page-1)*pageSize ..< page*pageSize {
        if index < items.count {
          newData.append(items[index])
        }
      }
    
    return newData
  }

}
