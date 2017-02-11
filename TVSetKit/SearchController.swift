import UIKit
import Runglish

open class SearchController: UIViewController {
  @IBOutlet weak var query: UITextField!
  @IBOutlet weak var transcodedQuery: UILabel!
  @IBOutlet weak var useRunglish: UIButton!
  @IBOutlet weak var useRunglishLabel: UILabel!
  @IBOutlet weak var searchButton: UIButton!

  public var adapter: ServiceAdapter!

  var params = [String: Any]()

  let checkedImage = UIImage(named: "ic_check_box")! as UIImage
  let uncheckedImage = UIImage(named: "ic_check_box_outline_blank")! as UIImage

  static public func instantiate() -> Self {
    let bundle = Bundle(identifier: "com.rubikon.TVSetKit")!

    return AppStoryboard.instantiateController( "Player", bundle: bundle, viewControllerClass: self)
  }

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
    
    useRunglishLabel.text = adapter?.languageManager?.localize(useRunglishLabel.text!)
    searchButton.setTitle(adapter?.languageManager?.localize(searchButton.title(for: .normal)!), for: .normal)
    query.placeholder = adapter?.languageManager?.localize(query.placeholder!)
    
    query.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
  }
  
  func textFieldDidChange(textField: UITextField) {
    if isChecked {
      let transcoded = LatToRusConverter().transliterate(query.text!)
      
      transcodedQuery.text = transcoded
    }
    else {
      transcodedQuery.text = ""
    }
  }

  @IBAction func onSearchAction(_ sender: UIButton) {
    let destination = MediaItemsController.instantiate()

    if isChecked {
      let transcoded = LatToRusConverter().transliterate(query.text!)

      adapter.query = transcoded
      transcodedQuery.text = transcoded
    }
    else {
      adapter.query = query.text
    }

    destination.adapter = adapter

    destination.collectionView?.collectionViewLayout = adapter.buildLayout()!

    self.show(destination, sender: destination)
  }
  
  @IBAction func onUseRunglish(_ sender: UIButton) {
    isChecked = !isChecked
  }
}
