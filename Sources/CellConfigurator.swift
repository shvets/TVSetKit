import Foundation
import UIKit

struct CellConfigurator<Model> {
  let titleKeyPath: KeyPath<Model, String?>
  let imageKeyPath: KeyPath<Model, String?>
  
  func configure(_ cell: UITableViewCell, for model: Model, localizer: Localizer) {
    cell.textLabel?.text = localizer.getLocalizedName(model[keyPath: titleKeyPath])
    
    if let imageName = model[keyPath: imageKeyPath] {
      cell.imageView?.image = UIImage(named: imageName)
    }
  }
}
