import AVFoundation
import UIKit
import AVKit
import SwiftyJSON

class VideoPlayerController: AVPlayerViewController {
  static let SegueIdentifier = "Video Player"
  public class var StoryboardControllerId: String { return "videoPlayerController" }

//class VideoPlayerController: UIViewController, AVPlayerViewControllerDelegate {

  //let playerViewController: AVPlayerViewController? = AVPlayerViewController()
  var adapter: ServiceAdapter!
  var localizer = Localizer("com.rubikon.TVSetKit", bundleClass: TVSetKit.self)

  var params = [String: Any]()

  var navigator: MediaItemsNavigator?
  var initialQualityLevel: QualityLevel?

  var mode: String?
  var playVideo: Bool = false
  var collectionItems: [MediaItem] = []
  var mediaItem: MediaItem?
  var bitrate: [String: Any]?

  override func viewDidLoad() {
    super.viewDidLoad()

    navigator = MediaItemsNavigator(collectionItems)

    initialQualityLevel = QualityLevel(rawValue: bitrate!["name"] as! String)

#if os(tvOS)
    let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.doubleTapPressed(_:)))
    doubleTapRecognizer.numberOfTapsRequired = 2

    self.view.addGestureRecognizer(doubleTapRecognizer)
#endif

    _ = [UISwipeGestureRecognizerDirection.right, .left, .up, .down].map({ direction in
      let recognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.swiped(_:)))

      recognizer.direction = direction

      self.view.addGestureRecognizer(recognizer)
    })

    if playVideo {
      play()
    }
  }

  func doubleTapPressed(_ gesture: UITapGestureRecognizer) {
    if preparePreviousMediaItem() {
      play()
    }
  }
  
  func swiped(_ gesture: UISwipeGestureRecognizer) {
#if os(iOS)
    switch gesture.direction {
      case UISwipeGestureRecognizerDirection.up:
        if prepareNextMediaItem() {
          play()
        }
      case UISwipeGestureRecognizerDirection.down:
        if preparePreviousMediaItem() {
          play()
        }

      default:
        break
    }
#endif

#if os(tvOS)
    switch gesture.direction {
      case UISwipeGestureRecognizerDirection.up:
        if prepareNextMediaItem() {
          play()
        }

      default:
        break
    }
#endif
  }

  func preparePreviousMediaItem() -> Bool {
    let currentId = mediaItem?.id
    
    let previousId = navigator?.getPreviousId(currentId!)
    
    if previousId != currentId {
      let previousItem = navigator?.items?.filter { item in item.id == previousId }.first
      
      mediaItem = previousItem
    }
    
    return previousId != currentId
  }
  
  func prepareNextMediaItem() -> Bool {
    let currentId = mediaItem?.id
    
    let nextId = navigator?.getNextId(currentId!)
    
    if nextId != currentId {
      let nextItem = navigator?.items?.filter { item in item.id == nextId }.first

      mediaItem = nextItem
    }
    
    return nextId != currentId
  }
  
  func play() {
    let name = mediaItem?.name
    let description = mediaItem?.description!

    if let url = getMediaUrl() {
      let asset = AVAsset(url: url)

      let playerItem = AVPlayerItem(asset: asset)

      #if os(tvOS)
        playerItem.externalMetadata = externalMetaData(title: name!, description: description!)
      #endif

      // playerViewController?.delegate = self

      player = AVPlayer(playerItem: playerItem)
      // playerViewController?.player = player

      let overlayView = UIView(frame: CGRect(x: 50, y: 50, width: 200, height: 200))
      overlayView.addSubview(UIImageView(image: UIImage(named: "tv-watermark")))

      self.contentOverlayView?.addSubview(overlayView)
      //playerViewController?.contentOverlayView?.addSubview(overlayView)

      player?.play()

      //self.present(playerViewController!, animated: false) {
      //  /*
      //   Begin playing the media as soon as the controller has
      //   been presented.
      //   */
      //  player.play()
     // }
    }
    else {
      let title = localizer.localize("Cannot Find Source")
      let message = localizer.localize("Cannot Find Source")
      
      let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
      
      let closeAction = UIAlertAction(title: "Close", style: .default) { _ in
        // redirect to previous page
      }
      
      alertController.addAction(closeAction)
      
      present(alertController, animated: false, completion: nil)
    }
  }

  // MARK: Meta data

  private func externalMetaData(title: String, description: String) -> [AVMetadataItem] {
    let titleItem = AVMutableMetadataItem()
    titleItem.identifier = AVMetadataCommonIdentifierTitle
    titleItem.value = title as NSString
    titleItem.extendedLanguageTag = "und"

    let descriptionItem = AVMutableMetadataItem()
    descriptionItem.identifier = AVMetadataCommonIdentifierDescription
    descriptionItem.value = description as NSString
    descriptionItem.extendedLanguageTag = "und"

    return [titleItem, descriptionItem]
  }
  
  private func getMediaUrl() -> URL? {
    var url: String?

    do {
      let qualityLevel = initialQualityLevel!.nearestLevel(qualityLevels: try mediaItem!.getQualityLevels())

      let bitrate = try mediaItem!.getBitrate(qualityLevel: qualityLevel!)

      var params = [String: Any]()
      params["bitrate"] = bitrate
      params["id"] = mediaItem?.id
      params["item"] = mediaItem

      url = try adapter!.getUrl(params)
    }
    catch {
      print("Cannot get urls.")
    }

    if url != nil {
      return NSURL(string: url!)! as URL
    }
    else {
      return nil
    }
  }
}
