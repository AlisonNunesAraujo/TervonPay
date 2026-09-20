// PagamentosViewModel.swift — Lógica de pagamentos de boletos e contas
//
// CONEXÕES:
//   ← Criado por PagamentosView.swift via private let
//   → Acessa DependencyContainer.shared.authRepository para ler e atualizar o saldo
//   → Acessa DependencyContainer.shared.transactionRepository para registrar o pagamento no extrato
//
// CONCEITO:
//   A View cuida dos campos e da navegação entre etapas.
//   O ViewModel cuida da regra de negócio: validar saldo, debitar e salvar transação.

import Foundation

final class PagamentosViewModel {
    private var authRepository        = DependencyContainer.shared.authRepository
    private var transactionRepository = DependencyContainer.shared.transactionRepository

    var currentBalance: Double {
        authRepository.currentUser()?.balance ?? 0
    }

    // Retorna nil se o pagamento foi feito com sucesso, ou uma mensagem de erro
    func payBill(barcode: String, payee: String, amount: Double) -> String? {
        guard let user = authRepository.currentUser() else {
            return "Usuário não encontrado."
        }
        guard barcode.filter({ $0.isNumber }).count >= 10 else {
            return "Informe um código de barras válido."
        }
        guard !payee.trimmingCharacters(in: .whitespaces).isEmpty else {
            return "Informe o beneficiário."
        }
        guard amount > 0 else {
            return "Informe um valor válido."
        }
        guard amount <= user.balance else {
            return "Saldo insuficiente. Seu saldo é \(user.balance.asCurrency)."
        }

        authRepository.updateBalance(user.balance - amount)

        let transaction = Transaction(
            title: "Pagamento de boleto",
            description: payee,
            amount: amount,
            type: .outgoing
        )
        transactionRepository.save(transaction)

        return nil
    }
}
