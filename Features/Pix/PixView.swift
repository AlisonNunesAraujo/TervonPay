// PixView.swift — Tela de envio de Pix
//
// CONEXÕES:
//   ← Acessada por HomeView.swift via NavigationLink no tile "Pix"
//   ← Recebe @Binding balance de HomeView para atualizar o saldo ao voltar
//   → Usa PixViewModel para processar o envio e atualizar o saldo no repositório
//
// FLUXO DE 4 PASSOS:
//   1. chave      → usuário escolhe o tipo de chave e digita a chave do destinatário
//   2. valor      → usuário informa o valor e a descrição
//   3. confirmacao→ resumo completo antes de confirmar
//   4. sucesso    → confirmação visual após o envio

import SwiftUI

// Etapas do fluxo de Pix
private enum PixStep { case chave, valor, confirmacao, sucesso }

// Tipos de chave Pix com suas propriedades
private enum TipoChave: String, CaseIterable {
    case email     = "E-mail"
    case telefone  = "Telefone"
    case cpf       = "CPF"
    case cnpj      = "CNPJ"
    case aleatoria = "Aleatória"

    var placeholder: String {
        switch self {
        case .email:     return "exemplo@email.com"
        case .telefone:  return "(11) 99999-9999"
        case .cpf:       return "000.000.000-00"
        case .cnpj:      return "00.000.000/0001-00"
        case .aleatoria: return "Chave aleatória (UUID)"
        }
    }

    var icon: String {
        switch self {
        case .email:     return "envelope"
        case .telefone:  return "phone"
        case .cpf:       return "person"
        case .cnpj:      return "building.2"
        case .aleatoria: return "key"
        }
    }

    var keyboardType: UIKeyboardType {
        switch self {
        case .email:           return .emailAddress
        case .telefone:        return .phonePad
        case .cpf, .cnpj:     return .numberPad
        case .aleatoria:       return .default
        }
    }
}

struct PixView: View {
    // @Binding: referência direta ao @State balance de HomeView
    @Binding var balance: Double

    private let viewModel = PixViewModel()

    @State private var step         = PixStep.chave
    @State private var tipoChave    = TipoChave.email
    @State private var chave        = ""
    @State private var valorTexto   = ""
    @State private var descricao    = ""
    @State private var errorMessage = ""
    @State private var valorEnviado: Double = 0
    // Controla se deve mostrar erro de validação (só após tocar em "Continuar")
    @State private var mostrarErroChave = false

