//import UIKit
import ConfigFile

open class Localizer {
  public static let DefaultLocale = "ru"
  private static let configName = NSHomeDirectory() + "/Library/Caches/localizer.json"

  let config: StringConfigFile!

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

    config = StringConfigFile(Localizer.configName)
  }

  public func setLocale(langCode: String) {
    config.items["langCode"] = langCode
    
    do {
      try config.save()
    }
    catch let error {
      print("Error saving configuration: \(error)")
    }
  }
  
  public func getLocale() -> String {
    var locale = Localizer.DefaultLocale

    do {
      if config.exists() {
        try config.load()
      }
    }
    catch let error {
      print("Error loading configuration: \(error)")
    }

    if let langCode = config.items["langCode"] {
      locale = langCode
    }

    return locale
  }
  
  public func setOffset(offset: Int) {
    config.items["offset"] = String(offset)
    
    do {
      try config.save()
    }
    catch let error {
      print("Error saving configuration: \(error)")
    }
  }

  public func getOffset() -> Int {
    var newOffset = 0
    
    do {
      if config.exists() {
        try config.load()
      }
    }
    catch let error {
      print("Error loading configuration: \(error)")
    }
    
    if let offset = config.items["offset"] {
      newOffset = Int(offset)!
    }
    
    return newOffset
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
  
  public func getLocalizedName(_ name: String?) -> String {
    if let name = name {
      return localize(name)
    }
    else {
      return ""
    }
  }

}
