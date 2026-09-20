// TrazerSaldoViewModel.swift — Lógica de entrada de saldo
//
// CONEXÕES:
//   ← Criado por TrazerSaldoView.swift via private let
//   → Acessa DependencyContainer.shared.authRepository para ler e atualizar o saldo
//   → Acessa DependencyContainer.shared.transactionRepository para registrar a entrada no extrato
//
// CONCEITO:
//   Esta feature simula adicionar dinheiro à conta.
//   Em um app real, isso envolveria uma instituição externa ou compensação bancária.

import Foundation

final class TrazerSaldoViewModel {
    private var authRepository        = DependencyContainer.shared.authRepository
    private var transactionRepository = DependencyContainer.shared.transactionRepository

    var currentBalance: Double {
        authRepository.currentUser()?.balance ?? 0
    }

    // Retorna nil em caso de sucesso, ou uma mensagem de erro
    func addBalance(origin: String, amount: Double) -> String? {
        guard let user = authRepository.currentUser() else {
            return "Usuário não encontrado."
        }
        guard !origin.trimmingCharacters(in: .whitespaces).isEmpty else {
            return "Selecione a origem do saldo."
        }
        guard amount >= 10 else {
            return "O valor mínimo é R$ 10,00."
        }

        authRepository.updateBalance(user.balance + amount)

        let transaction = Transaction(
            title: "Saldo adicionado",
            description: origin,
            amount: amount,
            type: .incoming
        )
        transactionRepository.save(transaction)

        return nil
    }
}
