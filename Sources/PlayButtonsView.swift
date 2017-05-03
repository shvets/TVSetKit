import UIKit

class PlayButton: UIButton {
  var controller: MediaItemDetailsController?
  var bitrate: MediaName?

  override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
    for item in presses {
      if item.type == .select {
        controller?.playMediaItem(sender: self)
      }
    }
  }
}

class PlayButtonsView: UIView {
  let localizer = Localizer("com.rubikon.TVSetKit")

  var buttons = [UIButton]()

  func createPlayButtons(_ bitrates: [MediaName], mobile: Bool) {
    let delta: CGFloat = (mobile == true) ? 0 : 70

    var width: CGFloat = 0

    for bitrate in bitrates {
      let title = localizer.localize(bitrate.name!)

      let button = PlayButton(type: .system)

      button.setTitle(title, for: .normal)
      button.bitrate = bitrate

      if mobile == true {
        button.frame.size = CGSize(width: title.characters.count*10, height: 20)
      }
      else {
        button.frame.size = CGSize(width: title.characters.count*50, height: 80)
      }

      button.frame.origin = CGPoint(x: width+delta, y: 0)

      buttons.append(button)

      addSubview(button)

      width += button.frame.size.width+delta
    }
  }

}
