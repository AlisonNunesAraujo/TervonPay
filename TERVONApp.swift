// TERVONApp.swift — Ponto de entrada do app
//
// CONEXÕES:
//   → Renderiza RootView (App/RootView.swift) como tela raiz
//   → Configura a aparência global da UINavigationBar via UIKit
//
// POR QUE UIKit AQUI?
//   O SwiftUI não expõe controle direto da cor da status bar.
//   O iOS determina a cor da status bar a partir da UINavigationBar.
//   Configurando a aparência global aqui, todas as telas ficam com
//   a status bar verde e texto branco, sem precisar repetir em cada View.

import SwiftUI

@main
struct TERVONApp: App {
    init() {
        configureNavigationBarAppearance()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }

    // Configura a UINavigationBar globalmente:
    // - Fundo verde → status bar fica verde
    // - tintColor branco → texto e ícones da status bar ficam brancos
    private func configureNavigationBarAppearance() {
        let green = UIColor(Color.brandGreen)

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = green
        appearance.titleTextAttributes      = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        UINavigationBar.appearance().standardAppearance   = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance    = appearance
        UINavigationBar.appearance().tintColor            = .white
    }
}
