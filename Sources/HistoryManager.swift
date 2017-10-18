import Foundation

open class HistoryManager {
  public let history: History!

  public init(_ history: History) {
    self.history = history

    history.load()
  }

  open func addHistoryItem(_ item: MediaItem) {
    history.add(item: item)
  }
}
