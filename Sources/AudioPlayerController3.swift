import UIKit
import AVFoundation

class AudioPlayerController3: UIViewController {
  static let SegueIdentifier = "Audio Player3"

  var trackID: Int!

  var mediaItem: MediaItem!
  var items: [MediaItem]!

  var audioPlayer:AVAudioPlayer!

  @IBOutlet var trackLbl: UILabel!
  @IBOutlet var progressView: UIProgressView!

  override func viewDidLoad() {
    super.viewDidLoad()

    trackLbl.text = "Track \(trackID + 1)"

//    let path: String! = Bundle.main.resourcePath?.appending("/\(trackID!).mp3")
//    let mp3URL = NSURL(fileURLWithPath: path)

    let item = items[0]

    print(item.id!)

    if let audioPath = getMediaUrl(url: item.id!.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!) {
      do {
        audioPlayer = try AVAudioPlayer(contentsOf: audioPath, fileTypeHint: <#T##String?##Swift.String?#>)
        audioPlayer.play()

        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateAudioProgressView), userInfo: nil, repeats: true)
        progressView.setProgress(Float(audioPlayer.currentTime/audioPlayer.duration), animated: false)
      }
      catch let error {
        print("An error occurred while trying to extract audio file: \(error)")
      }
      catch {
        print("An error occurred while trying to extract audio file")
      }
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    audioPlayer.stop()
  }

  func updateAudioProgressView() {
    if audioPlayer.isPlaying {
      // Update progress
      progressView.setProgress(Float(audioPlayer.currentTime/audioPlayer.duration), animated: true)
    }
  }

  @IBAction func fastBackward(_ sender: AnyObject) {
    var time: TimeInterval = audioPlayer.currentTime

    time -= 5.0 // Go back by 5 seconds

    if time < 0 {
      stop(self)
    }
    else {
      audioPlayer.currentTime = time
    }
  }

  @IBAction func pause(_ sender: AnyObject) {
    audioPlayer.pause()
  }

  @IBAction func play(_ sender: AnyObject) {
    if !audioPlayer.isPlaying {
      audioPlayer.play()
    }
  }

  @IBAction func stop(_ sender: AnyObject) {
    audioPlayer.stop()
    audioPlayer.currentTime = 0
    progressView.progress = 0.0
  }

  @IBAction func fastForward(_ sender: AnyObject) {
    var time: TimeInterval = audioPlayer.currentTime
    time += 5.0 // Go forward by 5 seconds

    if time > audioPlayer.duration {
      stop(self)
    }
    else {
      audioPlayer.currentTime = time
    }
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