    var body: some View {
        Group {
            switch step {
            case .chave:        chaveSection
            case .valor:        valorSection
            case .confirmacao:  confirmacaoSection
            case .sucesso:      sucessoSection
            }
        }
        .background(Color.appBackground)
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var navigationTitle: String {
        switch step {
        case .chave:        return "Pix"
        case .valor:        return "Valor"
        case .confirmacao:  return "Confirmar"
        case .sucesso:      return "Pix enviado"
        }
    }

    // MARK: - Validações

    // Valida a chave de acordo com o tipo selecionado
    private var isChaveValida: Bool {
        let digitos = chave.filter { $0.isNumber }
        switch tipoChave {
        case .email:
            let partes = chave.split(separator: "@")
            return partes.count == 2 && (partes.last?.contains(".") == true)
        case .telefone:
            return digitos.count == 10 || digitos.count == 11
        case .cpf:
            return digitos.count == 11
        case .cnpj:
            return digitos.count == 14
        case .aleatoria:
            return !chave.trimmingCharacters(in: .whitespaces).isEmpty
        }
    }

    private var mensagemErroChave: String {
        if chave.isEmpty { return "Informe a chave Pix." }
        switch tipoChave {
        case .email:     return "E-mail inválido."
        case .telefone:  return "Telefone deve ter 10 ou 11 dígitos."
        case .cpf:       return "CPF deve ter 11 dígitos."
        case .cnpj:      return "CNPJ deve ter 14 dígitos."
        case .aleatoria: return "Informe a chave."
        }
    }

    // Converte o valor formatado ("1.234,56") para Double
    private var valorDouble: Double? {
        let clean = valorTexto
            .replacingOccurrences(of: ".", with: "")  // remove separador de milhar
            .replacingOccurrences(of: ",", with: ".")  // vírgula decimal → ponto
        return Double(clean)
    }

    private var isValorValido: Bool {
        guard let val = valorDouble else { return false }
        return val > 0
    }

    // MARK: - Passo 1: Escolher tipo e digitar chave

    private var chaveSection: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 28) {
                VStack(spacing: 8) {
                    Image(systemName: "diamond.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(Color.brandGreen)
                    Text("Para quem você quer enviar?")
                        .font(.headline)
                    Text("Escolha o tipo de chave do destinatário")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 24)

                // Chips de tipo de chave — horizontal scroll
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(TipoChave.allCases, id: \.self) { tipo in
                            Button(action: {
                                tipoChave = tipo
                                chave = ""
                                mostrarErroChave = false
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: tipo.icon)
                                        .font(.caption)
                                    Text(tipo.rawValue)
                                        .font(.subheadline)
                                        .fontWeight(tipoChave == tipo ? .semibold : .regular)
                                }
                                .foregroundStyle(tipoChave == tipo ? .white : .primary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 9)
                                .background(tipoChave == tipo ? Color.brandGreen : Color.controlBackground)
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 24)
                }

                // Campo da chave com validação inline
                VStack(alignment: .leading, spacing: 8) {
                    Text("Chave \(tipoChave.rawValue)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    TextField(tipoChave.placeholder, text: $chave)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(tipoChave.keyboardType)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(tipoChave == .email || tipoChave == .aleatoria ? .never : .sentences)
                        .onChange(of: chave) { _, newValue in
                            mostrarErroChave = false
                            // Aplica a máscara correta para cada tipo de chave
                            switch tipoChave {
                            case .telefone:
                                let m = maskTelefone(newValue)
                                if m != newValue { chave = m }
                            case .cpf:
                                let m = maskCPF(newValue)
                                if m != newValue { chave = m }
                            case .cnpj:
                                let m = maskCNPJ(newValue)
                                if m != newValue { chave = m }
                            default: break
                            }
                        }

                    Text(mensagemErroChave)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .opacity(mostrarErroChave && !isChaveValida ? 1 : 0)
                }
                .padding(.horizontal, 24)

                Button(action: {
                    if isChaveValida {
                        step = .valor
                    } else {
                        mostrarErroChave = true
                    }
                }) {
                    Text("Continuar")
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

    // MARK: - Passo 2: Informar valor e descrição

    private var valorSection: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {

                // Card do destinatário (com botão para alterar)
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.brandGreen.opacity(0.12))
                            .frame(width: 44, height: 44)
                        Image(systemName: tipoChave.icon)
                            .foregroundStyle(Color.brandGreen)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(tipoChave.rawValue)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(chave)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .lineLimit(1)
                    }
                    Spacer()
                    Button(action: { step = .chave }) {
                        Text("Alterar")
                            .font(.caption)
                            .foregroundStyle(Color.brandGreen)
                    }
                }
                .padding(16)
                .background(Color.controlBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 24)

                // Campo de valor
                VStack(alignment: .leading, spacing: 8) {
                    Text("Valor")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack {
                        Text("R$")
                            .foregroundStyle(.secondary)
                        TextField("0,00", text: $valorTexto)
                            .keyboardType(.decimalPad)
                            .onChange(of: valorTexto) { _, newValue in
                                let masked = maskValor(newValue)
                                if masked != newValue { valorTexto = masked }
                            }
                    }
                    .padding(12)
                    .background(Color.controlBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                    Text("Saldo disponível: \(viewModel.currentBalance.asCurrency)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 24)

                // Campo de descrição
                VStack(alignment: .leading, spacing: 8) {
                    Text("Descrição (opcional)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("Para que é esse Pix?", text: $descricao)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.horizontal, 24)

                // Mensagem de erro
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .opacity(errorMessage.isEmpty ? 0 : 1)

                Button(action: avancarParaConfirmacao) {
                    Text("Revisar Pix")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.brandGreen)
                .controlSize(.large)
                .padding(.horizontal, 24)

                Spacer()
            }
            .padding(.top, 8)
        }
    }

    // MARK: - Passo 3: Confirmação

    private var confirmacaoSection: some View {
        VStack(spacing: 24) {

            Text("Revise os dados antes de confirmar")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.top, 16)

            // Resumo da transferência
            VStack(spacing: 0) {
                resumoLinha(label: "Tipo de chave", valor: tipoChave.rawValue)
                Divider().padding(.leading, 16)
                resumoLinha(label: "Chave", valor: chave)
                Divider().padding(.leading, 16)
                resumoLinha(label: "Valor", valor: valorDouble?.asCurrency ?? "—")
                if !descricao.isEmpty {
                    Divider().padding(.leading, 16)
                    resumoLinha(label: "Descrição", valor: descricao)
                }
                Divider().padding(.leading, 16)
                resumoLinha(label: "Saldo atual", valor: viewModel.currentBalance.asCurrency)
                Divider().padding(.leading, 16)
                resumoLinha(
                    label: "Saldo após",
                    valor: (viewModel.currentBalance - (valorDouble ?? 0)).asCurrency,
                    destaque: true
                )
            }
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 24)

            VStack(spacing: 12) {
                Button(action: confirmarPix) {
                    Text("Confirmar e enviar")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.brandGreen)
                .controlSize(.large)

                Button(action: { step = .valor }) {
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

    // Linha de resumo reutilizável
    private func resumoLinha(label: String, valor: String, destaque: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(valor)
                .font(.subheadline)
                .fontWeight(destaque ? .bold : .regular)
                .foregroundStyle(destaque ? Color.brandGreen : .primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    // MARK: - Passo 4: Sucesso

    private var sucessoSection: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.brandGreen.opacity(0.12))
                    .frame(width: 100, height: 100)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(Color.brandGreen)
            }

            VStack(spacing: 8) {
                Text("Pix enviado!")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("\(valorEnviado.asCurrency) enviados para")
                    .foregroundStyle(.secondary)
                Text(chave)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .padding(.horizontal, 32)
            }

            VStack(spacing: 4) {
                Text("Novo saldo")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(balance.asCurrency)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.brandGreen)
            }
            .padding(16)
            .background(Color.controlBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Spacer()
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Máscaras de entrada

    // Telefone: (XX) XXXX-XXXX (10 dígitos) ou (XX) XXXXX-XXXX (11 dígitos)
    private func maskTelefone(_ input: String) -> String {
        let digits = String(input.filter { $0.isNumber }.prefix(11))
        var result = ""
        for (i, c) in digits.enumerated() {
            if i == 0 { result += "(" }
            if i == 2 { result += ") " }
            if digits.count <= 10 && i == 6 { result += "-" }
            if digits.count == 11 && i == 7 { result += "-" }
            result += String(c)
        }
        return result
    }

    // CPF: 000.000.000-00
    private func maskCPF(_ input: String) -> String {
        let digits = String(input.filter { $0.isNumber }.prefix(11))
        var result = ""
        for (i, c) in digits.enumerated() {
            if i == 3 || i == 6 { result += "." }
            if i == 9 { result += "-" }
            result += String(c)
        }
        return result
    }

    // CNPJ: 00.000.000/0001-00
    private func maskCNPJ(_ input: String) -> String {
        let digits = String(input.filter { $0.isNumber }.prefix(14))
        var result = ""
        for (i, c) in digits.enumerated() {
            if i == 2 || i == 5 { result += "." }
            if i == 8 { result += "/" }
            if i == 12 { result += "-" }
            result += String(c)
        }
        return result
    }

    // Valor monetário: dígitos digitados representam centavos → "1234" vira "12,34"
    private func maskValor(_ input: String) -> String {
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

    private func avancarParaConfirmacao() {
        errorMessage = ""
        guard isValorValido else {
            errorMessage = "Informe um valor válido."
            return
        }
        guard let val = valorDouble, val <= viewModel.currentBalance else {
            errorMessage = "Saldo insuficiente. Seu saldo é \(viewModel.currentBalance.asCurrency)."
            return
        }
        step = .confirmacao
    }

    private func confirmarPix() {
        guard let amount = valorDouble else { return }

        if let erro = viewModel.sendPix(to: chave, amount: amount, description: descricao) {
            step = .valor
            errorMessage = erro
            return
        }

        // Sucesso — atualiza @Binding para que HomeView exiba o novo saldo
        valorEnviado = amount
        balance = viewModel.currentBalance
        step = .sucesso
    }
}

#Preview {
    NavigationStack {
        PixView(balance: .constant(5000.0))
    }
}
