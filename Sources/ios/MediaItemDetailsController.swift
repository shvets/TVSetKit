import UIKit

open class MediaItemDetailsController: UIViewController {
  public static let SegueIdentifier = "Media Item Details"
  //let CellIdentifier = "MediaItemDetailsCell"

  @IBOutlet private weak var imageView: UIImageView!
  @IBOutlet private weak var movieDescription: UITextView!
  @IBOutlet private weak var name: UILabel!
  @IBOutlet private weak var tag: UILabel!
  @IBOutlet private weak var rating: UILabel!
  @IBOutlet private weak var watchStatus: UILabel!

  let localizer = Localizer("com.rubikon.TVSetKit", bundleClass: TVSetKit.self)

  @IBOutlet private weak var playButtonsView: PlayButtonsView!

  var historyManager: HistoryManager?

  var storyboardId: String?

  public var params = Parameters()
  public var configuration: [String: Any]?

  var items: [Item]!
    
  var mediaItem: MediaItem!
  var bitrates = [MediaName]()

  override open func viewDidLoad() {
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

    var isMobile = false
    
    if let mobile = configuration?["mobile"] as? Bool {
      isMobile = mobile
    }

    playButtonsView.createPlayButtons(bitrates, mobile: isMobile)

    if let view = playButtonsView {
      for button in view.buttons {
        let playButton = button as! PlayButton

        playButton.controller = self

        if isMobile {
          let action = #selector(self.playMediaItemAction)

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

//    let width = playButtonsView.createPlayButtons(bitrates, mobile: isMobile)
//    playButtonsView.createEmailButton(width: width, mobile: isMobile)
//
//    if let view = playButtonsView {
//      for button in view.buttons {
//        if let playButton = button as? PlayButton {
//          playButton.controller = self
//
//          if isMobile {
//            let action = #selector(self.playMediaItemAction)
//
//            button.addTarget(self, action: action, for: .touchUpInside)
//          }
//          else {
//            let action = #selector(self.tapped(_:))
//            let tapGesture = UITapGestureRecognizer(target: self, action: action)
//
//            tapGesture.allowedPressTypes = [NSNumber(value: UIPressType.playPause.rawValue)]
//
//            button.addGestureRecognizer(tapGesture)
//          }
//        }
//        else {
//          let emailButton = button
//
//          let count = view.buttons.count
//
//          for index in 0..<count-1 {
//            if let url = mediaItem.getMediaUrl(index: index) {
//              print(url)
//            }
//          }
//        }
//      }
//    }

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

    if let frame = configuration?["detailsImageFrame"] {
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
      playMediaItemAction(sender: sender)
    }
  }

  @objc func playMediaItemAction(sender: UIView) {
    if let view = playButtonsView {
      let index = view.buttons.index(where: { $0 == sender as? UIButton })

      if let index = index, let storyboardId = storyboardId {
        MediaItemDetailsController.playMediaItem(mediaItem, parent: self, items: items,
          storyboardId: storyboardId, index: index)
      }
    }
  }

  open static func playMediaItem(_ mediaItem: MediaItem, parent: UIViewController,
    items: [Item], storyboardId: String, index: Int) {
    let controller = UIViewController.instantiate(
      controllerId: VideoPlayerController.reuseIdentifier,
      storyboardId: storyboardId,
      bundle: Bundle.main
    )

    if let destination = controller as? VideoPlayerController {
      destination.playVideo = true
      destination.items = items
      destination.mediaItem = mediaItem
      destination.receiver = parent

      func getMediaUrl(_ mediaItem: MediaItem) throws -> URL? {
        return mediaItem.getMediaUrl(index: index)
      }

      destination.getMediaUrl = getMediaUrl

      parent.present(controller, animated: true, completion: nil)
    }
  }

}
