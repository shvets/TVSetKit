import Foundation
import SwiftyJSON

open class History: FileStorage {
  let HISTORY_SIZE = 60;

  public func getHistoryItems(pageSize: Int, page: Int) -> [Any] {
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

  public func add(item: MediaItem) {
    let id = item.id!

    let found = items.filter { (key, _) in key == id }.first

    if found == nil {
      let time = String(Int(Date().timeIntervalSince1970))

      add(key: id, value: ["time": time, "item": item.toJson()])

      if items.count > HISTORY_SIZE {
        let sortedItems = items.sorted { element1, element2 in
          let (_, value1) = element1
          let (_, value2) = element1

          let data1 = value1 as! [String: Any]
          let data2 = value2 as! [String: Any]

          let time1 = Double(data1["time"] as! String)!
          let time2 = Double(data2["time"] as! String)!

          return time1 < time2
        }

        //print(sortedItems)

        //[String: Any]

        //items = sortedItems[0..<HISTORY_SIZE]
      }

      save()
    }
  }

}
