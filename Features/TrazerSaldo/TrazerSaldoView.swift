// TrazerSaldoView.swift — Tela para adicionar saldo à conta
//
// CONEXÕES:
//   ← Acessada por HomeView.swift no botão "Trazer saldo"
//   ← Recebe @Binding balance de HomeView para atualizar o saldo ao voltar
//   → Usa TrazerSaldoViewModel para creditar o saldo e salvar a transação no extrato
//
// FLUXO DE 3 PASSOS:
//   1. dados      → usuário escolhe origem e valor
//   2. confirmacao→ resumo antes de confirmar
//   3. sucesso    → confirmação visual após adicionar saldo

import SwiftUI

private enum TrazerSaldoStep { case dados, confirmacao, sucesso }

private enum OrigemSaldo: String, CaseIterable {
    case outraConta = "Outra conta"
    case deposito = "Depósito"
    case salario = "Salário"
    case rendimento = "Rendimento"

    var icon: String {
        switch self {
        case .outraConta: return "building.columns"
        case .deposito: return "tray.and.arrow.down"
        case .salario: return "briefcase"
        case .rendimento: return "chart.line.uptrend.xyaxis"
        }
    }
}

struct TrazerSaldoView: View {
    @Binding var balance: Double

    private let viewModel = TrazerSaldoViewModel()

    @State private var step = TrazerSaldoStep.dados
    @State private var selectedOrigin: OrigemSaldo?
    @State private var amountText = ""
    @State private var errorMessage = ""
    @State private var addedAmount: Double = 0
    @State private var showOriginError = false
    @State private var showAmountError = false

    private let quickValues: [Double] = [50, 100, 200, 500, 1000, 2000]

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
        case .dados: return "Trazer saldo"
        case .confirmacao: return "Confirmar"
        case .sucesso: return "Saldo adicionado"
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

    // MARK: - Passo 1: Dados

    private var dadosSection: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 46))
                        .foregroundStyle(Color.brandGreen)
                    Text("Adicionar dinheiro")
                        .font(.headline)
                    Text("Escolha a origem e informe o valor")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 24)

                originSection
                amountSection

                Text("Saldo atual: \(viewModel.currentBalance.asCurrency)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .opacity(errorMessage.isEmpty ? 0 : 1)

                Button(action: reviewBalance) {
                    Text("Revisar entrada")
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

    private var originSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Origem")
                .font(.caption)
                .foregroundStyle(.secondary)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2), spacing: 10) {
                ForEach(OrigemSaldo.allCases, id: \.self) { origin in
                    Button(action: {
                        selectedOrigin = origin
                        showOriginError = false
                        errorMessage = ""
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: origin.icon)
                                .font(.subheadline)
                            Text(origin.rawValue)
                                .font(.subheadline)
                                .fontWeight(selectedOrigin == origin ? .semibold : .regular)
                                .lineLimit(1)
                                .minimumScaleFactor(0.85)
                            Spacer()
                        }
                        .foregroundStyle(selectedOrigin == origin ? .white : .primary)
                        .padding(12)
                        .background(selectedOrigin == origin ? Color.brandGreen : Color.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }

            Text("Selecione a origem do saldo.")
                .font(.caption)
                .foregroundStyle(.red)
                .opacity(showOriginError && selectedOrigin == nil ? 1 : 0)
        }
        .padding(.horizontal, 24)
    }

    private var amountSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Valor")
                .font(.caption)
                .foregroundStyle(.secondary)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
                ForEach(quickValues, id: \.self) { value in
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

            Text(amountText.isEmpty ? "Informe um valor." : "Valor mínimo: R$ 10,00.")
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
                resumoLinha(label: "Origem", value: selectedOrigin?.rawValue ?? "-")
                Divider().padding(.leading, 16)
                resumoLinha(label: "Valor", value: amount?.asCurrency ?? "-")
                Divider().padding(.leading, 16)
                resumoLinha(label: "Saldo atual", value: viewModel.currentBalance.asCurrency)
                Divider().padding(.leading, 16)
                resumoLinha(
                    label: "Saldo após",
                    value: (viewModel.currentBalance + (amount ?? 0)).asCurrency,
                    highlighted: true
                )
            }
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 24)

            VStack(spacing: 12) {
                Button(action: confirmBalance) {
                    Text("Confirmar entrada")
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
                    Text("Saldo adicionado")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("\(addedAmount.asCurrency) entraram na sua conta")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
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

    private func reviewBalance() {
        errorMessage = ""
        showOriginError = selectedOrigin == nil
        showAmountError = !isAmountValid

        guard selectedOrigin != nil else { return }
        guard let amount, amount >= 10 else { return }

        step = .confirmacao
    }

    private func confirmBalance() {
        guard let amount, let selectedOrigin else { return }

        if let error = viewModel.addBalance(origin: selectedOrigin.rawValue, amount: amount) {
            step = .dados
            errorMessage = error
            return
        }

        addedAmount = amount
        balance = viewModel.currentBalance
        step = .sucesso
    }
}

#Preview {
    NavigationStack {
        TrazerSaldoView(balance: .constant(5000.0))
    }
}
