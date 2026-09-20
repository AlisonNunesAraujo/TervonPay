// AuthRepository.swift — Implementação concreta da autenticação
//
// CONEXÕES:
//   ← Implementa AuthRepositoryProtocol.swift (Domain/RepositoryProtocols)
//   ← Usa LocalStorage.swift (Core/Storage) para persistir dados no dispositivo
//   ← Instanciado em DependencyContainer.swift (App/)
//   → Fornecido para LoginViewModel e RegisterViewModel via DependencyContainer
//
// CONCEITO:
//   O Repository isola "de onde os dados vêm" do resto do app.
//   Hoje os dados vêm do UserDefaults. Amanhã podem vir de uma API —
//   só este arquivo precisaria mudar, sem tocar em nenhuma View ou ViewModel.

import Foundation

// Erros possíveis durante a autenticação
enum AuthError: LocalizedError {
    case userNotFound
    case wrongPassword
    case emailAlreadyInUse

    var errorDescription: String? {
        switch self {
        case .userNotFound:      return "Usuário não encontrado."
        case .wrongPassword:     return "Senha incorreta."
        case .emailAlreadyInUse: return "Este e-mail já está cadastrado."
        }
    }
}

final class AuthRepository: AuthRepositoryProtocol {
    private let storage = LocalStorage.shared

    // Chaves usadas no UserDefaults para identificar cada dado salvo
    private enum Keys {
        static let user     = "tervon_user"
        static let password = "tervon_password"
        static let loggedIn = "tervon_logged_in"
    }

    func login(email: String, password: String) throws -> User {
        guard let user = storage.load(User.self, forKey: Keys.user),
              user.email.lowercased() == email.lowercased() else {
            throw AuthError.userNotFound
        }
        guard storage.load(String.self, forKey: Keys.password) == password else {
            throw AuthError.wrongPassword
        }
        storage.save(true, forKey: Keys.loggedIn)
        return user
    }

    func register(name: String, email: String, password: String) throws -> User {
        if let existing = storage.load(User.self, forKey: Keys.user),
           existing.email.lowercased() == email.lowercased() {
            throw AuthError.emailAlreadyInUse
        }
        let user = User(name: name, email: email)
        storage.save(user, forKey: Keys.user)
        storage.save(password, forKey: Keys.password)
        storage.save(true, forKey: Keys.loggedIn)
        return user
    }

    func updateBalance(_ newBalance: Double) {
        guard var user = currentUser() else { return }
        user.balance = newBalance
        storage.save(user, forKey: Keys.user)
    }

    func logout() {
        storage.save(false, forKey: Keys.loggedIn)
    }

    func currentUser() -> User? {
        storage.load(User.self, forKey: Keys.user)
    }

    var isLoggedIn: Bool {
        storage.load(Bool.self, forKey: Keys.loggedIn) ?? false
    }
}
