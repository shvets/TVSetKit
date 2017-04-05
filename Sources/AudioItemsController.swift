import UIKit
import AVFoundation

class AudioItemsController: BaseTableViewController {
  static let SegueIdentifier = "Audio Items"
  public class var StoryboardControllerId: String { return "AudioItemsController" }

  override open var CellIdentifier: String { return "AudioItemCell" }

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
    adapter.spinner = PlainSpinner(activityIndicatorView)

    loadInitialData()

    if adapter?.requestType != "HISTORY" {
      adapter?.addHistoryItem(adapter.selectedItem!)
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

    return cell
  }

#if os(iOS)
  override open func navigate(from view: UITableViewCell) {
    performSegue(withIdentifier: APController.SegueIdentifier, sender: view)
  }
#endif

  // MARK: - Table view data source

#if os(tvOS)
  override open func tapped(_ gesture: UITapGestureRecognizer) {
    if (gesture.view as? MediaItemCell) != nil {
      performSegue(withIdentifier: APController.SegueIdentifier, sender: gesture.view)
    }
  }
#endif

  // MARK: Navigation

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
        case APController.SegueIdentifier:
          if let destination = segue.destination as? APController {

            destination.items = items
            destination.parentName = adapter.selectedItem?.name!
            destination.selectedItemId = tableView?.indexPath(for: sender as! UITableViewCell)!.row
          }

        default: break
      }
    }
  }
#endif
  
}
