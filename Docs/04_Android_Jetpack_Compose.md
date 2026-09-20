# Doc 04 — Reescrevendo o TERVON em Android com Jetpack Compose

## Visão Geral

Esta doc explica como recriar o app TERVON no Android usando Kotlin + Jetpack Compose, mantendo a mesma ideia de código limpo e fácil de estudar.

O objetivo não é copiar linha por linha do SwiftUI. O objetivo é manter a mesma arquitetura mental:

- telas separadas por feature;
- ViewModels cuidando de regras;
- repositórios cuidando dos dados;
- entidades simples no domínio;
- navegação centralizada;
- UI declarativa com estado.

---

## Mapa Mental: SwiftUI → Jetpack Compose

| iOS SwiftUI | Android Jetpack Compose | Para que serve |
|---|---|---|
| `View` | `@Composable` | Define uma parte da interface |
| `@State` | `remember { mutableStateOf(...) }` | Estado local da tela |
| `@Binding` | Estado passado por parâmetro + callback | Permite uma tela alterar estado da anterior |
| `@Observable` | `ViewModel` + `StateFlow` | Estado observável de tela/app |
| `NavigationStack` | `NavHost` | Pilha de navegação |
| `NavigationLink` | `navController.navigate(...)` | Ir para outra tela |
| `TabView` | `NavigationBar` + `NavHost` | Abas inferiores |
| `UserDefaults` | `DataStore` | Persistência local simples |
| `Color(...)` extension | `ColorScheme` / arquivo `Theme.kt` | Cores do app |
| `DependencyContainer.shared` | Manual DI ou Hilt | Fornece repositórios para ViewModels |

---

## Estrutura de Pastas Sugerida

No Android, uma estrutura parecida ficaria assim:

```text
app/src/main/java/com/tervon/
├── app/
│   ├── TervonApp.kt
│   ├── AppViewModel.kt
│   ├── AppScreen.kt
│   └── DependencyContainer.kt
│
├── core/
│   ├── common/
│   │   ├── CurrencyExtensions.kt
│   │   └── TervonColors.kt
│   └── storage/
│       └── LocalStorage.kt
│
├── data/
│   └── repositories/
│       ├── AuthRepository.kt
│       └── TransactionRepository.kt
│
├── domain/
│   ├── entities/
│   │   ├── User.kt
│   │   └── Transaction.kt
│   └── repositories/
│       ├── AuthRepositoryProtocol.kt
│       └── TransactionRepositoryProtocol.kt
│
└── features/
    ├── authentication/
    │   ├── login/
    │   │   ├── LoginScreen.kt
    │   │   └── LoginViewModel.kt
    │   └── register/
    │       ├── RegisterScreen.kt
    │       └── RegisterViewModel.kt
    ├── home/
    │   ├── HomeScreen.kt
    │   └── HomeViewModel.kt
    ├── pix/
    ├── pagamentos/
    ├── recarga/
    ├── cartao/
    ├── extrato/
    ├── profile/
    ├── notifications/
    └── trazerSaldo/
```

A organização é quase igual à do iOS, só adaptando nomes para Kotlin.

---

## Entidades do Domínio

### User.kt

Equivalente ao `User.swift`.

```kotlin
data class User(
    val id: String,
    val name: String,
    val email: String,
    val balance: Double = 5000.0
)
```

### Transaction.kt

Equivalente ao `Transaction.swift`.

```kotlin
enum class TransactionType {
    INCOMING,
    OUTGOING
}

data class Transaction(
    val id: String,
    val title: String,
    val description: String,
    val amount: Double,
    val dateMillis: Long,
    val type: TransactionType
)
```

No Android, para salvar em `DataStore`, é mais simples guardar `dateMillis` em vez de `Date`.

---

## Repositórios

### Contratos

Em Swift usamos `protocol`. Em Kotlin usamos `interface`.

```kotlin
interface AuthRepositoryProtocol {
    suspend fun login(email: String, password: String): User
    suspend fun register(name: String, email: String, password: String): User
    suspend fun logout()
    suspend fun currentUser(): User?
    suspend fun updateBalance(newBalance: Double)
    suspend fun isLoggedIn(): Boolean
}
```

```kotlin
interface TransactionRepositoryProtocol {
    suspend fun save(transaction: Transaction)
    suspend fun all(): List<Transaction>
}
```

### Implementações

No iOS usamos `UserDefaults`. No Android, para estudo, use `DataStore`.

A ideia é a mesma:

```text
ViewModel
    ↓ chama
RepositoryProtocol
    ↓ implementado por
Repository concreto
    ↓ salva/carrega
DataStore
```

---

## App Layer

### AppScreen.kt

