import AVFoundation

#if os(iOS)

class AudioPlayer: NSObject {
  let audioSession = AVAudioSession.sharedInstance()

  var timeObserver: AnyObject!
  let notificationCenter = NotificationCenter.default

  var player: AVPlayer?
  var currentTrackIndex: Int=0

  var timeControlStatus: AVPlayerTimeControlStatus? {
    return player?.timeControlStatus
  }

  var currentMediaItem: MediaItem {
    return items[currentTrackIndex]
  }

  var playbackHandler: (() -> Void)?

  var items: [MediaItem]!
  var selectedItemId: Int

  init(_ items: [MediaItem], selectedItemId: Int) throws {
    self.items = items
    self.selectedItemId = selectedItemId

    currentTrackIndex = selectedItemId

    super.init()

    try self.configure()
  }

  deinit {
    if let observer = timeObserver {
      player?.removeTimeObserver(observer)
    }
  }

  func configure() throws {
    try audioSession.setCategory(AVAudioSessionCategoryPlayback)
    try audioSession.setMode(AVAudioSessionModeDefault)
    try audioSession.setActive(true)

    UIApplication.shared.beginReceivingRemoteControlEvents() // begin receiving remote events
  }

  func newPlayer() {
    let path = items[currentTrackIndex].id!

    if let audioPath = getMediaUrl(path: path) {
      let asset = AVURLAsset(url: audioPath, options: nil)

      let playerItem = AVPlayerItem(asset: asset)

      player = AVPlayer(playerItem: playerItem)

      startBackgroundTask()
    }
    else {
      reset()
    }
  }

  func seek(toSeconds seconds: Int) {
    player?.seek(to: CMTimeMake(Int64(seconds), 1))
  }

  func isPlaying() -> Bool {
    return player?.timeControlStatus == .playing
  }

  func play() {
    player?.play()
  }

  func pause() {
    player?.pause()
  }

  func stop() {
    reset()

    stopBackgroundTask()
  }

  func reset() {
    player = nil
  }

  func changeVolume(_ volume: Float) {
    player?.volume = volume
  }

  func getPlayerPosition(_ value: Float) -> Int {
    let duration = player?.currentItem?.asset.duration.seconds
    let requestedTime = Double(value)

    return Int(requestedTime * duration!)
  }

  func previousTrack() {
    currentTrackIndex = currentTrackIndex-1
  }

  func nextTrack() {
    currentTrackIndex = currentTrackIndex+1
  }

  func navigateToNextTrack() -> Bool {
    if currentTrackIndex < items.count-1 {
      currentTrackIndex = currentTrackIndex+1

      return true
    }

    return false
  }

  func navigateToPreviousTrack() -> Bool {
    if currentTrackIndex > 0 {
      currentTrackIndex = currentTrackIndex-1

      return true
    }

    return false
  }

  // MARK: Progress tracking

  func startProgressTimer() {
    if let playbackHandler = playbackHandler {
      if player?.currentItem?.duration.isValid == true {
        let timeInterval: CMTime = CMTimeMakeWithSeconds(1.0, 10)

        timeObserver = player?.addPeriodicTimeObserver(forInterval: timeInterval,
          queue: DispatchQueue.main) { (elapsedTime: CMTime) -> Void in

          playbackHandler()
        } as AnyObject
      }
    }
  }

  func stopProgressTimer() {
    if let observer = timeObserver {
      player?.removeTimeObserver(observer)

      timeObserver = nil
    }
  }

  // MARK: Background task

  var backgroundIdentifier = UIBackgroundTaskInvalid

  func startBackgroundTask() {
    backgroundIdentifier = UIApplication.shared.beginBackgroundTask (expirationHandler: { () -> Void in
      UIApplication.shared.endBackgroundTask(self.backgroundIdentifier)
      self.backgroundIdentifier = UIBackgroundTaskInvalid
    })
  }

  func stopBackgroundTask() {
    UIApplication.shared.endBackgroundTask(backgroundIdentifier)
    backgroundIdentifier = UIBackgroundTaskInvalid
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
