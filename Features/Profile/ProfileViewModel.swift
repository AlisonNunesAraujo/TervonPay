// ProfileViewModel.swift — Dados da tela de perfil
//
// CONEXÕES:
//   ← Criado por ProfileView.swift via private let
//   → Acessa DependencyContainer.shared.authRepository para carregar o usuário logado

import Foundation

final class ProfileViewModel {
    private var authRepository = DependencyContainer.shared.authRepository

    private var user: User? {
        authRepository.currentUser()
    }

    var name: String {
        user?.name ?? "Usuário"
    }

    var email: String {
        user?.email ?? "email@tervon.com"
    }

    var initials: String {
        let parts = name.split(separator: " ")
        let first = parts.first?.first.map(String.init) ?? "U"
        let last = parts.dropFirst().first?.first.map(String.init) ?? ""
        return (first + last).uppercased()
    }

    // Dados simulados para estudo. Em app real, viriam de API.
    let accountNumber = "000123-4"
    let agency = "0001"
}
