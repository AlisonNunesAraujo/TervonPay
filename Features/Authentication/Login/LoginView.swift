// LoginView.swift — Tela de login
//
// CONEXÕES:
//   ← Renderizada por RootView.swift quando currentScreen == .login
//   → Acessa AppViewModel.shared para chamar showHome() ao logar
//   → Usa LoginViewModel apenas para chamar a lógica de autenticação
//   → Navega para RegisterView ao tocar em "Criar conta"

import SwiftUI

struct LoginView: View {
    private var appViewModel = AppViewModel.shared
    private let viewModel = LoginViewModel()

    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var successMessage = ""
    @State private var isLoading = false
    @State private var showRegister = false
    @FocusState private var focusedField: Field?

    private enum Field {
        case email
        case password
    }

    private var isEmailValid: Bool { email.contains("@") && email.contains(".") }
    private var isPasswordValid: Bool { password.count >= 6 }

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                header

                VStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("E-mail", text: $email)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .textContentType(.emailAddress)
                            .submitLabel(.next)
                            .focused($focusedField, equals: .email)
                            .onSubmit { focusedField = .password }

                        Text("E-mail inválido")
                            .font(.caption)
                            .foregroundStyle(.red)
                            .opacity(!email.isEmpty && !isEmailValid ? 1 : 0)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        SecureField("Senha", text: $password)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.password)
                            .submitLabel(.done)
                            .focused($focusedField, equals: .password)
                            .onSubmit { focusedField = nil }

                        Text("Mínimo 6 caracteres")
                            .font(.caption)
                            .foregroundStyle(.red)
                            .opacity(!password.isEmpty && !isPasswordValid ? 1 : 0)
                    }
                }

                // Mensagem de erro ou sucesso — .opacity mantém hierarquia estável
                Text(errorMessage.isEmpty ? successMessage : errorMessage)
                    .font(.caption)
                    .fontWeight(successMessage.isEmpty ? .regular : .medium)
                    .foregroundStyle(errorMessage.isEmpty ? .green : .red)
                    .opacity(errorMessage.isEmpty && successMessage.isEmpty ? 0 : 1)

                loginButton

                Button("Não tem conta? Criar agora") {
                    showRegister = true
                }
                .foregroundStyle(.secondary)
                .font(.footnote)

                Spacer()
            }
            .padding()
            .navigationDestination(isPresented: $showRegister) {
                RegisterView()
            }
        }
    }

    // MARK: - Subviews

    private var header: some View {
        VStack(spacing: 8) {
            Text("TERVON")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Entre na sua conta")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 40)
    }

    private var loginButton: some View {
        Button {
            isLoading = true
            errorMessage = ""
            successMessage = ""

            if let error = viewModel.login(email: email, password: password) {
                errorMessage = error
                isLoading = false
            } else {
                successMessage = "Login realizado! Entrando..."
                // Pequena pausa para o usuário ver a mensagem antes de navegar
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(1))
                    appViewModel.showHome()
                }
            }
        } label: {
            if isLoading && successMessage.isEmpty {
                ProgressView()
            } else {
                Text("Entrar").frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(isLoading || !isEmailValid || !isPasswordValid)
    }
}

#Preview {
    LoginView()
}
