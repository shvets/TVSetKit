import UIKit
import AVFoundation

class AudioPlayerController: UIViewController {
  static let SegueIdentifier = "Audio Player"

  var parentName: String!
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

  var audioPlayer = AudioPlayer.shared

  override func viewDidLoad() {
    super.viewDidLoad()

    addNotifications()

    if audioPlayer.name != parentName {
      audioPlayer.name = parentName
      audioPlayer.items = items
    }

    if audioPlayer.playbackHandler != nil {
      audioPlayer.playbackHandler = nil
    }
    audioPlayer.playbackHandler = playbackProgressDidChange

    let isAnotherTrack = (audioPlayer.currentTrackIndex != selectedItemId)
    let isNewPlayer = (audioPlayer.currentTrackIndex == -1)

    if isAnotherTrack {
      audioPlayer.currentTrackIndex = selectedItemId
    }

    title = parentName

    titleLabel.text = audioPlayer.currentMediaItem.name

    playbackSlider.tintColor = UIColor.green
    playbackSlider.setThumbImage(UIImage(named: "sliderThumb"), for: UIControlState())

    update()

    if isNewPlayer {
      play()
    }
    else if isAnotherTrack {
      stop()
      play()
    }
    else {
      audioPlayer.startProgressTimer()
      playPauseButton.setImage(UIImage(named: "Pause"), for: .normal)
      startAnimate()
      stopAnimate()
    }
  }

  func newPlayer() {
    audioPlayer.newPlayer()

    if let player = audioPlayer.player {
      let asset = player.currentItem?.asset

      startAnimate()

      asset?.loadValuesAsynchronously(forKeys: ["duration"], completionHandler: { () -> Void in
        DispatchQueue.main.async {
          self.stopAnimate()
        }
      })

      if let currentItem = player.currentItem {
        removeNotifications(currentItem)
      }
    }
  }

  func play() {
    if audioPlayer.player == nil {
      newPlayer()

      update()
    }

    audioPlayer.startProgressTimer()

    audioPlayer.play()

    playPauseButton.setImage(UIImage(named: "Pause"), for: .normal)
  }

  func pause() {
    audioPlayer.pause()

    audioPlayer.stopProgressTimer()

    playPauseButton.setImage(UIImage(named: "Play"), for: .normal)
  }

