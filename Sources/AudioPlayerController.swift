import UIKit
import AVFoundation
import MediaPlayer

class AudioPlayerController: UIViewController {
  static let SegueIdentifier = "Audio Player"

  var parentName: String!
  var coverImageUrl: String!
  var bookId: String!
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

    if audioPlayer.playbackHandler != nil {
      audioPlayer.playbackHandler = nil
    }
    audioPlayer.playbackHandler = playbackProgressDidChange

    handleRemoteCenter()

    audioPlayer.items = items

    let isAnotherBook = audioPlayer.currentBookId != bookId
    let isAnotherTrack = audioPlayer.currentTrackIndex != selectedItemId
    let isNewPlayer = audioPlayer.currentTrackIndex == -1

    if isAnotherBook {
      audioPlayer.currentBookId = bookId
    }

    audioPlayer.currentTrackIndex = selectedItemId

    if isAnotherBook || isAnotherTrack {
      audioPlayer.currentTrackIndex = selectedItemId
      audioPlayer.currentSongPosition = -1
    }

    audioPlayer.save()

    title = parentName

    titleLabel.text = audioPlayer.currentMediaItem.name

    playbackSlider.tintColor = UIColor.green
    playbackSlider.setThumbImage(UIImage(named: "sliderThumb"), for: UIControlState())

    update()

    if audioPlayer.player.timeControlStatus == .playing {
      audioPlayer.status = .playing
    }

