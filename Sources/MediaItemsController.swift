import UIKit
import AudioPlayer

open class MediaItemsController: UICollectionViewController, UICollectionViewDelegateFlowLayout  {
  open static let SegueIdentifier = "Media Items"
  open static let StoryboardControllerId = "MediaItemsController"
  static let BundleId = "com.rubikon.TVSetKit"
  
  let CellIdentifier = "MediaItemCell"

  var HeaderViewIdentifier: String { return "MediaItemsHeader" }

  var bookmarksManager: BookmarksManager?
  var historyManager: HistoryManager?
  var dataSource: DataSource?
  var storyboardId: String?
  var mobile: Bool?

  static public func instantiateController(_ storyboardId: String) -> MediaItemsController? {
    return UIViewController.instantiate(
      controllerId: MediaItemsController.StoryboardControllerId,
      storyboardId: storyboardId,
      bundle: Bundle.main
      ).getActionController() as? MediaItemsController
  }

  let localizer = Localizer(MediaItemsController.BundleId, bundleClass: TVSetKit.self)

#if os(iOS)
  public let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
#endif

#if os(tvOS)
  public let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
#endif

  public var configuration: [String: Any]?
  public var params = Parameters()

  private var items = Items()

  override open func viewDidLoad() {
    super.viewDidLoad()

    title = getHeaderName()

    clearsSelectionOnViewWillAppear = false

    #if os(iOS)
      let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressed(_:)))
      collectionView?.addGestureRecognizer(longPressRecognizer)
    #endif

    collectionView?.backgroundView = activityIndicatorView

    items.pageLoader.load = {
      var newParams = Parameters()

      for (key, value) in self.params {
        newParams[key] = value
      }

      newParams["pageSize"] = self.items.pageLoader.pageSize
      newParams["currentPage"] = self.items.pageLoader.currentPage
      newParams["bookmarksManager"] = self.configuration?["bookmarksManager"]
      newParams["historyManager"] = self.configuration?["historyManager"]

      if let data = try self.dataSource?.load(params: newParams) {
        return data
      }
      else {
        return []
      }
    }

    if let configuration = configuration {
      items.pageLoader.pageSize = configuration["pageSize"] as! Int
      items.pageLoader.rowSize = configuration["rowSize"] as! Int

      if let bookmarksManager = configuration["bookmarksManager"] as? BookmarksManager {
        self.bookmarksManager = bookmarksManager
      }

      if let historyManager = configuration["historyManager"] as? HistoryManager {
        self.historyManager = historyManager
      }

      if let dataSource = configuration["dataSource"] as? DataSource {
        self.dataSource = dataSource
      }

      if let storyboardId = configuration["storyboardId"] as? String {
        self.storyboardId = storyboardId
      }

      if let mobile = configuration["mobile"] as? Bool {
        self.mobile = mobile
      }
    }

    items.pageLoader.enablePagination()
    items.pageLoader.spinner = PlainSpinner(activityIndicatorView)

    items.loadInitialData(self.collectionView)
  }

  // MARK: UICollectionViewDataSource

  override open func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }

  override open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return items.count
  }

  override open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier, for: indexPath) as? MediaItemCell {
      if items.nextPageAvailable(dataCount: items.count, index: indexPath.row) {
        items.loadMoreData(collectionView)
      }

      let item = items[indexPath.row]

      cell.configureCell(item: item, localizedName: localizer.getLocalizedName(item.name))

#if os(tvOS)
      CellHelper.shared.addTapGestureRecognizer(view: cell, target: self, action: #selector(self.tapped(_:)), pressType: .select)

      CellHelper.shared.addTapGestureRecognizer(view: cell, target: self, action: #selector(self.tapped(_:)), pressType: .playPause)
#endif

      if mobile == false,
         let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
        let itemSize = layout.itemSize

        cell.thumb.frame = CGRect(x: 10, y: 0, width: itemSize.width, height: itemSize.height)
        cell.title.frame = CGRect(x: 10, y: itemSize.height, width: itemSize.width, height: 100)
      }

      return cell
    }
    else {
      return UICollectionViewCell()
    }
  }

  // MARK: UIScrollViewDelegate

  override open func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let currentOffset = scrollView.contentOffset.y
    let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
    let deltaOffset = maximumOffset - currentOffset

    if deltaOffset <= 1 { // approximately, close to zero
      if items.nextPageAvailable(dataCount: items.count, index: items.count-1) {
        items.loadMoreData(self.collectionView)
      }
    }
  }

