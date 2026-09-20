// HomeView.swift — Tela principal da carteira
//
// CONEXÕES:
//   ← Renderizada por RootView.swift quando currentScreen == .home
//   → Acessa AppViewModel.shared para logout (aba Menu)
//   → Usa HomeViewModel para carregar usuário e saldo
//   → Passa @Binding balance para PixView, que o atualiza após um Pix bem-sucedido
//   → Navega para PixView, PagamentosView, RecargaView, InvestirView, CartaoView e ExtratoView
//   → Cores definidas em Extensions.swift (Color.brandGreen / Color.brandGreenDark)
//   → QuickActionTile e ServiceRow são subviews privadas deste arquivo

import SwiftUI

private enum HomeSearchDestination: String, CaseIterable, Identifiable {
    case pix
    case pagamentos
    case recarga
    case investir
    case extrato
    case cartao

    var id: String { rawValue }

    var title: String {
        switch self {
        case .pix: return "Pix"
        case .pagamentos: return "Pagamentos"
        case .recarga: return "Recarga"
        case .investir: return "Investir"
        case .extrato: return "Extrato"
        case .cartao: return "Cartão"
        }
    }

    var subtitle: String {
        switch self {
        case .pix: return "Enviar dinheiro por chave Pix"
        case .pagamentos: return "Pagar boleto ou conta"
        case .recarga: return "Recarregar celular"
        case .investir: return "Acessar investimentos"
        case .extrato: return "Ver movimentações da conta"
        case .cartao: return "Gerenciar cartão"
        }
    }

    var icon: String {
        switch self {
        case .pix: return "diamond.fill"
        case .pagamentos: return "barcode"
        case .recarga: return "iphone"
        case .investir: return "chart.line.uptrend.xyaxis"
        case .extrato: return "doc.text"
        case .cartao: return "creditcard"
        }
    }

    func matches(_ query: String) -> Bool {
        let normalizedQuery = query.folding(options: .diacriticInsensitive, locale: .current).lowercased()
        let searchableText = "\(title) \(subtitle)"
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()
        return normalizedQuery.isEmpty || searchableText.contains(normalizedQuery)
    }
}

struct HomeView: View {
    private var appViewModel = AppViewModel.shared
    private let viewModel = HomeViewModel()

    @State private var showBalance = true
    @State private var selectedTab = 0
    @State private var showSearch = false
    @State private var searchDestination: HomeSearchDestination?
    // @State balance é atualizado via .onAppear e via @Binding passado ao PixView
    @State private var balance: Double = 0

