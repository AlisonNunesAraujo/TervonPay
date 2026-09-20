# Feature 03 — Home

## Objetivo
Tela principal da carteira digital, exibida após login/cadastro bem-sucedido. Layout inspirado no PicPay: cabeçalho verde com saldo, ações rápidas e lista de transações recentes.

---

## Arquivos

### `Domain/Entities/Transaction.swift`
Define o modelo de dados de uma transação.
- `TransactionType`: enum com `.incoming` (entrada) e `.outgoing` (saída)
- `Transaction`: struct com `id`, `title`, `description`, `amount`, `date`, `type`
- Não tem lógica — é puro dado

### `Core/Common/Extensions.swift`
Extensões utilitárias compartilhadas no projeto.
- `Double.asCurrency`: formata um valor Double como moeda brasileira (R$ 1.000,00)
- Usado em `HomeView` para exibir saldo e valores das transações

### `Features/Home/HomeViewModel.swift`
ViewModel da Home — busca dados e prepara para a View.
- `currentUser`: lê o usuário logado via `AuthRepository`
- `firstName`: extrai o primeiro nome do usuário
- `balance`: saldo atual do usuário
- `recentTransactions`: lista mock de 5 transações para demonstração

### `Features/Home/HomeView.swift`
View principal da Home. Contém toda a UI e subviews privadas.

**Estrutura:**
```
TabView
├── homeContent (aba Início)
│   ├── headerSection    → cabeçalho verde com nome + saldo + botão olho
│   ├── quickActionsCard → 4 botões: Pix, Transferir, Pagar, Extrato
│   └── transactionsCard → lista de transações com dividers
├── placeholderTab (aba Pix)
├── placeholderTab (aba Cartões)
└── profileContent (aba Perfil) → exibe nome/email + botão Sair
```

**Subviews privadas no mesmo arquivo:**
- `QuickActionButton`: botão com ícone circular e label
- `TransactionRow`: linha de transação com ícone colorido, título, valor e data

### `App/RootView.swift`
Atualizado para renderizar `HomeView()` quando `currentScreen == .home` (antes mostrava um `Text` placeholder).

---

## Fluxo de Dados

```
AuthRepository (UserDefaults)
    ↓ currentUser()
HomeViewModel
    ↓ firstName, balance, recentTransactions
HomeView
    ↓ headerSection, quickActionsCard, transactionsCard
    ↓ profileContent → AppViewModel.logout() → volta para LoginView
```

---

## Decisões de Design

| Decisão | Motivo |
|---|---|
| `brandGreen` como `let` privado no arquivo | Evita repetição de `Color(red:...)` em cada subview |
| TabView com `.tint(brandGreen)` | Mantém cor da marca nos ícones e labels selecionados |
| `.ignoresSafeArea(edges: .top)` no background do header | Faz o verde cobrir a área da status bar, igual ao PicPay |
| `showBalance` com `.animation(.default)` | Troca suave entre valor e "•••••" sem recriar a view |
| Subviews como `struct` privados no mesmo arquivo | Mantém o código organizado sem proliferar arquivos desnecessários |
| Transações como mock no ViewModel | Sem backend — dados reais virão numa feature futura |
