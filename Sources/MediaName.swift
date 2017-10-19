import UIKit

open class MediaName: Item {
  public var imageName: String?

  public init(name: String?=nil, id: String?=nil, imageName: String?=nil) {
    super.init(name: name, id: id)

    self.imageName = imageName
  }

  private enum CodingKeys: String, CodingKey {
    case name
    case id
    case imageName
  }

  public required convenience init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    let name = try container.decodeIfPresent(String.self, forKey: .name)
    let id = try container.decodeIfPresent(String.self, forKey: .id)
    let imageName = try container.decodeIfPresent(String.self, forKey: .imageName)

    self.init(name: name ?? "",
      id: id ?? "",
      imageName: imageName ?? ""
    )
  }

  public override func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encode(name, forKey: .name)
    try container.encode(id, forKey: .id)
    try container.encode(imageName, forKey: .imageName)
  }
}

