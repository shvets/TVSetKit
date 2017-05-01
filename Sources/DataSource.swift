open class DataSource {
  public var params = RequestParams()

  public init() {}

  open func load(pageSize: Int, currentPage: Int, convert: Bool) throws -> [Any] {
    return []
  }

}