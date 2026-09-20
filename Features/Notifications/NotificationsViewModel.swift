// NotificationsViewModel.swift — Dados da tela de notificações
//
// CONEXÕES:
//   ← Criado por NotificationsView.swift via private let
//
// CONCEITO:
//   AppNotification é uma entidade simples da feature.
//   Como ainda não há backend, usamos dados simulados para montar a interface.

import SwiftUI

struct AppNotification: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let time: String
    let icon: String
    let tint: Color
}

final class NotificationsViewModel {
    let notifications: [AppNotification] = [
        AppNotification(
            title: "Pix enviado",
            message: "Seu Pix foi concluído e já aparece no extrato.",
            time: "Agora",
            icon: "diamond.fill",
            tint: Color.brandGreen
        ),
        AppNotification(
            title: "Cartão protegido",
            message: "Compras online e aproximação estão ativadas no seu cartão.",
            time: "Hoje",
            icon: "shield.checkered",
            tint: .blue
        ),
        AppNotification(
            title: "Recarga disponível",
            message: "Você pode recarregar celular direto pelo app TERVON.",
            time: "Ontem",
            icon: "iphone",
            tint: .orange
        )
    ]
}
