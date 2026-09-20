// RecargaView.swift — Tela de Recarga de Celular
//
// CONEXÕES:
//   ← Acessada por HomeView.swift via NavigationLink no tile "Recarga"
//   ← Recebe @Binding balance de HomeView para atualizar o saldo ao voltar
//   → Usa RecargaViewModel para debitar o saldo e salvar a transação no extrato
//
// FLUXO DE 3 PASSOS:
//   1. dados      → usuário informa telefone, operadora e valor
//   2. confirmacao→ resumo completo antes de confirmar
//   3. sucesso    → confirmação visual após a recarga

import SwiftUI

private enum RecargaStep { case dados, confirmacao, sucesso }

private enum Operadora: String, CaseIterable {
    case vivo = "Vivo"
    case claro = "Claro"
    case tim = "TIM"
    case oi = "Oi"

    var icon: String {
        switch self {
        case .vivo: return "antenna.radiowaves.left.and.right"
        case .claro: return "dot.radiowaves.left.and.right"
        case .tim: return "phone.connection"
        case .oi: return "simcard"
        }
    }
}

struct RecargaView: View {
    @Binding var balance: Double

    private let viewModel = RecargaViewModel()

    @State private var step = RecargaStep.dados
    @State private var phone = ""
    @State private var selectedOperator: Operadora?
    @State private var amountText = ""
    @State private var errorMessage = ""
    @State private var rechargedAmount: Double = 0
    @State private var showPhoneError = false
    @State private var showOperatorError = false
    @State private var showAmountError = false

    private let rechargeValues: [Double] = [10, 15, 20, 30, 50, 100]

    private var phoneDigits: String {
        phone.filter { $0.isNumber }
    }

    private var isPhoneValid: Bool {
        phoneDigits.count == 11
    }

