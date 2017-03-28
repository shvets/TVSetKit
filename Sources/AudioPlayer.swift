import UIKit
import AVFoundation

#if os(iOS)

class JukeboxPlayer: JukeboxDelegate {
  var player : Jukebox!
  var playerUI: AudioPlayer!

  var items: [MediaItem]!
  var selectedItemId: Int!

  init(_ playerUI: AudioPlayer, items: [MediaItem], selectedItemId: Int) {
    self.playerUI = playerUI
    self.selectedItemId = selectedItemId

    var playerItems: [JukeboxItem] = []

    for item in items {
      if let url = getMediaUrl(url: item.id!) {
        playerItems.append(JukeboxItem(URL: url))
      }
    }

    player = Jukebox(delegate: self, items: playerItems)!
  }

  func isPlaying() -> Bool {
    return player.state == .playing
  }

  func play() {
    playerUI.resetUI()

    player.play()

    playerUI.playPauseButton.setImage(UIImage(named: "Pause"), for: .normal)
  }

  func playPause() {
    switch player.state {
      case .ready:
        playFromStart()

      case .playing:
        pause()

      case .paused:
        play()

      default:
        stop()
    }
  }

  func playAt(index: Int) {
    playerUI.resetUI()

    player.play(atIndex: index)

    playerUI.playPauseButton.setImage(UIImage(named: "Pause"), for: .normal)
  }

  func playFromStart() {
    playerUI.resetUI()

    player.play(atIndex: 0)

    playerUI.playPauseButton.setImage(UIImage(named: "Pause"), for: .normal)
  }

  func pause() {
    player.pause()

    playerUI.playPauseButton.setImage(UIImage(named: "Play"), for: .normal)
  }

  func replay() {
    playerUI.resetUI()

    player.replay()
  }

  func stop() {
    player.stop()

    playerUI.resetUI()
  }

  func playNext() {
    if selectedItemId < items.count-1 {
      selectedItemId = selectedItemId+1

      playerUI.titleLabel.text = items[selectedItemId].name

      player.playNext()
    }
  }

  func playPrevious() {
    if let time = player.currentItem?.currentTime, time > 5.0 || player.playIndex == 0 {
      player.replayCurrentItem()
    }
    else {
      if selectedItemId > 0 {
        selectedItemId = selectedItemId-1

        playerUI.titleLabel.text = items[selectedItemId].name
      }

      player.playPrevious()
    }
  }

  func changeVolume(_ volume: Float) {
    player.volume = volume
  }

  func changePlayerPosition() {
    if let duration = player.currentItem?.meta.duration {
      player.seek(toSecond: Int(Double(playerUI.playbackSlider.value) * duration))
    }
  }

  func jukeboxStateDidChange(_ player: Jukebox) {
    UIView.animate(withDuration: 0.3, animations: { [unowned self] () -> Void in
      self.playerUI.indicator.alpha = self.player.state == .loading ? 1 : 0
      self.playerUI.playPauseButton.alpha = self.player.state == .loading ? 0 : 1
      self.playerUI.playPauseButton.isEnabled = self.player.state == .loading ? false : true
    })

    if player.state == .ready {
      playerUI.playPauseButton.setImage(UIImage(named: "Play"), for: UIControlState())
    }
    else if player.state == .loading  {
      playerUI.playPauseButton.setImage(UIImage(named: "Pause"), for: UIControlState())
    }
    else {
      playerUI.volumeSlider.value = player.volume

      let imageName: String

      switch player.state {
        case .playing, .loading:
          imageName = "Pause"

        case .paused, .failed, .ready:
          imageName = "Play"
      }

      playerUI.playPauseButton.setImage(UIImage(named: imageName), for: UIControlState())
    }

    print("Jukebox state changed to \(player.state)")
  }

  func jukeboxPlaybackProgressDidChange(_ player: Jukebox) {
    if let currentTime = player.currentItem?.currentTime, let duration = player.currentItem?.meta.duration {
      let value = Float(currentTime / duration)
      playerUI.playbackSlider.value = value
      populateLabelWithTime(playerUI.currentTimeLabel, time: currentTime)
      populateLabelWithTime(playerUI.durationLabel, time: duration)
    }
    else {
      playerUI.resetUI()
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

    jukeboxPlayer = JukeboxPlayer(self, items: items, selectedItemId: selectedItemId)

    configureUI()

    UIApplication.shared.beginReceivingRemoteControlEvents() // begin receiving remote events

    _ = jukeboxPlayer.playAt(index: selectedItemId)
  }

  func configureUI () {
    resetUI()

    let item = items[selectedItemId]

    title = item.name
    titleLabel.text = item.name

    playbackSlider.tintColor = UIColor.green

    //playbackSlider.setThumbImage(UIImage(named: "sliderThumb"), for: UIControlState())

    playPauseButton.setImage(UIImage(named: "Pause"), for: .normal)
  }

  override func viewWillDisappear(_ animated: Bool) {
    jukeboxPlayer.stop()
  }

  @IBAction func volumeSliderValueChanged() {
    jukeboxPlayer.changeVolume(volumeSlider.value)
  }

  @IBAction func playbackSliderValueChanged(_ sender: UISlider) {
//    let seconds : Int64 = Int64(playbackSlider.value)
//    let targetTime:CMTime = CMTimeMake(seconds, 1)
//
//    player!.seek(to: targetTime)
//
//    _ = play()

    jukeboxPlayer.changePlayerPosition()
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
    jukeboxPlayer.playPrevious()
  }

  @IBAction func nextAction() {
    jukeboxPlayer.playNext()
  }

  @IBAction func playPauseAction(_ sender: AnyObject) {
    jukeboxPlayer.playPause()
  }

  @IBAction func replayAction() {
    jukeboxPlayer.replay()
  }

  @IBAction func stopAction() {
    jukeboxPlayer.stop()
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
        jukeboxPlayer.playPause()

      default:
        break
      }
    }
  }

  func resetUI() {
    durationLabel.text = "00:00"
    currentTimeLabel.text = "00:00"
    playbackSlider.value = 0
  }

#endif

}
