import Foundation
import UIKit

public class UIHelper {
  lazy private var cache = NSCache<NSString, UIImage>()

  static public let shared: UIHelper = {
    return UIHelper()
  }()

  public func textToImage(drawText text: String, width: Int, height: Int) -> UIImage? {
    return textToImage(drawText: text, size: CGSize(width: width, height: height))
  }

  public func textToImage(drawText text: String, size: CGSize, drawImage: UIImage?=nil) -> UIImage? {
    var image: UIImage?
    
    if let cachedImage = self.cache.object(forKey: text as NSString) {
      // use the cached version
      image = cachedImage
    }
    else {
      // create it from scratch then store in the cache
      
      let renderer = UIGraphicsImageRenderer(size: size)
      
      image = renderer.image { _ in
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        var textFont = UIFont(name: "Menlo", size: 36)

        if textFont == nil {
          textFont = UIFont.systemFont(ofSize: 36)
        }

        let attrs: [NSAttributedString.Key: Any] = [
          NSAttributedString.Key.font: textFont!,
          NSAttributedString.Key.foregroundColor: UIColor.black,
          NSAttributedString.Key.paragraphStyle: paragraphStyle,
        ]

        if let drawImage = drawImage {
          let width = size.width-size.height
          let height = size.height

          text.draw(with: CGRect(x: size.height, y: height/3, width: width, height: height), options: .usesLineFragmentOrigin,
                    attributes: attrs, context: nil)

          drawImage.draw(in: CGRect(x: 0, y: 0, width: height, height: height))
        }
        else {
          let width = size.width
          let height = size.height

          text.draw(with: CGRect(x: 0, y: height/3, width: width, height: height), options: .usesLineFragmentOrigin,
            attributes: attrs, context: nil)
        }
      }

      if let image = image {
        self.cache.setObject(image, forKey: text as NSString)
      }
    }

    return image
  }

  public func getItemSize(_ controller: UICollectionViewController) -> CGSize {
    var itemSize = CGSize(width: 300, height: 300)

    if let view = controller.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
      itemSize = view.itemSize
    }

    return itemSize
  }

}
