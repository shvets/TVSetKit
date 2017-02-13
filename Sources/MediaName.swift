import UIKit

open class MediaName {
  public var name: String?
  public var id: String?

  public init(name: String, id: String? = nil) {
    self.name = name
        
    if id != nil {
      self.id = id
    }
  }

  public func toJson() -> [String: Any] {
    return ["name": name!, "id": id!]
  }
}
