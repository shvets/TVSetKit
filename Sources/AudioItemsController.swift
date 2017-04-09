import UIKit
import AVFoundation

class AudioItemsController: BaseTableViewController {
  static let SegueIdentifier = "Audio Items"
  public class var StoryboardControllerId: String { return "AudioItemsController" }

  override open var CellIdentifier: String { return "AudioItemCell" }

  var loaded = false

#if os(iOS)

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
    activityIndicatorView.center = (tableView?.center)!;
    adapter.spinner = PlainSpinner(activityIndicatorView)

    loadInitialData()

    if adapter?.requestType != "History" {
      adapter?.addHistoryItem(adapter.selectedItem!)
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    if loaded {
      let currentTrackIndex = AudioPlayer.shared.currentTrackIndex

      if isSameBook() && currentTrackIndex != -1 {
        let indexPath = IndexPath(row: currentTrackIndex, section: 0)
        tableView?.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
      }
    }
  }

  func isSameBook() -> Bool {
    return adapter.selectedItem?.id! == AudioPlayer.shared.currentBookId
  }

  func isSameTrack(_ row: Int) -> Bool {
    let currentTrackIndex = AudioPlayer.shared.currentTrackIndex

    return currentTrackIndex != -1 && row == currentTrackIndex
  }

  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if isSameBook() && isSameTrack(indexPath.row) {
      cell.setSelected(true, animated: true)
      //loaded = true
    }
    else if cell.isSelected {
      cell.setSelected(false, animated: true)
    }
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

    loaded = true

    return cell
  }

#if os(iOS)
  override open func navigate(from view: UITableViewCell) {
    performSegue(withIdentifier: AudioPlayerController.SegueIdentifier, sender: view)
  }
#endif

  // MARK: - Table view data source

#if os(tvOS)
  override open func tapped(_ gesture: UITapGestureRecognizer) {
    if (gesture.view as? MediaItemCell) != nil {
      performSegue(withIdentifier: AudioPlayerController.SegueIdentifier, sender: gesture.view)
    }
  }
#endif

  // MARK: Navigation

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
        case AudioPlayerController.SegueIdentifier:
          if let destination = segue.destination as? AudioPlayerController {
            destination.items = items
            destination.parentName = adapter.selectedItem?.name!
            destination.coverImageUrl = adapter.selectedItem?.thumb!
            destination.bookId = adapter.selectedItem?.id!
            destination.selectedItemId = tableView?.indexPath(for: sender as! UITableViewCell)!.row
          }

        default: break
      }
    }
  }
#endif
  
}
