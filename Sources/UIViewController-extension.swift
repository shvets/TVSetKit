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
}
