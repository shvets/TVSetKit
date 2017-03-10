import UIKit
import SwiftyJSON

class MediaItemDetailsController: UIViewController {
  static let SegueIdentifier = "MediaItemDetails"
  let CellIdentifier = "MediaItemDetailsCell"

  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var movieDescription: UITextView!
  @IBOutlet weak var name: UILabel!
  @IBOutlet weak var tag: UILabel!
  @IBOutlet weak var rating: UILabel!
  @IBOutlet weak var watchStatus: UILabel!

  let localizer = Localizer("com.rubikon.TVSetKit")

  @IBOutlet weak var playButtonsView: PlayButtonsView!

  var adapter: ServiceAdapter?
  var collectionItems: [MediaItem]!

  var mediaItem: MediaItem!

  var bitrates = [MediaName]()

  override func viewDidLoad() {
    super.viewDidLoad()

    do {
      try adapter?.retrieveExtraInfo(mediaItem)
    }
    catch {
      print("Error getting extra data.")
    }

    do {
      try loadData()
    }
    catch {
      print("Error loading data.")
    }

    playButtonsView.createPlayButtons(bitrates, mobile: adapter!.mobile!)

    for button in playButtonsView!.buttons {
      let playButton = button as! PlayButton

      playButton.controller = self

      if adapter?.mobile == true {
        let action = #selector(self.playMediaItem)

        button.addTarget(self, action: action, for: .touchUpInside)
      }
      else {
        let action = #selector(self.tapped(_:))
        let tapGesture = UITapGestureRecognizer(target: self, action: action)

        tapGesture.allowedPressTypes = [NSNumber(value: UIPressType.playPause.rawValue)]

        button.addGestureRecognizer(tapGesture)
      }
    }

    if adapter?.requestType != "HISTORY" {
      adapter?.addHistoryItem(mediaItem)
    }

    movieDescription.text = mediaItem.description
    name.text = mediaItem.name

    let ws = mediaItem.getWatchStatus()

    if ws != "" {
      watchStatus.text = ws
    }

    let rt = mediaItem.rating!

    if rt > 0 {
      rating.text = String(describing: "Rating: \(rt)")
    }

    tag.text = mediaItem.tags

    let posterPath = mediaItem.getPosterPath(isBetterQuality: true)

    let image = createDetailsImage(path: posterPath)

    imageView.image = image

    if let frame = adapter?.getDetailsImageFrame() {
      imageView.frame = frame
    }
  }

  func loadData() throws {
    do {
      for bitrate in try mediaItem.getBitrates() {
        let name = bitrate["name"] as! String
        let id = bitrate["id"] as? String

        bitrates.append(MediaName(name: name, id: id))
      }
    }
    catch {
      print("error")
    }
  }

  func createDetailsImage(path: String) -> UIImage? {
    var image: UIImage?

    if path.isEmpty {
      let localizedName = localizer.localize(mediaItem.name!)

      image = UIHelper.shared.textToImage(drawText: localizedName, width: 450, height: 150)
    }
    else {
      let url = NSURL(string: path)!

      let data = NSData(contentsOf: url as URL)

      if let data = data {
        image = UIImage(data: data as Data)
      }
    }

    return image
  }

  func tapped(_ gesture: UITapGestureRecognizer) {
    playMediaItem(sender: gesture.view!)
  }

  func playMediaItem(sender: UIView) {
    let controller = UIViewController.instantiate(
      controllerId: VideoPlayerController.StoryboardControllerId,
      storyboardId: adapter!.playerStoryboardId,
      bundleId: adapter!.playerBundleId
    )

    if let destination = controller.getActionController() as? VideoPlayerController {
      destination.playVideo = true
      destination.collectionItems = collectionItems
      destination.mediaItem = mediaItem
      destination.adapter = adapter

      let index = playButtonsView!.buttons.index(where: { $0 == sender as? UIButton })

      if let index = index {
        do {
          let bitrates = try mediaItem.getBitrates()

          if !bitrates.isEmpty {
            destination.bitrate = bitrates[index]
          }
        } catch {
          print("Error getting bitrate")
        }
      }

      present(controller, animated: true, completion: nil)
    }
  }

}
