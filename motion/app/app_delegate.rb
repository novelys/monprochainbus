class AppDelegate
  attr_reader :app, :window

  def application(application, didFinishLaunchingWithOptions: launchOptions)
    setupNotifier

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
    @navController.navigationBar.translucent = true

    @navController
  end

  def setupGlobalStyles
    ## Status bar
    app.statusBarStyle = UIStatusBarStyleLightContent

    ## Nav Bar
    navBarProxy = UINavigationBar.appearance
    navBarProxy.barTintColor = AppColors.mainGreen
    navBarProxy.tintColor = UIColor.blackColor
    navBarProxy.titleTextAttributes = {
      UITextAttributeFont      => UIFont.fontWithName('Oswald', size: 21.0),
      UITextAttributeTextColor => UIColor.whiteColor
    }

    ## Pager items
    pageControlProxy = UIPageControl.appearance
    pageControlProxy.pageIndicatorTintColor = UIColor.lightGrayColor
    pageControlProxy.currentPageIndicatorTintColor = AppColors.mainGreen
    pageControlProxy.backgroundColor = UIColor.clearColor
  end

  def setupNotifier
    if ENV['AIRBRAKE_KEY']
      ABNotifier.startNotifierWithAPIKey(ENV['AIRBRAKE_KEY'],
        environmentName: (ENV['AIRBRAKE_ENV'] || ABNotifierAutomaticEnvironment),
        useSSL:true,
        delegate:self
      )
    end
  end
end
