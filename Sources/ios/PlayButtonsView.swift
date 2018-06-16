import UIKit

class PlayButtonsView: UIView {
  let localizer = Localizer("com.rubikon.TVSetKit", bundleClass: TVSetKit.self)

  var buttons = [UIButton]()

  func createPlayButtons(_ bitrates: [MediaName], mobile: Bool) -> CGFloat {
    let delta: CGFloat = (mobile == true) ? 0 : 70

    var width: CGFloat = 0

    for bitrate in bitrates {
      let title = localizer.localize(bitrate.name ?? "")

      let button = PlayButton(type: .system)

      button.setTitle(title, for: .normal)
      button.bitrate = bitrate

      if mobile == true {
        button.frame.size = CGSize(width: title.count*10, height: 20)
      }
      else {
        button.frame.size = CGSize(width: title.count*50, height: 80)
      }

      button.frame.origin = CGPoint(x: width+delta, y: 0)

      buttons.append(button)

      addSubview(button)

      width += button.frame.size.width+delta
    }
    
    return width
  }
  
//  func createEmailButton(width: CGFloat, mobile: Bool) {
//    let delta: CGFloat = (mobile == true) ? 0 : 70
//
//    let title = localizer.localize("Send URL")
//
//    let button = UIButton(type: .system)
//
//    button.setTitle(title, for: .normal)
//
//    if mobile == true {
//      button.frame.size = CGSize(width: title.count*10, height: 20)
//    }
//    else {
//      button.frame.size = CGSize(width: title.count*50, height: 80)
//    }
//
//    button.frame.origin = CGPoint(x: width+delta, y: 0)
//
//    button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
//
//    buttons.append(button)
//
//    addSubview(button)
//  }
//
//  @objc func buttonAction(sender: UIButton!) {
//    print("Email sent")
//  }

}
