import UIKit
import PageLoader

extension MediaItemCell: ReusableView { }

open class MediaItemsController: UICollectionViewController, UICollectionViewDelegateFlowLayout, ReusableController {
  open static let SegueIdentifier = "Media Items"
  static let BundleId = "com.rubikon.TVSetKit"

  var HeaderViewIdentifier: String { return "MediaItemsHeader" }

  public var pageLoader = PageLoader()

  var newMediaItemIndex = -1
  var receiver: UIViewController?

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

  required public init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)!

    let nc = NotificationCenter.default
    nc.addObserver(self, selector: #selector(changeSelectedItem), name: NSNotification.Name(rawValue: "mediaItem"), object: nil)
  }

  override open func viewDidLoad() {
    super.viewDidLoad()

    title = getHeaderName()

    restoresFocusAfterTransition = false

#if os(iOS)
    if let collectionView = collectionView {
      registerGestures(collectionView)
    }
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

    pageLoader.loadData(onLoad: loadMediaItems) { result in
      if let items = result as? [Item] {
        self.items.items = items
      }

      self.collectionView?.reloadData()
    }
  }

  override open func viewWillDisappear(_ animated: Bool) {
    if let mediaItem = params["selectedItem"] as? Item {
      notifyMediaItemChange(mediaItem)
    }
  }

  func notifyMediaItemChange(_ mediaItem: Item) {
    let nc = NotificationCenter.default

    nc.post(name: NSNotification.Name(
      rawValue: "mediaItem"),
      object: nil,
      userInfo: [
        "id" : mediaItem.id as Any,
        "receiver": receiver as Any
      ])
  }

  @objc func changeSelectedItem(notification:NSNotification) {
    if let userInfo = notification.userInfo as? Dictionary<String, Any>,
      let id = userInfo["id"] as? String,
      let receiver = userInfo["receiver"] as? UIViewController {

      if receiver == self {
        if let index = items.items.index(where: { $0.id == id }) {
          newMediaItemIndex = index
        }
        else {
          newMediaItemIndex = 1
        }
      }
    }
  }

  override open var preferredFocusEnvironments: [UIFocusEnvironment] {
    var selection: [UIView] = []

    if newMediaItemIndex >= 0 {
      let indexPath = IndexPath(row: newMediaItemIndex, section: 0)

      // collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)

      newMediaItemIndex = -1

      if let cell = collectionView?.cellForItem(at: indexPath) {
      //if let cell = collectionView?.dequeueReusableCell(withReuseIdentifier: MediaItemCell.reuseIdentifier, for: indexPath) as? MediaItemCell {
        selection = [cell]
      }
    }

    return selection
  }

  func loadMediaItems() throws -> [Any] {
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

    if let dataSource = dataSource {
      return try dataSource.loadAndWait(params: newParams)
    }

    return []
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
        pageLoader.loadData(onLoad: loadMediaItems) { result in
          if let items = result as? [Item] {
            self.items.items += items

            self.collectionView?.reloadData()
          }
        }
      }

      let item = items[indexPath.row]

      cell.configureCell(item: item, localizedName: localizer.getLocalizedName(item.name))

#if os(tvOS)
        registerGestures(cell)
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
        pageLoader.loadData(onLoad: loadMediaItems) { result in
          if let items = result as? [Item] {
            self.items.items += items

            self.collectionView?.reloadData()
          }
        }
      }
    }
  }

#if os(iOS)
  func registerGestures(_ view: UIView) {
    let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressed(_:)))

    view.addGestureRecognizer(longPressGesture)

    let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.doubleTapPressed(_:)))
    doubleTapGesture.numberOfTapsRequired = 2

    view.addGestureRecognizer(doubleTapGesture)

    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapped(_:)))
    tapGesture.require(toFail: doubleTapGesture)

    view.addGestureRecognizer(tapGesture)
  }

//  override open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//    if let location = collectionView.cellForItem(at: indexPath) {
//      navigate(from: location)
//    }
//  }

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

  @objc func tapped(_ gesture: UITapGestureRecognizer) {
    if gesture.state == UIGestureRecognizerState.ended,
      let collectionView = collectionView {
      let point = gesture.location(in: collectionView)

      if let indexPath = collectionView.indexPathForItem(at: point) {
        items.cellSelection = indexPath

        if let location = collectionView.cellForItem(at: indexPath) {
          navigate(from: location, playImmediately: true)
        }
      }
    }
  }

  @objc func longPressed(_ gesture: UILongPressGestureRecognizer) {
    if gesture.state == UIGestureRecognizerState.ended,
      let collectionView = collectionView {
      let point = gesture.location(in: collectionView)

      if let indexPath = collectionView.indexPathForItem(at: point) {
        items.cellSelection = indexPath

        if let location = collectionView.cellForItem(at: indexPath) {
          navigate(from: location, playImmediately: false)
        }
      }
    }
  }

  @objc func doubleTapPressed(_ gesture: UITapGestureRecognizer) {
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
  func registerGestures(_ view: UIView) {
    let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressed(_:)))

    longPressGesture.allowedPressTypes = [NSNumber(value: UIPressType.select.rawValue), NSNumber(value: UIPressType.playPause.rawValue)]

    view.addGestureRecognizer(longPressGesture)

    let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.doubleTapPressed(_:)))
    doubleTapGesture.numberOfTapsRequired = 2

    view.addGestureRecognizer(doubleTapGesture)

    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapped(_:)))
    tapGesture.require(toFail: doubleTapGesture)

    tapGesture.allowedPressTypes = [NSNumber(value: UIPressType.select.rawValue), NSNumber(value: UIPressType.playPause.rawValue)]

    view.addGestureRecognizer(tapGesture)
  }

  @objc func tapped(_ gesture: UITapGestureRecognizer) {
    if let location = gesture.view as? UICollectionViewCell {
      navigate(from: location, playImmediately: true)
    }
  }

  @objc func longPressed(_ gesture: UITapGestureRecognizer) {
    if gesture.state == UIGestureRecognizerState.ended {
      if let location = gesture.view as? UICollectionViewCell {
        navigate(from: location, playImmediately: false)
      }
    }
  }

  @objc func doubleTapPressed(_ gesture: UITapGestureRecognizer) {
    if let location = gesture.view as? UICollectionViewCell,
      let indexPath = collectionView?.indexPath(for: location),
      let mediaItem = items.getItem(for: indexPath) as? MediaItem {
      items.cellSelection = indexPath

      navigationItem.title = mediaItem.name

      processBookmark()
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
          //performSegue(withIdentifier: VideoPlayerController.SegueIdentifier, sender: view)
          historyManager?.addHistoryItem(mediaItem)
          MediaItemDetailsController.playMediaItem(mediaItem, parent: self, items: items.items, storyboardId: storyboardId!, index: 0)
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
      destination.receiver = self

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

      if let indexPath = collectionView?.indexPath(for: selectedCell),
         let mediaItem = items[indexPath.row] as? MediaItem {

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

            destination.receiver = self
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

//        case VideoPlayerController.SegueIdentifier:
//          if let destination = segue.destination as? VideoPlayerController {
//            destination.playVideo = true
//            destination.items = items.items
//            destination.mediaItem = mediaItem
//
//            func getMediaUrl(_ mediaItem: MediaItem) throws -> URL? {
//              return mediaItem.getMediaUrl(index: 0)
//            }
//
//            destination.getMediaUrl = getMediaUrl
//          }
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
