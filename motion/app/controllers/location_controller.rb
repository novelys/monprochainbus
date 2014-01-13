class LocationController < UIViewController
  def init
    super
    self.title = "Localisation"
    self.navigationItem.leftBarButtonItem = backButtonItem
    self
  end

  ## Actions
  def dismiss
    self.dismissModalViewControllerAnimated(true)
  end

  ## UI Bits
  def backButtonItem
    return @backButtonItem if @backButtonItem

    @backButtonItem = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemDone,
                                                                        target: self,
                                                                        action: 'dismiss')
    @backButtonItem.tintColor = UIColor.whiteColor
    @backButtonItem
  end
end