    if isNewPlayer {
      createNewPlayer()
      play()
    }
    else if !isAnotherBook && isAnotherTrack {
      stop()

      createNewPlayer()
      play()
    }
    else if isAnotherBook {
      stop()

      createNewPlayer()
      play()
    }
    else {
      if audioPlayer.status == .ready {
        let currentSongPosition = audioPlayer.currentSongPosition

        createNewPlayer()

        var seconds = getPlayedSeconds(currentSongPosition)

        if seconds > 5 {
          seconds = seconds - 5
        }

        audioPlayer.seek(toSeconds: seconds)

        update()

        play()
      }
      else if audioPlayer.status == .paused {
        startAnimate()
        stopAnimate()
        audioPlayer.startProgressTimer()
        playPauseButton.setImage(UIImage(named: "Play"), for: .normal)
      }
      else {
        startAnimate()
        stopAnimate()
        audioPlayer.startProgressTimer()
        playPauseButton.setImage(UIImage(named: "Pause"), for: .normal)
      }
    }
  }

  func getPlayedSeconds(_ songPosition: Float) -> Int {
    var seconds = 0

    if songPosition != -1 {
      seconds = audioPlayer.getPlayerPosition(songPosition)
    }

    return seconds
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    audioPlayer.save()
  }

  func createNewPlayer(toSeconds: Int=0) {
    audioPlayer.newPlayer()

    let asset = audioPlayer.player.currentItem?.asset

    startAnimate()

    audioPlayer.status = AudioPlayer.Status.loading

    asset?.loadValuesAsynchronously(forKeys: ["duration"], completionHandler: { () -> Void in
      DispatchQueue.main.async { [unowned self] in
        self.stopAnimate()

        self.updateNowPlayingInfoCenter()

        self.audioPlayer.status = AudioPlayer.Status.ready
      }
    })

    if let currentItem = audioPlayer.player.currentItem {
      removeNotifications(currentItem)
    }

    audioPlayer.seek(toSeconds: toSeconds)

    update()
  }

  func play() {
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
    let status = audioPlayer.player.timeControlStatus

    switch status {
      case .waitingToPlayAtSpecifiedRate:
        play()

      case .playing:
        pause()

      case .paused:
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

      createNewPlayer()
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

      createNewPlayer()
      play()
    }
    else {
      replay()
    }
  }

  func skipBackward() {
    pause()

    let playerPosition = audioPlayer.getPlayerPosition(playbackSlider.value)

    audioPlayer.seek(toSeconds: playerPosition - 15)

    play()
  }

  func skipForward() {
    pause()

    let playerPosition = audioPlayer.getPlayerPosition(playbackSlider.value)

    audioPlayer.seek(toSeconds: playerPosition + 15)

    play()
  }

  func handleAVPlayerItemDidPlayToEndTime(notification : Notification) {
    audioPlayer.save()

    if audioPlayer.navigateToNextTrack() {
      stop()

      titleLabel.text = audioPlayer.currentMediaItem.name

      audioPlayer.reset()

      createNewPlayer()
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

  @discardableResult func playbackProgressDidChange() -> Float {
    if let playerItem = audioPlayer.player.currentItem {
      let currentTime = playerItem.currentTime().seconds
      let duration = playerItem.asset.duration.seconds

      playbackSlider.value =  Float(currentTime / duration)

      currentTimeLabel.text = formatTime(currentTime)

      let sign = (duration-currentTime == 0) ? "" : "-"

      durationLabel.text = "\(sign)\(formatTime(duration-currentTime))"

      updateNowPlayingInfoCenter()
    }

    return playbackSlider.value
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

  @IBAction func skipBackward(_ sender: UIButton) {
    skipBackward()
  }

  @IBAction func skipForward(_ sender: UIButton) {
    skipForward()
  }

  func update() {
    if let playerItem = audioPlayer.player.currentItem {
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

#if os(iOS)

extension AudioPlayerController {
  // MARK: MPNowPlayingInfoCenter

  func updateNowPlayingInfoCenter() {
    if NSClassFromString("MPNowPlayingInfoCenter") != nil {
      let defaultNowPlayingInfoCenter = MPNowPlayingInfoCenter.default()

      if let currentItem = audioPlayer.player.currentItem {
        let title = audioPlayer.currentMediaItem.name
        let currentTime = currentItem.currentTime().seconds
        let duration = currentItem.asset.duration.seconds

        let trackNumber = audioPlayer.currentTrackIndex
        let trackCount = audioPlayer.items.count

        var nowPlayingInfo: [String: AnyObject] = [
          MPNowPlayingInfoPropertyPlaybackRate: 1.0 as AnyObject,
          MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime as AnyObject,
          MPMediaItemPropertyPlaybackDuration: duration as AnyObject,
          MPMediaItemPropertyTitle: title as AnyObject,
          MPNowPlayingInfoPropertyPlaybackQueueCount: trackCount as AnyObject,
          MPNowPlayingInfoPropertyPlaybackQueueIndex: trackNumber as AnyObject
        ]

        nowPlayingInfo[MPMediaItemPropertyMediaType] = MPMediaType.anyAudio.rawValue as AnyObject

        // If is a live broadcast, you can set a newest property (iOS 10+): MPNowPlayingInfoPropertyIsLiveStream indicating that is a live broadcast
//        if #available(iOS 10.0, *) {
//          nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = true as AnyObject
//        }

//      if let artist = item.meta.artist {
//        nowPlayingInfo[MPMediaItemPropertyArtist] = artist as AnyObject?
//      }
//
//      if let album = item.meta.album {
//        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = album as AnyObject?
//      }

        if let url = NSURL(string: coverImageUrl),
           let data = NSData(contentsOf: url as URL),
           let image = UIImage(data: data as Data) {
          nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: image)
        }

        defaultNowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
      }
    }
  }

}

extension AudioPlayerController {
  // MARK: MPRemoteCommandCenter

  func handleRemoteCenter() {
    if #available(iOS 9.1, *) {
      let rcc = MPRemoteCommandCenter.shared()

      rcc.togglePlayPauseCommand.removeTarget(nil)
      rcc.playCommand.removeTarget(nil)
      rcc.pauseCommand.removeTarget(nil)

//      rcc.skipBackwardCommand.removeTarget(nil)
//      rcc.skipForwardCommand.removeTarget(nil)

      rcc.previousTrackCommand.removeTarget(nil)
      rcc.nextTrackCommand.removeTarget(nil)

      rcc.togglePlayPauseCommand.addTarget(self, action: #selector(self.doPlayPause))
      rcc.playCommand.addTarget(self, action:#selector(self.doPlayPause))
      rcc.pauseCommand.addTarget(self, action:#selector(self.doPlayPause))

//      rcc.skipBackwardCommand.addTarget(self, action:#selector(doSkipBackward))
//      rcc.skipForwardCommand.addTarget(self, action:#selector(doSkipForward))

      rcc.previousTrackCommand.addTarget(self, action:#selector(self.doPreviousTrack))
      rcc.nextTrackCommand.addTarget(self, action:#selector(self.doNextTrack))

      rcc.changePlaybackPositionCommand.addTarget(self, action:#selector(self.doPlaybackSliderValueChanged))

      //delay(1) { // we somehow get disabled after removing our player v.c.
        //rcc.togglePlayPauseCommand.isEnabled = true
        rcc.playCommand.isEnabled = true
        rcc.pauseCommand.isEnabled = true

//        rcc.skipBackwardCommand.isEnabled = true
//        rcc.skipForwardCommand.isEnabled = true

        rcc.previousTrackCommand.isEnabled = true
        rcc.nextTrackCommand.isEnabled = true
      //}
    }
  }

  func delay(_ delay: Double, closure: @escaping () -> ()) {
    let when = DispatchTime.now() + delay

    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
  }

  func doPlayPause(_ event:MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
    playPauseAction(self)

    return .success
  }

  func doPlay(_ event:MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
    playPauseAction(self)

    return .success
  }
  func doPause(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
    playPauseAction(self)

    return .success
  }

  func doSkipBackward(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
    skipBackward()

    return .success
  }

  func doSkipForward(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
    skipForward()

    return .success
  }

  func doPreviousTrack(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
    prevAction()

    return .success
  }

  func doNextTrack(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
    nextAction()

    return .success
  }

  func doPlaybackSliderValueChanged(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
    if let playbackEvent = event as? MPChangePlaybackPositionCommandEvent {
      audioPlayer.seek(toSeconds: Int(playbackEvent.positionTime))

      playbackProgressDidChange()
    }

    return .success
  }
}

#endif
