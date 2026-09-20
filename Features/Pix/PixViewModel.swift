// PixViewModel.swift — Lógica de envio de Pix
//
// CONEXÕES:
//   ← Criado por PixView.swift via private let
//   → Acessa DependencyContainer.shared.authRepository para ler e atualizar o saldo
//   → Acessa DependencyContainer.shared.transactionRepository para registrar a transação
//   → Após um Pix bem-sucedido: debita o saldo E salva a transação no extrato

import Foundation

final class PixViewModel {
    private var authRepository        = DependencyContainer.shared.authRepository
    private var transactionRepository = DependencyContainer.shared.transactionRepository

    // Saldo atual do usuário — relido do repositório a cada chamada
    var currentBalance: Double {
        authRepository.currentUser()?.balance ?? 0
    }

    // Retorna nil se o Pix foi enviado com sucesso, ou uma mensagem de erro
    func sendPix(to chave: String, amount: Double, description: String) -> String? {
        guard let user = authRepository.currentUser() else {
            return "Usuário não encontrado."
        }
        guard amount > 0 else {
            return "Informe um valor válido."
        }
        guard amount <= user.balance else {
            return "Saldo insuficiente. Seu saldo é \(user.balance.asCurrency)."
        }

        // 1. Debita o saldo
        authRepository.updateBalance(user.balance - amount)

        // 2. Registra a transação para aparecer no extrato
        let desc = description.isEmpty ? "Para: \(chave)" : description
        let transaction = Transaction(
            title: "Pix enviado",
            description: desc,
            amount: amount,
            type: .outgoing
        )
        transactionRepository.save(transaction)

        return nil
    }
}
