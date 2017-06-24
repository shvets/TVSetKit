import UIKit
import SwiftyJSON

open class MediaItem: MediaName {
  public var type: String?
  public var parentName: String?
  public var parentId: String?
  public var thumb: String?
  public var tags: String?
  public var description: String?
  public var rating: Int?
  public var watchStatus: String?
  public var seasonNumber: String?
  public var episodeNumber: String?

  public override init(name: String, id: String? = nil, imageName: String? = nil) {
    super.init(name: name, id: id, imageName: imageName)
  }

  public init(data: JSON) {
    self.type = data["type"].stringValue
    self.thumb = data["thumb"].stringValue
    self.tags = data["tags"].stringValue
    self.description = data["description"].stringValue
    self.rating = data["rating"].intValue
    self.parentName = data["parentName"].stringValue
    self.parentId = data["parentId"].stringValue
    self.watchStatus = data["watchStatus"].stringValue
    self.seasonNumber = data["seasonNumber"].stringValue
    self.episodeNumber = data["episodeNumber"].stringValue

    super.init(name: data["name"].stringValue, id: data["id"].stringValue)
  }

  open func isContainer() -> Bool {
    return false
  }
  
  open func isAudioContainer() -> Bool {
    return false
  }

  open func hasMultipleVersions() -> Bool {
    return false
  }

  open func getDetailedName() -> String {
    if let name = name {
      return name
    }

    return ""
  }

  open func resolveType() {}

  open func getPosterPath(isBetterQuality: Bool = false) -> String {
    return thumb ?? ""
  }
  
  open func getWatchStatus() -> String {
    return ""
  }
  
  open func getBitrates() throws -> [[String: Any]] {
    return []
  }

  open func getBitrate(qualityLevel: QualityLevel) throws -> [String: Any] {
    let bitrates = try getBitrates()

    var selectedIndex = -1

    for (index, bitrate) in bitrates.enumerated() {
      if let bitrate = bitrate["name"] as? String,
         bitrate == qualityLevel.rawValue {
        selectedIndex = index
      }
    }

    if selectedIndex >= 0 {
      return bitrates[selectedIndex]
    }
    else {
      return [:]
    }
  }

  open func getQualityLevels() throws -> [QualityLevel] {
    var qualityLevels: [QualityLevel] = []

    let bitrates = try getBitrates()

    for bitrate in bitrates {
      if let name = bitrate["name"] as? String,
         let qualityLevel = QualityLevel(rawValue: name) {
        qualityLevels.append(qualityLevel)
      }
    }

    return qualityLevels
  }

  override open func toJson() -> [String: Any] {
    var result: [String: Any] = ["type": type ?? "", "parentName": parentName ?? "", "thumb": thumb ?? "",
                                 "tags": tags ?? "", "description": description ?? "",
                                 "rating": rating?.description ?? "",
                                 "seasonNumber": seasonNumber ?? ""]

    for (key, value) in super.toJson() {
      result[key] = value
    }

    return result
  }
}
