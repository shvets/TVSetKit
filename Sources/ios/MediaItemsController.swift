import UIKit
import PageLoader

extension MediaItemCell: ReusableView { }

open class MediaItemsController: UICollectionViewController, UICollectionViewDelegateFlowLayout, ReusableController {
  open static let SegueIdentifier = "Media Items"
  //open static let StoryboardControllerId = "MediaItemsController"
  static let BundleId = "com.rubikon.TVSetKit"

  //let CellIdentifier = "MediaItemCell"

  var HeaderViewIdentifier: String { return "MediaItemsHeader" }

  public var pageLoader = PageLoader()
  
  public var bookmarksManager: BookmarksManager?
  public var historyManager: HistoryManager?
  public var dataSource: DataSource?
  public var storyboardId: String?
  public var mobile: Bool = true

  static public func instantiateController(_ storyboardId: String) -> MediaItemsController? {
    return UIViewController.instantiate(
      controllerId: MediaItemsController.reuseIdentifier,
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

  public var configuration: Configuration?
  public var params = Parameters()

  public var items = Items()

  override open func viewDidLoad() {
    super.viewDidLoad()

    title = getHeaderName()

    clearsSelectionOnViewWillAppear = false

#if os(iOS)
    let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressed(_:)))
    collectionView?.addGestureRecognizer(longPressRecognizer)
#endif

    collectionView?.backgroundView = activityIndicatorView

    pageLoader.enablePagination()
    pageLoader.spinner = PlainSpinner(activityIndicatorView)

    if let configuration = configuration {
      pageLoader.pageSize = configuration["pageSize"] as! Int
      pageLoader.rowSize = configuration["rowSize"] as? Int ?? 1

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

    func load() throws -> [Any] {
      var newParams = Parameters()

      for (key, value) in self.params {
        newParams[key] = value
      }

      if let pageSize = newParams["pageSize"] as? Int {
        self.pageLoader.pageSize = pageSize
      }
      else {
        newParams["pageSize"] = self.pageLoader.pageSize
      }

      newParams["currentPage"] = self.pageLoader.currentPage
      newParams["bookmarksManager"] = self.configuration?["bookmarksManager"]
      newParams["historyManager"] = self.configuration?["historyManager"]

      return try (self.dataSource?.loadAndWait(params: newParams))!
    }

    pageLoader.loadData(onLoad: load) { result in
      if let items = result as? [Item] {
        self.items.items = items
      }

      self.collectionView?.reloadData()
    }
  }

  // MARK: UICollectionViewDataSource

  override open func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }

  override open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return items.count
  }

  override open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaItemCell.reuseIdentifier, for: indexPath) as? MediaItemCell {
      if pageLoader.nextPageAvailable(dataCount: items.count, index: indexPath.row) {
        pageLoader.loadData { result in
          if let items = result as? [Item] {
            self.items.items += items
            
            self.collectionView?.reloadData()
          }
        }
      }

      let item = items[indexPath.row]

      cell.configureCell(item: item, localizedName: localizer.getLocalizedName(item.name))

#if os(tvOS)
      CellHelper.shared.addTapGestureRecognizer(view: cell, target: self, action: #selector(self.tapped(_:)), pressType: .select)

      CellHelper.shared.addTapGestureRecognizer(view: cell, target: self, action: #selector(self.tapped(_:)), pressType: .playPause)
#endif

      if !mobile,
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
      if pageLoader.nextPageAvailable(dataCount: items.count, index: items.count-1) {
        pageLoader.loadData { result in
          if let items = result as? [Item] {
            self.items.items += items

            self.collectionView?.reloadData()
          }
        }
      }
    }
  }

#if os(iOS)

  override open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if let location = collectionView.cellForItem(at: indexPath) {
      navigate(from: location)
    }
  }

  // MARK: UICollectionViewDataSource

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

  @objc func longPressed(_ gesture: UILongPressGestureRecognizer) {
    if gesture.state == UIGestureRecognizerState.ended,
       let collectionView = collectionView {
      let point = gesture.location(in: collectionView)

      if let indexPath = collectionView.indexPathForItem(at: point) {
        items.cellSelection = indexPath

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

  open func navigate(from view: UICollectionViewCell, playImmediately: Bool=false) {
    if let indexPath = collectionView?.indexPath(for: view),
       let mediaItem = items.getItem(for: indexPath) as? MediaItem {

      if mediaItem.isContainer() {
        navigateWithContainer(mediaItem)
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

  func navigateWithContainer(_ mediaItem: MediaItem) {
    if let storyboardId = configuration?["storyboardId"] as? String,
       let destination = MediaItemsController.instantiateController(storyboardId) {
      destination.configuration = configuration

      for (key, value) in self.params {
        destination.params[key] = value
      }

      destination.params["selectedItem"] = mediaItem
      destination.params["parentId"] = mediaItem.id
      destination.params["parentName"] = mediaItem.name
      destination.params["isContainer"] = true

      if !mobile {
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

  // MARK: Navigation

  override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier,
       let selectedCell = sender as? MediaItemCell {

      if let indexPath = collectionView?.indexPath(for: selectedCell) {
        let mediaItem = items[indexPath.row] as! MediaItem

        switch identifier {
        case MediaItemsController.SegueIdentifier:
          if let destination = segue.destination.getActionController() as? MediaItemsController {
            if mediaItem.isContainer() {
              //destination.configuration = configuration

              for (key, value) in self.params {
                destination.params[key] = value
              }

              destination.params["selectedItem"] = mediaItem
              destination.params["parentId"] = mediaItem.id
              destination.params["parentName"] = mediaItem.name
              destination.params["isContainer"] = true
            }
            else {
              destination.params["parentId"] = mediaItem.id
              destination.params["parentName"] = mediaItem.name
              destination.params["isContainer"] = true

              for (key, value) in self.params {
                destination.params[key] = value
              }
            }
            
            destination.configuration = configuration

            if !mobile, let layout = configuration?["buildLayout"] as? UICollectionViewLayout {
              destination.collectionView?.collectionViewLayout = layout
            }
          }

        case MediaItemDetailsController.SegueIdentifier:
          if let destination = segue.destination as? MediaItemDetailsController {
            destination.items = items.items as! [MediaItem]
            destination.mediaItem = mediaItem
            destination.historyManager = historyManager
            destination.storyboardId = storyboardId
            destination.configuration = configuration
          }

        case VideoPlayerController.SegueIdentifier:
          if let destination = segue.destination as? VideoPlayerController {
            destination.playVideo = true
            destination.items = items.items
            destination.mediaItem = mediaItem

            func getMediaUrl(_ mediaItem: MediaItem) throws -> URL? {
              return mediaItem.getMediaUrl(index: 0)
            }

            destination.getMediaUrl = getMediaUrl
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
    items.cellSelection = indexPath

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
