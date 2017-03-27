import UIKit
import AVFoundation

#if os(iOS)

class JukeboxPlayer: JukeboxDelegate {
  var jukebox : Jukebox!

  var audioPlayerUI: AudioPlayer!

  init(_ audioPlayerUI: AudioPlayer, items: [MediaItem]) {
    self.audioPlayerUI = audioPlayerUI

    var playerItems: [JukeboxItem] = []

    for item in items {
      if let url = getMediaUrl(url: item.id!) {
        playerItems.append(JukeboxItem(URL: url))
      }
    }
    
    jukebox = Jukebox(delegate: self, items: playerItems)!
  }
  func play() {
    audioPlayerUI.resetUI()

    jukebox.play()

    audioPlayerUI.playPauseButton.setImage(UIImage(named: "Pause"), for: .normal)
  }

  func playAt(index: Int) {
    audioPlayerUI.resetUI()

    jukebox.play(atIndex: index)

    audioPlayerUI.playPauseButton.setImage(UIImage(named: "Pause"), for: .normal)
  }

  func playFromStart() {
    audioPlayerUI.resetUI()

    jukebox.play(atIndex: 0)

    audioPlayerUI.playPauseButton.setImage(UIImage(named: "Pause"), for: .normal)
  }

  func pause() {
    jukebox.pause()

    audioPlayerUI.playPauseButton.setImage(UIImage(named: "Play"), for: .normal)
  }

  func replay() {
    audioPlayerUI.resetUI()

    jukebox.replay()
  }

  func stop() {
    jukebox.stop()

    audioPlayerUI.resetUI()
  }

  func playNext() {
    //audioPlayerUI.resetUI()

    jukebox.playNext()
  }

  func playPrevious() {
    //audioPlayerUI.resetUI()

    jukebox.playPrevious()
  }

  func jukeboxStateDidChange(_ player: Jukebox) {
    UIView.animate(withDuration: 0.3, animations: { [unowned self] () -> Void in
      self.audioPlayerUI.indicator.alpha = self.jukebox.state == .loading ? 1 : 0
      self.audioPlayerUI.playPauseButton.alpha = self.jukebox.state == .loading ? 0 : 1
      self.audioPlayerUI.playPauseButton.isEnabled = self.jukebox.state == .loading ? false : true
    })

    if player.state == .ready {
      audioPlayerUI.playPauseButton.setImage(UIImage(named: "Play"), for: UIControlState())
    }
    else if player.state == .loading  {
      audioPlayerUI.playPauseButton.setImage(UIImage(named: "Pause"), for: UIControlState())
    }
    else {
      audioPlayerUI.volumeSlider.value = player.volume

      let imageName: String

      switch player.state {
        case .playing, .loading:
          imageName = "Pause"

        case .paused, .failed, .ready:
          imageName = "Play"
      }

      audioPlayerUI.playPauseButton.setImage(UIImage(named: imageName), for: UIControlState())
    }

    print("Jukebox state changed to \(player.state)")
  }

  func jukeboxPlaybackProgressDidChange(_ player: Jukebox) {
    if let currentTime = player.currentItem?.currentTime, let duration = player.currentItem?.meta.duration {
      let value = Float(currentTime / duration)
      audioPlayerUI.playbackSlider.value = value
      populateLabelWithTime(audioPlayerUI.currentTimeLabel, time: currentTime)
      populateLabelWithTime(audioPlayerUI.durationLabel, time: duration)
    }
    else {
      audioPlayerUI.resetUI()
    }
  }

  func jukeboxDidLoadItem(_ player: Jukebox, item: JukeboxItem) {
    print("Jukebox did load: \(item.URL.lastPathComponent)")
  }

  func jukeboxDidUpdateMetadata(_ player: Jukebox, forItem: JukeboxItem) {
    print("Item updated:\n\(forItem)")
  }

  func populateLabelWithTime(_ label : UILabel, time: Double) {
    let minutes = Int(time / 60)
    let seconds = Int(time) - minutes * 60

    label.text = String(format: "%02d", minutes) + ":" + String(format: "%02d", seconds)
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
}

#endif

class AudioPlayer: UIViewController {
  static let SegueIdentifier = "Audio Player"
  
  var items: [MediaItem]!
  var selectedItemId: Int!

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
  
  var jukeboxPlayer: JukeboxPlayer!

