import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        // Создаём сервис один раз здесь
        let socketService = QuotesWebSocketService()

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = MainRouter.createModule(socketService: socketService)
        self.window = window
        window.makeKeyAndVisible()
    }
}
