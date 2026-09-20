// RegisterViewModel.swift — Lógica da tela de cadastro
//
// CONEXÕES:
//   ← Criado por RegisterView.swift via private let
//   → Acessa DependencyContainer.shared.authRepository para registrar

import Foundation

final class RegisterViewModel {
    private var authRepository = DependencyContainer.shared.authRepository

    func register(name: String, email: String, password: String) -> String? {
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else {
            return "Preencha todos os campos."
        }
        do {
            _ = try authRepository.register(name: name, email: email, password: password)
            return nil
        } catch {
            return error.localizedDescription
        }
    }
}
