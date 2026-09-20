// RootView.swift — Roteador principal de telas
//
// CONEXÕES:
//   ← Renderizada por TERVONApp.swift
//   → Observa AppViewModel.shared via @State para reagir a mudanças de tela
//   → Renderiza SplashView, LoginView ou HomeView conforme currentScreen
//
// NOTA:
//   @State é necessário aqui (e só aqui) porque RootView precisa RE-RENDERIZAR
//   quando currentScreen muda. Sem @State, o SwiftUI não se subscreve às mudanças.
//   As outras views (Login, Register, Splash) apenas chamam métodos — não precisam observar.

import SwiftUI

struct RootView: View {
    @State private var appViewModel = AppViewModel.shared

    var body: some View {
        Group {
            switch appViewModel.currentScreen {
            case .splash:
                SplashView()
            case .login:
                LoginView()
            case .home:
                HomeView()
            }
        }
        .dismissKeyboardOnTap()
    }
}

#Preview {
    RootView()
}
