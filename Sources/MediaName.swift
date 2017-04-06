import UIKit

open class MediaName {
  public var name: String?
  public var id: String?
  public var imageName: String?

  public init(name: String, id: String? = nil, imageName: String? = nil) {
    self.name = name
        
    if id != nil {
      self.id = id
    }

    if imageName != nil {
      self.imageName = imageName
    }
  }

  public func toJson() -> [String: Any] {
    return ["name": name!, "id": id == nil ? "" : id!, "imageName": imageName == nil ? "" : imageName!]
  }
}
