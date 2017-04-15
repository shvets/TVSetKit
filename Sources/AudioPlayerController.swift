import UIKit
import AVFoundation
import MediaPlayer

class AudioPlayerController: UIViewController, AudioPlayerUI {
  static let SegueIdentifier = "Audio Player"

  var parentName: String!
  var coverImageUrl: String!
  var items: [MediaItem]!
  var selectedBookId: String!
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

    title = parentName

    playbackSlider.tintColor = UIColor.green
    playbackSlider.setThumbImage(UIImage(named: "sliderThumb"), for: UIControlState())

    audioPlayer.ui = self

    audioPlayer.coverImageUrl = coverImageUrl

    audioPlayer.authorName = getAuthorName(parentName)
    audioPlayer.bookName = getBookName(parentName)

    audioPlayer.items = items
    audioPlayer.selectedBookId = selectedBookId
    audioPlayer.selectedItemId = selectedItemId

    audioPlayer.setupPlayer()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    audioPlayer.save()
  }

  @IBAction func volumeSliderValueChanged() {
    audioPlayer.changeVolume(volumeSlider.value)
  }

  @IBAction func playbackSliderValueChanged(_ sender: UISlider) {
    audioPlayer.changePlayerPosition(value: getPlayerValue())
    audioPlayer.play()
  }

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

  @IBAction func skipBackward(_ sender: UIButton) {
    audioPlayer.skipBackward(getPlayerValue())
  }

  @IBAction func skipForward(_ sender: UIButton) {
    audioPlayer.skipForward(getPlayerValue())
  }

  private func getAuthorName(_ name: String) -> String {
    let index = name.range(of: "-")?.lowerBound

    return name[name.startIndex ..< name.index(index!, offsetBy: -1)]
  }

  private func getBookName(_ name: String) -> String {
    let index = name.range(of: "-")?.lowerBound

    return name[name.index(index!, offsetBy: 1) ..< name.endIndex].trimmingCharacters(in: .whitespaces)
  }

#endif

}

extension AudioPlayerController {

#if os(iOS)

  // MARK: AudioPlayerUI

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

  func displayPlay() {
    playPauseButton.setImage(UIImage(named: "Play"), for: .normal)
  }

  func displayPause() {
    playPauseButton.setImage(UIImage(named: "Pause"), for: .normal)
  }

  func updateTitle(_ title: String?) {
    if let title = title {
      titleLabel.text = title
    }
  }

  func getPlayerValue() -> Float {
    return playbackSlider.value
  }

  func playbackProgressDidChange(duration: Double, currentTime: Double) {
    currentTimeLabel.text = formatTime(currentTime)

    let leftTime = duration - currentTime

    let sign = (leftTime == 0) ? "" : "-"

    durationLabel.text = "\(sign)\(formatTime(leftTime))"

    playbackSlider.value = Float(currentTime / duration)
  }

  private func formatTime(_ time: Double) -> String {
    return String(format: "%02d", getMinutes(time)) + ":" + String(format: "%02d", getSeconds(time))
  }

  private func getMinutes(_ time: Double) -> Int {
    return Int(time / 60)
  }

  private func getSeconds(_ time: Double) -> Int {
    return Int(time) - getMinutes(time) * 60
  }

#endif

}