//  @objc open func tapped(_ gesture: UITapGestureRecognizer) {
//    if let location = gesture.view as? UICollectionViewCell {
//      navigate(from: location)
//    }
//  }

  override open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if let location = collectionView.cellForItem(at: indexPath) {
      navigate(from: location)
    }
  }

  // MARK: UICollectionViewDataSource

#if os(iOS)
  override open func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
    collectionViewLayout.invalidateLayout()
  }

  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
      let itemSize = layout.itemSize

      return CGSize(width: collectionView.bounds.width, height: itemSize.height)
    }
    else {
      return CGSize(width: 0, height: 0)
    }
  }
#endif

#if os(iOS)
  @objc func longPressed(_ gesture: UILongPressGestureRecognizer) {
    if gesture.state == UIGestureRecognizerState.ended,
       let collectionView = collectionView {
      let point = gesture.location(in: collectionView)
      let indexPath = collectionView.indexPathForItem(at: point)

      if let indexPath = indexPath {
        items.cellSelection.setIndexPath(indexPath)

        processBookmark()
      }
    }
  }
#endif

#if os(tvOS)
  @objc open func tapped(_ gesture: UITapGestureRecognizer) {
    var playImmediately = false

    if gesture.allowedPressTypes.contains(NSNumber(value: UIPressType.playPause.rawValue)) {
      playImmediately = true
    }

    if let location = gesture.view as? UICollectionViewCell {
      navigate(from: location, playImmediately: playImmediately)
    }
  }
