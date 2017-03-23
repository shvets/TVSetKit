import Foundation
import UIKit

open class CellHelper {
  private lazy var cache = NSCache<NSString, UIImage>()

  public static let shared: CellHelper = {
    return CellHelper()
  }()
  
  public func addTapGestureRecognizer(view: UIView, target: Any?, action: Selector?, pressType: UIPressType = .select) {
    let tapGesture = UITapGestureRecognizer(target: target, action: action)

    tapGesture.allowedPressTypes = [NSNumber(value: pressType.rawValue)]

    view.addTapGestureRecognizer(tapGesture)
  }
  
  func loadImage(path: String, name: String="", imageView: UIImageView, width: Int=450, height: Int=150) {
    if let cachedImage = self.cache.object(forKey: path as NSString) {
      // use the cached version
      let image = cachedImage

      DispatchQueue.main.async {
        imageView.image = image
      }
    }
    else {
      // create it from scratch then store in the cache

      if path == "" {
        DispatchQueue.global().async {
          let image = UIHelper.shared.textToImage(drawText: name, width: width, height: height)

          DispatchQueue.main.async {
            imageView.image = image
          }
        }
      }
      else {
        // draw placeholder image

        DispatchQueue.global().async {
          let placeholder = UIHelper.shared.textToImage(drawText: name, width: width, height: height)

          DispatchQueue.main.async {
            imageView.image = placeholder
          }
        }

        // draw image

        DispatchQueue.global().async {
          let url = NSURL(string: path)!

          if let data = NSData(contentsOf: url as URL) {
            if let image = UIImage(data: data as Data) {
              self.cache.setObject(image, forKey: path as NSString)

              DispatchQueue.main.async {
                imageView.image = image
              }
            }
          }
        }
      }
    }
  }
}
