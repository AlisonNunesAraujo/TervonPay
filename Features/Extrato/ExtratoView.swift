// ExtratoView.swift — Tela de extrato (histórico de movimentações)
//
// CONEXÕES:
//   ← Acessada por HomeView.swift via NavigationLink no botão "Ver extrato"
//   → Usa ExtratoViewModel para carregar saldo e lista de transações
//   → TransactionRow é uma subview privada deste arquivo

import SwiftUI

struct ExtratoView: View {
    private let viewModel = ExtratoViewModel()

    @State private var filtro = FiltroExtrato.todos
    // @State transactions relido do repositório sempre que a tela aparece
    @State private var transactions: [Transaction] = []

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                balanceCard
                filterPills
                transactionsList
            }
            .padding(16)
        }
        .background(Color.appBackground)
        .navigationTitle("Extrato")
        .navigationBarTitleDisplayMode(.inline)
        // Recarrega sempre que a tela aparece (inclusive ao voltar do Pix)
        .onAppear { transactions = viewModel.allTransactions }
    }

    // MARK: - Card de saldo

    private var balanceCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Saldo disponível")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.8))
            Text(viewModel.balance.asCurrency)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.brandGreen)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Filtros

    private var filterPills: some View {
        HStack(spacing: 8) {
            ForEach(FiltroExtrato.allCases, id: \.self) { tipo in
                Button(action: { filtro = tipo }) {
                    Text(tipo.rawValue)
                        .font(.subheadline)
                        .fontWeight(filtro == tipo ? .semibold : .regular)
                        .foregroundStyle(filtro == tipo ? .white : .primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(filtro == tipo ? Color.brandGreen : Color.controlBackground)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
    }

    // MARK: - Lista de transações

    private var transactionsList: some View {
        // Filtra o @State transactions que é atualizado via .onAppear
        let filtered = transactions.filter { transaction in
            switch filtro {
            case .todos:     return true
            case .enviados:  return transaction.type == .outgoing
            case .recebidos: return transaction.type == .incoming
            }
        }

        return VStack(spacing: 0) {
            if filtered.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 40))
                        .foregroundStyle(Color.brandGreen.opacity(0.4))
                    Text("Nenhuma movimentação")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(32)
                .background(Color.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(filtered.enumerated()), id: \.element.id) { index, transaction in
                        if index > 0 { Divider().padding(.leading, 56) }
                        TransactionRow(transaction: transaction)
                    }
                }
                .padding(.horizontal, 16)
                .background(Color.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }
}

// MARK: - Transaction Row

private struct TransactionRow: View {
    let transaction: Transaction

    private var isIncoming: Bool   { transaction.type == .incoming }
    private var amountColor: Color { isIncoming ? .green : .red }
    private var amountPrefix: String { isIncoming ? "+" : "-" }
    private var arrowIcon: String   { isIncoming ? "arrow.down" : "arrow.up" }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(amountColor.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: arrowIcon)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(amountColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(transaction.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(amountPrefix + transaction.amount.asCurrency)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(amountColor)
                Text(transaction.date, style: .date)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 14)
    }
}

#Preview {
    NavigationStack { ExtratoView() }
}
