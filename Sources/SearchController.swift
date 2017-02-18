//import UIKit
//
//open class SearchController: UIViewController {
//  @IBOutlet weak var query: UITextField!
//  @IBOutlet weak var transcodedQuery: UILabel!
//  @IBOutlet weak var searchButton: UIButton!
//
//  public var adapter: ServiceAdapter!
//
//  static public func instantiate() -> Self {
//    let bundle = Bundle(identifier: "com.rubikon.TVSetKit")!
//
//    return AppStoryboard.instantiateController( "Player", bundle: bundle, viewControllerClass: self)
//  }
//
//  override open func viewDidLoad() {
//    super.viewDidLoad()
//
//    let bundle = Bundle(identifier: "com.rubikon.TVSetKit")!
//
//    searchButton.setTitle(adapter?.languageManager?.localize(searchButton.title(for: .normal)!, bundle: bundle), for: .normal)
//    query.placeholder = adapter?.languageManager?.localize(query.placeholder!, bundle: bundle)
//  }
//
//  @IBAction func onSearchAction(_ sender: UIButton) {
//    let destination = MediaItemsController.instantiate()
//
//    adapter.query = query.text
//
//    destination.adapter = adapter
//
//    destination.collectionView?.collectionViewLayout = adapter.buildLayout()!
//
//    self.show(destination, sender: destination)
//  }
//
//}
