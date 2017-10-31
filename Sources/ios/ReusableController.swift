protocol ReusableController: class {}

extension ReusableController where Self: UIViewController {
  
  static var reuseIdentifier: String {
    return String(describing: self)
  }
}

