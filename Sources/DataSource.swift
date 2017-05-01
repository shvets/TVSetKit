open class DataSource {
  public var params = RequestParams()

  public init() {}

  open func load(convert: Bool) throws -> [Any] {
    return []
  }

}