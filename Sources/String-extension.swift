import UIKit

extension String {
  static let languageManager = LanguageManager()

  public func localize(_ bundle: Bundle=Bundle.main, comment: String = "") -> String {
    return String.languageManager.localize(self, comment: comment, bundle: bundle)
  }
}
