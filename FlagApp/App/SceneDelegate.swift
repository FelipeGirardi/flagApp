import FirebaseCore
import FirebaseDynamicLinks
import SwiftUI
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var userManager: UserManager
    let authenticationService: FirebaseAuthService
    let authenticationManager: AuthenticationManager
    let signInViewModel: SignInViewModel
    var window: UIWindow?
    var iapManager: IAPManager

    override init() {
        self.userManager = UserManager()
        self.authenticationService = FirebaseAuthService(userManager: userManager)
        self.authenticationManager = AuthenticationManager(firebaseAuthService: authenticationService)
        self.signInViewModel = SignInViewModel(
            appleAuthController: AppleSignInControllerAuthAdapter(
                controller: SignInWithAppleController(),
                nonceProvider: NonceProvider()
            ),
            userManager: self.userManager,
            sessionManager: self.authenticationManager
        )

        self.iapManager = IAPManager(userManager: self.userManager)

        // MARK: restore in-app purchases if app was deleted
        self.iapManager.restorePurchases()

        super.init()
    }

    func setNavigationBar() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.shadowColor = .clear
        navBarAppearance.backgroundColor = UIColor.clear
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont(name: "Heebo-Bold", size: 34) ?? UIFont()]
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
    }

    func setList() {
        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
        UITableView.appearance().separatorStyle = .none
        UITableViewCell.appearance().selectionStyle = .none
        UITableView.appearance().showsVerticalScrollIndicator = false
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        self.authenticationService.signIn()

//        GameKitHelper.sharedInstance.authenticateLocalPlayer { [weak self] _ in
//            self?.authenticationService.signIn()
//        }

        // Configure nav bar and list
        setNavigationBar()
        setList()

        // Create the SwiftUI view that provides the window contents.
        let contentView = MainTabView(userManager: userManager, sessionManager: authenticationManager, signInViewModel: signInViewModel, iapManager: iapManager)

        // MARK: Navigation Settings
        let appNavigationManager = AppNavigationManager()
        let permissionManager = PermissionManager()
        let theme = Theme()

        // Use a UIHostingController as window root view controller.
        guard let windowScene = scene as? UIWindowScene else {
            return
        }
        let window = UIWindow(windowScene: windowScene)

        PopupControllerMessage
            .presentAuthentication
            .addHandlerForNotification(
                self,
                handler: #selector(SceneDelegate.showAuthenticationViewController)
            )

        PopupControllerMessage
            .gameCenter
            .addHandlerForNotification(
                self,
                handler: #selector(SceneDelegate.showGameCenterViewController)
            )

        // Force app to be dark
        window.overrideUserInterfaceStyle = .dark

        // MARK: Navigation Settings (Precisa ser assim para navegação funcionar)
        window.rootViewController = UIHostingController(
            rootView:
                contentView
                    .environmentObject(appNavigationManager)
                    .environmentObject(permissionManager)
                    .environmentObject(theme)
                    .environmentObject(AuthenticationManager(firebaseAuthService: authenticationService))
                    .environmentObject(GameKitHelper.sharedInstance)
        )
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    // pop's up the leaderboard and achievement screen
    @objc
    func showGameCenterViewController() {
        if let gameCenterViewController =
            GameKitHelper.sharedInstance.gameCenterViewController {
            self.window?.rootViewController?.present(
                gameCenterViewController,
                animated: true,
                completion: nil
            )
        }
    }

    // pop's up the authentication screen
    @objc
    func showAuthenticationViewController() {
        if let authenticationViewController = GameKitHelper.sharedInstance.authenticationViewController {
            self.window?.rootViewController?.present(authenticationViewController, animated: true)
            GameKitHelper.sharedInstance.enabled = GameKitHelper.sharedInstance.gameCenterEnabled
        }
    }

    // MARK: dynamic link handling
    func handleIncomingDynamicLink(_ dynamicLink: DynamicLink) {
        guard let url = dynamicLink.url else {
            print("Dynamic link has no URL")
            return
        }
        print("Incoming link parameter: \(url.absoluteString)")
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        if let incomingURL = userActivity.webpageURL {
            print("Incoming URL: \(incomingURL)")
            _ = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { dynamicLink, error in
                guard error == nil else {
                    print("Error: \(error!.localizedDescription)")
                    return
                }
                if let dynamicLink = dynamicLink {
                    self.handleIncomingDynamicLink(dynamicLink)
                }
            }
        }
    }
}
