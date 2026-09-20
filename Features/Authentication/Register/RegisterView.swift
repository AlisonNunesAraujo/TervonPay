// RegisterView.swift — Tela de cadastro
//
// CONEXÕES:
//   ← Aberta por LoginView.swift via NavigationStack (navigationDestination)
//   → Acessa AppViewModel.shared para chamar showHome() após cadastro
//   → Usa RegisterViewModel apenas para chamar a lógica de registro

import SwiftUI

struct RegisterView: View {
    private var appViewModel = AppViewModel.shared
    private let viewModel = RegisterViewModel()

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var successMessage = ""
    @State private var isLoading = false
    @FocusState private var focusedField: Field?

    private enum Field {
        case name
        case email
        case password
    }

    private var isEmailValid: Bool { email.contains("@") && email.contains(".") }
    private var isPasswordValid: Bool { password.count >= 6 }

    var body: some View {
        VStack(spacing: 32) {
            header

            VStack(spacing: 12) {
                TextField("Nome completo", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    .textContentType(.name)
                    .submitLabel(.next)
                    .focused($focusedField, equals: .name)
                    .onSubmit { focusedField = .email }

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
                        .textContentType(.newPassword)
                        .submitLabel(.done)
                        .focused($focusedField, equals: .password)
                        .onSubmit { focusedField = nil }

                    Text("Mínimo 6 caracteres (\(password.count)/6)")
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
                .multilineTextAlignment(.center)
                .opacity(errorMessage.isEmpty && successMessage.isEmpty ? 0 : 1)

            registerButton

            Spacer()
        }
        .padding()
        .navigationTitle("Cadastro")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Subviews

    private var header: some View {
        VStack(spacing: 8) {
            Text("Criar conta")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Preencha seus dados para começar")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 20)
    }

    private var registerButton: some View {
        Button {
            isLoading = true
            errorMessage = ""
            successMessage = ""

            if let error = viewModel.register(name: name, email: email, password: password) {
                errorMessage = error
                isLoading = false
            } else {
                successMessage = "Conta criada com sucesso! Bem-vindo(a), \(name)!"
                // Pequena pausa para o usuário ver a mensagem antes de navegar
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(1.5))
                    appViewModel.showHome()
                }
            }
        } label: {
            if isLoading && successMessage.isEmpty {
                ProgressView()
            } else {
                Text("Criar conta").frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(isLoading || !isEmailValid || !isPasswordValid || name.isEmpty)
    }
}

#Preview {
    NavigationStack {
        RegisterView()
    }
}
