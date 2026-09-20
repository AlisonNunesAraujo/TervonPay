// CartaoView.swift — Tela do Cartão
//
// CONEXÕES:
//   ← Acessada por HomeView.swift via NavigationLink na linha "Cartão"
//   ← Também exibida diretamente na aba "Cartão" do TabView em HomeView.swift
//   → Usa CartaoViewModel para exibir dados simulados do cartão
//
// CONCEITO:
//   Esta tela mostra uma feature de cartão sem mexer no saldo da conta.
//   Estado visual como mostrar número e bloquear cartão fica em @State na View.

import SwiftUI

struct CartaoView: View {
    private let viewModel = CartaoViewModel()

    @State private var showCardNumber = false
    @State private var isCardLocked = false
    @State private var onlinePurchasesEnabled = true
    @State private var contactlessEnabled = true

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                cardPreview
                invoiceSection
                quickActionsSection
                settingsSection
            }
            .padding(16)
        }
        .background(Color.appBackground)
        .navigationTitle("Cartão")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Cartão visual

    private var cardPreview: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack {
                Text("TERVON")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                Image(systemName: isCardLocked ? "lock.fill" : "creditcard.fill")
                    .font(.title3)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(showCardNumber ? "•••• •••• •••• \(viewModel.cardLastDigits)" : "•••• •••• •••• ••••")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .monospacedDigit()

                HStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Nome")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.65))
                        Text(viewModel.cardholderName)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Validade")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.65))
                        Text(viewModel.expirationDate)
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                }
            }

            Button(action: { withAnimation { showCardNumber.toggle() } }) {
                Label(showCardNumber ? "Ocultar número" : "Mostrar número", systemImage: showCardNumber ? "eye.slash" : "eye")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(.white.opacity(0.16))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
        }
        .foregroundStyle(.white)
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Color.brandGreen, Color.brandGreenDark],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    // MARK: - Fatura e limite

    private var invoiceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Fatura atual")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(viewModel.currentInvoice.asCurrency)
                    .font(.title2)
                    .fontWeight(.bold)
            }

            VStack(alignment: .leading, spacing: 8) {
                ProgressView(value: viewModel.limitUsage)
                    .tint(Color.brandGreen)
                HStack {
                    Text("Limite disponível")
                    Spacer()
                    Text(viewModel.availableLimit.asCurrency)
                        .fontWeight(.semibold)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }

            Button(action: {}) {
                Text("Pagar fatura")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.brandGreen)
            .controlSize(.large)
        }
        .padding(16)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Ações rápidas

    private var quickActionsSection: some View {
        HStack(spacing: 10) {
            CardActionButton(icon: "doc.text", title: "Fatura")
            CardActionButton(icon: "slider.horizontal.3", title: "Limite")
            CardActionButton(icon: "number", title: "Virtual")
            CardActionButton(icon: "questionmark.circle", title: "Ajuda")
        }
    }

    // MARK: - Configurações

    private var settingsSection: some View {
        VStack(spacing: 0) {
            ToggleRow(
                icon: "lock",
                title: "Bloquear cartão",
                subtitle: isCardLocked ? "Cartão bloqueado temporariamente" : "Cartão liberado para uso",
                isOn: $isCardLocked,
                tint: .red
            )

            Divider().padding(.leading, 58)

            ToggleRow(
                icon: "globe",
                title: "Compras online",
                subtitle: "Permitir pagamentos na internet",
                isOn: $onlinePurchasesEnabled,
                tint: Color.brandGreen
            )

            Divider().padding(.leading, 58)

            ToggleRow(
                icon: "wave.3.right",
                title: "Aproximação",
                subtitle: "Pagar aproximando o cartão",
                isOn: $contactlessEnabled,
                tint: Color.brandGreen
            )
        }
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

}

// MARK: - Componentes privados

private struct CardActionButton: View {
    let icon: String
    let title: String

    var body: some View {
        Button(action: {}) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                    .frame(height: 26)
                Text(title)
                    .font(.caption)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}

private struct ToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    let tint: Color

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(tint)
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

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(tint)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

#Preview {
    NavigationStack { CartaoView() }
}
