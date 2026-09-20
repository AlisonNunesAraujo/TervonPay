// SplashView.swift — Tela de abertura do app
//
// CONEXÕES:
//   ← Renderizada por RootView.swift quando currentScreen == .splash
//   → Chama AppViewModel.shared.checkAuthStatus() após 2 segundos

import SwiftUI

struct SplashView: View {
    private var appViewModel = AppViewModel.shared

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 8) {
                Text("TERVON")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                Text("Sua carteira digital")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(2))
            appViewModel.checkAuthStatus()
        }
    }
}

#Preview {
    SplashView()
}