#endif

  func navigate(from view: UICollectionViewCell, playImmediately: Bool=false) {
    if let indexPath = collectionView?.indexPath(for: view),
      let mediaItem = items.getItem(for: indexPath) as? MediaItem {
      if let type = mediaItem.type {
        if type.isEmpty {
          mediaItem.resolveType()
        }
      }

      if mediaItem.isContainer() {
        if mediaItem.isAudioContainer() {
          if mediaItem.hasMultipleVersions() {
            performSegue(withIdentifier: AudioVersionsController.SegueIdentifier, sender: view)
          }
          else {
            performSegue(withIdentifier: AudioItemsController.SegueIdentifier, sender: view)
          }
        }
        else {
          if let destination = MediaItemsController.instantiateController(configuration?["storyboardId"] as! String) {
//            let newAdapter = adapter.clone()
//            newAdapter.params["selectedItem"] = mediaItem
//            newAdapter.params["parentId"] = mediaItem.id
//            newAdapter.params["parentName"] = mediaItem.name
//            newAdapter.params["isContainer"] = true
//
//            destination.adapter = newAdapter
            destination.configuration = configuration

            destination.params["selectedItem"] = mediaItem
            destination.params["parentId"] = mediaItem.id
            destination.params["parentName"] = mediaItem.name
            destination.params["isContainer"] = true

            if mobile == false {
              if let layout = configuration?["buildLayout"] {
                destination.collectionView?.collectionViewLayout = layout as! UICollectionViewLayout
              }

              present(destination, animated: true)
            }
            else {
              navigationController?.pushViewController(destination, animated: true)
            }
          }
        }
      }
      else {
        if playImmediately {
          performSegue(withIdentifier: VideoPlayerController.SegueIdentifier, sender: view)
        }
        else {
          performSegue(withIdentifier: MediaItemDetailsController.SegueIdentifier, sender: view)
        }
      }
    }
  }

  // MARK: Navigation

  override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier,
       let selectedCell = sender as? MediaItemCell {

      if let indexPath = collectionView?.indexPath(for: selectedCell) {
        let mediaItem = items[indexPath.row] as! MediaItem

        switch identifier {
        case MediaItemsController.SegueIdentifier:
          if let destination = segue.destination.getActionController() as? MediaItemsController {
//            let newAdapter = adapter.clone()
//            newAdapter.params["selectedItem"] = mediaItem
//
//            newAdapter.params["parentId"] = mediaItem.id
//            newAdapter.params["parentName"] = mediaItem.name
//            newAdapter.params["isContainer"] = true

            destination.params["parentId"] = mediaItem.id
            destination.params["parentName"] = mediaItem.name
            destination.params["isContainer"] = true

//            destination.adapter = newAdapter
            destination.configuration = configuration

            if mobile == false {
              if let layout = configuration?["buildLayout"] {
                destination.collectionView?.collectionViewLayout = layout as! UICollectionViewLayout
              }
            }
          }

        case MediaItemDetailsController.SegueIdentifier:
          if let destination = segue.destination as? MediaItemDetailsController {
            destination.collectionItems = items.items as! [MediaItem]
            destination.mediaItem = mediaItem
            destination.historyManager = historyManager
            destination.storyboardId = storyboardId
            destination.configuration = configuration
          }

        case AudioVersionsController.SegueIdentifier:
          if let destination = segue.destination as? AudioVersionsController {
            destination.name = mediaItem.name
            destination.thumb = mediaItem.thumb
            destination.id = mediaItem.id

//            destination.pageLoader.pageSize = adapter.pageLoader.pageSize
//            destination.pageLoader.rowSize = adapter.pageLoader.rowSize


            destination.pageLoader.load = {
              var items: [AudioItem] = []

//              self.adapter.params["requestType"] = "Versions"
//              self.adapter.params["selectedItem"] = mediaItem
//              self.adapter.params["convert"] = false

              //let mediaItems = try self.adapter.load()

              var newParams = Parameters()

//              for (key, value) in self.params {
//                newParams[key] = value
//              }

              newParams["pageSize"] = self.items.pageLoader.pageSize
              newParams["currentPage"] = self.items.pageLoader.currentPage
              newParams["requestType"] = "Versions"
              newParams["selectedItem"] = mediaItem
              newParams["convert"] = false

              var mediaItems: [Any] = []

              if let data = try self.dataSource?.load(params: newParams) {
                mediaItems = data
              }

              for mediaItem in mediaItems {
                if let item = mediaItem as? [String: String],
                  let name = item["name"],
                  let id = item["id"] {
                  items.append(AudioItem(name: name, id: id))
                }
              }

              return items
            }

            destination.audioItemsLoad = {
              var items: [AudioItem] = []

//              self.adapter.params["requestType"] = "Tracks"
//              self.adapter.params["selectedItem"] = mediaItem
//              self.adapter.params["version"] = destination.version
//              self.adapter.params["convert"] = false

              var newParams = Parameters()

//              for (key, value) in self.params {
//                newParams[key] = value
//              }

              newParams["requestType"] = "Tracks"
              newParams["selectedItem"] = mediaItem
              newParams["version"] = destination.version
              newParams["convert"] = false

              var mediaItems: [Any] = []

              if let data = try self.dataSource?.load(params: newParams) {
                mediaItems = data
              }

//              let mediaItems = try self.adapter.load()

              for mediaItem in mediaItems {
                if let item = mediaItem as? [String: String],
                   let name = item["name"],
                   let id = item["id"] {
                  items.append(AudioItem(name: name, id: id))
                }
              }

              return items
            }
          }

        case AudioItemsController.SegueIdentifier:
          if let destination = segue.destination as? AudioItemsController {
            destination.name = mediaItem.name
            destination.thumb = mediaItem.thumb
            destination.id = mediaItem.id

//            destination.pageLoader.pageSize = adapter.pageLoader.pageSize
//            destination.pageLoader.rowSize = adapter.pageLoader.rowSize

            if let requestType = params["requestType"] as? String {
              if requestType != "History" {
                historyManager?.addHistoryItem(mediaItem)
              }
            }

            destination.pageLoader.load = {
              var items: [AudioItem] = []

//              self.adapter.params["requestType"] = "Tracks"
//              self.adapter.params["selectedItem"] = mediaItem
//              self.adapter.params["convert"] = false

             var newParams = Parameters()

//              for (key, value) in self.params {
//                newParams[key] = value
//              }

              newParams["requestType"] = "Tracks"
              newParams["selectedItem"] = mediaItem
              newParams["convert"] = false

//              let mediaItems = try self.adapter.load()

              var mediaItems: [Any] = []

              if let data = try self.dataSource?.load(params: newParams) {
                mediaItems = data
              }

              for mediaItem in mediaItems {
                if let item = mediaItem as? [String: String] {
                  let name = item["name"] ?? ""
                  let id = item["id"] ?? ""

                  items.append(AudioItem(name: name, id: id))
                }
                else if let item = mediaItem as? AudioItem {
                  items.append(item)
                }
              }

              return items
            }
          }

        case VideoPlayerController.SegueIdentifier:
          if let destination = segue.destination as? VideoPlayerController {
            destination.playVideo = true
            destination.collectionItems = items.items  as! [MediaItem]
            destination.mediaItem = mediaItem
          }
        default: break
        }
      }
    }
  }