    private var amount: Double? {
        let clean = amountText
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: ".")
        return Double(clean)
    }

    private var isAmountValid: Bool {
        guard let amount else { return false }
        return amount >= 10
    }

    private var navigationTitle: String {
        switch step {
        case .dados: return "Recarga"
        case .confirmacao: return "Confirmar"
        case .sucesso: return "Recarga feita"
        }
    }

    var body: some View {
        Group {
            switch step {
            case .dados: dadosSection
            case .confirmacao: confirmacaoSection
            case .sucesso: sucessoSection
            }
        }
        .background(Color.appBackground)
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Passo 1: Dados da recarga

    private var dadosSection: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: "iphone")
                        .font(.system(size: 46))
                        .foregroundStyle(Color.brandGreen)
                    Text("Recarregar celular")
                        .font(.headline)
                    Text("Informe o número, operadora e valor")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 24)

                phoneField
                operatorSection
                amountSection

                Text("Saldo disponível: \(viewModel.currentBalance.asCurrency)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .opacity(errorMessage.isEmpty ? 0 : 1)

                Button(action: reviewRecharge) {
                    Text("Revisar recarga")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.brandGreen)
                .controlSize(.large)
                .padding(.horizontal, 24)

                Spacer()
            }
        }
    }

    private var phoneField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Celular")
                .font(.caption)
                .foregroundStyle(.secondary)

            TextField("(11) 99999-9999", text: $phone)
                .keyboardType(.phonePad)
                .textFieldStyle(.roundedBorder)
                .onChange(of: phone) { _, newValue in
                    let masked = maskPhone(newValue)
                    if masked != newValue { phone = masked }
                    showPhoneError = false
                    errorMessage = ""
                }

            Text(phone.isEmpty ? "Informe o número com DDD." : "Celular deve ter DDD + 9 dígitos.")
                .font(.caption)
                .foregroundStyle(.red)
                .opacity(showPhoneError && !isPhoneValid ? 1 : 0)
        }
        .padding(.horizontal, 24)
    }

    private var operatorSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Operadora")
                .font(.caption)
                .foregroundStyle(.secondary)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2), spacing: 10) {
                ForEach(Operadora.allCases, id: \.self) { operadora in
                    Button(action: {
                        selectedOperator = operadora
                        showOperatorError = false
                        errorMessage = ""
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: operadora.icon)
                                .font(.subheadline)
                            Text(operadora.rawValue)
                                .font(.subheadline)
                                .fontWeight(selectedOperator == operadora ? .semibold : .regular)
                            Spacer()
                        }
                        .foregroundStyle(selectedOperator == operadora ? .white : .primary)
                        .padding(12)
                        .background(selectedOperator == operadora ? Color.brandGreen : Color.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }

            Text("Selecione uma operadora.")
                .font(.caption)
                .foregroundStyle(.red)
                .opacity(showOperatorError && selectedOperator == nil ? 1 : 0)
        }
        .padding(.horizontal, 24)
    }

    private var amountSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Valor")
                .font(.caption)
                .foregroundStyle(.secondary)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
                ForEach(rechargeValues, id: \.self) { value in
                    Button(action: {
                        amountText = maskAmount(String(Int(value * 100)))
                        showAmountError = false
                        errorMessage = ""
                    }) {
                        Text(value.asCurrency)
                            .font(.subheadline)
                            .fontWeight(amount == value ? .semibold : .regular)
                            .foregroundStyle(amount == value ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(amount == value ? Color.brandGreen : Color.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }

            HStack {
                Text("R$")
                    .foregroundStyle(.secondary)
                TextField("Outro valor", text: $amountText)
                    .keyboardType(.decimalPad)
                    .onChange(of: amountText) { _, newValue in
                        let masked = maskAmount(newValue)
                        if masked != newValue { amountText = masked }
                        showAmountError = false
                        errorMessage = ""
                    }
            }
            .padding(12)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            Text(amountText.isEmpty ? "Informe um valor de recarga." : "Valor mínimo: R$ 10,00.")
                .font(.caption)
                .foregroundStyle(.red)
                .opacity(showAmountError && !isAmountValid ? 1 : 0)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Passo 2: Confirmação

    private var confirmacaoSection: some View {
        VStack(spacing: 24) {
            Text("Revise os dados antes de confirmar")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.top, 16)

            VStack(spacing: 0) {
                resumoLinha(label: "Celular", value: phone)
                Divider().padding(.leading, 16)
                resumoLinha(label: "Operadora", value: selectedOperator?.rawValue ?? "-")
                Divider().padding(.leading, 16)
                resumoLinha(label: "Valor", value: amount?.asCurrency ?? "-")
                Divider().padding(.leading, 16)
                resumoLinha(label: "Saldo atual", value: viewModel.currentBalance.asCurrency)
                Divider().padding(.leading, 16)
                resumoLinha(
                    label: "Saldo após",
                    value: (viewModel.currentBalance - (amount ?? 0)).asCurrency,
                    highlighted: true
                )
            }
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 24)

            VStack(spacing: 12) {
                Button(action: confirmRecharge) {
                    Text("Confirmar recarga")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.brandGreen)
                .controlSize(.large)

                Button(action: { step = .dados }) {
                    Text("Voltar e editar")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.secondary)
                .controlSize(.large)
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }

    private func resumoLinha(label: String, value: String, highlighted: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(highlighted ? .bold : .regular)
                .foregroundStyle(highlighted ? Color.brandGreen : .primary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    // MARK: - Passo 3: Sucesso

    private var sucessoSection: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 22) {
                ZStack {
                    Circle()
                        .fill(Color.brandGreen.opacity(0.12))
                        .frame(width: 100, height: 100)
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(Color.brandGreen)
                }

                VStack(spacing: 8) {
                    Text("Recarga realizada")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("\(rechargedAmount.asCurrency) enviados para")
                        .foregroundStyle(.secondary)
                    Text(phone)
                        .fontWeight(.medium)
                }

                Divider()

                VStack(spacing: 4) {
                    Text("Novo saldo")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(balance.asCurrency)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.brandGreen)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(24)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Spacer()
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Máscaras

    private func maskPhone(_ input: String) -> String {
        let digits = String(input.filter { $0.isNumber }.prefix(11))
        var result = ""

        for (index, character) in digits.enumerated() {
            if index == 0 { result += "(" }
            if index == 2 { result += ") " }
            if index == 7 { result += "-" }
            result += String(character)
        }

        return result
    }

    private func maskAmount(_ input: String) -> String {
        let digits = input.filter { $0.isNumber }
        guard !digits.isEmpty else { return "" }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","

        return formatter.string(from: NSNumber(value: (Double(digits) ?? 0) / 100)) ?? ""
    }

    // MARK: - Ações

    private func reviewRecharge() {
        errorMessage = ""
        showPhoneError = !isPhoneValid
        showOperatorError = selectedOperator == nil
        showAmountError = !isAmountValid

        guard isPhoneValid else { return }
        guard selectedOperator != nil else { return }
        guard let amount, amount >= 10 else { return }
        guard amount <= viewModel.currentBalance else {
            errorMessage = "Saldo insuficiente. Seu saldo é \(viewModel.currentBalance.asCurrency)."
            return
        }

        step = .confirmacao
    }

    private func confirmRecharge() {
        guard let amount, let selectedOperator else { return }

        if let error = viewModel.recharge(phone: phone, operatorName: selectedOperator.rawValue, amount: amount) {
            step = .dados
            errorMessage = error
            return
        }

        rechargedAmount = amount
        balance = viewModel.currentBalance
        step = .sucesso
    }
}

#Preview {
    NavigationStack {
        RecargaView(balance: .constant(5000.0))
    }
}
