class EmialButton: UIButton {
  var controller: MediaItemDetailsController?
  var bitrate: MediaName?
  
  override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
    for item in presses {
      if item.type == .select {
        controller?.playMediaItemAction(sender: self)
      }
    }
  }
}
