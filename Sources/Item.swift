import Foundation

open class Item: Codable {
  public var name: String?
  public var id: String?

  public init(name: String?=nil, id: String?=nil) {
    self.name = name
    self.id = id
  }

  private enum CodingKeys: String, CodingKey {
    case name
    case id
  }

  public required convenience init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    let name = try container.decodeIfPresent(String.self, forKey: .name)
    let id = try container.decodeIfPresent(String.self, forKey: .id)

    self.init(name: name ?? "", id: id ?? "")
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encode(name, forKey: .name)
    try container.encode(id, forKey: .id)
  }
}

