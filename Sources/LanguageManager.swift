import UIKit

open class LanguageManager {
  public static let DefaultLocale = "ru"

  private let configName: String

  public init(_ configName: String) {
    self.configName = configName
  }

  public func setLocale(langCode: String) {
    let localData = ["langCode": langCode]
    let content = JsonConverter.toData(localData)

    save(content)
  }
  
  public func getLocale() -> String {
    let data = load()

    if data != nil {
      if let langCode = data?["langCode"] as? String {
        return langCode
      }
      else {
        return LanguageManager.DefaultLocale
      }
    }
    else {
      return LanguageManager.DefaultLocale
    }
  }

  public func localize(_ key: String, comment: String = "", bundle: Bundle=Bundle.main) -> String {
    let locale = getLocale()

    let lang = locale
    let path = bundle.path(forResource: lang, ofType: "lproj")
    let bundle = Bundle(path: path!)

    return NSLocalizedString(key, bundle: bundle!, comment: comment)
  }

  private func load() -> [String: Any]? {
    var data: [String: Any]?

    if FileManager.default.fileExists(atPath: configName) {
      var content: Data?

      if let file = FileHandle(forReadingAtPath: configName) {
        content = file.readDataToEndOfFile()

        file.closeFile()
      }

      data = JsonConverter.toItems(content!)
    }

    return data
  }

  private func save(_ data: Data) {
    let defaultManager = FileManager.default

    if !defaultManager.fileExists(atPath: configName) {
      defaultManager.createFile(atPath: configName, contents: data)
    }
    else {
      if let file = FileHandle(forWritingAtPath: configName) {
        file.truncateFile(atOffset: 0)
        file.write(data)

        file.closeFile()
      }
      else {
        print("Error writing to file")
      }
    }
  }

}
