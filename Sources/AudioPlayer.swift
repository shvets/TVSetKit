import UIKit
import AVFoundation

class AudioPlayer: UIViewController {
  static let SegueIdentifier = "Audio Player"

  var items: [MediaItem]!
  var selectedItemId: Int!
  
#if os(iOS)

  var player: AVPlayer!

  @IBOutlet weak var playbackSlider: UISlider!
  @IBOutlet weak var trackDescription: UITextView!
  @IBOutlet weak var playButton: UIButton!

  override func viewDidLoad() {
    super.viewDidLoad()

    let item = items[selectedItemId]

    title = item.name

    if let audioPath = getMediaUrl(url: item.id!) {
      let asset = AVAsset(url: audioPath)

      let playerItem = AVPlayerItem(asset: asset)

      player = AVPlayer(playerItem: playerItem)
      player.volume = 0.5;

      playbackSlider.minimumValue = 0

      let duration : CMTime = playerItem.asset.duration
      let seconds : Float64 = CMTimeGetSeconds(duration)

      playbackSlider.maximumValue = Float(seconds)
      playbackSlider.isContinuous = true
      playbackSlider.tintColor = UIColor.green

      _ = play()
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
//    player.stop()
  }

  @IBAction func playbackSliderValueChanged(_ sender: UISlider) {
    let seconds : Int64 = Int64(playbackSlider.value)
    let targetTime:CMTime = CMTimeMake(seconds, 1)

    player!.seek(to: targetTime)

    _ = play()
  }

  @IBAction func fastBackward(_ sender: AnyObject) {
//    var time: TimeInterval = player.currentTime
//
//    time -= 5.0 // Go back by 5 seconds
//
//    if time < 0 {
//      stop(self)
//    }
//    else {
//      player.currentTime = time
//    }
  }


  @IBAction func onPlayButtonClick(_ sender: AnyObject) {
    if !play() {
      pause()
    }
  }

  @IBAction func fastForward(_ sender: AnyObject) {
//    var time: TimeInterval = player.currentTime
//    time += 5.0 // Go forward by 5 seconds
//
//    if time > player.duration {
//      stop(self)
//    }
//    else {
//      player.currentTime = time
//    }
  }

  func play() -> Bool {
    if player!.rate == 0 {
      player.play()

      playButton.setImage(UIImage(named: "Pause"), for: .normal)

      return true
    }
    else {
      return false
    }
  }

  func pause() {
    player!.pause()

    playButton.setImage(UIImage(named: "Play"), for: .normal)
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
