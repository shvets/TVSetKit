public protocol DataSource {

  func load(_ requestType: String, params: RequestParams, pageSize: Int, currentPage: Int, convert: Bool) throws -> [Any]

}