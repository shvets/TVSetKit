import UIKit

open class TVSetKitLocalizer: Localizer {
  static let ModuleBundle = Bundle(identifier: "com.rubikon.TVSetKit")!

  override public func localize(_ key: String, comment: String = "", bundle: Bundle=ModuleBundle) -> String {
    return super.localize(key, comment: comment, bundle: bundle)
  }

}
