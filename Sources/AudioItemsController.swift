import UIKit
import AVFoundation
import AudioPlayer

class AudioItemsController: UITableViewController {
  static let SegueIdentifier = "Audio Items"
  public class var StoryboardControllerId: String { return "AudioItemsController" }

  open var CellIdentifier: String { return "AudioItemCell" }

  public var adapter: ServiceAdapter!
  
#if os(iOS)
  
  public let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)

  public var localizer: Localizer!

  public var items = [AudioItem]()

  var loaded = false

  static public func instantiate(_ adapter: ServiceAdapter) -> UIViewController {
    return UIViewController.instantiate(
      controllerId: AudioItemsController.StoryboardControllerId,
      storyboardId: type(of: adapter).StoryboardId,
      bundle: Bundle.main
    )
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    title = adapter.selectedItem!.name

    tableView?.backgroundView = activityIndicatorView
    activityIndicatorView.center = (tableView?.center)!;
    adapter.spinner = PlainSpinner(activityIndicatorView)

    adapter.loadData() { result in
      for item in result {
        self.items.append(AudioItem(name: item.name!, id: item.id!))
      }

      self.tableView?.reloadData()
    }
    if adapter?.requestType != "History" {
      adapter?.addHistoryItem(adapter.selectedItem!)
    }
  }

  func navigateToSelectedRow() {
    if loaded {
      let currentTrackIndex = AudioPlayer.shared.currentTrackIndex

      if isSameBook() && currentTrackIndex != -1 {
        let indexPath = IndexPath(row: currentTrackIndex, section: 0)
        tableView?.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
        tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
      }
    }
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    navigateToSelectedRow()
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
    }
    else if cell.isSelected {
      cell.setSelected(false, animated: true)
    }
  }

  // MARK: UITableViewDataSource

  override open func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath) as! MediaItemTableCell

    let item = items[indexPath.row]

    //cell.configureCell(item: item, localizedName: getLocalizedName(item.name))

    cell.title.text = item.name

    cell.layer.masksToBounds = true
    cell.layer.borderWidth = 0.5
    cell.layer.borderColor = UIColor( red: 0, green: 0, blue:0, alpha: 1.0 ).cgColor

    if !loaded {
      loaded = true

      navigateToSelectedRow()
    }

    return cell
  }

  override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    navigate(from: tableView.cellForRow(at: indexPath)!)
    //performSegue(withIdentifier: AudioPlayerController.SegueIdentifier, sender: view)
  }

  open func navigate(from view: UITableViewCell) {
    performSegue(withIdentifier: AudioPlayerController.SegueIdentifier, sender: view)
  }

  // MARK: Navigation

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
        case AudioPlayerController.SegueIdentifier:
          if let destination = segue.destination as? AudioPlayerController {
            destination.parentName = adapter.selectedItem?.name!
            destination.coverImageUrl = adapter.selectedItem?.thumb!
            destination.items = items
            destination.selectedBookId = adapter.selectedItem?.id!
            destination.selectedItemId = tableView?.indexPath(for: sender as! UITableViewCell)!.row
          }

        default: break
      }
    }
  }

  open func getLocalizedName(_ name: String?) -> String {
    if let name = name {
      return localizer.localize(name)
    }
    else {
      return ""
    }
  }
#endif
  
}
