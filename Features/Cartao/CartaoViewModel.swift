// CartaoViewModel.swift — Dados da tela de Cartão
//
// CONEXÕES:
//   ← Criado por CartaoView.swift via private let
//   → Acessa DependencyContainer.shared.authRepository para exibir o nome do usuário no cartão
//
// CONCEITO:
//   Por enquanto esta feature usa dados simulados.
//   Em um app real, limite e fatura viriam de uma API do banco.

import Foundation

final class CartaoViewModel {
    private var authRepository = DependencyContainer.shared.authRepository

    var cardholderName: String {
        authRepository.currentUser()?.name.uppercased() ?? "USUARIO TERVON"
    }

    let cardLastDigits = "4821"
    let expirationDate = "12/30"
    let availableLimit = 3200.00
    let totalLimit = 5000.00
    let currentInvoice = 847.90

    var limitUsage: Double {
        guard totalLimit > 0 else { return 0 }
        return currentInvoice / totalLimit
    }
}
