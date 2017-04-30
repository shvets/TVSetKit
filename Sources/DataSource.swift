open class DataSource {
  public var params = RequestParams()

  public init() {}

  open func load(_ requestType: String, params: RequestParams, pageSize: Int, currentPage: Int, convert: Bool) throws -> [Any] {
    return []
  }

}