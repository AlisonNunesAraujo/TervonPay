// ExtratoViewModel.swift — Lógica da tela de Extrato
//
// CONEXÕES:
//   ← Criado por ExtratoView.swift via private let
//   → Acessa DependencyContainer.shared.authRepository para carregar o saldo atual
//   → Acessa DependencyContainer.shared.transactionRepository para carregar as transações reais

import Foundation

// Filtros disponíveis na tela de extrato
enum FiltroExtrato: String, CaseIterable {
    case todos     = "Todos"
    case enviados  = "Enviados"
    case recebidos = "Recebidos"
}

final class ExtratoViewModel {
    private var authRepository        = DependencyContainer.shared.authRepository
    private var transactionRepository = DependencyContainer.shared.transactionRepository

    var balance: Double { authRepository.currentUser()?.balance ?? 0 }

    // Lê as transações reais salvas pelo TransactionRepository
    var allTransactions: [Transaction] { transactionRepository.all() }

    // Retorna as transações filtradas pelo tipo selecionado
    func filtered(by filtro: FiltroExtrato) -> [Transaction] {
        switch filtro {
        case .todos:     return allTransactions
        case .enviados:  return allTransactions.filter { $0.type == .outgoing }
        case .recebidos: return allTransactions.filter { $0.type == .incoming }
        }
    }
}
