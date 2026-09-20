// HomeViewModel.swift — Lógica da tela Home
//
// CONEXÕES:
//   ← Criado por HomeView.swift via private let
//   → Acessa DependencyContainer.shared.authRepository para carregar o usuário logado
//   → Fornece recentTransactions (mock) para HomeView exibir

import Foundation

final class HomeViewModel {
    private var authRepository = DependencyContainer.shared.authRepository

    var currentUser: User? { authRepository.currentUser() }

    var firstName: String {
        currentUser?.name.components(separatedBy: " ").first ?? "Usuário"
    }

    var balance: Double { currentUser?.balance ?? 0.0 }

    // Transações mock — serão substituídas por dados reais nas próximas features
    let recentTransactions: [Transaction] = [
        Transaction(title: "Pix recebido",          description: "De: Maria Silva",     amount: 150.00, date: .now,                              type: .incoming),
        Transaction(title: "Transferência enviada",  description: "Para: Pedro Santos",  amount: 80.00,  date: .now - 86_400,                     type: .outgoing),
        Transaction(title: "Pix recebido",          description: "De: João Alves",      amount: 300.00, date: .now - 172_800,                    type: .incoming),
        Transaction(title: "Pagamento de conta",     description: "Energia elétrica",    amount: 127.50, date: .now - 259_200,                    type: .outgoing),
        Transaction(title: "Pix recebido",          description: "De: Ana Costa",       amount: 250.00, date: .now - 345_600,                    type: .incoming),
    ]
}
