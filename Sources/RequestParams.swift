public struct RequestParams {
  public init() {}

  public var requestType: String?

  public var identifier: String?

  public var isContainer: Bool?

  public var selectedItem: MediaItem?

  public var parentName: String?

  public var parentId: String?

  public var query: String?

  public var document: Any?

  public var bookmarks: Bookmarks?

  public var history: History?

  public var archiveChannelsBookmarks: Bookmarks?

  public var version: Int?
}