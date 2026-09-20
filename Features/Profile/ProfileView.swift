// ProfileView.swift — Tela de perfil do usuário
//
// CONEXÕES:
//   ← Acessada por HomeView.swift ao tocar no avatar do header
//   → Usa ProfileViewModel para carregar os dados do usuário logado
//
// CONCEITO:
//   Esta tela apenas exibe dados da conta.
//   Alteração de cadastro ficaria para uma próxima feature.

import SwiftUI

struct ProfileView: View {
    private var appViewModel = AppViewModel.shared
    private let viewModel = ProfileViewModel()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                headerCard
                accountSection
                securitySection
                logoutButton
            }
            .padding(16)
        }
        .background(Color.appBackground)
        .navigationTitle("Perfil")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var headerCard: some View {
        VStack(spacing: 14) {
            Circle()
                .fill(Color.brandGreen.opacity(0.14))
                .frame(width: 86, height: 86)
                .overlay {
                    Text(viewModel.initials)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.brandGreen)
                }

            VStack(spacing: 4) {
                Text(viewModel.name)
                    .font(.title2)
                    .fontWeight(.bold)
                Text(viewModel.email)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Dados da conta

    private var accountSection: some View {
        VStack(spacing: 0) {
            ProfileInfoRow(icon: "person", title: "Nome", value: viewModel.name)
            Divider().padding(.leading, 58)
            ProfileInfoRow(icon: "envelope", title: "E-mail", value: viewModel.email)
            Divider().padding(.leading, 58)
            ProfileInfoRow(icon: "number", title: "Conta", value: viewModel.accountNumber)
            Divider().padding(.leading, 58)
            ProfileInfoRow(icon: "building.columns", title: "Agência", value: viewModel.agency)
        }
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Segurança

    private var securitySection: some View {
        VStack(spacing: 0) {
            ProfileActionRow(icon: "lock", title: "Alterar senha", subtitle: "Em breve")
            Divider().padding(.leading, 58)
            ProfileActionRow(icon: "shield", title: "Privacidade e segurança", subtitle: "Em breve")
            Divider().padding(.leading, 58)
            ProfileActionRow(icon: "questionmark.circle", title: "Ajuda", subtitle: "Central de atendimento")
        }
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Logout

    private var logoutButton: some View {
        Button(action: { appViewModel.logout() }) {
            Label("Sair da conta", systemImage: "rectangle.portrait.and.arrow.right")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(.red)
        .controlSize(.large)
        .padding(.top, 4)
    }
}

private struct ProfileInfoRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.brandGreen)
                .frame(width: 34)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

private struct ProfileActionRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.brandGreen)
                .frame(width: 34)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

#Preview {
    NavigationStack { ProfileView() }
}
