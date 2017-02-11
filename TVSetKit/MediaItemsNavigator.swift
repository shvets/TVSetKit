class MediaItemsNavigator {
  let items: [MediaItem]?
  
  init(_ items: [MediaItem]) {
    self.items = items
  }

  func getNextId(_ id: String) -> String {
    var currentIndex = -1
    
    for (index, item) in (items?.enumerated())! {
      if item.id == id {
        currentIndex = index
        break
      }
    }
    
    let nextIndex = (currentIndex < (items?.count)!-1) ? currentIndex + 1 : 0

    return items![nextIndex].id!
  }
  
  func getPreviousId(_ id: String) -> String {
    var currentIndex = -1
    
    for (index, item) in (items?.enumerated())! {
      if item.id! == id {
        currentIndex = index
        break
      }
    }
    
    let previousIndex = (currentIndex > 0) ? currentIndex - 1 : (items?.count)! - 1
    
    return items![previousIndex].id!
  }
}
