import Foundation

open class BookmarksManager {
  public var bookmarks: Bookmarks!
  
  public init(_ bookmarks: Bookmarks) {
    self.bookmarks = bookmarks
    
    bookmarks.load()
  }
  
  @discardableResult open func addBookmark(item: MediaItem) -> Bool {
    return bookmarks.addBookmark(item: item)
  }
  
  open func removeBookmark(item: MediaItem) -> Bool {
    return bookmarks.removeBookmark(id: item.id!)
  }
  
  open func isBookmark(_ requestType: String) -> Bool {
    return requestType != "History" && requestType == "Bookmarks"
  }
  
  open func handleBookmark(isBookmark: Bool, localizer: Localizer,
                           addCallback: @escaping () -> Void,
                           removeCallback: @escaping () -> Void) -> NSAlert? {
    var alert: NSAlert?
    
    if isBookmark {
      alert = buildRemoveBookmarkController(removeCallback, localizer: localizer)
    }
    else {
      alert = buildAddBookmarkController(addCallback, localizer: localizer)
    }
    
    return alert
  }
  
  func buildRemoveBookmarkController(_ callback: @escaping () -> Void, localizer: Localizer) -> NSAlert {
    let title = localizer.localize("Your Selection Will Be Removed")
    let message = localizer.localize("Confirm Your Choice")
    
    let alert = NSAlert()
    alert.messageText = "question"
    alert.informativeText = "text"
    alert.alertStyle = .warning
    alert.addButton(withTitle: "OK")
    alert.addButton(withTitle: "Cancel")
    //alert.runModal() == .alertFirstButtonReturn
    
//    let alertController = NSAlert(title: title, message: message, preferredStyle: .alert)
//
//    let okAction = NSAlert(title: "OK", style: .default) { _ in
//      callback()
//    }
//
//    let cancelAction = NSAlert(title: "Cancel", style: .cancel)
//
//    alertController.addAction(cancelAction)
//    alertController.addAction(okAction)
//
//    return alertController
    return alert
  }
  
  func buildAddBookmarkController(_ callback: @escaping () -> Void, localizer: Localizer) -> NSAlert {
    let title = localizer.localize("Your Selection Will Be Added")
    let message = localizer.localize("Confirm Your Choice")

    let alert = NSAlert()
    alert.messageText = "question"
    alert.informativeText = "text"
    alert.alertStyle = .warning
    alert.addButton(withTitle: "OK")
    alert.addButton(withTitle: "Cancel")
    //alert.runModal() == .alertFirstButtonReturn
    
//    let alert = NSAlert(title: title, message: message, preferredStyle: .alert)
//
//    let okAction = UIAlertAction(title: "OK", style: .default) { _ in
//      callback()
//    }
//
//    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
//
//    alert.addAction(cancelAction)
//    alert.addAction(okAction)
    
    return alert
  }
}

