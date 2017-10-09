import UIKit
import AudioPlayer

open class MediaItemsController: BaseCollectionViewController {
  open class var SegueIdentifier: String { return "Media Items" }
  open class var StoryboardControllerId: String { return "MediaItemsController" }

  override open var CellIdentifier: String { return "MediaItemCell" }

  var HeaderViewIdentifier: String { return "MediaItemsHeader" }

  static public func instantiate(_ adapter: ServiceAdapter) -> UIViewController {
    return UIViewController.instantiate(
      controllerId: MediaItemsController.StoryboardControllerId,
      storyboardId: type(of: adapter).StoryboardId,
      bundle: Bundle.main
    )
  }

  override open func viewDidLoad() {
    super.viewDidLoad()

    localizer = Localizer("com.rubikon.TVSetKit", bundleClass: TVSetKit.self)

    title = getHeaderName()

    clearsSelectionOnViewWillAppear = false

    adapter.pageLoader.enablePagination()

#if os(iOS)
    let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressed(_:)))
    collectionView?.addGestureRecognizer(longPressRecognizer)
#endif

    collectionView?.backgroundView = activityIndicatorView
    adapter.pageLoader.spinner = PlainSpinner(activityIndicatorView)

    loadInitialData()
  }

  // MARK: UICollectionViewDataSource

#if os(iOS)  
  override open func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
    collectionViewLayout.invalidateLayout()
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
      let itemSize = layout.itemSize

      return CGSize(width: collectionView.bounds.width, height: itemSize.height)
    }
    else {
      return CGSize(width: 0, height: 0)
    }
  }
