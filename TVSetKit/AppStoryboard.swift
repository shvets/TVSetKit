open class AppStoryboard {

  public static func instantiateController<T: UIViewController>(_ storyboardId: String, viewControllerClass: T.Type,
                function: String = #function, line: Int = #line, file: String = #file) -> T {
    let storyboard: UIStoryboard = UIStoryboard(name: storyboardId, bundle: Bundle.main)

    let storyboardID = (viewControllerClass as UIViewController.Type).storyboardID

    guard let scene = storyboard.instantiateViewController(withIdentifier: storyboardID) as? T else {
      fatalError("ViewController with identifier \(storyboardID), not found in \(storyboardId) Storyboard.\n" +
                 "File : \(file) \nLine Number : \(line) \nFunction : \(function)")
    }

    return scene
  }
}