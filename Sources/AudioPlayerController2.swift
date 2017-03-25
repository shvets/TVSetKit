import UIKit
import AVFoundation

class AudioPlayerController2: UIViewController  {
  static let SegueIdentifier = "Audio Player2"

  var mediaItem: MediaItem!
  var items: [MediaItem]!

  var player:AVPlayer?
  var playerItem:AVPlayerItem?
  var playButton:UIButton?

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    let url = URL(string: "https://s3.amazonaws.com/kargopolov/kukushka.mp3")
    let playerItem:AVPlayerItem = AVPlayerItem(url: url!)
    player = AVPlayer(playerItem: playerItem)

    let playerLayer=AVPlayerLayer(player: player!)
    playerLayer.frame=CGRect(x:0, y:0, width:10, height:50)
    self.view.layer.addSublayer(playerLayer)

    playButton = UIButton(type: UIButtonType.system) as UIButton
    let xPostion:CGFloat = 50
    let yPostion:CGFloat = 100
    let buttonWidth:CGFloat = 150
    let buttonHeight:CGFloat = 45

    playButton!.frame = CGRect(x:xPostion, y:yPostion, width:buttonWidth, height:buttonHeight)
    playButton!.backgroundColor = UIColor.lightGray
    playButton!.setTitle("Play", for: UIControlState.normal)
    playButton!.tintColor = UIColor.black
    //playButton!.addTarget(self, action: Selector("playButtonTapped:"), for: .touchUpInside)
    playButton!.addTarget(self, action: #selector(AudioPlayerController2.playButtonTapped(_:)), for: .touchUpInside)

    self.view.addSubview(playButton!)


    // Add playback slider

    let playbackSlider = UISlider(frame:CGRect(x:10, y:300, width:300, height:20))
    playbackSlider.minimumValue = 0


    let duration : CMTime = playerItem.asset.duration
    let seconds : Float64 = CMTimeGetSeconds(duration)

    playbackSlider.maximumValue = Float(seconds)
    playbackSlider.isContinuous = true
    playbackSlider.tintColor = UIColor.green

    playbackSlider.addTarget(self, action: #selector(AudioPlayerController2.playbackSliderValueChanged(_:)), for: .valueChanged)
    // playbackSlider.addTarget(self, action: "playbackSliderValueChanged:", forControlEvents: .ValueChanged)
    self.view.addSubview(playbackSlider)

  }

  func playbackSliderValueChanged(_ playbackSlider: UISlider)
  {

    let seconds : Int64 = Int64(playbackSlider.value)
    let targetTime:CMTime = CMTimeMake(seconds, 1)

    player!.seek(to: targetTime)

    if player!.rate == 0
    {
      player?.play()
    }
  }


  func playButtonTapped(_ sender:UIButton)
  {
    if player?.rate == 0
    {
      player!.play()
      //playButton!.setImage(UIImage(named: "player_control_pause_50px.png"), forState: UIControlState.Normal)
      playButton!.setTitle("Pause", for: UIControlState.normal)
    } else {
      player!.pause()
      //playButton!.setImage(UIImage(named: "player_control_play_50px.png"), forState: UIControlState.Normal)
      playButton!.setTitle("Play", for: UIControlState.normal)
    }
  }

}