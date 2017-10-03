import UIKit

open class Localizer {
  public static let DefaultLocale = "ru"
  private static let configName = NSHomeDirectory() + "/Library/Caches/localizer.json"

  let config: Config!

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

    config = Config(configName: Localizer.configName)
  }

  public func setLocale(langCode: String) {
    do {
      try config.saveStorage(["langCode": langCode])
    }
    catch {
      print("Error saving locale")
    }
  }

  public func getLocale() -> String {
    var locale = Localizer.DefaultLocale

    do {
      let data = try config.loadStorage()

      if let langCode = data["langCode"] {
        locale = langCode
      }
    }
    catch {
      print("Error loading locale")
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
