import UIKit
import SwiftyJSON

open class MediaItemsController: InfiniteCollectionViewController {
  public class var SEGUE_IDENTIFIER: String { return  "MediaItems" }
  var CELL_IDENTIFIER: String { return  "MediaItemCell" }
  var HEADER_VIEW_IDENTIFIER: String { return  "MediaItemsHeader" }

  static public func instantiate() -> Self {
    let bundle = Bundle(identifier: "com.rubikon.TVSetKit")!

    return AppStoryboard.instantiateController("Player", bundle: bundle, viewControllerClass: self)
  }

  public var displayTitle = true

  override open func viewDidLoad() {
    super.viewDidLoad()

    navigationItem.title = ""
    clearsSelectionOnViewWillAppear = false

    collectionView?.backgroundView = activityIndicatorView
    adapter.spinner = PlainSpinner(activityIndicatorView)

    loadInitialData()
  }

  // MARK: UICollectionViewDataSource

  override open func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }

  override open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return items.count
  }

  override open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_IDENTIFIER, for: indexPath) as! MediaItemCell

    let item = items[indexPath.row]

    let localizedName = adapter?.languageManager?.localize(item.name!) ?? "Unknown"

    cell.configureCell(item: item, localizedName: localizedName, target: self, action: #selector(self.tapped(_:)))

    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.played(_:)))

    tapGesture.allowedPressTypes = [NSNumber(value: UIPressType.playPause.rawValue)]

    cell.addGestureRecognizer(tapGesture)

    let itemSize = (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize

    cell.thumb.frame = CGRect(x: 10, y: 0, width: itemSize.width, height: itemSize.height)
    cell.title.frame = CGRect(x: 10, y: itemSize.height, width: itemSize.width, height: 100)

    if !displayTitle {
      cell.title.text = ""
    }

    return cell
  }

  override open func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let currentOffset = scrollView.contentOffset.y
    let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
    let deltaOffset = maximumOffset - currentOffset

    if deltaOffset <= 0 {
      if adapter.nextPageAvailable(dataCount: items.count, index: items.count-1) {
        loadMoreData(items.count-1)
      }
    }
  }

  func played(_ gesture: UITapGestureRecognizer) {
    if (gesture.view as? MediaItemCell) != nil {
      let selectedCell = gesture.view as! MediaItemCell

      let mediaItem = selectedCell.item!

      if mediaItem.isContainer() {
        tapped(gesture)
      }
      else {
        performSegue(withIdentifier: VideoPlayerController.SEGUE_IDENTIFIER, sender: gesture.view)
      }
    }
  }

  func tapped(_ gesture: UITapGestureRecognizer) {
    if (gesture.view as? MediaItemCell) != nil {
      let selectedCell = gesture.view as! MediaItemCell

      let mediaItem = selectedCell.item!

      let type = mediaItem.type

      if type != nil && type!.isEmpty {
        mediaItem.resolveType()
      }

      if mediaItem.isContainer() {
        if mediaItem.isAudioContainer() {
          performSegue(withIdentifier: AudioItemsController.SEGUE_IDENTIFIER, sender: gesture.view)
        }
        else {
          let newAdapter = adapter.clone()
          newAdapter.selectedItem = mediaItem

          newAdapter.parentId = selectedCell.item?.id
          newAdapter.parentName = selectedCell.item?.name
          newAdapter.isContainer = true

          let destination = MediaItemsController.instantiate()

          destination.adapter = newAdapter

          destination.collectionView?.collectionViewLayout = adapter.buildLayout()!

          self.present(destination, animated: true)
        }
      }
      else {
        performSegue(withIdentifier: MediaItemDetailsController.SEGUE_IDENTIFIER, sender: gesture.view)
      }
    }
  }

  // MARK: Navigation

  override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      let selectedCell = sender as! MediaItemCell
      let mediaItem = selectedCell.item!

      switch identifier {
        case MediaItemDetailsController.SEGUE_IDENTIFIER:
          if let destination = segue.destination as? MediaItemDetailsController {
            destination.collectionItems = items
            destination.mediaItem = mediaItem
            destination.adapter = adapter
          }
        case AudioItemsController.SEGUE_IDENTIFIER:
          if let destination = segue.destination as? AudioItemsController {
            destination.mediaItem = mediaItem
            destination.adapter = adapter
            destination.adapter.selectedItem = mediaItem
          }
        case VideoPlayerController.SEGUE_IDENTIFIER:
          if let destination = segue.destination as? VideoPlayerController {
            destination.playVideo = true
            destination.collectionItems = items
            destination.mediaItem = mediaItem
            destination.adapter = adapter
            destination.provider = adapter.provider

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

  override open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String,
                               at indexPath: IndexPath) -> UICollectionReusableView {
    if kind == "UICollectionElementKindSectionHeader" {
      let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
        withReuseIdentifier: HEADER_VIEW_IDENTIFIER, for: indexPath as IndexPath) as! MediaItemsHeaderView

      headerView.sectionLabel.text = adapter?.languageManager?.localize(getHeaderName())
      
      return headerView
    }

    return UICollectionReusableView()
  }

  func getHeaderName() -> String {
    var name = ""

    if adapter.getParentName() != nil {
      name = adapter.getParentName()!
    }
    else {
      name = adapter.requestType!
    }

    return name
  }

  override open func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    cellSelection.setIndexPath(indexPath)

    let item = items[indexPath.row]

    navigationItem.title = item.name

    manageMovieBookmark()

    return true
  }

  // MARK:- Add Cell

  func manageMovieBookmark() {
    if adapter.requestType != "HISTORY" {
      let selectedItem = getSelectedItem()

      if let item = selectedItem {
        if adapter.requestType == "BOOKMARKS" {
          self.present(buildRemoveBookmarkController(item), animated: false, completion: nil)
        }
        else {
          self.present(buildAddBookmarkController(item), animated: false, completion: nil)
        }
      }
    }
  }

  func buildRemoveBookmarkController(_ item: MediaItem) -> UIAlertController {
    let title = adapter?.languageManager?.localize("BOOKMARK_WILL_BE_REMOVED")
    let message = adapter?.languageManager?.localize("BOOKMARK_WILL_BE_REMOVED")
    
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
    let title = adapter?.languageManager?.localize("BOOKMARK_WILL_BE_ADDED")
    let message = adapter?.languageManager?.localize("BOOKMARK_WILL_BE_ADDED")
    
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
      if self.adapter.addBookmark(item: item) {
        self.navigationItem.title = ""
      }
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
    
    alertController.addAction(cancelAction)
    alertController.addAction(okAction)
    
    return alertController
  }

}
