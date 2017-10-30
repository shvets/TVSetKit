import Foundation
import Files

extension File {
  open class func exists(atPath path: String) -> Bool {
    return FileManager.default.fileExists(atPath: path)
  }
}