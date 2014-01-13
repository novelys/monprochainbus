module PCPageViewControllerDelegate
  def pageViewController(pageViewController, willTransitionToViewControllers: viewControllers)
    vc = viewControllers.first
    @nextTitle = vc.title
  end

  def pageViewController(pageViewController, didFinishAnimating:finishes, previousViewControllers:viewController, transitionCompleted:completed)
    self.title = @nextTitle if completed
    @nextTitle = nil
  end
end
