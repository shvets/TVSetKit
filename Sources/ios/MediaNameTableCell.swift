import UIKit

//extension UIImage {
//    convenience init?(imageName: String) {
//        self.init(named: imageName)
//        accessibilityIdentifier = imageName
//    }
//
//    // https://stackoverflow.com/a/40177870/4488252
//    func imageWithColor (newColor: UIColor?) -> UIImage? {
//
//        if let newColor = newColor {
//            UIGraphicsBeginImageContextWithOptions(size, false, scale)
//
//            let context = UIGraphicsGetCurrentContext()!
//            context.translateBy(x: 0, y: size.height)
//            context.scaleBy(x: 1.0, y: -1.0)
//            context.setBlendMode(.normal)
//
//            let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
//            context.clip(to: rect, mask: cgImage!)
//
//            newColor.setFill()
//            context.fill(rect)
//
//            let newImage = UIGraphicsGetImageFromCurrentImageContext()!
//            UIGraphicsEndImageContext()
//            newImage.accessibilityIdentifier = accessibilityIdentifier
//            return newImage
//        }
//
//        if let accessibilityIdentifier = accessibilityIdentifier {
//            return UIImage(imageName: accessibilityIdentifier)
//        }
//
//        return self
//    }
//}

open class MediaNameTableCell: UITableViewCell {
  @IBOutlet private weak var thumb: UIImageView!

  public func configureCell(item: Item, localizedName: String, applyColor: Bool = true) {
    textLabel?.text = localizedName

    if let item = item as? MediaName, let imageName = item.imageName {
      if applyColor {
        let color = self.traitCollection.userInterfaceStyle == .dark ? UIColor.lightGray : UIColor.darkGray

        imageView?.image = UIImage(named: imageName)?.imageWithColor(newColor: color)
      }
      else {
        imageView?.image = UIImage(named: imageName)
      }
    
//      if applyColor {
//        imageView?.image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
//
//        if #available(iOS 13.0, *) {
//          let color = self.traitCollection.userInterfaceStyle == .dark ? UIColor.lightText : UIColor.darkText
//
//          imageView?.tintColor = color
//        }
//      }
//      else {
//        imageView?.image = UIImage(named: imageName)
//      }
    }
  }
}
