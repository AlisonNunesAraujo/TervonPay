# TERVON
## Ainda em desenvolvimento(algumas funções)
Aplicativo iOS de carteira digital desenvolvido em SwiftUI. O TERVON reúne, em um único fluxo, cadastro e autenticação local, consulta de saldo, envio de Pix, pagamento de contas, recarga de celular, entrada de saldo, extrato, cartão, notificações e perfil.

A intenção do projeto é demonstrar como um produto financeiro pode ser estruturado de forma clara e evolutiva no ecossistema Apple. Além da interface, o app implementa regras como validação de saldo, débito ou crédito na conta e criação de registros de transação. Atualmente, tudo funciona de forma local e serve como base para uma futura integração com serviços reais.

> O TERVON é um projeto demonstrativo. Ele não se conecta a uma instituição financeira, não movimenta dinheiro real e ainda não possui os requisitos de segurança necessários para uso em produção.

## O que o aplicativo oferece

- Cadastro e login de usuário;
- manutenção da sessão entre execuções do app;
- saldo inicial de R$ 5.000,00 para novas contas;
- envio de Pix com chave, valor e descrição;
- pagamento de conta por código de barras;
- recarga de celular;
- entrada de saldo a partir de uma origem informada;
- extrato com transações persistidas e filtros por tipo;
- área de cartão com limite e fatura demonstrativos;
- tela inicial com atalhos, busca, notificações e acesso ao perfil;
- encerramento da sessão pelo perfil.

Algumas áreas, como cartão, investimentos e notificações, usam dados demonstrativos. Já Pix, pagamento, recarga e entrada de saldo atualizam o usuário salvo e registram transações no dispositivo.

## Fluxo principal

O aplicativo começa pela tela de splash e verifica se há uma sessão salva no dispositivo. Quando encontra um usuário autenticado, segue direto para a Home. Caso contrário, apresenta o login, de onde também é possível acessar o cadastro.

O ponto de entrada é `TERVONApp`, que apresenta a `RootView`. A raiz observa o `AppViewModel` e escolhe entre `SplashView`, `LoginView` e `HomeView`. Depois da autenticação, a Home dá acesso a Pix, pagamentos, recarga, entrada de saldo, extrato, cartão, investimentos e perfil. A navegação dessas funcionalidades usa `NavigationStack`, `NavigationLink`, destinos tipados e uma `TabView`.

## Arquitetura

O projeto combina **MVVM**, separação em camadas inspirada em **Clean Architecture**, Repository Pattern e injeção de dependências. A divisão não é apenas organizacional: cada camada tem uma responsabilidade definida.

Na prática, as telas e seus ViewModels ficam em `Features`. Os ViewModels acessam os contratos declarados em `Domain`, enquanto `Data` fornece as implementações concretas desses contratos. A infraestrutura comum, incluindo a persistência local, fica em `Core`. A pasta `App` conecta essas partes e controla o estado geral da aplicação.

### App

Contém a composição e o estado global:

- `TERVONApp.swift`: ponto de entrada e configuração visual global da barra de navegação;
- `RootView.swift`: roteador das três fases principais do aplicativo;
- `AppViewModel.swift`: controla splash, autenticação, home e logout;
- `DependencyContainer.swift`: cria e compartilha as implementações dos repositórios.

### Domain

Representa as regras e os tipos centrais sem depender da interface:

- `User`: identidade, nome, e-mail e saldo;
- `Transaction`: valor, data, descrição e natureza de entrada ou saída;
- `AuthRepositoryProtocol`: contrato para autenticação, sessão e atualização de saldo;
- `TransactionRepositoryProtocol`: contrato para gravar e consultar movimentações.

Os ViewModels conhecem os protocolos, não os detalhes de armazenamento. Isso permite substituir a implementação local por uma API sem reescrever as telas e as regras de apresentação.

### Data

Implementa os contratos definidos no domínio:

- `AuthRepository`: cadastra, autentica, encerra a sessão, recupera o usuário atual e atualiza seu saldo;
- `TransactionRepository`: salva transações e retorna o histórico em ordem de inserção.

Essa camada concentra a origem dos dados. Hoje ela aponta para o armazenamento local; futuramente poderá coordenar API, cache e sincronização.

### Core

Reúne infraestrutura compartilhada:

- `LocalStorage`: codifica entidades com `JSONEncoder`, armazena os dados no `UserDefaults` e os recupera com `JSONDecoder`;
- `Extensions`: concentra utilitários reutilizados, como formatação monetária e comportamento de teclado.

### Features

