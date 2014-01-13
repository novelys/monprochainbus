class PagesController < UIViewController
  include PCPageViewControllerDataSource
  include PCPageViewControllerDelegate

  attr_reader :currentLocation

  def init
    self.initWithNibName(nil, bundle: nil)
    self.view.backgroundColor = UIColor.groupTableViewBackgroundColor
    self.title = "Mon Prochain Bus"

    @pagesShown = false

    self
  end

  ## View Lifecycle
  def viewDidLoad
    super

    refresh
  end

  def didRotateFromInterfaceOrientation(fromInterfaceOrientation)
    centerActivityInfo
    updatePageControllerFrame
  end

  def refresh
    hidePages
    clearModels

    getLocation do
      getStops do
        getLines do
          stopLoading
          presentPages
        end
      end
    end
  end

  ## UI Bits
  def barButtonItem
    return @barButtonItem if @barButtonItem

    @barButtonItem = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemRefresh,
                                                                      target: self,
                                                                      action: 'refresh')
    @barButtonItem.tintColor = UIColor.whiteColor
    @barButtonItem
  end

  def spinner
    return @spinner if @spinner

    @spinner = UIActivityIndicatorView.alloc.initWithActivityIndicatorStyle(UIActivityIndicatorViewStyleGray)
    @spinner.center = [self.view.size.width / 2, (self.view.size.height / 2 + 20)]
    @spinner.hidesWhenStopped = true
    @spinner.color = UIColor.blackColor#AppColors.mainGreen
    @spinner
  end

  def activityLabel
    return @activityLabel if @activityLabel

    @activityLabel = UILabel.alloc.init
    @activityLabel.textAlignment = NSTextAlignmentCenter
    @activityLabel.font = UIFont.fontWithName("Droid Sans", size: 20)
    @activityLabel.frame = CGRectMake(0, 0, 320, 30)
    @activityLabel.center = [self.view.size.width / 2, (self.view.size.height / 2 - 20)]
    @activityLabel
  end

  def loadingLabel
    label = activityLabel
    label.text = "Géolocalisation en cours..."
    label
  end

  def startLoad
    spinner.startAnimating
    self.view.addSubview(loadingLabel)
    self.view.addSubview(spinner)
  end

  def stopSpinner
    navigationItem.rightBarButtonItem = barButtonItem
    spinner.stopAnimating
    spinner.removeFromSuperview
  end

  def stopLoading
    stopSpinner
    activityLabel.removeFromSuperview
  end

  def centerActivityInfo
    @activityLabel.center = [self.view.size.width / 2, (self.view.size.height / 2 - 20)] if @activityLabel
    @spinner.center = [self.view.size.width / 2, (self.view.size.height / 2 + 20)] if @spinner
  end

  def updatePageControllerFrame
    return unless @pageController

    navigationBarFrame = App.delegate.navController.navigationBar.frame
    offset = navigationBarFrame.origin.y + navigationBarFrame.size.height
    newFrame = CGRectMake(0, offset, view.frame.size.width, view.frame.size.height - offset)

    @pageController.view.setFrame(newFrame)
  end

  ## Controllers logic
  def viewControllerAtIndex(index)
    @childControllers ||= (0..Stop.count - 1).map do |i|
      controller = StopController.alloc.initWithModel(Stop.at(i), atIndex: i)
      controller.pagesController = self
      controller
    end

    @childControllers[index]
  end

  def pageController
    return @pageController if @pageController

    @pageController = UIPageViewController.alloc.initWithTransitionStyle(UIPageViewControllerTransitionStyleScroll,
                                                                         navigationOrientation: UIPageViewControllerNavigationOrientationHorizontal,
                                                                         options: nil)
    @pageController.dataSource = self
    @pageController.delegate = self

    updatePageControllerFrame

    @pageController
  end

  def pagesHidden?
    !@pagesShown
  end

  def pagesShown?
    !!@pagesShown
  end

  def hidePages
    navigationItem.rightBarButtonItem = nil

    return if pagesHidden?

    pageController.view.removeFromSuperview
    pageController.removeFromParentViewController

    @pagesShown = false
  end

  def presentPages
    navigationItem.rightBarButtonItem = barButtonItem

    return if pagesShown?

    pageController.setViewControllers([viewControllerAtIndex(0)],
                                      direction: UIPageViewControllerNavigationDirectionForward,
                                      animated: false,
                                      completion: nil)

    addChildViewController(pageController)
    view.addSubview(self.pageController.view)
    pageController.didMoveToParentViewController(self)

    @pagesShown = true
  end

  ## Domain logic
  def clearModels
    Direction.delete_all
    Line.delete_all
    Stop.delete_all
  end

  def getLocation(accuracy = 200, &block)
    startLoad

    BW::Location.get do |result|
      if result[:error]
        case result[:error]
        when DISABLED
          activityLabel.text = "Géolocalisation désactivée."
        when PERMISSION_DENIED
          activityLabel.text = "Géolocalisation non autorisée."
        when NETWORK_FAILURE
          activityLabel.text = "Problème de réseau..."
        when LOCATION_UNKNOWN
          activityLabel.text = "Localisation inconnue..."
        end

        stopSpinner
      else
        location = result[:to]

        if location.horizontalAccuracy < accuracy
          @currentLocation = location
          BW::Location.stop

          block.call
        end
      end
    end
  end

  def getStops(&block)
    url = "http://www.monprochainbus.eu/stops.json?lat=#{currentLocation.latitude}&lng=#{currentLocation.longitude}"
    activityLabel.text = "Recherche des arrêts..."

    BW::HTTP.get(url, options: {cache_policy: NSURLRequestReloadIgnoringCacheData}) do |response|
      if response.ok?
        json = BW::JSON.parse(response.body.to_str)

        if json['stops'].none?
          activityLabel.text = "Aucun arrêt à proximité."
          stopSpinner
        else
          stops = Stop.loadFromJson(json)

          block.call
        end
      else
        activityLabel.text = "Le service n'est pas joignable."
        stopSpinner
      end
    end
  end

  def getLines(&block)
    url = "http://www.monprochainbus.eu/lines.json?#{Stop.paramsForLines}"
    activityLabel.text = "Recherche des horaires..."

    BW::HTTP.get(url, options: {cache_policy: NSURLRequestReloadIgnoringCacheData}) do |response|
      if response.ok?
        json = BW::JSON.parse(response.body.to_str)
        lines = Line.loadFromJson(json)

        block.call(json)
      else
        activityLabel.text = "Le service n'est pas joignable."
        stopSpinner
      end
    end
  end
end
