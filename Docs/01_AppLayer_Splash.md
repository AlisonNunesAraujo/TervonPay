# Doc 01 — App Layer + Feature Splash

## Visão Geral

Esta doc cobre os arquivos base do app e a primeira feature (Splash).
Eles formam o esqueleto que sustenta todas as outras features.

---

## Arquivos e Responsabilidades

### TERVONApp.swift
Ponto de entrada do app (marcado com `@main`).
- Cria o `AppViewModel` uma única vez com `@State`
- Injeta o ViewModel no ambiente com `.environment(viewModel)`
- Renderiza `RootView` como tela raiz

### App/AppViewModel.swift
Cérebro da navegação global.
- Define `enum AppScreen` com todos os destinos principais: `.splash`, `.login`, `.home`
- Usa `@Observable` para que qualquer view que leia `currentScreen` atualize automaticamente
- Expõe funções de ação: `showLogin()`, `showHome()`, `logout()`

### App/RootView.swift
Roteador principal — decide qual tela renderizar.
- Lê `AppViewModel` via `@Environment`
- Faz um `switch` em `currentScreen` e renderiza a view correspondente
- Não tem lógica própria: só observa e delega

### App/DependencyContainer.swift
Singleton que vai centralizar repositórios e serviços.
- Ainda vazio; será preenchido conforme as features exigirem acesso a dados

### Features/Splash/SplashView.swift
Tela de abertura exibida ao iniciar o app.
- Exibe logo e tagline sobre fundo preto
- Usa `.task` para executar código assíncrono assim que a view aparece
- Após 2 segundos chama `viewModel.showLogin()` para avançar

---

## Fluxo de Dados

```
TERVONApp
    │
    ├── cria AppViewModel (currentScreen = .splash)
    └── renderiza RootView
            │
            └── switch currentScreen
                    │
                    ├── .splash  → SplashView
                    │       └── após 2s → viewModel.showLogin()
                    │                           └── currentScreen = .login
                    │
                    ├── .login   → LoginView (próxima feature)
                    └── .home    → HomeView  (feature futura)
```

---

## Conceitos Aprendidos

| Conceito | Onde aparece |
|---|---|
| `@main` | TERVONApp — marca o ponto de entrada |
| `@Observable` | AppViewModel — reatividade sem Combine |
| `@Environment` | RootView, SplashView — acesso ao ViewModel sem passar por parâmetro |
| `@State` | TERVONApp — mantém o ViewModel vivo enquanto o app roda |
| `.task` | SplashView — código async atrelado ao ciclo de vida da view |
| `withAnimation` | AppViewModel — anima as transições de tela automaticamente |

---

## Próxima Feature
**Authentication** — telas de login e cadastro dentro de `Features/Authentication/`
