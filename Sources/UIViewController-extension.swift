import UIKit

extension UIViewController {
  public func getActionController() -> UIViewController? {
    if let controller = self as? UINavigationController {
      return controller.visibleViewController
    }
    else {
      return self
    }
  }

  public static func instantiate(controllerId: String, storyboardId: String, bundleId: String) -> UIViewController {
    let bundle = Bundle(identifier: bundleId)!

    let storyboard: UIStoryboard = UIStoryboard(name: storyboardId, bundle: bundle)

    return storyboard.instantiateViewController(withIdentifier: controllerId)
  }

  public static func instantiate(controllerId: String, storyboardId: String, bundle: Bundle=Bundle.main) -> UIViewController {
    let storyboard: UIStoryboard = UIStoryboard(name: storyboardId, bundle: bundle)

    return storyboard.instantiateViewController(withIdentifier: controllerId)
  }
}
