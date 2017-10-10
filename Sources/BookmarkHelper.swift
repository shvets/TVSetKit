open class BookmarkHelper {
  let localizer: Localizer
  
  public init(localizer: Localizer) {
    self.localizer = localizer
  }
  
  open func handleBookmark(isBookmark: Bool, addCallback: @escaping () -> Void,
                           removeCallback: @escaping () -> Void) -> UIAlertController? {
    var alert: UIAlertController?

    if isBookmark {
      alert = buildRemoveBookmarkController(removeCallback)
    }
    else {
      alert = buildAddBookmarkController(addCallback)
    }

    return alert
  }
  
  func buildRemoveBookmarkController(_ callback: @escaping () -> Void) -> UIAlertController {
    let title = localizer.localize("Your Selection Will Be Removed")
    let message = localizer.localize("Confirm Your Choice")
    
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    let okAction = UIAlertAction(title: "OK", style: .default) { _ in
      callback()
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
    
    alertController.addAction(cancelAction)
    alertController.addAction(okAction)
    
    return alertController
  }
  
  func buildAddBookmarkController(_ callback: @escaping () -> Void) -> UIAlertController {
    let title = localizer.localize("Your Selection Will Be Added")
    let message = localizer.localize("Confirm Your Choice")
    
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    let okAction = UIAlertAction(title: "OK", style: .default) { _ in
      callback()
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
    
    alert.addAction(cancelAction)
    alert.addAction(okAction)
    
    return alert
  }
}
