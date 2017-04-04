import AVFoundation

#if os(iOS)

class AudioPlayer: NSObject {
  let notificationCenter = NotificationCenter.default
  let audioSession = AVAudioSession.sharedInstance()

  var player: AVPlayer?
  var backgroundIdentifier = UIBackgroundTaskInvalid
  var currentTrackIndex: Int=0

//  open var currentMediaItem: MediaItem? {
//    guard currentTrackIndex >= 0 && currentTrackIndex < items.count else {
//      return nil
//    }
//
//    return items[currentTrackIndex]
//  }
  var currentItem: AVPlayerItem?


  var playerUI: APController!
  var items: [MediaItem]!

  init(_ playerUI: APController, items: [MediaItem], selectedItemId: Int) throws {
    super.init()

    self.playerUI = playerUI
    self.items = items
    self.currentTrackIndex = selectedItemId

    try self.configure()
  }

  func configure() throws {
    try audioSession.setCategory(AVAudioSessionCategoryPlayback)
    try audioSession.setMode(AVAudioSessionModeDefault)
    try audioSession.setActive(true)

    notificationCenter.addObserver(self, selector: #selector(handleAVPlayerItemPlaybackStalled),
      name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: nil)

    notificationCenter.addObserver(self, selector: #selector(handleAVAudioSessionInterruption),
      name: NSNotification.Name.AVAudioSessionInterruption, object: AVAudioSession.sharedInstance())
  }

  func newPlayer() -> AVPlayer? {
    var player: AVPlayer?

    let path = items[currentTrackIndex].id!

    if let audioPath = getMediaUrl(path: path) {
      //let asset = AVAsset(url: audioPath)
      let asset = AVURLAsset(url: audioPath, options: nil)

      let playerItem = AVPlayerItem(asset: asset)

//      asset.loadValuesAsynchronously(forKeys: ["duration"], completionHandler: { () -> Void in
//        DispatchQueue.main.async {
//          print(asset)
//
////          let title = (playerItem.meta.title ?? playerItem.localTitle) ?? playerItem.URL.lastPathComponent
////          let currentTime = playerItem.currentTime ?? 0
////          let duration = playerItem.meta.duration ?? 0
//        }
//      })


      print(playerItem.asset.duration.seconds)
      print(playerItem.currentTime().seconds)

      if currentItem != nil {
        notificationCenter.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
      }

      notificationCenter.addObserver(self, selector: #selector(self.handleAVPlayerItemDidPlayToEndTime(_:)),
        name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)

      player = AVPlayer(playerItem: playerItem)

      startProgressTimer()
    }

    return player
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

  func play() {
    if player == nil {
      player = newPlayer()
    }

    playerUI.resetUI()

    backgroundIdentifier = UIApplication.shared.beginBackgroundTask (expirationHandler: { () -> Void in
      UIApplication.shared.endBackgroundTask(self.backgroundIdentifier)
      self.backgroundIdentifier = UIBackgroundTaskInvalid
    })

    player?.play()

    playerUI.playPauseButton.setImage(UIImage(named: "Pause"), for: .normal)
  }

  func pause() {
    player?.pause()
    stopProgressTimer()

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

    UIApplication.shared.endBackgroundTask(backgroundIdentifier)
    backgroundIdentifier = UIBackgroundTaskInvalid

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

  func handleAVPlayerItemDidPlayToEndTime(_ notification : Notification) {
    if currentTrackIndex >= items.count-1 {
      stop()
    }
    else {
      currentTrackIndex = currentTrackIndex + 1
      player = nil

      play()
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
    player?.volume = volume
  }

  // MARK: Progress tracking

  var progressObserver: AnyObject!

  func startProgressTimer() {
    guard let player = player,
          player.currentItem?.duration.isValid == true
    else {
      return
    }

    progressObserver = player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(0.05, Int32(NSEC_PER_SEC)), queue: nil, using: { [unowned self] (time : CMTime) -> Void in
      print("addPeriodicTimeObserver")
      //self.timerAction()
    }) as AnyObject!
  }

  func stopProgressTimer() {
    print("stopProgressTimer")

    guard let player = player,
          let observer = progressObserver
    else {
      return
    }

    player.removeTimeObserver(observer)
    progressObserver = nil
  }

  func changePlayerPosition() {
//    if let duration = currentItem?.asset.duration.seconds {
      //pause()

      //let seconds = Int(Double(playerUI.playbackSlider.value) * duration)

      let seconds = Int(playerUI.playbackSlider.value)
      //let targetTime: CMTime = CMTimeMake(seconds, 1)

      seek(toSeconds: seconds)

      play()
//    }
  }

//      let seconds : Int64 = Int64(playbackSlider.value)
//    let targetTime:CMTime = CMTimeMake(seconds, 1)
//
//    player!.seek(to: targetTime)
//
//    _ = play()



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
