// TransactionRepositoryProtocol.swift — Contrato do repositório de transações
//
// CONEXÕES:
//   ← Implementado por TransactionRepository.swift (Data/Repositories)
//   ← Acessado por PixViewModel (salvar) e ExtratoViewModel (carregar)
//   → Garante que os ViewModels não dependam da implementação concreta

import Foundation

protocol TransactionRepositoryProtocol {
    func save(_ transaction: Transaction)
    func all() -> [Transaction]
}
