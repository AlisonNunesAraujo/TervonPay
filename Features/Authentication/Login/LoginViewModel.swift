// LoginViewModel.swift — Lógica da tela de login
//
// CONEXÕES:
//   ← Criado por LoginView.swift via private let
//   → Acessa DependencyContainer.shared.authRepository para autenticar
//
// NOTA:
//   Não usa @Observable — errorMessage e isLoading vivem como @State na LoginView.
//   Isso evita re-renders causados pelo ViewModel enquanto o usuário digita.

import Foundation

final class LoginViewModel {
    private var authRepository = DependencyContainer.shared.authRepository

    // Retorna nil em caso de sucesso, ou a mensagem de erro
    func login(email: String, password: String) -> String? {
        guard !email.isEmpty, !password.isEmpty else {
            return "Preencha e-mail e senha."
        }
        do {
            _ = try authRepository.login(email: email, password: password)
            return nil
        } catch {
            return error.localizedDescription
        }
    }
}
