// DependencyContainer.swift — Central de dependências do app
//
// CONEXÕES:
//   ← Acessado por LoginViewModel e RegisterViewModel para obter AuthRepository
//   ← Acessado por PixViewModel e ExtratoViewModel para obter TransactionRepository
//   → Cria e fornece instâncias concretas dos repositórios
//
// CONCEITO:
//   Em vez de cada ViewModel criar seu próprio repositório, o DependencyContainer
//   centraliza a criação. Isso facilita testes (pode-se substituir por mocks)
//   e garante que só existe uma instância de cada serviço (evita duplicação de dados).

import Foundation

final class DependencyContainer {
    static let shared = DependencyContainer()

    // Repositório de autenticação — usado por LoginViewModel e RegisterViewModel
    let authRepository: AuthRepositoryProtocol = AuthRepository()

    // Repositório de transações — usado por PixViewModel (salvar) e ExtratoViewModel (carregar)
    let transactionRepository: TransactionRepositoryProtocol = TransactionRepository()

    private init() {}
}
