// InvestirView.swift — Tela de Investimentos
//
// CONEXÕES:
//   ← Acessada por HomeView.swift via NavigationLink no tile "Investir"
//   → Futuramente usará InvestirViewModel para lógica de investimentos

import SwiftUI

struct InvestirView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 64))
                .foregroundStyle(Color.brandGreen)
            Text("Investir")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Em breve")
                .foregroundStyle(.secondary)
            Spacer()
        }
        .navigationTitle("Investir")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { InvestirView() }
}
