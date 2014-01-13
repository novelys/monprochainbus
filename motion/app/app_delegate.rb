class AppDelegate
  attr_reader :app, :window

  def application(application, didFinishLaunchingWithOptions: launchOptions)
    @app = application
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)

    window.makeKeyAndVisible
    window.rootViewController = navController(pagesController)

    setupGlobalStyles

    true
  end

  def pagesController
    @pagesController = PagesController.alloc.init
  end

  def navController(rootController = nil)
    return @navController if @navController

    @navController = UINavigationController.alloc.initWithRootViewController(rootController)
    @navController.navigationBar.barTintColor = AppColors.mainGreen
    @navController.navigationBar.translucent = true
    @navController.navigationBar.tintColor = UIColor.blackColor
    @navController.navigationBar.titleTextAttributes = {
      UITextAttributeFont      => UIFont.fontWithName('Oswald', size: 21.0),
      UITextAttributeTextColor => UIColor.whiteColor
    }

    @navController
  end

  def setupGlobalStyles
    ## Status bar
    app.statusBarStyle = UIStatusBarStyleLightContent

    ## Pager items
    pageControlProxy = UIPageControl.appearance
    pageControlProxy.pageIndicatorTintColor = UIColor.lightGrayColor
    pageControlProxy.currentPageIndicatorTintColor = AppColors.mainGreen
    pageControlProxy.backgroundColor = UIColor.clearColor
  end
end