Equivalente ao `AppScreen` do Swift.

```kotlin
enum class AppScreen {
    SPLASH,
    LOGIN,
    HOME
}
```

### AppViewModel.kt

Equivalente ao `AppViewModel.swift`.

```kotlin
class AppViewModel(
    private val authRepository: AuthRepositoryProtocol
) : ViewModel() {

    private val _currentScreen = MutableStateFlow(AppScreen.SPLASH)
    val currentScreen: StateFlow<AppScreen> = _currentScreen

    fun checkAuthStatus() {
        viewModelScope.launch {
            _currentScreen.value = if (authRepository.isLoggedIn()) {
                AppScreen.HOME
            } else {
                AppScreen.LOGIN
            }
        }
    }

    fun showHome() {
        _currentScreen.value = AppScreen.HOME
    }

    fun logout() {
        viewModelScope.launch {
            authRepository.logout()
            _currentScreen.value = AppScreen.LOGIN
        }
    }
}
```

### RootScreen.kt

Equivalente ao `RootView.swift`.

```kotlin
@Composable
fun RootScreen(appViewModel: AppViewModel) {
    val currentScreen by appViewModel.currentScreen.collectAsState()

    when (currentScreen) {
        AppScreen.SPLASH -> SplashScreen(onFinished = appViewModel::checkAuthStatus)
        AppScreen.LOGIN -> LoginScreen(onLoginSuccess = appViewModel::showHome)
        AppScreen.HOME -> HomeScreen(onLogout = appViewModel::logout)
    }
}
```

---

## Navegação Principal

No iOS, a Home usa `TabView`.

No Android, use `Scaffold` com `NavigationBar`.

```kotlin
@Composable
fun HomeScreen() {
    var selectedTab by remember { mutableStateOf(HomeTab.HOME) }

    Scaffold(
        bottomBar = {
            NavigationBar {
                NavigationBarItem(
                    selected = selectedTab == HomeTab.HOME,
                    onClick = { selectedTab = HomeTab.HOME },
                    icon = { Icon(Icons.Default.Home, contentDescription = null) },
                    label = { Text("Início") }
                )

                NavigationBarItem(
                    selected = selectedTab == HomeTab.CARD,
                    onClick = { selectedTab = HomeTab.CARD },
                    icon = { Icon(Icons.Default.CreditCard, contentDescription = null) },
                    label = { Text("Cartão") }
                )

                NavigationBarItem(
                    selected = selectedTab == HomeTab.PROFILE,
                    onClick = { selectedTab = HomeTab.PROFILE },
                    icon = { Icon(Icons.Default.Person, contentDescription = null) },
                    label = { Text("Perfil") }
                )
            }
        }
    ) { padding ->
        when (selectedTab) {
            HomeTab.HOME -> HomeContent(modifier = Modifier.padding(padding))
            HomeTab.CARD -> CardScreen(modifier = Modifier.padding(padding))
            HomeTab.PROFILE -> ProfileScreen(modifier = Modifier.padding(padding))
        }
    }
}
```

---

## Equivalência das Features

| Feature iOS | Tela Android | Observação |
|---|---|---|
| `LoginView` | `LoginScreen` | Campos de e-mail/senha e chamada ao ViewModel |
| `RegisterView` | `RegisterScreen` | Cadastro e validação de senha |
| `HomeView` | `HomeScreen` | Tela principal com saldo e ações rápidas |
| `PixView` | `PixScreen` | Fluxo em etapas com validação |
| `PagamentosView` | `PaymentsScreen` | Pagar boleto/conta |
| `RecargaView` | `RechargeScreen` | Recarga de celular |
| `CartaoView` | `CardScreen` | Dados e configurações do cartão |
| `ExtratoView` | `StatementScreen` | Lista de transações |
| `ProfileView` | `ProfileScreen` | Dados do usuário e logout |
| `NotificationsView` | `NotificationsScreen` | Lista de notificações |
| `TrazerSaldoView` | `AddBalanceScreen` | Entrada de dinheiro na conta |

---

## Estado Local em Compose

No SwiftUI:

```swift
@State private var email = ""
```

No Compose:

```kotlin
var email by remember { mutableStateOf("") }
```

Campo de texto:

```kotlin
OutlinedTextField(
    value = email,
    onValueChange = { email = it },
    label = { Text("E-mail") },
    singleLine = true
)
```

---

## ViewModel de Feature

Exemplo com Recarga.

No iOS temos:

```text
RecargaView
    ↓ chama
RecargaViewModel.recharge()
    ↓ atualiza saldo
AuthRepository
    ↓ salva transação
TransactionRepository
```

No Android, a ideia fica igual:

