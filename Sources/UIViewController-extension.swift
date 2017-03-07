import UIKit

extension UIViewController {
  public class var storyboardID : String {
    return "\(self)"
  }

  public func getActionController() -> UIViewController? {
    if let controller = self as? UINavigationController {
      return controller.visibleViewController
    }
    else {
      return self
    }
  }

  public static func instantiate(controllerId: String, storyboardId: String,
                                 bundleIdentifier: String) -> UIViewController {
    let bundle = Bundle(identifier: bundleIdentifier)!

    let storyboard: UIStoryboard = UIStoryboard(name: storyboardId, bundle: bundle)

    return storyboard.instantiateViewController(withIdentifier: controllerId)
  }
}
