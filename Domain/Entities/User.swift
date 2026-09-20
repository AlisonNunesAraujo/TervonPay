// User.swift — Entidade principal do domínio
//
// CONEXÕES:
//   ← Salvo e carregado por AuthRepository.swift (Data/Repositories)
//   ← Retornado por AuthRepositoryProtocol após login e registro
//   → Será exibido na HomeView e ProfileView nas próximas features
//
// CONCEITO:
//   Entidades (Domain/Entities) são structs simples que representam
//   os dados do negócio. Elas NÃO importam frameworks como SwiftUI.
//   Isso garante que o domínio seja independente de qualquer plataforma.

import Foundation

struct User: Codable, Identifiable {
    let id: UUID
    var name: String
    var email: String
    var balance: Double

    init(name: String, email: String) {
        self.id = UUID()
        self.name = name
        self.email = email
        self.balance = 5000.0 // saldo inicial
    }
}
