public protocol IServiceAdapter {

  func nextPageAvailable(dataCount: Int, index: Int) -> Bool

  func loadData(onLoadCompleted: @escaping ([MediaItem]) -> Void)

  func load() throws -> [MediaItem]

  func buildLayout() -> UICollectionViewFlowLayout?

  func getDetailsImageFrame() -> CGRect?

  func getParentName() -> String?

  func getUrl(_ params: [String: Any]) throws -> String?

  func retrieveExtraInfo(_ item: MediaItem) throws

  func addBookmark(item: MediaItem) -> Bool

  func removeBookmark(item: MediaItem) -> Bool

  func addHistoryItem(_ item: MediaItem)

}

