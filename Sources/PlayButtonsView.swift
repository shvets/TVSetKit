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

  var xOffsets: [CGFloat] = []

  var buttons = [UIButton]()

//  override func layoutSubviews() {
//
//    var width: CGFloat = 0
//    var zeroWidthView: UIView?
//
//    for i in 0..<subviews.count {
//      var view = subviews[i] as UIView
//      width += xOffsets[i]
//      if view.frame.width == 0 {
//        zeroWidthView = view
//      } else {
//        width += view.frame.width
//      }
//    }
//
//    if width < superview!.frame.width && zeroWidthView != nil {
//      zeroWidthView!.frame.size.width = superview!.frame.width - width
//    }
//
//    super.layoutSubviews()
//
//  }

  override func addSubview(_ view: UIView) {

    xOffsets.append(view.frame.origin.x)
    super.addSubview(view)
  }

  func createPlayButtons(_ bitrates: [MediaName], mobile: Bool) {
    var currentOffset = 0

    for (index, bitrate) in bitrates.enumerated() {
      if index > 0 {
        if mobile == true {
          currentOffset += Int(buttons[index - 1].frame.size.width / 2.5) + 40
        } else {
          currentOffset += Int(buttons[index - 1].frame.size.width) + 30
        }
      }

      let button = createPlayButton(bitrate: bitrate, mobile: mobile, offset: currentOffset)

      buttons.append(button)

      addSubview(button)
    }
  }

  func createPlayButton(bitrate: MediaName, mobile: Bool, offset: Int) -> PlayButton {
    let title = localizer.localize(bitrate.name!)

    let button = PlayButton(type: .system)

    button.setTitle(title, for: .normal)
    button.bitrate = bitrate

    if mobile == true {
      let scale = localizer.getLocale() == "en" ? 26 : 18

      button.frame = CGRect(x: offset, y: 0, width: scale*title.characters.count, height: 20)
    }
    else {
      let scale = localizer.getLocale() == "en" ? 52 : 36

      button.frame = CGRect(x: offset, y: 0, width: scale*title.characters.count, height: 80)
    }

    return button
  }

}