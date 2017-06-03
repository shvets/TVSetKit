import UIKit

open class Localizer {
  public static let DefaultLocale = "ru"
  private static let configName = NSHomeDirectory() + "/Library/Caches/localizer.json"

  let config: FileStorage!

  public var bundle: Bundle?

  public init(_ identifier: String="", bundleClass: Any) {
    if identifier.isEmpty {
      bundle = Bundle.main
    }
    else {
      bundle = Bundle(identifier: identifier)
    }

    if bundle == nil {
      let podBundle = Bundle(for: bundleClass.self)

      if let bundleURL = podBundle.url(forResource: identifier, withExtension: "bundle") {
        bundle = Bundle(url: bundleURL)!
      }
    }

    config = FileStorage(Localizer.configName)
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

      if let langCode = data["langCode"] as? String {
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
