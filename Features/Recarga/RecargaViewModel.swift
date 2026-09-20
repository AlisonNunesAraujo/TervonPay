// RecargaViewModel.swift — Lógica de recarga de celular
//
// CONEXÕES:
//   ← Criado por RecargaView.swift via private let
//   → Acessa DependencyContainer.shared.authRepository para ler e atualizar o saldo
//   → Acessa DependencyContainer.shared.transactionRepository para registrar a recarga no extrato
//
// CONCEITO:
//   A View valida os campos para guiar o usuário.
//   O ViewModel confirma as regras importantes antes de debitar o saldo e salvar a transação.

import Foundation

final class RecargaViewModel {
    private var authRepository        = DependencyContainer.shared.authRepository
    private var transactionRepository = DependencyContainer.shared.transactionRepository

    var currentBalance: Double {
        authRepository.currentUser()?.balance ?? 0
    }

    // Retorna nil em caso de sucesso, ou uma mensagem de erro
    func recharge(phone: String, operatorName: String, amount: Double) -> String? {
        guard let user = authRepository.currentUser() else {
            return "Usuário não encontrado."
        }
        guard phone.filter({ $0.isNumber }).count == 11 else {
            return "Informe um celular com DDD e 9 dígitos."
        }
        guard !operatorName.trimmingCharacters(in: .whitespaces).isEmpty else {
            return "Selecione uma operadora."
        }
        guard amount >= 10 else {
            return "O valor mínimo de recarga é R$ 10,00."
        }
        guard amount <= user.balance else {
            return "Saldo insuficiente. Seu saldo é \(user.balance.asCurrency)."
        }

        authRepository.updateBalance(user.balance - amount)

        let transaction = Transaction(
            title: "Recarga de celular",
            description: "\(operatorName) - \(phone)",
            amount: amount,
            type: .outgoing
        )
        transactionRepository.save(transaction)

        return nil
    }
}
