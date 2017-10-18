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

  var storyboardId: String?

  public var params = Parameters()
  public var configuration: [String: Any]?

  var collectionItems: [MediaItem]!

  var historyManager: HistoryManager?
    
  var mediaItem: MediaItem!
  var bitrates = [MediaName]()

  override func viewDidLoad() {
    super.viewDidLoad()

    do {
      try mediaItem.retrieveExtraInfo()
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

    var mobile = false

#if os(iOS)
    mobile = true
#endif

    playButtonsView.createPlayButtons(bitrates, mobile: mobile)

    if let view = playButtonsView {
      for button in view.buttons {
        let playButton = button as! PlayButton

        playButton.controller = self

        if mobile {
          let action = #selector(self.playMediaItem)

          button.addTarget(self, action: action, for: .touchUpInside)
        }
        else {
#if os(tvOS)
          let action = #selector(self.tapped(_:))
          let tapGesture = UITapGestureRecognizer(target: self, action: action)

          tapGesture.allowedPressTypes = [NSNumber(value: UIPressType.playPause.rawValue)]

          button.addGestureRecognizer(tapGesture)
#endif
        }
      }
    }

    if let requestType = params["requestType"] as? String, requestType != "History" {
      historyManager?.addHistoryItem(mediaItem)
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

    if let frame = configuration?["getailsImageFrame"] {
      imageView.frame = frame as! CGRect
    }
  }

  func loadData() throws {
    do {
      for bitrate in try mediaItem.getBitrates() {
        if let name = bitrate["name"] {
          let id = bitrate["id"] ?? ""

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
      storyboardId: storyboardId!,
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
            return mediaItem.getMediaUrl(index: index)
          }
            
          destination.getMediaUrl = getMediaUrl
        }
      }

      present(controller, animated: true, completion: nil)
    }
  }

}
