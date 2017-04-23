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

    //navigationItem.title = ""

    title = getHeaderName()

    clearsSelectionOnViewWillAppear = false

    adapter.enablePagination()

#if os(iOS)
    let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressed(_:)))
    collectionView?.addGestureRecognizer(longPressRecognizer)
#endif

    collectionView?.backgroundView = activityIndicatorView
    adapter.spinner = PlainSpinner(activityIndicatorView)

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
        performSegue(withIdentifier: AudioItemsController.SegueIdentifier, sender: view)
      }
      else {
        let controller = MediaItemsController.instantiate(adapter)

        let destination = controller.getActionController() as! MediaItemsController

        let newAdapter = adapter.clone()
        newAdapter.selectedItem = mediaItem

        newAdapter.parentId = mediaItem.id
        newAdapter.parentName = mediaItem.name
        newAdapter.isContainer = true

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
            newAdapter.selectedItem = mediaItem

            newAdapter.parentId = mediaItem.id
            newAdapter.parentName = mediaItem.name
            newAdapter.isContainer = true

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
        case AudioItemsController.SegueIdentifier:
          if let destination = segue.destination as? AudioItemsController {
            destination.name = mediaItem.name
            destination.thumb = mediaItem.thumb
            destination.id = mediaItem.id

//            destination.tableView?.backgroundView = activityIndicatorView
//            destination.activityIndicatorView.center = (destination.tableView?.center)!;

            let newAdapter = adapter.clone()
            newAdapter.selectedItem = mediaItem
            newAdapter.requestType = "Tracks"
            newAdapter.pageLoader.loadData() { result in
              destination.items = []

              for item in result {
                let mediaItem = item as! MediaItem
                destination.items.append(AudioItem(name: mediaItem.name!, id: mediaItem.id!))
              }

              destination.tableView?.reloadData()
            }

            if newAdapter.requestType != "History" {
              newAdapter.addHistoryItem(mediaItem)
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
      name = adapter.requestType!
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
    if adapter.requestType != "History" {
      let selectedItem = getSelectedItem()

      if let item = selectedItem {
        var controller: UIAlertController?

        if adapter.requestType == "Bookmarks" {
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
//      if self.adapter.addBookmark(item: item) {
//        //self.navigationItem.title = ""
//      }
    }

    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

    alertController.addAction(cancelAction)
    alertController.addAction(okAction)

    return alertController
  }
}
