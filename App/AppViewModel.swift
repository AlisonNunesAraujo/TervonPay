// AppViewModel.swift — Cérebro da navegação global
//
// CONEXÕES:
//   ← Acessado por RootView.swift, SplashView.swift, LoginView, RegisterView
//   → Controla qual tela está visível via currentScreen
//   → Consulta DependencyContainer para verificar estado de login
//
// FLUXO:
//   1. App inicia → currentScreen = .splash
//   2. SplashView chama checkAuthStatus()
//      → se já logado: currentScreen = .home
//      → se não logado: currentScreen = .login
//   3. Login ou Register chama showHome() → currentScreen = .home
//   4. Qualquer tela chama logout() → currentScreen = .login

import SwiftUI

enum AppScreen {
    case splash
    case login
    case home
}

@Observable
final class AppViewModel {

    // Instância única do app — acesse com AppViewModel.shared
    static let shared = AppViewModel()
    private init() {}

    var currentScreen: AppScreen = .splash

    func checkAuthStatus() {
        let isLoggedIn = DependencyContainer.shared.authRepository.isLoggedIn
        withAnimation { currentScreen = isLoggedIn ? .home : .login }
    }

    func showHome() {
        withAnimation { currentScreen = .home }
    }

    func logout() {
        DependencyContainer.shared.authRepository.logout()
        withAnimation { currentScreen = .login }
    }
}
