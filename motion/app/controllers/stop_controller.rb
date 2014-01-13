class StopController < UITableViewController
  include SCTableViewControllerDataSource
  include SCTableViewControllerDelegate

  attr_accessor :model, :index, :pagesController

  def initWithModel(model, atIndex: index)
    self.initWithStyle(UITableViewStyleGrouped)
    self.model = model
    self.title = model.name
    self.index = index
    self
  end
end
