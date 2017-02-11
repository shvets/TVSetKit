import SwiftSoup

public struct RequestParams {
  public init() {}

  public var identifier: String?

  public var isContainer: Bool?

  public var selectedItem: MediaItem?

  public var parentName: String?

  public var document: Document?

  public var bookmarks: Bookmarks?

  public var history: History?
}