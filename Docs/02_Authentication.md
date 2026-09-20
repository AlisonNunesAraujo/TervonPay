# Doc 02 — Feature Authentication

## Visão Geral

Responsável por login, cadastro e persistência local do usuário.
Sem backend — todos os dados são salvos no UserDefaults do dispositivo.

---

## Arquivos e Responsabilidades

### Core/Storage/LocalStorage.swift
Wrapper sobre o `UserDefaults`.
- Converte qualquer `struct Codable` para `Data` (via `JSONEncoder`) antes de salvar
- Converte de volta com `JSONDecoder` ao carregar
- Motivo: UserDefaults só aceita tipos primitivos; structs precisam ser serializadas

### Domain/Entities/User.swift
Modelo de dados do usuário.
- `id: UUID` — identificador único gerado no cadastro
- `name`, `email`, `balance` — dados básicos
- Não importa SwiftUI — entidade pura de domínio

### Domain/RepositoryProtocols/AuthRepositoryProtocol.swift
Contrato (interface) de autenticação.
- Define `login()`, `register()`, `logout()`, `currentUser()`, `isLoggedIn`
- Os ViewModels dependem DESTE protocolo, não da implementação concreta
- Permite trocar UserDefaults por API futuramente sem mudar os ViewModels

### Data/Repositories/AuthRepository.swift
Implementação concreta do protocolo.
- Usa `LocalStorage` para persistir `User`, senha e estado de login
- Define `AuthError` com casos: `userNotFound`, `wrongPassword`, `emailAlreadyInUse`
- Chaves no UserDefaults: `tervon_user`, `tervon_password`, `tervon_logged_in`

### App/DependencyContainer.swift
Ponto central de criação de dependências.
- Cria `AuthRepository()` e o expõe como `AuthRepositoryProtocol`
- ViewModels recebem o repositório via `DependencyContainer.shared.authRepository`

### App/AppViewModel.swift *(atualizado)*
Ganhou `checkAuthStatus()`:
- Consulta `authRepository.isLoggedIn`
- Se logado → `.home`; se não → `.login`
- Chamado pela SplashView após o delay de abertura

### Features/Authentication/Login/LoginViewModel.swift
Lógica do login:
- Campos: `email`, `password`, `errorMessage`, `isLoading`
- `login(onSuccess:)` — valida campos, chama repositório, chama closure em caso de sucesso

### Features/Authentication/Login/LoginView.swift
Interface do login:
- Usa `@Bindable var viewModel = viewModel` para criar bindings com `@Observable`
- `NavigationStack` + `navigationDestination` para abrir RegisterView
- Chama `appViewModel.showHome()` na closure de sucesso do ViewModel

### Features/Authentication/Register/RegisterViewModel.swift
Lógica do cadastro:
- Campos: `name`, `email`, `password`, `confirmPassword`, `errorMessage`, `isLoading`
- Valida: campos vazios, senhas diferentes, senha < 6 caracteres
- `register(onSuccess:)` — mesma estrutura do LoginViewModel

### Features/Authentication/Register/RegisterView.swift
Interface do cadastro:
- Aberta por LoginView via `navigationDestination`
- Mesma estrutura da LoginView com campos extras (nome e confirmação)

---

## Fluxo de Dados

```
SplashView (após 2s)
    └── viewModel.checkAuthStatus()
            └── authRepository.isLoggedIn (UserDefaults)
                    ├── true  → currentScreen = .home
                    └── false → currentScreen = .login
                                    └── RootView exibe LoginView
                                            │
                                            ├── Entrar
                                            │   └── LoginViewModel.login()
                                            │       └── AuthRepository.login()
                                            │           └── LocalStorage (UserDefaults)
                                            │               ├── sucesso → showHome()
                                            │               └── falha   → errorMessage
                                            │
                                            └── Criar conta → RegisterView
                                                    └── RegisterViewModel.register()
                                                        └── AuthRepository.register()
                                                            └── LocalStorage (UserDefaults)
                                                                ├── sucesso → showHome()
                                                                └── falha   → errorMessage
```

---

## Conceitos Aprendidos

| Conceito | Onde aparece |
|---|---|
| `Codable` | User.swift — permite serialização JSON |
| `JSONEncoder` / `JSONDecoder` | LocalStorage — converte structs ↔ Data |
| `protocol` | AuthRepositoryProtocol — desacopla interface de implementação |
| `throws` / `do-catch` | AuthRepository + ViewModels — tratamento de erros tipados |
| `LocalizedError` | AuthError — exibe mensagens legíveis ao usuário |
| `@Bindable` | LoginView, RegisterView — cria bindings com `@Observable` |
| Closure `onSuccess` | ViewModels → Views — comunica resultado sem acoplar camadas |
| `DependencyContainer` | Injeção centralizada de dependências |

---

## Próxima Feature
**Home** — tela principal com saldo, ações rápidas e lista de transações recentes
