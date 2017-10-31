import AppKit
import PageLoader

open class PlainSpinner: Spinner {
  open var view: NSProgressIndicator
  
  public init(_ view: NSProgressIndicator) {
    self.view = view
//    let indicator = NSProgressIndicator(frame: NSRect(x: 20, y: 20, width: 260, height: 20))
//    indicator.minValue = 0.0
//    indicator.maxValue = 100.0
//    indicator.doubleValue = 33.0
//    self.view.addSubview(indicator)
  }
  
  open func start() {
    view.startAnimation(self)
  }
  
  open func stop() {
    view.stopAnimation(self)
  }
}

