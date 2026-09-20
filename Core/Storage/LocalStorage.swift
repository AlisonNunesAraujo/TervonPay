// LocalStorage.swift — Camada de persistência local (UserDefaults)
//
// CONEXÕES:
//   ← Usado por AuthRepository.swift para salvar/carregar dados do usuário
//   → Futuras features que precisem de persistência local também usarão este arquivo
//
// CONCEITO:
//   UserDefaults só armazena tipos primitivos (String, Int, Bool, Data).
//   Para salvar structs customizadas (como User), convertemos para Data via JSONEncoder.
//   Para recuperar, usamos JSONDecoder para converter de volta para o tipo original.

import Foundation

final class LocalStorage {
    static let shared = LocalStorage()
    private let defaults = UserDefaults.standard

    private init() {}

    // Salva qualquer tipo que pode ser convertido para JSON (Encodable)
    func save<T: Encodable>(_ value: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: key)
        }
    }

    // Carrega e converte de JSON para o tipo solicitado (Decodable)
    func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    // Remove um valor salvo
    func remove(forKey key: String) {
        defaults.removeObject(forKey: key)
    }
}
