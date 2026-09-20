// PagamentosView.swift — Tela de Pagamentos
//
// CONEXÕES:
//   ← Acessada por HomeView.swift via NavigationLink no tile "Pagamentos"
//   ← Recebe @Binding balance de HomeView para atualizar o saldo ao voltar
//   → Usa PagamentosViewModel para pagar boleto/conta e salvar no extrato
//
// FLUXO DE 3 PASSOS:
//   1. dados      → usuário informa código, beneficiário e valor
//   2. confirmacao→ resumo completo antes de confirmar
//   3. sucesso    → confirmação visual após o pagamento

import SwiftUI

private enum PagamentoStep { case dados, confirmacao, sucesso }

struct PagamentosView: View {
    @Binding var balance: Double

    private let viewModel = PagamentosViewModel()

    @State private var step = PagamentoStep.dados
    @State private var barcode = ""
    @State private var payee = ""
    @State private var amountText = ""
    @State private var errorMessage = ""
    @State private var paidAmount: Double = 0

    private var amount: Double? {
        let clean = amountText
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: ".")
        return Double(clean)
    }

    private var cleanBarcode: String {
        barcode.filter { $0.isNumber }
    }

    private var navigationTitle: String {
        switch step {
        case .dados: return "Pagamentos"
        case .confirmacao: return "Confirmar"
        case .sucesso: return "Pago"
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

    // MARK: - Passo 1: Dados do pagamento

    private var dadosSection: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: "barcode")
                        .font(.system(size: 46))
                        .foregroundStyle(Color.brandGreen)
                    Text("Pagar boleto ou conta")
                        .font(.headline)
                    Text("Informe os dados do pagamento")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 24)

                VStack(spacing: 14) {
                    fieldContainer(title: "Código de barras") {
                        TextField("Digite ou cole o código", text: $barcode)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                            .onChange(of: barcode) { _, newValue in
                                let masked = maskBarcode(newValue)
                                if masked != newValue { barcode = masked }
                                errorMessage = ""
                            }
                    }

                    fieldContainer(title: "Beneficiário") {
                        TextField("Ex: Energia elétrica", text: $payee)
                            .textFieldStyle(.roundedBorder)
                            .autocorrectionDisabled()
                            .onChange(of: payee) { _, _ in errorMessage = "" }
                    }

                    fieldContainer(title: "Valor") {
                        HStack {
                            Text("R$")
                                .foregroundStyle(.secondary)
                            TextField("0,00", text: $amountText)
                                .keyboardType(.decimalPad)
                                .onChange(of: amountText) { _, newValue in
                                    let masked = maskAmount(newValue)
                                    if masked != newValue { amountText = masked }
                                    errorMessage = ""
                                }
                        }
                        .padding(12)
                        .background(Color.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(.horizontal, 24)

                Text("Saldo disponível: \(viewModel.currentBalance.asCurrency)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .opacity(errorMessage.isEmpty ? 0 : 1)

                Button(action: reviewPayment) {
                    Text("Revisar pagamento")
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

    private func fieldContainer<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            content()
        }
    }

    // MARK: - Passo 2: Confirmação

    private var confirmacaoSection: some View {
        VStack(spacing: 24) {
            Text("Revise os dados antes de pagar")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.top, 16)

            VStack(spacing: 0) {
                resumoLinha(label: "Beneficiário", value: payee)
                Divider().padding(.leading, 16)
                resumoLinha(label: "Código", value: barcode)
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
                Button(action: confirmPayment) {
                    Text("Confirmar pagamento")
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
        HStack(alignment: .top) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer(minLength: 16)
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

            ZStack {
                Circle()
                    .fill(Color.brandGreen.opacity(0.12))
                    .frame(width: 100, height: 100)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(Color.brandGreen)
            }

            VStack(spacing: 8) {
                Text("Pagamento realizado")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("\(paidAmount.asCurrency) pagos para")
                    .foregroundStyle(.secondary)
                Text(payee)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            VStack(spacing: 4) {
                Text("Novo saldo")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(balance.asCurrency)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.brandGreen)
            }
            .padding(16)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Spacer()
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Máscaras

    private func maskBarcode(_ input: String) -> String {
        let digits = String(input.filter { $0.isNumber }.prefix(48))
        return stride(from: 0, to: digits.count, by: 4)
            .map { index in
                let start = digits.index(digits.startIndex, offsetBy: index)
                let end = digits.index(start, offsetBy: min(4, digits.distance(from: start, to: digits.endIndex)))
                return String(digits[start..<end])
            }
            .joined(separator: " ")
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

    private func reviewPayment() {
        errorMessage = ""

        guard cleanBarcode.count >= 10 else {
            errorMessage = "Informe um código de barras válido."
            return
        }
        guard !payee.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Informe o beneficiário."
            return
        }
        guard let amount, amount > 0 else {
            errorMessage = "Informe um valor válido."
            return
        }
        guard amount <= viewModel.currentBalance else {
            errorMessage = "Saldo insuficiente. Seu saldo é \(viewModel.currentBalance.asCurrency)."
            return
        }

        step = .confirmacao
    }

    private func confirmPayment() {
        guard let amount else { return }

        if let error = viewModel.payBill(barcode: cleanBarcode, payee: payee, amount: amount) {
            step = .dados
            errorMessage = error
            return
        }

        paidAmount = amount
        balance = viewModel.currentBalance
        step = .sucesso
    }
}

#Preview {
    NavigationStack {
        PagamentosView(balance: .constant(5000.0))
    }
}
