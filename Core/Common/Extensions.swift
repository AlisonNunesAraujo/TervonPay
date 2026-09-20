// Extensions.swift — Extensões utilitárias compartilhadas
//
// CONEXÕES:
//   ← Color.brandGreen e Color.brandGreenDark usados em todas as Features
//   ← Double.asCurrency usado em HomeView, ExtratoView, PixView e qualquer tela com valores

import SwiftUI

// Cores oficiais do app — definidas aqui para serem consistentes em todos os arquivos
extension Color {
    // Verde principal — PicPay #21BF73 (R:33 G:191 B:115)
    static let brandGreen     = Color(red: 0.129, green: 0.749, blue: 0.451)
    // Verde escuro — card de saldo dentro do header
    static let brandGreenDark = Color(red: 0.08,  green: 0.56,  blue: 0.33)

    // Cores semânticas do app — adaptam automaticamente ao modo claro/escuro.
    // Use estas cores para fundos e cards em vez de .white ou cinzas fixos.
    static let appBackground     = Color(.systemGroupedBackground)
    static let cardBackground    = Color(.secondarySystemGroupedBackground)
    static let controlBackground = Color(.tertiarySystemGroupedBackground)
}

extension Double {
    // Formata o valor como moeda brasileira: 1500.0 → "R$ 1.500,00"
    var asCurrency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: self)) ?? "R$ 0,00"
    }
}

extension View {
    // Fecha o teclado quando o usuário toca fora de um campo de texto.
    // Aplicamos no RootView para funcionar em todas as telas sem repetir código.
    func dismissKeyboardOnTap() -> some View {
        simultaneousGesture(
            TapGesture().onEnded {
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil,
                    from: nil,
                    for: nil
                )
            }
        )
    }
}
