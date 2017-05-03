import UIKit

open class Localizer {
  public static let DefaultLocale = "ru"
  private static let configName = NSHomeDirectory() + "/Library/Caches/localizer.json"

  let config: FileStorage!

  let bundle: Bundle!

  public init(_ identifier: String="") {
    if identifier.isEmpty {
      bundle = Bundle.main
    }
    else {
      bundle = Bundle(identifier: identifier)
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
    let path = bundle.path(forResource: lang, ofType: "lproj")

    return NSLocalizedString(key, bundle: Bundle(path: path!)!, comment: comment)
  }

}
