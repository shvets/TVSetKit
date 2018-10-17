//import UIKit
import SwiftyJSON

open class MediaItem: MediaName {
  public var type: String?
  public var parentName: String?
  public var parentId: String?
  public var thumb: String?
  public var tags: String?
  public var description: String?
  public var rating: String?
  public var watchStatus: String?
  public var seasonNumber: String?
  public var episodeNumber: String?

  private enum CodingKeys: String, CodingKey {
    case name
    case id
    case imageName
    
    case type
    case parentName
    case parentId
    case thumb
    case tags
    case description
    case rating
    case watchStatus
    case seasonNumber
    case episodeNumber
  }

  public override init(name: String?, id: String? = nil, imageName: String? = nil) {
    super.init(name: name, id: id, imageName: imageName)
  }

  public init(name: String?, id: String? = nil, imageName: String? = nil,
              type: String?, parentName: String?, parentId: String?, thumb: String?, tags: String?,
              description: String?, rating: String?, watchStatus: String?, seasonNumber: String?,
              episodeNumber: String?) {
    self.type = type
    self.thumb = thumb
    self.tags = tags
    self.description = description
    self.rating = rating
    self.parentName = parentName
    self.parentId = parentId
    self.watchStatus = watchStatus
    self.seasonNumber = seasonNumber
    self.episodeNumber = episodeNumber

    super.init(name: name, id: id, imageName: imageName)
  }

  public init(data: JSON) {
    self.type = data["type"].stringValue
    self.thumb = data["thumb"].stringValue
    self.tags = data["tags"].stringValue
    self.description = data["description"].stringValue
    self.rating = data["rating"].stringValue
    self.parentName = data["parentName"].stringValue
    self.parentId = data["parentId"].stringValue
    self.watchStatus = data["watchStatus"].stringValue
    self.seasonNumber = data["seasonNumber"].stringValue
    self.episodeNumber = data["episodeNumber"].stringValue

    super.init(name: data["name"].stringValue, id: data["id"].stringValue)
  }

  public init(data: [String: String]) {
    self.type = data["type"]
    self.thumb = data["thumb"]
    self.tags = data["tags"]
    self.description = data["description"]
    self.rating = data["rating"]
    self.parentName = data["parentName"]
    self.parentId = data["parentId"]
    self.watchStatus = data["watchStatus"]
    self.seasonNumber = data["seasonNumber"]
    self.episodeNumber = data["episodeNumber"]

    super.init(name: data["name"], id: data["id"])
  }
  
  public required convenience init(from decoder: Decoder) throws {
    self.init(data: [:])
    
    let container = try decoder.container(keyedBy: CodingKeys.self)

    name = try container.decodeIfPresent(String.self, forKey: .name)
    id = try container.decodeIfPresent(String.self, forKey: .id)
    imageName = try container.decodeIfPresent(String.self, forKey: .imageName)

    type = try container.decodeIfPresent(String.self, forKey: .type)
    thumb = try container.decodeIfPresent(String.self, forKey: .thumb)
    tags = try container.decodeIfPresent(String.self, forKey: .tags)
    description = try container.decodeIfPresent(String.self, forKey: .description)
    rating = try container.decodeIfPresent(String.self, forKey: .rating)
    parentName = try container.decodeIfPresent(String.self, forKey: .parentName)
    parentId = try container.decodeIfPresent(String.self, forKey: .parentId)
    watchStatus = try container.decodeIfPresent(String.self, forKey: .watchStatus)
    seasonNumber = try container.decodeIfPresent(String.self, forKey: .seasonNumber)
    episodeNumber = try container.decodeIfPresent(String.self, forKey: .episodeNumber)  
  }
  
  override public func encode(to encoder: Encoder) throws {
    try super.encode(to: encoder)

    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encode(type, forKey: .type)
    try container.encode(parentName, forKey: .parentName)
    try container.encode(parentId, forKey: .parentId)
    try container.encode(thumb, forKey: .thumb)
    try container.encode(tags, forKey: .tags)
    try container.encode(description, forKey: .description)
    try container.encode(rating, forKey: .rating)
    try container.encode(watchStatus, forKey: .watchStatus)

    try container.encode(seasonNumber, forKey: .seasonNumber)
    try container.encode(episodeNumber, forKey: .episodeNumber)
  }

  open func isContainer() -> Bool {
    return false
  }

  open func getDetailedName() -> String {
    if let name = name {
      return name
    }

    return ""
  }

  open func getPosterPath(isBetterQuality: Bool = false) -> String {
    return thumb ?? ""
  }
  
  open func getWatchStatus() -> String {
    return ""
  }
  
  open func getBitrates() throws -> [[String: String]] {
    return []
  }

  open func getBitrate(qualityLevel: QualityLevel) throws -> [String: Any] {
    let bitrates = try getBitrates()

    var selectedIndex = -1

    for (index, bitrate) in bitrates.enumerated() {
      if let bitrate = bitrate["name"], bitrate == qualityLevel.rawValue {
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
      if let name = bitrate["name"], let qualityLevel = QualityLevel(rawValue: name) {
        qualityLevels.append(qualityLevel)
      }
    }

    return qualityLevels
  }

  open func getMediaUrl(index: Int) -> URL? {
    do {
      let bitrates = try getBitrates()

      if !bitrates.isEmpty {
        if let url = try getUrl(bitrates[index]) {
          return NSURL(string: url) as URL?
        }
      }
    }
    catch {
      print("Cannot get bitrates.")
    }

    return nil
  }

  open func getRequestHeaders() -> [String: String] {
    return [:]
  }

  open func getUrl(_ bitrate: [String: String]) throws -> String? {
    return bitrate["url"]
  }

  open func retrieveExtraInfo() throws {}
}
