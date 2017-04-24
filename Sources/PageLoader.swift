public class PageLoader {
  private let dispatchQueue = DispatchQueue(label: "Dispatch Queue", attributes: [], target: nil)

  public var spinner: Spinner?

  public var currentPage = 1

  private var loading = false
  private var endOfData = false

  public var pageSize: Int?
  public var rowSize: Int?

  private var paginationEnabled = false

  public var load: (() throws -> [Any]) = {
    return []
  }

  public init() {}

  public func clear() {
    currentPage = 1
    loading = false
    endOfData = false
  }

  open func enablePagination() {
    paginationEnabled = true
  }

  open func loadData(onLoadCompleted: @escaping ([Any]) -> Void) {
    if !loading {
      loading = true

      spinner?.start()

      dispatchQueue.async {
        do {
          let result = try self.load()

          self.endOfData = result.isEmpty || result.count < self.pageSize!

          OperationQueue.main.addOperation() {
            if !result.isEmpty && result.count == self.pageSize! {
              self.currentPage = self.currentPage + 1
            }

            self.loading = false

            self.spinner?.stop()

            if !result.isEmpty {
              onLoadCompleted(result)
            }
          }
        }
        catch {
          print("Error loading data.")

          self.loading = false

          self.spinner?.stop()
        }
      }
    }
  }

  open func nextPageAvailable(dataCount: Int, index: Int) -> Bool {
    return paginationEnabled && !endOfData && dataCount - index <= self.rowSize!
  }
}