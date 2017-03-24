import UIKit
import AVFoundation
import AVKit

class AudioItemsController: InfiniteTableViewController {
  static let SegueIdentifier = "Audio Items"
  public class var StoryboardControllerId: String { return "AudioItemsController" }

  override open var CellIdentifier: String { return "AudioItemCell" }

  static public func instantiate(_ adapter: ServiceAdapter) -> UIViewController {
    return UIViewController.instantiate(
      controllerId: AudioItemsController.StoryboardControllerId,
      storyboardId: type(of: adapter).StoryboardId,
      bundle: Bundle.main
    )
  }

  var selectedCell: AudioItemCell?
  var mediaItem: MediaItem?

  var player: AVPlayer?
  
  var currentTrack: String?

  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView?.backgroundView = activityIndicatorView
    adapter.spinner = PlainSpinner(activityIndicatorView)

    loadInitialData()
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath) as! AudioItemCell

    let item = items[indexPath.row]
    
    cell.configureCell(item: item)

#if os(tvOS)
    CellHelper.shared.addTapGestureRecognizer(view: cell, target: self, action: #selector(self.tapped(_:)))
#endif

    return cell
  }

  override func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let currentOffset = scrollView.contentOffset.y
    let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
    let deltaOffset = maximumOffset - currentOffset

    if deltaOffset <= 0 {
      if adapter.nextPageAvailable(dataCount: items.count, index: items.count-1) {
        loadMoreData(items.count-1)
      }
    }
  }

#if os(iOS)
  override open func navigate(from view: UITableViewCell) {
    //self.navigationController?.setNavigationBarHidden(true, animated: false)

    performSegue(withIdentifier: AudioPlayerController.SegueIdentifier, sender: view)

//    let mediaItem = getItem(for: view)
//
//    let controller = AudioItemsController.instantiate(adapter)
//
//    let destination = controller.getActionController() as! AudioItemsController
//
//    let newAdapter = adapter.clone()
//    newAdapter.selectedItem = mediaItem
//
//    newAdapter.parentId = mediaItem.id
//    newAdapter.parentName = mediaItem.name
//    newAdapter.isContainer = true
//
//    destination.adapter = newAdapter
//
//    navigationController!.pushViewController(destination, animated: true)
  }
#endif

  // MARK: - Table view data source

#if os(tvOS)
  func tapped(_ gesture: UITapGestureRecognizer) {
    if (gesture.view as? AudioItemCell) != nil {
//        let cell = gesture.view as! AudioItemCell
//        
//        if selectedCell == nil {
//          cell.current.text = "->"
//        }
//        else if cell == selectedCell {
//          cell.current.text = "->"
//        }
//        else {
//          selectedCell?.current.text = ""
//          cell.current.text = "->"
//        }
//        
//        selectedCell = cell
//        
//        let mediaItem = selectedCell!.item!
//        
//        let track = mediaItem.id!
//        
//        if currentTrack == track {
//          if status == "paused" || status == "init" {
//            player?.play()
//          }
//          else {
//            player?.pause()
//          }
//          
//          status = (status == "paused") ? "resumed" : "paused"
//        }
//        else {
//          currentTrack = track
//          
//          status = "init"
//          
//          if player != nil {
//            player?.pause()
//          }
//          
//          if let url = getMediaUrl() {
//            playAudio(url)
//          }
//        }

      performSegue(withIdentifier: AudioPlayerController.SegueIdentifier, sender: gesture.view)
    }
  }
#endif

  // MARK: Navigation

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
        case AudioPlayerController.SegueIdentifier:
          if let destination = segue.destination as? AudioPlayerController,
             let selectedCell = sender as? AudioItemCell {

            destination.mediaItem = getItem(for: selectedCell)
          }

        default: break
      }
    }
  }

}