#if os(tvOS)
  override open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String,
                               at indexPath: IndexPath) -> UICollectionReusableView {
    if kind == "UICollectionElementKindSectionHeader" {
      if let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
        withReuseIdentifier: HeaderViewIdentifier, for: indexPath as IndexPath) as? MediaItemsHeaderView {
        headerView.sectionLabel.text = getHeaderName()

        return headerView
      }
    }

    return UICollectionReusableView()
  }
#endif

  open func getParentName() -> String? {
    if let selectedItem = params["selectedItem"] as? Item {
      return selectedItem.name
    }
    else if let parentName = params["parentName"] as? String {
      return parentName
    }
    else {
      return ""
    }
  }

  func getHeaderName() -> String {
    var name = ""

    if let parentName = getParentName() {
      name = parentName
    }
    else {
      if let requestType = params["requestType"] as? String {
        name = requestType
      }
      else {
        name = ""
      }

      let localizer = Localizer(configuration?["bundleId"] as! String, bundleClass: TVSetKit.self)

      let localizedName = localizer.localize(name)

      if !localizedName.isEmpty {
        name = localizedName
      }
    }

    return name
  }

#if os(tvOS)
  override open func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    items.cellSelection.setIndexPath(indexPath)

    let item = items[indexPath.row]

    navigationItem.title = item.name

    processBookmark()

    return true
  }
#endif

  func processBookmark() {
    if let selectedItem = items.getSelectedItem() as? MediaItem {
      func addCallback() {
        self.bookmarksManager?.addBookmark(item: selectedItem)
      }

      func removeCallback() {
        let result = self.bookmarksManager?.removeBookmark(item: selectedItem)

        if let result = result, result {
          items.removeCell() {
            DispatchQueue.main.async {
              self.collectionView?.reloadData()
            }
          }
        }
        else {
          print("Bookmark already removed")
        }
      }

      let isBookmark: Bool

      if let requestType = params["requestType"] as? String, let bookmarksManager = bookmarksManager {
        isBookmark = bookmarksManager.isBookmark(requestType)
      }
      else {
        isBookmark = false
      }

      if let alert = bookmarksManager?.handleBookmark(isBookmark: isBookmark, localizer: localizer, addCallback: addCallback, removeCallback: removeCallback) {
        present(alert, animated: false, completion: nil)
      }
    }
  }

}
