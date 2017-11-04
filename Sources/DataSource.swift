import RxSwift

open class DataSource {
  public init() {}

  public func loadAndWait(params: Parameters) throws -> [Any] {
    var items = [Any]()

    let semaphore = DispatchSemaphore.init(value: 0)

    _ = try load(params: params).subscribe(onNext: { result in
      items = result

      semaphore.signal()
    })

    _ = semaphore.wait(timeout: DispatchTime.distantFuture)

    return items
  }

  open func load(params: Parameters) throws -> Observable<[Any]> {
    return .create { observer in
      observer.onNext([])
      observer.onCompleted()
      
      return Disposables.create()
    }
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

