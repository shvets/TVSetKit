import UIKit

class APController: UIViewController {
  static let SegueIdentifier = "Audio Player"

  var items: [MediaItem]!
  var selectedItemId: Int!
  var parentName: String!

#if os(iOS)
  @IBOutlet weak var playbackSlider: UISlider!
  @IBOutlet weak var playPauseButton: UIButton!
  @IBOutlet weak var replayButton: UIButton!
  @IBOutlet weak var stopButton: UIButton!
  @IBOutlet weak var currentTimeLabel: UILabel!
  @IBOutlet weak var durationLabel: UILabel!
  @IBOutlet weak var volumeSlider: UISlider!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var indicator: UIActivityIndicatorView!

  var audioPlayer: AudioPlayer!

  override func viewDidLoad() {
    super.viewDidLoad()

    do {
      audioPlayer = try AudioPlayer(self, items: items, selectedItemId: selectedItemId)

      configureUI()

      UIApplication.shared.beginReceivingRemoteControlEvents() // begin receiving remote events

      audioPlayer.play()
    }
    catch {
      print("Cannot instantiate audio player")
    }
  }

  func configureUI () {
    title = parentName

    resetUI()

    titleLabel.text = items[selectedItemId].name

    playbackSlider.tintColor = UIColor.green

    playbackSlider.setThumbImage(UIImage(named: "sliderThumb"), for: UIControlState())
  }

  override func viewWillDisappear(_ animated: Bool) {
    audioPlayer.stop()
  }

  @IBAction func volumeSliderValueChanged() {
    audioPlayer.changeVolume(volumeSlider.value)
  }

  @IBAction func playbackSliderValueChanged(_ sender: UISlider) {
    audioPlayer.changePlayerPosition()
  }

//  @IBAction func fastBackward(_ sender: AnyObject) {
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
//  }

//  @IBAction func fastForward(_ sender: AnyObject) {
//    var time: TimeInterval = player.currentTime
//    time += 5.0 // Go forward by 5 seconds
//
//    if time > player.duration {
//      stop(self)
//    }
//    else {
//      player.currentTime = time
//    }
//  }

  @IBAction func prevAction() {
    audioPlayer.playPrevious()
  }

  @IBAction func nextAction() {
    audioPlayer.playNext()
  }

  @IBAction func playPauseAction(_ sender: AnyObject) {
    audioPlayer.togglePlayPause()
  }

  @IBAction func replayAction() {
    audioPlayer.replay()
  }

  @IBAction func stopAction(_ sender: UIButton) {
    audioPlayer.stop()
  }

  @IBAction func tapeBack(_ sender: UIButton) {
    audioPlayer.tapeBack()
  }

  @IBAction func tapeForward(_ sender: UIButton) {
    audioPlayer.tapeForward()
  }

  func resetUI() {
    durationLabel.text = "00:00"
    currentTimeLabel.text = "00:00"
    playbackSlider.value = 0
  }

#endif

}

extension APController {
  override func remoteControlReceived(with event: UIEvent?) {
    
#if os(iOS)
      
    if event?.type == .remoteControl {
      switch event!.subtype {
        case .remoteControlPlay:
          audioPlayer.play()

        case .remoteControlPause:
          audioPlayer.pause()

        case .remoteControlNextTrack:
          audioPlayer.playNext()

        case .remoteControlPreviousTrack:
          audioPlayer.playPrevious()

        case .remoteControlTogglePlayPause:
          audioPlayer.togglePlayPause()

        default:
          break
      }
    }
    
#endif
  
  }
}
