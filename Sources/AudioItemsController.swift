import UIKit
import AVFoundation

class AudioItemsController: BaseTableViewController {
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

//  var currentTrack: String?

  override func viewDidLoad() {
    super.viewDidLoad()

    title = adapter.selectedItem!.name

    tableView?.backgroundView = activityIndicatorView
    adapter.spinner = PlainSpinner(activityIndicatorView)

    loadInitialData()
  }
  
  // MARK: - Table view data source
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath) as! MediaItemTableCell

    let item = items[indexPath.row]

    cell.configureCell(item: item, localizedName: getLocalizedName(item.name))

    cell.layer.masksToBounds = true
    cell.layer.borderWidth = 0.5
    cell.layer.borderColor = UIColor( red: 0, green: 0, blue:0, alpha: 1.0 ).cgColor

#if os(tvOS)
    CellHelper.shared.addTapGestureRecognizer(view: cell, target: self, action: #selector(self.tapped(_:)))
#endif

    return cell
  }

#if os(iOS)
  override open func navigate(from view: UITableViewCell) {
    //self.navigationController?.setNavigationBarHidden(true, animated: false)

    performSegue(withIdentifier: AudioPlayer.SegueIdentifier, sender: view)

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
  override open func tapped(_ gesture: UITapGestureRecognizer) {
    if (gesture.view as? MediaItemCell) != nil {
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

      performSegue(withIdentifier: AudioPlayer.SegueIdentifier, sender: gesture.view)
    }
  }
#endif

  // MARK: Navigation

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
        case AudioPlayer.SegueIdentifier:
          if let destination = segue.destination as? AudioPlayer {

            destination.items = items
            destination.selectedItemId = tableView?.indexPath(for: sender as! UITableViewCell)!.row
          }

        default: break
      }
    }
  }

}
