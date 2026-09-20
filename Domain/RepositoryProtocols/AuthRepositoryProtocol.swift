// AuthRepositoryProtocol.swift — Contrato (protocolo) da autenticação
//
// CONEXÕES:
//   ← Implementado por AuthRepository.swift (Data/Repositories)
//   ← Referenciado por LoginViewModel e RegisterViewModel via injeção de dependência
//   → Garante que os ViewModels não dependam da implementação concreta
//
// CONCEITO:
//   Protocols em Clean Architecture definem "o quê" deve ser feito, sem dizer "como".
//   Isso permite trocar a implementação (UserDefaults → API real) sem mudar
//   nenhuma linha dos ViewModels. Os ViewModels só conhecem o protocolo.

import Foundation

protocol AuthRepositoryProtocol {
    func login(email: String, password: String) throws -> User
    func register(name: String, email: String, password: String) throws -> User
    func logout()
    func currentUser() -> User?
    func updateBalance(_ newBalance: Double) // chamado por PixViewModel e outros após transações
    var isLoggedIn: Bool { get }
}
