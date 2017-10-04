import UIKit

open class Localizer {
  public static let DefaultLocale = "ru"
  private static let configName = NSHomeDirectory() + "/Library/Caches/localizer.json"

  let config: PlainConfig!

  public var bundle: Bundle?

  public init(_ identifier: String="", bundleClass: AnyClass?=nil) {
    if identifier.isEmpty {
      bundle = Bundle.main
    }
    else {
      bundle = Bundle(identifier: identifier)
    }

    if bundle == nil {
      if let bundleClass = bundleClass {
        let podBundle = Bundle(for: bundleClass)

        if let bundleURL = podBundle.url(forResource: identifier, withExtension: "bundle") {
          bundle = Bundle(url: bundleURL)!
        }
      }
    }

    config = PlainConfig(Localizer.configName)
  }

  public func setLocale(langCode: String) {
    config.items["langCode"] = langCode
    config.save()
  }

  public func getLocale() -> String {
    var locale = Localizer.DefaultLocale

    config.load()

    if let langCode = config.items["langCode"] {
      locale = langCode
    }

    return locale
  }

  public func localize(_ key: String, comment: String = "") -> String {
    let locale = getLocale()

    let lang = locale

    if let path = bundle?.path(forResource: lang, ofType: "lproj") {
      return NSLocalizedString(key, bundle: Bundle(path: path)!, comment: comment)
    }
    else {
      return comment
    }
  }

}
