import UIKit
import AVFoundation

#if os(iOS)

class AudioPlayer: NSObject {
  let defaultNotificationCenter = NotificationCenter.default

  var player: AVPlayer?
  var currentTrackIndex: Int=0

  open var currentItem: MediaItem? {
    guard currentTrackIndex >= 0 && currentTrackIndex < items.count else {
      return nil
    }

    return items[currentTrackIndex]
  }

  var playerUI: APController!
  var items: [MediaItem]!

  init(_ playerUI: APController, items: [MediaItem], selectedItemId: Int) {
    self.playerUI = playerUI
    self.items = items
    self.currentTrackIndex = selectedItemId
  }

  func newPlayer() -> AVPlayer? {
    var player: AVPlayer?

    let path = items[currentTrackIndex].id!

    if let audioPath = getMediaUrl(path: path) {
      let asset = AVAsset(url: audioPath)
      let playerItem = AVPlayerItem(asset: asset)

      if currentItem != nil {
        defaultNotificationCenter.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
      }

      defaultNotificationCenter.addObserver(self, selector: #selector(self.playerItemDidPlayToEnd(_:)),
        name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)

      player = AVPlayer(playerItem: playerItem)
    }

    return player
  }

  func play() {
    if player == nil {
      player = newPlayer()
    }

    playerUI.resetUI()

    player?.play()

    playerUI.playPauseButton.setImage(UIImage(named: "Pause"), for: .normal)
  }

  func seek(toSeconds seconds: Int) {
    player?.seek(to: CMTimeMake(Int64(seconds), 1))
  }

  func isPlaying() -> Bool {
    return player?.timeControlStatus == .playing
  }

  func togglePlayPause() {
    if let status = player?.timeControlStatus {
      switch status {
        case .waitingToPlayAtSpecifiedRate:
          play()

        case .playing:
          pause()

        case .paused:
          play()
      }
    }
    else {
      play()
    }
  }

  func pause() {
    player?.pause()

    playerUI.playPauseButton.setImage(UIImage(named: "Play"), for: .normal)
  }

  func replay() {
    playerUI.resetUI()

    pause()
    seek(toSeconds: 0)
    play()
  }

  func stop() {
    pause()

    player = nil

    playerUI.resetUI()

    playerUI.playPauseButton.setImage(UIImage(named: "Play"), for: .normal)
  }

  func playNext() {
    if currentTrackIndex < items.count-1 {
      stop()

      currentTrackIndex = currentTrackIndex+1

      playerUI.titleLabel.text = items[currentTrackIndex].name

      play()
    }
  }

  func playPrevious() {
    //    if let time = player.currentItem?.currentTime, time > 5.0 || player.playIndex == 0 {
//      player.replayCurrentItem()
//    }
    if currentTrackIndex > 0 {
      stop()

      currentTrackIndex = currentTrackIndex-1

      playerUI.titleLabel.text = items[currentTrackIndex].name

      play()
    }
    else {
      replay()
    }
  }

  func playerItemDidPlayToEnd(_ notification : Notification) {
    if currentTrackIndex >= items.count-1 {
      stop()
    }
    else {
      currentTrackIndex = currentTrackIndex + 1
      player = nil

      play()
    }
  }

  func changeVolume(_ volume: Float) {
    player?.volume = volume
  }

  // MARK: Progress tracking

//  var progressObserver: AnyObject!
//
//  fileprivate func startProgressTimer(){
//    guard let player = player , player.currentItem?.duration.isValid == true else {return}
//    progressObserver = player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(0.05, Int32(NSEC_PER_SEC)), queue: nil, using: { [unowned self] (time : CMTime) -> Void in
//      self.timerAction()
//    }) as AnyObject!
//  }
//
//  fileprivate func stopProgressTimer() {
//    guard let player = player, let observer = progressObserver else {
//      return
//    }
//    player.removeTimeObserver(observer)
//    progressObserver = nil
//  }

  func changePlayerPosition() {
//    if let duration = player.currentItem?.meta.duration {
//      player.seek(toSecond: Int(Double(playerUI.playbackSlider.value) * duration))
//    }
  }

//  func jukeboxStateDidChange(_ player: Jukebox) {
//    UIView.animate(withDuration: 0.3, animations: { [unowned self] () -> Void in
//      self.playerUI.indicator.alpha = self.player.state == .loading ? 1 : 0
//      self.playerUI.playPauseButton.alpha = self.player.state == .loading ? 0 : 1
//      self.playerUI.playPauseButton.isEnabled = self.player.state == .loading ? false : true
//    })
//
//    if player.state == .ready {
//      playerUI.playPauseButton.setImage(UIImage(named: "Play"), for: UIControlState())
//    }
//    else if player.state == .loading  {
//      playerUI.playPauseButton.setImage(UIImage(named: "Pause"), for: UIControlState())
//    }
//    else {
//      playerUI.volumeSlider.value = player.volume
//
//      let imageName: String
//
//      switch player.state {
//        case .playing, .loading:
//          imageName = "Pause"
//
//        case .paused, .failed, .ready:
//          imageName = "Play"
//      }
//
//      playerUI.playPauseButton.setImage(UIImage(named: imageName), for: UIControlState())
//    }
//
//    print("Jukebox state changed to \(player.state)")
//  }
//
//  func jukeboxPlaybackProgressDidChange(_ player: Jukebox) {
//    if let currentTime = player.currentItem?.currentTime, let duration = player.currentItem?.meta.duration {
//      let value = Float(currentTime / duration)
//      playerUI.playbackSlider.value = value
//      populateLabelWithTime(playerUI.currentTimeLabel, time: currentTime)
//      populateLabelWithTime(playerUI.durationLabel, time: duration)
//    }
//    else {
//      playerUI.resetUI()
//    }
//  }
//
//  func jukeboxDidLoadItem(_ player: Jukebox, item: JukeboxItem) {
//    print("Jukebox did load: \(item.URL.lastPathComponent)")
//  }
//
//  func jukeboxDidUpdateMetadata(_ player: Jukebox, forItem: JukeboxItem) {
//    print("Item updated:\n\(forItem)")
//  }

  func populateLabelWithTime(_ label : UILabel, time: Double) {
    let minutes = Int(time / 60)
    let seconds = Int(time) - minutes * 60

    label.text = String(format: "%02d", minutes) + ":" + String(format: "%02d", seconds)
  }

  private func getMediaUrl(path: String) -> URL? {
    let link = path.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!

    if link != "" {
      return NSURL(string: link)! as URL
    }
    else {
      return nil
    }
  }
}

#endif

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

    audioPlayer = AudioPlayer(self, items: items, selectedItemId: selectedItemId)

    configureUI()

    UIApplication.shared.beginReceivingRemoteControlEvents() // begin receiving remote events

    audioPlayer.play()
  }

  func configureUI () {
    title = parentName

    resetUI()

    titleLabel.text = items[selectedItemId].name

    playbackSlider.tintColor = UIColor.green

    //playbackSlider.setThumbImage(UIImage(named: "sliderThumb"), for: UIControlState())
  }

  override func viewWillDisappear(_ animated: Bool) {
    audioPlayer.stop()
  }

  @IBAction func volumeSliderValueChanged() {
    audioPlayer.changeVolume(volumeSlider.value)
  }

  @IBAction func playbackSliderValueChanged(_ sender: UISlider) {
//    let seconds : Int64 = Int64(playbackSlider.value)
//    let targetTime:CMTime = CMTimeMake(seconds, 1)
//
//    player!.seek(to: targetTime)
//
//    _ = play()

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

  @IBAction func stopAction() {
    audioPlayer.stop()
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