  func togglePlayPause() {
    if let status = audioPlayer.timeControlStatus {
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

  func replay() {
    update()

    pause()
    audioPlayer.seek(toSeconds: 0)
    play()
  }

  func stop() {
    pause()

    audioPlayer.stop()

    update()

    playPauseButton.setImage(UIImage(named: "Play"), for: .normal)
  }

  func playNext() {
    if audioPlayer.navigateToNextTrack() {
      stop()

      titleLabel.text = audioPlayer.currentMediaItem.name

      play()
    }
    else {
      replay()
    }
  }

  func playPrevious() {
    if audioPlayer.navigateToPreviousTrack() {
      stop()

      titleLabel.text = audioPlayer.currentMediaItem.name

      play()
    }
    else {
      replay()
    }
  }

  func scrollForward() {
    pause()

    let playerPosition = audioPlayer.getPlayerPosition(playbackSlider.value)

    audioPlayer.seek(toSeconds: playerPosition + 30)

    play()
  }

  func scrollBack() {
    pause()

    let playerPosition = audioPlayer.getPlayerPosition(playbackSlider.value)

    audioPlayer.seek(toSeconds: playerPosition - 15)

    play()
  }

  func handleAVPlayerItemDidPlayToEndTime(notification : Notification) {
    if audioPlayer.navigateToNextTrack() {
      stop()

      titleLabel.text = audioPlayer.currentMediaItem.name

      audioPlayer.reset()

      play()
    }
    else {
      stop()
    }
  }

  func handleAVPlayerItemPlaybackStalled() {
    pause()

    play()
  }

  func handleAVAudioSessionInterruption(_ notification : Notification) {
    guard let userInfo = notification.userInfo as? [String: AnyObject] else { return }

    guard let rawInterruptionType = userInfo[AVAudioSessionInterruptionTypeKey] as? NSNumber else { return }
    guard let interruptionType = AVAudioSessionInterruptionType(rawValue: rawInterruptionType.uintValue) else { return }

    switch interruptionType {
    case .began: //interruption started
      self.pause()

    case .ended: //interruption ended
      if let rawInterruptionOption = userInfo[AVAudioSessionInterruptionOptionKey] as? NSNumber {
        let interruptionOption = AVAudioSessionInterruptionOptions(rawValue: rawInterruptionOption.uintValue)
        if interruptionOption == AVAudioSessionInterruptionOptions.shouldResume {
          self.togglePlayPause()
        }
      }
    }
  }

  func changeVolume(_ volume: Float) {
    audioPlayer.changeVolume(volume)
  }

  func changePlayerPosition() {
    let playerPosition = audioPlayer.getPlayerPosition(playbackSlider.value)

    audioPlayer.seek(toSeconds: playerPosition)
  }

  func startAnimate() {
    UIView.animate(withDuration: 0.3, animations: { [unowned self] () -> Void in
      self.indicator.alpha = 1
      self.playPauseButton.alpha = 0
      self.playPauseButton.isEnabled = false
    })
  }

  func stopAnimate() {
    UIView.animate(withDuration: 0.3, animations: { [unowned self] () -> Void in
      self.indicator.alpha = 0
      self.playPauseButton.alpha = 1
      self.playPauseButton.isEnabled = true
    })
  }

  func playbackProgressDidChange() {
    if let playerItem = audioPlayer.player?.currentItem {
      let currentTime = playerItem.currentTime().seconds
      let duration = playerItem.asset.duration.seconds

      playbackSlider.value =  Float(currentTime / duration)

      currentTimeLabel.text = formatTime(currentTime)
      durationLabel.text = "-\(formatTime(duration-currentTime))"
    }
  }

  @IBAction func volumeSliderValueChanged() {
    changeVolume(volumeSlider.value)
  }

  @IBAction func playbackSliderValueChanged(_ sender: UISlider) {
    changePlayerPosition()
    play()
  }

  @IBAction func prevAction() {
    playPrevious()
  }

  @IBAction func nextAction() {
    playNext()
  }

  @IBAction func playPauseAction(_ sender: AnyObject) {
    togglePlayPause()
  }

  @IBAction func replayAction() {
    replay()
  }

  @IBAction func stopAction(_ sender: UIButton) {
    stop()
  }

  @IBAction func scrollBack(_ sender: UIButton) {
    scrollBack()
  }

  @IBAction func scrollForward(_ sender: UIButton) {
    scrollForward()
  }

  func update() {
    if let playerItem = audioPlayer.player?.currentItem {
      let currentTime = playerItem.currentTime().seconds
      let duration = playerItem.asset.duration.seconds

      playbackSlider.value =  Float(currentTime / duration)
      durationLabel.text = "-\(formatTime(duration-currentTime))"
      currentTimeLabel.text = formatTime(currentTime)
    }
    else {
      playbackSlider.value = 0
      durationLabel.text = "00:00"
      currentTimeLabel.text = "00:00"
    }
  }

  // MARK: Handle Notifications

  func addNotifications() {
    let notificationCenter = NotificationCenter.default

    notificationCenter.addObserver(self, selector: #selector(self.handleAVPlayerItemPlaybackStalled),
      name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: nil)

    notificationCenter.addObserver(self, selector: #selector(self.handleAVAudioSessionInterruption),
      name: NSNotification.Name.AVAudioSessionInterruption, object: AVAudioSession.sharedInstance())
  }

  func removeNotifications(_ object: Any) {
    let notificationCenter = NotificationCenter.default

    notificationCenter.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: object)

    notificationCenter.addObserver(self, selector: #selector(self.handleAVPlayerItemDidPlayToEndTime),
      name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: object)
  }

  private func getMinutes(_ time: Double) -> Int {
    return Int(time / 60)
  }

  private func getSeconds(_ time: Double) -> Int {
    return Int(time) - getMinutes(time) * 60
  }

  private func formatTime(_ time: Double) -> String {
    return String(format: "%02d", getMinutes(time)) + ":" + String(format: "%02d", getSeconds(time))
  }

#endif

}

extension AudioPlayerController {
  override func remoteControlReceived(with event: UIEvent?) {
    
#if os(iOS)
      
    if event?.type == .remoteControl {
      switch event!.subtype {
        case .remoteControlPlay:
          play()

        case .remoteControlPause:
          pause()

        case .remoteControlNextTrack:
          playNext()

        case .remoteControlPreviousTrack:
          playPrevious()

        case .remoteControlTogglePlayPause:
          togglePlayPause()

        default:
          break
      }
    }
    
#endif
  
  }
}