    var body: some View {
        TabView(selection: $selectedTab) {

            NavigationStack {
                homeContent
            }
            .background(Color.brandGreen.ignoresSafeArea(edges: .top))
            .toolbarBackground(Color.brandGreen, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .tabItem { Label("Início", systemImage: "house.fill") }
            .tag(0)

            NavigationStack { CartaoView() }
                .tabItem { Label("Cartão", systemImage: "creditcard.fill") }
                .tag(1)

            NavigationStack { ProfileView() }
                .tabItem { Label("Perfil", systemImage: "person.fill") }
                .tag(2)
        }
        .tint(Color.brandGreen)
    }

    // MARK: - Home Content

    private var homeContent: some View {
        ZStack(alignment: .top) {
            Color.appBackground
                .ignoresSafeArea()

            // Faixa verde atrás da status bar e do começo do header.
            // Ela fica fora do ScrollView para não depender da posição do conteúdo rolável.
            VStack(spacing: 0) {
                Color.brandGreen
                    .frame(height: 260)
                Spacer()
            }
            .ignoresSafeArea(edges: .top)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    headerSection
                    contentSection
                }
            }
        }
        // Oculta a barra de navegação — o header verde customizado substitui ela
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(item: $searchDestination) { destination in
            destinationView(for: destination)
        }
        .sheet(isPresented: $showSearch) {
            HomeSearchSheet { destination in
                openSearchDestination(destination)
            }
        }
        // Relê o saldo do repositório sempre que a home aparece (inclusive ao voltar do Pix)
        .onAppear { balance = viewModel.balance }
    }

    @ViewBuilder
    private func destinationView(for destination: HomeSearchDestination) -> some View {
        switch destination {
        case .pix:
            PixView(balance: $balance)
        case .pagamentos:
            PagamentosView(balance: $balance)
        case .recarga:
            RecargaView(balance: $balance)
        case .investir:
            InvestirView()
        case .extrato:
            ExtratoView()
        case .cartao:
            CartaoView()
        }
    }

    private func openSearchDestination(_ destination: HomeSearchDestination) {
        if destination == .cartao {
            selectedTab = 1
        } else {
            searchDestination = destination
        }
    }

    // MARK: - Header (verde, com busca e card de saldo)

    private var headerSection: some View {
        VStack(spacing: 16) {

            // Linha superior: avatar | busca | ícones
            HStack(spacing: 10) {
                NavigationLink(destination: ProfileView()) {
                    Circle()
                        .fill(.white.opacity(0.25))
                        .frame(width: 42, height: 42)
                        .overlay {
                            Image(systemName: "person.fill")
                                .foregroundStyle(.white)
                        }
                }
                .buttonStyle(.plain)

                Button(action: { showSearch = true }) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.white.opacity(0.7))
                        Text("Buscar")
                            .foregroundStyle(.white.opacity(0.7))
                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(.white.opacity(0.18))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                NavigationLink(destination: NotificationsView()) {
                    Image(systemName: "bell")
                        .font(.title3)
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)

            // Card de saldo — verde escuro dentro do header
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Image(systemName: "wallet.bifold")
                        .foregroundStyle(.white.opacity(0.8))
                    Text("Conta")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                    Spacer()
                    // Navega para ExtratoView ao tocar em "Ver extrato"
                    NavigationLink(destination: ExtratoView()) {
                        HStack(spacing: 4) {
                            Text("Ver extrato")
                                .font(.subheadline)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                        }
                        .foregroundStyle(.white.opacity(0.8))
                    }
                    .buttonStyle(.plain)
                }

                HStack {
                    Text(showBalance ? balance.asCurrency : "R$ •••••")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .animation(.default, value: showBalance)
                    Spacer()
                    Button(action: { withAnimation { showBalance.toggle() } }) {
                        Image(systemName: showBalance ? "eye.slash" : "eye")
                            .font(.title3)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }

                Text("Rendendo 100% do CDI")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))

                NavigationLink(destination: TrazerSaldoView(balance: $balance)) {
                    Text("Trazer saldo")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(.white.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            .background(Color.brandGreenDark)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 16)
        }
        .padding(.top, 16)
        .padding(.bottom, 24)
        // .ignoresSafeArea no background estende o verde atrás do Dynamic Island/status bar
        .background(Color.brandGreen.ignoresSafeArea(edges: .top))
    }

    // MARK: - Conteúdo (tiles e serviços)

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 24) {

            // Tiles de ações rápidas — cada um navega para sua tela
            VStack(alignment: .leading, spacing: 16) {
                Text("Pro dia a dia")
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding(.horizontal, 16)

                HStack(spacing: 10) {
                    NavigationLink(destination: PixView(balance: $balance)) {
                        QuickActionTile(icon: "diamond.fill", title: "Pix", highlighted: true)
                    }
                    NavigationLink(destination: PagamentosView(balance: $balance)) {
                        QuickActionTile(icon: "barcode", title: "Pagamentos", highlighted: false)
                    }
                    NavigationLink(destination: RecargaView(balance: $balance)) {
                        QuickActionTile(icon: "iphone", title: "Recarga", highlighted: false)
                    }
                    NavigationLink(destination: InvestirView()) {
                        QuickActionTile(icon: "chart.line.uptrend.xyaxis", title: "Investir", highlighted: false)
                    }
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
            }

            // Serviços — linha simples com chevron
            VStack(spacing: 0) {
                Button(action: { selectedTab = 1 }) {
                    ServiceRow(icon: "creditcard", title: "Cartão")
                }
                .buttonStyle(.plain)
            }
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 20)
    }

}

// MARK: - Quick Action Tile (tile quadrado, sem Button — NavigationLink faz o tap)

private struct QuickActionTile: View {
    let icon: String
    let title: String
    let highlighted: Bool

    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 14)
                .fill(highlighted ? Color.brandGreen : Color.controlBackground)
                .frame(height: 62)
                .overlay {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(highlighted ? .white : .primary)
                }
            Text(title)
                .font(.caption)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Service Row (linha de serviço, sem Button — NavigationLink faz o tap)

private struct ServiceRow: View {
    let icon: String
    let title: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .frame(width: 36)
                .foregroundStyle(.primary)
            Text(title)
                .font(.subheadline)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }
}

// MARK: - Home Search

private struct HomeSearchSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onSelect: (HomeSearchDestination) -> Void

    @State private var searchText = ""

    private var results: [HomeSearchDestination] {
        HomeSearchDestination.allCases.filter { $0.matches(searchText) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Buscar no app", text: $searchText)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(12)
                .background(Color.controlBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 16)

                if results.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 34))
                            .foregroundStyle(Color.brandGreen.opacity(0.5))
                        Text("Nada encontrado")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            ForEach(Array(results.enumerated()), id: \.element.id) { index, destination in
                                if index > 0 { Divider().padding(.leading, 58) }

                                Button {
                                    dismiss()
                                    onSelect(destination)
                                } label: {
                                    SearchResultRow(destination: destination)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .background(Color.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.top, 12)
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("Buscar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fechar") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

private struct SearchResultRow: View {
    let destination: HomeSearchDestination

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.brandGreen.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: destination.icon)
                    .font(.subheadline)
                    .foregroundStyle(Color.brandGreen)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(destination.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                Text(destination.subtitle)
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
    HomeView()
}
