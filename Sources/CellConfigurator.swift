import Foundation
import UIKit

public struct CellConfigurator<Model> {
  public let titleKeyPath: KeyPath<Model, String?>
  public let imageKeyPath: KeyPath<Model, String?>
  
  public func configure(_ cell: UITableViewCell, for model: Model, localizer: Localizer) {
    cell.textLabel?.text = localizer.getLocalizedName(model[keyPath: titleKeyPath])
    
    if let imageName = model[keyPath: imageKeyPath] {
      cell.imageView?.image = UIImage(named: imageName)
    }
  }
}
