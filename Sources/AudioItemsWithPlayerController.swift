import UIKit
import AVFoundation
//import AVKit
import MediaPlayer

class AudioItemsWithPlayerController: BaseTableViewController, AVAudioPlayerDelegate {
#if os(iOS)
  static let SegueIdentifier = "Audio Items With Player"
  public class var StoryboardControllerId: String { return "AudioItemsWithPlayerController" }

  override open var CellIdentifier: String { return "AudioItemCell" }

  static public func instantiate(_ adapter: ServiceAdapter) -> UIViewController {
    return UIViewController.instantiate(
      controllerId: AudioItemsController.StoryboardControllerId,
      storyboardId: type(of: adapter).StoryboardId,
      bundle: Bundle.main
    )
  }

  var player:AVAudioPlayer = AVAudioPlayer()

  @IBOutlet var sliderValue: UISlider!

  @IBAction func play(sender: AnyObject) {
    let audioInfo = MPNowPlayingInfoCenter.default
    print(audioInfo)

    player.play()
    //println("Playing \(audioPath)")

//    let playerItem = AVPlayerItem(URL: audioPath)
//    let metadataList = playerItem.asset.commonMetadata as! [AVMetadataItem]


//    for item in metadataList {
//      if let stringValue = item.value as? String {
//        println(item.commonKey)
//        if item.commonKey == "title" {
//          trackLabel.text = stringValue
//        }
//        if item.commonKey == "artist" {
//          artistLabel.text = stringValue
//        }
//
//      }
//    }
  }

  @IBAction func pause(sender: AnyObject) {
    player.pause()
  }

  @IBAction func stop(sender: AnyObject) {
    player.stop()

    player.currentTime = 0;
  }

  @IBAction func sliderChanged(sender: AnyObject) {
    player.volume = sliderValue.value
  }

//  var currentTrack: String?

  override func viewDidLoad() {
    super.viewDidLoad()

    player.delegate = self

    UIApplication.shared.beginReceivingRemoteControlEvents()

    title = adapter.selectedItem!.name

    tableView?.backgroundView = activityIndicatorView
    adapter.spinner = PlainSpinner(activityIndicatorView)

    loadInitialData()
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

//#if os(iOS)
//  override open func navigate(from view: UITableViewCell) {
//    //self.navigationController?.setNavigationBarHidden(true, animated: false)
//
//    performSegue(withIdentifier: AudioPlayerController.SegueIdentifier, sender: view)
//
////    let mediaItem = getItem(for: view)
////
////    let controller = AudioItemsController.instantiate(adapter)
////
////    let destination = controller.getActionController() as! AudioItemsController
////
////    let newAdapter = adapter.clone()
////    newAdapter.selectedItem = mediaItem
////
////    newAdapter.parentId = mediaItem.id
////    newAdapter.parentName = mediaItem.name
////    newAdapter.isContainer = true
////
////    destination.adapter = newAdapter
////
////    navigationController!.pushViewController(destination, animated: true)
//  }
//#endif

  // MARK: - Table view data source

#if os(tvOS)
  override open func tapped(_ gesture: UITapGestureRecognizer) {
    if (gesture.view as? MediaItemCell) != nil {
//        let cell = gesture.view as! AudioItemCell
//
//        if selectedCell == nil {
//          cell.current.text = "->"
//        }
//        else if cell == selectedCell {
//          cell.current.text = "->"
//        }
//        else {
//          selectedCell?.current.text = ""
//          cell.current.text = "->"
//        }
//
//        selectedCell = cell
//
//        let mediaItem = selectedCell!.item!
//
//        let track = mediaItem.id!
//
//        if currentTrack == track {
//          if status == "paused" || status == "init" {
//            player?.play()
//          }
//          else {
//            player?.pause()
//          }
//
//          status = (status == "paused") ? "resumed" : "paused"
//        }
//        else {
//          currentTrack = track
//
//          status = "init"
//
//          if player != nil {
//            player?.pause()
//          }
//
//          if let url = getMediaUrl() {
//            playAudio(url)
//          }
//        }

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

          destination.mediaItem = getItem(for: sender as! UITableViewCell)
          destination.items = items
        }

      default: break
      }
    }
  }

  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    print("finished")
  }

  func getPlayerItems(items: [MediaItem]) -> [AVPlayerItem] {
    var playerItems: [AVPlayerItem] = []

    for item in items {
      if let url = getMediaUrl(url: item.id!) {
        let asset = AVAsset(url: url)

        playerItems.append(AVPlayerItem(asset: asset))
      }
    }

    return playerItems
  }

  func playAudio() throws {
    let audioInfo = MPNowPlayingInfoCenter.default
    print(audioInfo)

//    let audioInfo = MPNowPlayingInfoCenter.default
//    let audioName = audioPath.lastPathComponent!.stringByDeletingPathExtension
//    audioInfo.nowPlayingInfo = [ MPMediaItemPropertyTitle: audioName, MPMediaItemPropertyArtist:"artistName"]

//    print(items[0])
    let item = items[0]
//    print(item.id!)
//    print(getMediaUrl(url: item.id!))

    //player = try AVAudioPlayer(contentsOf: getMediaUrl(url: item.id!)!, fileTypeHint: "mp3")

    let audioPath =  getMediaUrl(url: item.id!)

    player = try AVAudioPlayer(contentsOf: audioPath!)

    player.volume = 0.5;

//    let overlayView = UIView(frame: CGRect(x: 50, y: 50, width: 200, height: 200))
//    overlayView.addSubview(UIImageView(image: UIImage(named: "tv-watermark")))
//
//    self.contentOverlayView?.addSubview(overlayView)

    //playerViewController?.contentOverlayView?.addSubview(overlayView)

//    let playerLayer=AVPlayerLayer(player: player!)
//    playerLayer.frame=CGRect(x:0, y:0, width:10, height:50)
//    self.view.layer.addSublayer(playerLayer)

    //if player?.prepareToPlay() != nil {
    player.prepareToPlay()
    player.play()
    //}
  }

  private func getMediaUrl(url: String) -> URL? {
    let link = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!

    if link != "" {
      return NSURL(string: link)! as URL
    }
    else {
      return nil
    }
  }
#endif

}
