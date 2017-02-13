import UIKit
import SwiftyJSON

class PlayButton: UIButton {
  var controller: MediaItemDetailsController?
  var bitrate: MediaName?

  override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
    for item in presses {
      if item.type == .select {
        controller?.playMediaItem(sender: self)
      }
    }
  }
}

class MediaItemDetailsController: UIViewController {
  static let SEGUE_IDENTIFIER = "MediaItemDetails"
  let CELL_IDENTIFIER = "MediaItemDetailsCell"
  
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var movieDescription: UITextView!
  @IBOutlet weak var name: UILabel!
  @IBOutlet weak var tag: UILabel!
  @IBOutlet weak var rating: UILabel!
  @IBOutlet weak var watchStatus: UILabel!

  var adapter: ServiceAdapter?
  var collectionItems: [MediaItem]!

  var mediaItem: MediaItem!

  var bitrates = [MediaName]()
  
  var buttons = [UIButton]()

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

    var currentOffset = 0

    for (index, bitrate) in bitrates.enumerated() {
      if index > 0 {
        currentOffset += Int(buttons[index-1].frame.size.width)+30
      }

      let button = createButton(bitrate: bitrate, offset: currentOffset)

      buttons.append(button)
      
      view.addSubview(button)
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

    let imageView = createDetailsImage(path: posterPath)

    view.addSubview(imageView)
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

  func createButton(bitrate: MediaName, offset: Int) -> PlayButton {
    let title = adapter?.languageManager?.localize(bitrate.name!) ?? "Unknown"

    let button = PlayButton(type: .system)
    let scale = adapter?.languageManager?.getLocale() == "en" ? 52 : 36
    button.frame = CGRect(x: 680+offset, y: 920, width: scale*title.characters.count, height: 80)

    button.setTitle(title, for: .normal)
    button.bitrate = bitrate

    button.controller = self

    let action = #selector(self.tapped(_:))
    let tapGesture = UITapGestureRecognizer(target: self, action: action)

    tapGesture.allowedPressTypes = [NSNumber(value: UIPressType.playPause.rawValue)]

    button.addGestureRecognizer(tapGesture)

    return button
  }

  func createDetailsImage(path: String) -> UIImageView {
    var image: UIImage

    if path.isEmpty {
      let localizedName = adapter?.languageManager?.localize(mediaItem.name!)

      image = UIHelper.shared.textToImage(drawText: localizedName ?? "Unknown Name", width: 450, height: 150)
    }
    else {
      let url = NSURL(string: path)!

      let data = NSData(contentsOf: url as URL)!

      image = UIImage(data: data as Data)!
    }

    imageView.image = image

    if let frame = adapter?.getDetailsImageFrame() {
      imageView.frame = frame
    }

    return imageView
  }

  func tapped(_ gesture: UITapGestureRecognizer) {
    playMediaItem(sender: gesture.view!)
  }
  
  func playMediaItem(sender: UIView) {
    performSegue(withIdentifier: VideoPlayerController.SEGUE_IDENTIFIER, sender: sender)
  }

  // MARK: - Navigation

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
        case VideoPlayerController.SEGUE_IDENTIFIER:
          if let destination = segue.destination as? VideoPlayerController {
            destination.playVideo = true
            destination.collectionItems = collectionItems
            destination.mediaItem = mediaItem
            destination.provider = adapter!.provider
            destination.adapter = adapter

            let index = buttons.index(where: {$0 == sender as? UIButton})

            if let index = index {
              do {
                let bitrates = try mediaItem.getBitrates()

                if !bitrates.isEmpty {
                  destination.bitrate = bitrates[index]
                }
              }
              catch {
                print("Error getting bitrate")
              }
            }
          }

        default: break
      }
    }
  }
}
