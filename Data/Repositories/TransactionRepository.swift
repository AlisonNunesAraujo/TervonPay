// TransactionRepository.swift — Implementação concreta do repositório de transações
//
// CONEXÕES:
//   ← Implementa TransactionRepositoryProtocol.swift (Domain/RepositoryProtocols)
//   ← Usa LocalStorage.swift (Core/Storage) para persistir no UserDefaults
//   ← Instanciado em DependencyContainer.swift

import Foundation

final class TransactionRepository: TransactionRepositoryProtocol {
    private let storage = LocalStorage.shared
    private let key = "tervon_transactions"

    // Salva uma nova transação no topo da lista (mais recente primeiro)
    func save(_ transaction: Transaction) {
        var list = all()
        list.insert(transaction, at: 0)
        storage.save(list, forKey: key)
    }

    // Retorna todas as transações salvas, ou lista vazia se ainda não houver nenhuma
    func all() -> [Transaction] {
        storage.load([Transaction].self, forKey: key) ?? []
    }
}
