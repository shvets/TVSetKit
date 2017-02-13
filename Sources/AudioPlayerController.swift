import UIKit
import AVFoundation
import AVKit

class AudioPlayerController: AVPlayerViewController, AVPlayerViewControllerDelegate {
  static let SEGUE_IDENTIFIER = "playAudio"

  var mediaItem: MediaItem!

  override func viewDidLoad() {
    super.viewDidLoad()

    if let url = getMediaUrl() {
      playAudio(url)
    }
  }

//  public func playerViewController(_ playerViewController: AVPlayerViewController, didPresent interstitial: AVInterstitialTimeRange) {
//    print("finished")
//
////    if flag {
////      counter += 1
////    }
////
////    if ((counter + 1) == song.count) {
////      counter = 0
////    }
////
////    playAudio()
//  }

  func playAudio(_ url: URL) {
    let asset = AVAsset(url: url)

    let playerItem = AVPlayerItem(asset: asset)

    player = AVPlayer(playerItem: playerItem)

    let overlayView = UIView(frame: CGRect(x: 50, y: 50, width: 200, height: 200))
    overlayView.addSubview(UIImageView(image: UIImage(named: "tv-watermark")))

    self.contentOverlayView?.addSubview(overlayView)
    //playerViewController?.contentOverlayView?.addSubview(overlayView)

    player?.play()
  }

//  func playAudio0(_ url: URL) {
//    URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
//        DispatchQueue.main.async {
//          // you can use the data! here
//          if data != nil {
//            do {
//              // this codes for making this app ready to takeover the device audio
//              try AVAudioSession.shared().setCategory(AVAudioSessionCategoryPlayback)
//              try AVAudioSession.shared().setActive(true)
//
//              self.player = try AVAudioPlayer(data: data!, fileTypeHint: AVFileTypeMPEGLayer3)
//              // self.player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3)
//
////              self.status = "started"
//              self.player?.play()
//            }
//            catch let error as NSError {
//              print("error: \(error.localizedDescription)")
//            }
//          }
//        }
//      }).resume()
//  }

  private func getMediaUrl() -> URL? {
    let url = mediaItem.id!

    let link = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!

    if link != "" {
      return NSURL(string: link)! as URL
    }
    else {
      return nil
    }
  }
}
