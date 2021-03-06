import AVFoundation
import UIKit
import AVKit

open class VideoPlayerController: AVPlayerViewController, ReusableController {
  public static let SegueIdentifier = "Video Player"
  
  //class VideoPlayerController: UIViewController, AVPlayerViewControllerDelegate {
  
  //let playerViewController: AVPlayerViewController? = AVPlayerViewController()
  var localizer = Localizer("com.rubikon.TVSetKit", bundleClass: TVSetKit.self)
  
  var params = [String: Any]()
  
  var navigator: MediaItemsNavigator?
  
  var mode: String?
  var playVideo: Bool = false
  var items: [Item] = []
  var mediaItem: Item?
  var receiver: UIViewController?
  
  var getMediaUrl: ((MediaItem) throws -> URL?)!
  var getRequestHeaders: ((MediaItem) -> [String : String])!

  override open func viewDidLoad() {
    super.viewDidLoad()

    navigator = MediaItemsNavigator(items)
    
    #if os(tvOS)
      let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.doubleTapPressed(_:)))
      doubleTapRecognizer.numberOfTapsRequired = 2
      
      self.view.addGestureRecognizer(doubleTapRecognizer)
    #endif
    
    _ = [UISwipeGestureRecognizer.Direction.right, .left, .up, .down].map({ direction in
      let recognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.swiped(_:)))
      
      recognizer.direction = direction
      
      self.view.addGestureRecognizer(recognizer)
    })
    
    if playVideo {
      play()
    }
  }
  
  override open func viewWillDisappear(_ animated: Bool) {
    if let mediaItem = mediaItem {
      notifyMediaItemChange(mediaItem)
    }
  }

  func notifyMediaItemChange(_ mediaItem: Item) {
    let nc = NotificationCenter.default

    nc.post(name: NSNotification.Name(
      rawValue: "mediaItem"),
      object: nil,
      userInfo: [
        "id" : mediaItem.id as Any,
        "receiver": receiver as Any
      ])
  }
  
  @objc func doubleTapPressed(_ gesture: UITapGestureRecognizer) {
    if preparePreviousMediaItem() {
      play()
    }
  }
  
  @objc func swiped(_ gesture: UISwipeGestureRecognizer) {
    #if os(iOS)
      switch gesture.direction {
      case UISwipeGestureRecognizer.Direction.up:
        if prepareNextMediaItem() {
          play()
        }
      case UISwipeGestureRecognizer.Direction.down:
        if preparePreviousMediaItem() {
          play()
        }
        
      default:
        break
      }
    #endif
    
    #if os(tvOS)
      switch gesture.direction {
      case UISwipeGestureRecognizer.Direction.up:
        if prepareNextMediaItem() {
          play()
        }
        
      default:
        break
      }
    #endif
  }
  
  func preparePreviousMediaItem() -> Bool {
    if let currentId = mediaItem?.id {
      let previousId = navigator?.getPreviousId(currentId)
      
      if previousId != currentId {
        let previousItem = navigator?.items?.filter { item in item.id == previousId }.first
        
        mediaItem = previousItem
      }
      
      return previousId != currentId
    }
    else {
      return false
    }
  }
  
  func prepareNextMediaItem() -> Bool {
    if let currentId = mediaItem?.id {
      let nextId = navigator?.getNextId(currentId)
      
      if nextId != currentId {
        let nextItem = navigator?.items?.filter { item in item.id == nextId }.first
        
        mediaItem = nextItem
      }
      
      return nextId != currentId
    }
    else {
      return false
    }
  }
  
  func play() {
    var mediaUrl: URL?
    
    do {
      mediaUrl = try getMediaUrl(mediaItem as! MediaItem)
    }
    catch let e {
      print("Error: \(e)")
    }
    
    if let url = mediaUrl,
      let name = mediaItem?.name {
      
      let description: String
      
      if let mediaItem = mediaItem as? MediaItem {
        description = mediaItem.description ?? name
      }
      else {
        description = name
      }

//      let headers = getRequestHeaders(mediaItem as! MediaItem)
//
//      print(headers)

      let asset = AVURLAsset(url: url)
      //, options: ["AVURLAssetHTTPHeaderFieldsKey": headers])

      let playerItem = AVPlayerItem(asset: asset)
      
      #if os(tvOS)
        playerItem.externalMetadata = externalMetaData(title: name, description: description)
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
    
    titleItem.identifier = AVMetadataIdentifier.commonIdentifierTitle
    titleItem.value = title as NSString
    titleItem.extendedLanguageTag = "und"
    
    let descriptionItem = AVMutableMetadataItem()
    descriptionItem.identifier = AVMetadataIdentifier.commonIdentifierDescription
    descriptionItem.value = description as NSString
    descriptionItem.extendedLanguageTag = "und"
    
    return [titleItem, descriptionItem]
  }
  
}

