open class DataSource {
  public init() {}

  open func load(params: Parameters) throws -> [Any] {
    return []
  }

  open func transform(_ items: [Any], transformer: (Any) -> Item) -> [Item] {
    var list = [Item]()

    for item in items {
      list.append(transformer(item))
    }

    return list
  }

  open func transformWithIndex(_ items: [Any], transformer: (Int, Any) -> Item) -> [Item] {
    var list = [Item]()
        
    for (index, item) in items.enumerated() {
      list.append(transformer(index, item))
    }
        
    return list
  }
}

