// Transaction.swift — Entidade de transação financeira
//
// CONEXÕES:
//   ← Salva e carregada por TransactionRepository.swift (Data/Repositories)
//   ← Criada por PixViewModel após um Pix bem-sucedido
//   → Exibida por ExtratoView via TransactionRow

import Foundation

// Codable permite serializar para JSON e salvar no UserDefaults
enum TransactionType: String, Codable {
    case incoming   // entrada (ex: Pix recebido)
    case outgoing   // saída  (ex: Pix enviado)
}

struct Transaction: Codable, Identifiable {
    let id: UUID
    let title: String
    let description: String
    let amount: Double
    let date: Date
    let type: TransactionType

    // id gerado automaticamente — armazenado junto com os dados para persistência
    init(title: String, description: String, amount: Double, date: Date = .now, type: TransactionType) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.amount = amount
        self.date = date
        self.type = type
    }
}
