import Foundation
import UIKit

public struct MenuItem {
  public var name: String?
  public var imageName: String?

  public init(name: String? = nil, imageName: String? = nil) {
    self.name = name
    self.imageName = imageName
  }
}
