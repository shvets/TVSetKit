import UIKit

open class LanguageManager {
  public static let DefaultLocale = "ru"
  private static let configName = NSHomeDirectory() + "/Library/Caches/language_manager.json"

  let config: FileStorage!

  public init() {
    config = FileStorage(LanguageManager.configName)
  }

  public func setLocale(langCode: String) {
    config.saveStorage(["langCode": langCode])
  }
  
  public func getLocale() -> String {
    var locale = LanguageManager.DefaultLocale

    if let data = config.loadStorage() {
      if let langCode = data["langCode"] as? String {
        locale = langCode
      }
    }

    return locale
  }

  public func localize(_ key: String, comment: String = "", bundle: Bundle=Bundle.main) -> String {
    let locale = getLocale()

    let lang = locale
    let path = bundle.path(forResource: lang, ofType: "lproj")
    let bundle = Bundle(path: path!)

    return NSLocalizedString(key, bundle: bundle!, comment: comment)
  }

}