Cada funcionalidade fica em sua própria pasta e, quando possui regra de negócio, é composta por uma `View` e um `ViewModel`. Atualmente, essa divisão contempla autenticação, Home, Pix, pagamentos, recarga, entrada de saldo, extrato, cartão, investimentos, notificações, perfil e splash.

As Views cuidam da composição visual, estados temporários de formulário e navegação. Os ViewModels validam entradas, consultam repositórios e executam alterações de saldo e histórico.

## Exemplo do fluxo de dados

Ao confirmar um Pix:

1. `PixView` coleta chave, valor e descrição;
2. `PixViewModel` verifica se existe usuário autenticado e saldo suficiente;
3. o saldo atualizado é enviado ao `AuthRepositoryProtocol`;
4. uma `Transaction` do tipo `.outgoing` é criada;
5. o `TransactionRepositoryProtocol` persiste a movimentação;
6. a Home e o Extrato recuperam o estado atualizado.

Pagamentos e recargas seguem o mesmo desenho. Em “Trazer saldo”, o valor é creditado e a transação é registrada como `.incoming`.

## Persistência atual

O app usa `UserDefaults` por meio de `LocalStorage`. As entidades conformam com `Codable` e são serializadas em JSON antes de serem salvas.

Entre os dados mantidos localmente estão:

- usuário cadastrado;
- indicador de sessão ativa;
- saldo atualizado;
- lista de transações.

Essa escolha reduz a infraestrutura necessária para a demonstração e deixa os fluxos utilizáveis sem internet. Entretanto, `UserDefaults` não é apropriado para credenciais e dados financeiros reais. Uma versão de produção deve utilizar backend autenticado, Keychain para segredos, comunicação segura, tratamento de concorrência, trilha de auditoria e regras transacionais no servidor.

## Tecnologias e decisões

- **Swift** como linguagem;
- **SwiftUI** para interface e navegação;
- **Observation** com `@Observable` para o estado global;
- **Foundation** para modelos, datas, codificação e persistência;
- **UIKit** somente na configuração global de aparência da `UINavigationBar`;
- **SF Symbols** para iconografia;
- **UserDefaults + Codable** como persistência local;
- protocolos de repositório para desacoplar domínio e infraestrutura;
- container compartilhado para centralizar a composição das dependências.

## Como executar

1. Clone ou baixe este repositório.
2. Abra o projeto `TERVON` no Xcode.
3. Selecione o scheme **TERVON**.
4. Escolha um simulador de iPhone ou dispositivo compatível.
5. Execute com **Run** (`⌘R`).
6. Na primeira abertura, crie uma conta; o cadastro gera o saldo inicial usado nos fluxos demonstrativos.

O projeto não exige servidor, chave de API ou configuração externa para o funcionamento atual.

## Organização da documentação

A pasta `Docs` registra decisões e etapas específicas da implementação:

- `01_AppLayer_Splash.md`: inicialização, raiz e splash;
- `02_Authentication.md`: cadastro, login e persistência da sessão;
- `03_Home.md`: composição da tela inicial e fluxo de dados;
- `04_Android_Jetpack_Compose.md`: referência de implementação equivalente para Android.

Este README apresenta a visão do produto como um todo; os documentos internos detalham partes da construção.

## Limitações conhecidas

- não existe backend nem sincronização entre dispositivos;
- as credenciais são tratadas apenas como dados locais de demonstração;
- não há integração real com Pix, boletos, operadoras ou cartões;
- cartão, investimentos e notificações contêm conteúdo estático ou demonstrativo;
- os dados do usuário e das transações não possuem escopo multiusuário robusto;
- ainda não há suíte automatizada de testes no projeto;
- validações e tratamento de erros são adequados ao protótipo, não a uma operação financeira real.

## Próximos passos recomendados

- substituir a autenticação local por uma API e armazenar tokens no Keychain;
- implementar casos de uso explícitos entre ViewModels e repositórios à medida que o domínio crescer;
- adicionar implementações assíncronas com `async/await`;
- criar testes unitários com Swift Testing para regras de saldo e autenticação;
- criar testes de interface com XCUIAutomation para os fluxos principais;
- introduzir armazenamento seguro e estratégia de migração de dados;
- conectar cartão, notificações e investimentos a fontes reais;
- tratar acessibilidade, localização e estados de carregamento ou indisponibilidade.

## Finalidade

O TERVON foi construído como uma base didática e evolutiva para uma carteira digital em iOS. Seu principal valor está em mostrar o caminho completo entre interface, regra de negócio e persistência, mantendo essas responsabilidades separadas. Assim, o aplicativo pode crescer de uma experiência local para uma solução conectada sem exigir que toda a camada de apresentação seja refeita.
