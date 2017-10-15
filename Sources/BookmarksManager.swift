import Foundation

open class BookmarksManager {
  let bookmarks: Bookmarks!

  public init(_ bookmarks: Bookmarks) {
    self.bookmarks = bookmarks
  }

  @discardableResult open func addBookmark(item: MediaItem) -> Bool {
    return bookmarks.addBookmark(item: item)
  }

  open func removeBookmark(item: MediaItem) -> Bool {
    return bookmarks.removeBookmark(id: item.id!)
  }

  open static func isBookmark(_ requestType: String) -> Bool {
    return requestType != "History" && requestType == "Bookmarks"
  }
}