```kotlin
class RechargeViewModel(
    private val authRepository: AuthRepositoryProtocol,
    private val transactionRepository: TransactionRepositoryProtocol
) : ViewModel() {

    suspend fun recharge(phone: String, operatorName: String, amount: Double): String? {
        val user = authRepository.currentUser() ?: return "Usuário não encontrado."

        if (phone.filter { it.isDigit() }.length != 11) {
            return "Informe um celular com DDD e 9 dígitos."
        }

        if (operatorName.isBlank()) {
            return "Selecione uma operadora."
        }

        if (amount < 10) {
            return "O valor mínimo de recarga é R$ 10,00."
        }

        if (amount > user.balance) {
            return "Saldo insuficiente."
        }

        authRepository.updateBalance(user.balance - amount)

        transactionRepository.save(
            Transaction(
                id = UUID.randomUUID().toString(),
                title = "Recarga de celular",
                description = "$operatorName - $phone",
                amount = amount,
                dateMillis = System.currentTimeMillis(),
                type = TransactionType.OUTGOING
            )
        )

        return null
    }
}
```

---

## UI de Cores e Tema

No iOS criamos cores em `Extensions.swift`:

```swift
Color.brandGreen
Color.appBackground
Color.cardBackground
Color.controlBackground
```

No Android, crie em `ui/theme/Color.kt`:

```kotlin
val BrandGreen = Color(0xFF21BF73)
val BrandGreenDark = Color(0xFF148F54)
```

E use no `Theme.kt`:

```kotlin
private val LightColors = lightColorScheme(
    primary = BrandGreen,
    background = Color(0xFFF4F4F6),
    surface = Color.White
)

private val DarkColors = darkColorScheme(
    primary = BrandGreen,
    background = Color.Black,
    surface = Color(0xFF1C1C1E)
)
```

Assim como no iOS, evite usar branco fixo para cards. Use `MaterialTheme.colorScheme.surface`.

---

## Formatando Moeda

No iOS:

```swift
balance.asCurrency
```

No Android:

```kotlin
fun Double.asCurrency(): String {
    val formatter = NumberFormat.getCurrencyInstance(Locale("pt", "BR"))
    return formatter.format(this)
}
```

Arquivo sugerido:

```text
core/common/CurrencyExtensions.kt
```

---

## Fluxo de Dados Geral

```text
Composable Screen
    ↓ evento do usuário
ViewModel
    ↓ valida regra
Repository Protocol
    ↓ implementação concreta
DataStore / memória local
    ↓ retorna estado
ViewModel
    ↓ expõe StateFlow ou resultado
Composable recompõe UI
```

Esse fluxo é equivalente ao SwiftUI do projeto atual.

---

## Ordem Recomendada Para Recriar no Android

1. Criar projeto Android com Kotlin + Jetpack Compose.
2. Criar `domain/entities`: `User`, `Transaction`, `TransactionType`.
3. Criar contratos de repositório em `domain/repositories`.
4. Criar `LocalStorage` com `DataStore`.
5. Criar `AuthRepository` e `TransactionRepository`.
6. Criar `DependencyContainer` simples.
7. Criar `AppViewModel`, `AppScreen` e `RootScreen`.
8. Criar `SplashScreen`.
9. Criar Login e Cadastro.
10. Criar Home com bottom navigation.
11. Criar Pix, Pagamentos, Recarga e Trazer Saldo.
12. Criar Extrato.
13. Criar Cartão, Perfil e Notificações.
14. Revisar dark mode usando `MaterialTheme.colorScheme`.

---

## Regras Para Manter o Código Limpo

| Regra | Motivo |
|---|---|
| Não colocar regra de negócio dentro do Composable | A tela deve cuidar da UI, não da regra |
| Usar ViewModel para validações importantes | Facilita testar e entender o fluxo |
| Usar Repository para persistência | Permite trocar DataStore por API futuramente |
| Manter entidades sem Compose | Domínio não deve depender de UI |
| Usar tema para cores | Evita bugs no modo escuro |
| Separar features por pasta | Facilita encontrar e estudar cada parte |
| Começar simples antes de usar Hilt | Melhor para aprender a arquitetura primeiro |

---

## Resumo

Para reescrever o TERVON em Android, mantenha a mesma arquitetura mental do iOS:

```text
App
Core
Domain
Data
Features
```

A diferença principal é a tecnologia:

```text
SwiftUI View      → @Composable
@State            → remember + mutableStateOf
@Observable       → ViewModel + StateFlow
UserDefaults      → DataStore
NavigationStack   → NavHost
TabView           → NavigationBar
```

Se você respeitar essa equivalência, o app Android vai continuar limpo, estudável e bem parecido com o projeto iOS atual.