  override func viewDidLoad() {
    super.viewDidLoad()

    jukeboxPlayer = JukeboxPlayer(self, items: items)

    configureUI()

    playPauseButton.setImage(UIImage(named: "Pause"), for: .normal)

    let item = items[selectedItemId]

    title = item.name
    titleLabel.text = item.name

    //if let audioPath = getMediaUrl(url: item.id!) {

    // begin receiving remote events
    UIApplication.shared.beginReceivingRemoteControlEvents()

//    var playerItems: [JukeboxItem] = []
//
//    for item in items {
//      if let url = getMediaUrl(url: item.id!) {
//        playerItems.append(JukeboxItem(URL: url))
//      }
//    }

    //player = Jukebox(delegate: jukeboxPlayer, items: playerItems)!

    _ = jukeboxPlayer.playAt(index: selectedItemId)
    //}
  }

  func configureUI () {
    resetUI()

    let color = UIColor(red:0.84, green:0.09, blue:0.1, alpha:1)
    //indicator.color = color

    //playbackSlider.minimumValue = 0

//      let duration : CMTime = playerItem.asset.duration
//      let seconds : Float64 = CMTimeGetSeconds(duration)
//
//      playbackSlider.maximumValue = Float(seconds)
//      playbackSlider.isContinuous = true
    playbackSlider.tintColor = UIColor.green

    //playbackSlider.setThumbImage(UIImage(named: "sliderThumb"), for: UIControlState())
  }

  override func viewWillDisappear(_ animated: Bool) {
    jukeboxPlayer.stop()
  }

  @IBAction func volumeSliderValueChanged() {
    if let player = jukeboxPlayer.jukebox {
      player.volume = volumeSlider.value
    }
  }

  @IBAction func playbackSliderValueChanged(_ sender: UISlider) {
//    let seconds : Int64 = Int64(playbackSlider.value)
//    let targetTime:CMTime = CMTimeMake(seconds, 1)
//
//    player!.seek(to: targetTime)
//
//    _ = play()

    if let duration = jukeboxPlayer.jukebox.currentItem?.meta.duration {
      jukeboxPlayer.jukebox.seek(toSecond: Int(Double(playbackSlider.value) * duration))
    }
  }

//  @IBAction func fastBackward(_ sender: AnyObject) {
////    var time: TimeInterval = player.currentTime
////
////    time -= 5.0 // Go back by 5 seconds
////
////    if time < 0 {
////      stop(self)
////    }
////    else {
////      player.currentTime = time
////    }
//  }

  @IBAction func prevAction() {
    if let time = jukeboxPlayer.jukebox.currentItem?.currentTime, time > 5.0 || jukeboxPlayer.jukebox.playIndex == 0 {
      jukeboxPlayer.jukebox.replayCurrentItem()
    }
    else {
      if selectedItemId > 0 {
        selectedItemId = selectedItemId-1

        titleLabel.text = items[selectedItemId].name
      }

      jukeboxPlayer.playPrevious()
    }
  }

  @IBAction func nextAction() {
    if selectedItemId < items.count-1 {
      selectedItemId = selectedItemId+1

      titleLabel.text = items[selectedItemId].name
    }

    jukeboxPlayer.playNext()
  }

  @IBAction func playPauseAction(_ sender: AnyObject) {
    switch jukeboxPlayer.jukebox.state {
    case .ready:
      jukeboxPlayer.playFromStart()

    case .playing:
      jukeboxPlayer.pause()

    case .paused:
      jukeboxPlayer.play()

    default:
      jukeboxPlayer.jukebox.stop()
    }
  }

  @IBAction func replayAction() {
    jukeboxPlayer.replay()
  }

  @IBAction func stopAction() {
    jukeboxPlayer.stop()
  }

//  @IBAction func fastForward(_ sender: AnyObject) {
////    var time: TimeInterval = player.currentTime
////    time += 5.0 // Go forward by 5 seconds
////
////    if time > player.duration {
////      stop(self)
////    }
////    else {
////      player.currentTime = time
////    }
//  }

  func resetUI() {
    durationLabel.text = "00:00"
    currentTimeLabel.text = "00:00"
    playbackSlider.value = 0
  }

  override func remoteControlReceived(with event: UIEvent?) {
    if event?.type == .remoteControl {
      switch event!.subtype {
        case .remoteControlPlay:
          jukeboxPlayer.play()
  
        case .remoteControlPause:
          jukeboxPlayer.pause()
  
        case .remoteControlNextTrack:
          jukeboxPlayer.playNext()
  
        case .remoteControlPreviousTrack:
          jukeboxPlayer.playPrevious()
  
        case .remoteControlTogglePlayPause:
          if jukeboxPlayer.jukebox.state == .playing {
            jukeboxPlayer.pause()
          }
          else {
            jukeboxPlayer.play()
          }
  
        default:
          break
      }
    }
  }

#endif

}