#endif
  
  override open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier, for: indexPath) as? MediaItemCell {
      let item = items[indexPath.row]

      cell.configureCell(item: item, localizedName: getLocalizedName(item.name))

#if os(tvOS)
      CellHelper.shared.addTapGestureRecognizer(view: cell, target: self, action: #selector(self.tapped(_:)), pressType: .select)

      CellHelper.shared.addTapGestureRecognizer(view: cell, target: self, action: #selector(self.tapped(_:)), pressType: .playPause)
#endif

      if adapter.mobile == false,
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

#if os(iOS)
  @objc func longPressed(_ gesture: UILongPressGestureRecognizer) {
    if gesture.state == UIGestureRecognizerState.ended,
       let collectionView = collectionView {
      let point = gesture.location(in: collectionView)
      let indexPath = collectionView.indexPathForItem(at: point)

      if let indexPath = indexPath {
        cellSelection.setIndexPath(indexPath)

        handleBookmark()
      }
    }
  }
#endif

#if os(tvOS)
  override open func tapped(_ gesture: UITapGestureRecognizer) {
    var playImmediately = false

    if gesture.allowedPressTypes.contains(NSNumber(value: UIPressType.playPause.rawValue)) {
      playImmediately = true
    }

    if let location = gesture.view as? UICollectionViewCell {
      navigate(from: location, playImmediately: playImmediately)
    }
  }
#endif

  override open func navigate(from view: UICollectionViewCell, playImmediately: Bool=false) {
    let mediaItem = getItem(for: view) as! MediaItem

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
        let controller = MediaItemsController.instantiate(adapter)

        if let destination = controller.getActionController() as? MediaItemsController {
          let newAdapter = adapter.clone()
          newAdapter.params["selectedItem"] = mediaItem

          newAdapter.params["parentId"] = mediaItem.id
          newAdapter.params["parentName"] = mediaItem.name
          newAdapter.params["isContainer"] = true

          destination.adapter = newAdapter

          if adapter.mobile == false {
            if let layout = adapter.buildLayout() {
              destination.collectionView?.collectionViewLayout = layout
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

  // MARK: Navigation

  override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier,
       let selectedCell = sender as? MediaItemCell {

      if let indexPath = collectionView?.indexPath(for: selectedCell) {
        let mediaItem = items[indexPath.row] as! MediaItem

        switch identifier {
        case MediaItemsController.SegueIdentifier:
          if let destination = segue.destination.getActionController() as? MediaItemsController {
            let newAdapter = adapter.clone()
            newAdapter.params["selectedItem"] = mediaItem

            newAdapter.params["parentId"] = mediaItem.id
            newAdapter.params["parentName"] = mediaItem.name
            newAdapter.params["isContainer"] = true

            destination.adapter = newAdapter

            if adapter.mobile == false {
              if let layout = adapter.buildLayout() {
                destination.collectionView?.collectionViewLayout = layout
              }
            }
          }

        case MediaItemDetailsController.SegueIdentifier:
          if let destination = segue.destination as? MediaItemDetailsController {
            destination.collectionItems = items as! [MediaItem]
            destination.mediaItem = mediaItem
            destination.adapter = adapter
          }

        case AudioVersionsController.SegueIdentifier:
          if let destination = segue.destination as? AudioVersionsController {
            destination.name = mediaItem.name
            destination.thumb = mediaItem.thumb
            destination.id = mediaItem.id

            destination.pageLoader.pageSize = adapter.pageLoader.pageSize
            destination.pageLoader.rowSize = adapter.pageLoader.rowSize

            destination.pageLoader.load = {
              var items: [AudioItem] = []

              self.adapter.params["requestType"] = "Versions"
              self.adapter.params["selectedItem"] = mediaItem
              self.adapter.params["convert"] = false

              let mediaItems = try self.adapter.load()

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

              self.adapter.params["requestType"] = "Tracks"
              self.adapter.params["selectedItem"] = mediaItem
              self.adapter.params["version"] = destination.version
              self.adapter.params["convert"] = false

              let mediaItems = try self.adapter.load()

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

            destination.pageLoader.pageSize = adapter.pageLoader.pageSize
            destination.pageLoader.rowSize = adapter.pageLoader.rowSize

            if let requestType = adapter.params["requestType"] as? String {
              if requestType != "History" {
                adapter.addHistoryItem(mediaItem)
              }
            }

            destination.pageLoader.load = {
              var items: [AudioItem] = []

              self.adapter.params["requestType"] = "Tracks"
              self.adapter.params["selectedItem"] = mediaItem
              self.adapter.params["convert"] = false

              let mediaItems = try self.adapter.load()

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
            destination.collectionItems = items  as! [MediaItem]
            destination.mediaItem = mediaItem
            destination.adapter = adapter

            do {
              let bitrates = try mediaItem.getBitrates()

              if !bitrates.isEmpty {
                destination.bitrate = bitrates[0]
              }
            }
            catch {
              print("Error getting bitrate")
            }
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

  func getHeaderName() -> String {
    var name = ""

    if let adapter = adapter {
      if let parentName = adapter.getParentName() {
        name = parentName
      }
      else if let requestType = adapter.params["requestType"] as? String {
        name = requestType
      }
      else {
        name = ""
      }

      let localizer = Localizer(type(of: adapter).BundleId, bundleClass: TVSetKit.self)

      let localizedName = localizer.localize(name)

      if !localizedName.isEmpty {
        name = localizedName
      }
    }

    return name
  }

#if os(tvOS)
  override open func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    cellSelection.setIndexPath(indexPath)

    let item = items[indexPath.row]

    navigationItem.title = item.name

    handleBookmark()

    return true
  }
#endif

  func handleBookmark() {
    if let requestType = adapter.params["requestType"] as? String {
      if let item = getSelectedItem() as? MediaItem {
        var controller: UIAlertController?

        if adapter.isBookmark(requestType) {
          controller = buildRemoveBookmarkController(item)
        }
        else {
          controller = buildAddBookmarkController(item)
        }

        if let controller = controller {
          present(controller, animated: false, completion: nil)
        }
      }
    }
  }

  func buildRemoveBookmarkController(_ item: MediaItem) -> UIAlertController {
    let title = localizer.localize("Your Selection Will Be Removed")
    let message = localizer.localize("Confirm Your Choice")

    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

    let okAction = UIAlertAction(title: "OK", style: .default) { _ in
      let result = self.adapter.removeBookmark(item: item)

      if result {
        self.removeCell()
      }
      else {
        print("Bookmark already removed")
      }
    }

    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

    alertController.addAction(cancelAction)
    alertController.addAction(okAction)

    return alertController
  }

  func buildAddBookmarkController(_ item: MediaItem) -> UIAlertController {
    let title = localizer.localize("Your Selection Will Be Added")
    let message = localizer.localize("Confirm Your Choice")

    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

    let okAction = UIAlertAction(title: "OK", style: .default) { _ in
      self.adapter.addBookmark(item: item)
    }

    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

    alertController.addAction(cancelAction)
    alertController.addAction(okAction)

    return alertController
  }
}
