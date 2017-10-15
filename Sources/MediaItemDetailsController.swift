import UIKit

class MediaItemDetailsController: UIViewController {
  static let SegueIdentifier = "Media Item Details"
  let CellIdentifier = "MediaItemDetailsCell"

  @IBOutlet private weak var imageView: UIImageView!
  @IBOutlet private weak var movieDescription: UITextView!
  @IBOutlet private weak var name: UILabel!
  @IBOutlet private weak var tag: UILabel!
  @IBOutlet private weak var rating: UILabel!
  @IBOutlet private weak var watchStatus: UILabel!

  let localizer = Localizer("com.rubikon.TVSetKit", bundleClass: TVSetKit.self)

  @IBOutlet private weak var playButtonsView: PlayButtonsView!

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

    if let adapter = adapter, let mobile = adapter.mobile {
      playButtonsView.createPlayButtons(bitrates, mobile: mobile)
    }

    if let view = playButtonsView {
      for button in view.buttons {
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
    }

    if let requestType = adapter?.params["requestType"] as? String {
      if requestType != "History" {
        adapter?.addHistoryItem(mediaItem)
      }
    }

    movieDescription.text = mediaItem.description
    name.text = mediaItem.name

    let ws = mediaItem.getWatchStatus()

    if ws != "" {
      watchStatus.text = ws
    }

    if let rating = mediaItem.rating {
      if let rt = Int(rating), rt > 0 {
        self.rating.text = String(describing: "Rating: \(rt)")
      }
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
        if let name = bitrate["name"] as? String {
          let id = bitrate["id"] as? String ?? ""

          bitrates.append(MediaName(name: name, id: id))
        }
      }
    }
    catch {
      print("error")
    }
  }

  func createDetailsImage(path: String) -> UIImage? {
    var image: UIImage?

    if path.isEmpty {
      if let name = mediaItem.name {
        let localizedName = localizer.localize(name)

        image = UIHelper.shared.textToImage(drawText: localizedName, width: 450, height: 150)
      }
    }
    else {
      if let url = NSURL(string: path) {
        let data = NSData(contentsOf: url as URL)

        if let data = data {
          image = UIImage(data: data as Data)
        }
      }
    }

    return image
  }

  @objc func tapped(_ gesture: UITapGestureRecognizer) {
    if let sender = gesture.view {
      playMediaItem(sender: sender)
    }
  }

  @objc func playMediaItem(sender: UIView) {
    let controller = UIViewController.instantiate(
      controllerId: VideoPlayerController.StoryboardControllerId,
      storyboardId: type(of: adapter!).StoryboardId,
      bundle: Bundle.main
    )

    if let destination = controller.getActionController() as? VideoPlayerController {
      destination.playVideo = true
      destination.collectionItems = collectionItems
      destination.mediaItem = mediaItem

      if let view = playButtonsView {
        let index = view.buttons.index(where: { $0 == sender as? UIButton })

        if let index = index {
          func getMediaUrl() throws -> URL? {
            return try mediaItem.getMediaUrl(index: index)
          }
            
          destination.getMediaUrl = getMediaUrl
        }
      }

      present(controller, animated: true, completion: nil)
    }
  }

}
