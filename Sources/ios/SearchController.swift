import UIKit
import Runglish

open class SearchController: UIViewController {
  @IBOutlet private weak var query: UITextField!
  @IBOutlet private weak var transcodedQuery: UILabel!
  @IBOutlet private weak var useRunglish: UIButton!
  @IBOutlet private weak var useRunglishLabel: UILabel!
  @IBOutlet private weak var searchButton: UIButton!

  public class var SegueIdentifier: String { return "Search" }

  var localizer = Localizer("com.rubikon.TVSetKit", bundleClass: TVSetKit.self)

  public var configuration: [String: Any]?
  public var params = [String: Any]()

  let checkedImage = UIImage(named: "ic_check_box")! as UIImage
  let uncheckedImage = UIImage(named: "ic_check_box_outline_blank")! as UIImage

  var isChecked: Bool = false {
    didSet {
      if isChecked == true {
        useRunglish.setImage(checkedImage, for: .normal)
      }
      else {
        useRunglish.setImage(uncheckedImage, for: .normal)
      }
    }
  }

  override open func viewDidLoad() {
    super.viewDidLoad()

    isChecked = true

    useRunglishLabel.text = localizer.localize(useRunglishLabel.text ?? "")
    searchButton.setTitle(localizer.localize(searchButton.title(for: .normal) ?? ""), for: .normal)
    query.placeholder = localizer.localize(query.placeholder ?? "")

    query.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)

    if localizer.getLocale() == "en" {
      transcodedQuery.isHidden = true
      useRunglishLabel.isHidden = true
      useRunglish.isHidden = true
    }
  }

  @objc func textFieldDidChange(textField: UITextField) {
    if isChecked {
      let transcoded = LatToRusConverter().transliterate(query.text ?? "")

      transcodedQuery.text = transcoded
    }
    else {
      transcodedQuery.text = ""
    }
  }

  @IBAction func onSearchAction(_ sender: UIButton) {
    performSegue(withIdentifier: MediaItemsController.SegueIdentifier, sender: view)
  }

  override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
      case MediaItemsController.SegueIdentifier:
        if let destination = segue.destination.getActionController() as? MediaItemsController {
          destination.params["requestType"] = "Search"

          if localizer.getLocale() == "ru" && isChecked {
            let transcoded = LatToRusConverter().transliterate(query.text ?? "")

            destination.params["query"] = transcoded
            transcodedQuery.text = transcoded
          }
          else {
            destination.params["query"] = query.text
          }

          destination.configuration = configuration

          if let layout = configuration?["buildLayout"] {
            destination.collectionView?.collectionViewLayout = layout as! UICollectionViewLayout
          }
        }

      default: break
      }
    }
  }

  @IBAction func onUseRunglish(_ sender: UIButton) {
    isChecked = !isChecked
  }
}
