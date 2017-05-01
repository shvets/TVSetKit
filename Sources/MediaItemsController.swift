import UIKit
import SwiftyJSON
import AudioPlayer

open class MediaItemsController: BaseCollectionViewController {
  public class var SegueIdentifier: String { return "Media Items" }
  public class var StoryboardControllerId: String { return "MediaItemsController" }

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

    localizer = Localizer("com.rubikon.TVSetKit")

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

  override open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier, for: indexPath) as! MediaItemCell

    let item = items[indexPath.row]

    cell.configureCell(item: item, localizedName: getLocalizedName(item.name))

#if os(tvOS)
    CellHelper.shared.addTapGestureRecognizer(view: cell, target: self, action: #selector(self.tapped(_:)), pressType: .select)

    CellHelper.shared.addTapGestureRecognizer(view: cell, target: self, action: #selector(self.tapped(_:)), pressType: .playPause)
#endif

    if adapter.mobile == false {
      let itemSize = (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize

      cell.thumb.frame = CGRect(x: 10, y: 0, width: itemSize.width, height: itemSize.height)
      cell.title.frame = CGRect(x: 10, y: itemSize.height, width: itemSize.width, height: 100)
    }

    return cell
  }

#if os(iOS)
  func longPressed(_ gesture: UILongPressGestureRecognizer) {
    if gesture.state == UIGestureRecognizerState.ended {
      let point = gesture.location(in: collectionView)
      let indexPath = collectionView!.indexPathForItem(at: point)

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

    navigate(from: gesture.view as! UICollectionViewCell, playImmediately: playImmediately)
  }
#endif

  override open func navigate(from view: UICollectionViewCell, playImmediately: Bool=false) {
    let mediaItem = getItem(for: view)

    let type = mediaItem.type

    if type != nil && type!.isEmpty {
      mediaItem.resolveType()
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

        let destination = controller.getActionController() as! MediaItemsController

        let newAdapter = adapter.clone()
        newAdapter.params["selectedItem"] = mediaItem

        newAdapter.params["parentId"] = mediaItem.id
        newAdapter.params["parentName"] = mediaItem.name
        newAdapter.params["isContainer"] = true

        destination.adapter = newAdapter

        if adapter.mobile == false {
          destination.collectionView?.collectionViewLayout = adapter.buildLayout()!

          present(destination, animated: true)
        }
        else {
          navigationController!.pushViewController(destination, animated: true)
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
    if let identifier = segue.identifier {
      let selectedCell = sender as! MediaItemCell

      let indexPath = collectionView?.indexPath(for: selectedCell)!
      let mediaItem = items[indexPath!.row]

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
              destination.collectionView?.collectionViewLayout = adapter.buildLayout()!
            }
          }

        case MediaItemDetailsController.SegueIdentifier:
          if let destination = segue.destination as? MediaItemDetailsController {
            destination.collectionItems = items
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

              var params = RequestParams()
              params["requestType"] = "Versions"
              params["selectedItem"] = mediaItem
              params["pageSize"] = self.adapter.pageLoader.pageSize
//              params["currentPage"] = self.adapter.pageLoader.rowSize
              params["convert"] = false

              let mediaItems = try self.adapter.dataSource!.load(params: params)

              for mediaItem in mediaItems {
                let item = mediaItem as! [String: String]

                items.append(AudioItem(name: item["name"]!, id: item["id"]!))
              }

              return items
            }

            destination.audioItemsLoad = {
              var items: [AudioItem] = []

              var params = RequestParams()
              params["requestType"] = "Tracks"
              params["selectedItem"] = mediaItem
              params["version"] = destination.version
              params["pageSize"] = self.adapter.pageLoader.pageSize
//              params["currentPage"] = self.adapter.pageLoader.rowSize
              params["convert"] = false

              let mediaItems = try self.adapter.dataSource!.load(params: params)

              for mediaItem in mediaItems {
                let item = mediaItem as! [String: String]

                items.append(AudioItem(name: item["name"]!, id: item["id"]!))
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

            if adapter.params["requestType"] as! String != "History" {
              adapter.addHistoryItem(mediaItem)
            }

            destination.pageLoader.load = {
              var items: [AudioItem] = []

              var params = RequestParams()
              params["requestType"] = "Tracks"
              params["selectedItem"] = mediaItem
              params["pageSize"] = self.adapter.pageLoader.pageSize
//              params["currentPage"] = self.adapter.pageLoader.rowSize
              params["convert"] = false

              let mediaItems = try self.adapter.dataSource!.load(params: params)

              for mediaItem in mediaItems {
                let item = mediaItem as! [String: String]

                items.append(AudioItem(name: item["name"]!, id: item["id"]!))
              }

              return items
            }
          }

        case VideoPlayerController.SegueIdentifier:
          if let destination = segue.destination as? VideoPlayerController {
            destination.playVideo = true
            destination.collectionItems = items
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

#if os(tvOS)
  override open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String,
                               at indexPath: IndexPath) -> UICollectionReusableView {
    if kind == "UICollectionElementKindSectionHeader" {
      let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
        withReuseIdentifier: HeaderViewIdentifier, for: indexPath as IndexPath) as! MediaItemsHeaderView

      headerView.sectionLabel.text = getHeaderName()
      
      return headerView
    }

    return UICollectionReusableView()
  }
#endif

  func getHeaderName() -> String {
    var name = ""

    if adapter.getParentName() != nil {
      name = adapter.getParentName()!
    }
    else {
      name = adapter.params["requestType"] as! String
    }

    let localizer = Localizer(type(of: adapter!).BundleId)

    return localizer.localize(name)
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
    if adapter.params["requestType"] as! String != "History" {
      let selectedItem = getSelectedItem()

      if let item = selectedItem {
        var controller: UIAlertController?

        if adapter.params["requestType"] as! String == "Bookmarks" {
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

    let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
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

    let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
      self.adapter.addBookmark(item: item)
    }

    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

    alertController.addAction(cancelAction)
    alertController.addAction(okAction)

    return alertController
  }
}
