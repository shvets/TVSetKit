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
                           removeCallback: @escaping () -> Void) -> UIAlertController? {
    var alert: UIAlertController?

    if isBookmark {
      alert = buildRemoveBookmarkController(removeCallback, localizer: localizer)
    }
    else {
      alert = buildAddBookmarkController(addCallback, localizer: localizer)
    }

    return alert
  }

  func buildRemoveBookmarkController(_ callback: @escaping () -> Void, localizer: Localizer) -> UIAlertController {
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

  func buildAddBookmarkController(_ callback: @escaping () -> Void, localizer: Localizer) -> UIAlertController {
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
