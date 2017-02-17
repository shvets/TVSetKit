import UIKit
import AVFoundation
import AVKit

class AudioItemsController: InfiniteTableViewController {
  static let SEGUE_IDENTIFIER = "AudioItems"
  let CELL_IDENTIFIER = "AudioItemCell"

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
    let cell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER, for: indexPath) as! AudioItemCell

    let item = items[indexPath.row]
    
    cell.configureCell(item: item, target: self, action: #selector(self.tapped(_:)))
    
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
  
  // MARK: - Table view data source
  
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

      performSegue(withIdentifier: AudioPlayerController.SEGUE_IDENTIFIER, sender: gesture.view)
    }
  }

  // MARK: Navigation

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
        case AudioPlayerController.SEGUE_IDENTIFIER:
          if let destination = segue.destination as? AudioPlayerController,
             let selectedCell = sender as? AudioItemCell {

            destination.mediaItem = getItem(for: selectedCell)
          }

        default: break
      }
    }
  }

}
