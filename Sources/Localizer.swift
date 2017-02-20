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
    config.saveStorage(["langCode": langCode])
  }

  public func getLocale() -> String {
    var locale = Localizer.DefaultLocale

    if let data = config.loadStorage() {
      if let langCode = data["langCode"] as? String {
        locale = langCode
      }
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
