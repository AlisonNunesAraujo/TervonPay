// NotificationsView.swift — Tela de notificações
//
// CONEXÕES:
//   ← Acessada por HomeView.swift ao tocar no sino do header
//   → Usa NotificationsViewModel para carregar notificações simuladas
//
// CONCEITO:
//   As notificações ainda são dados locais para estudo.
//   Em um app real, seriam carregadas de uma API ou serviço de push.

import SwiftUI

struct NotificationsView: View {
    private let viewModel = NotificationsViewModel()

    @State private var notifications: [AppNotification] = []

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                if notifications.isEmpty {
                    emptyState
                } else {
                    notificationsList
                }
            }
            .padding(16)
        }
        .background(Color.appBackground)
        .navigationTitle("Notificações")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Limpar") {
                    notifications = []
                }
                .disabled(notifications.isEmpty)
            }
        }
        .onAppear {
            if notifications.isEmpty {
                notifications = viewModel.notifications
            }
        }
    }

    // MARK: - Lista

    private var notificationsList: some View {
        VStack(spacing: 0) {
            ForEach(Array(notifications.enumerated()), id: \.element.id) { index, notification in
                if index > 0 { Divider().padding(.leading, 58) }
                NotificationRow(notification: notification)
            }
        }
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Estado vazio

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "bell.slash")
                .font(.system(size: 44))
                .foregroundStyle(Color.brandGreen.opacity(0.5))

            Text("Nenhuma notificação")
                .font(.headline)

            Text("Quando houver novidades sobre sua conta, elas aparecem aqui.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
    }
}

private struct NotificationRow: View {
    let notification: AppNotification

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(notification.tint.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: notification.icon)
                    .font(.subheadline)
                    .foregroundStyle(notification.tint)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Text(notification.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Text(notification.time)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Text(notification.message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

#Preview {
    NavigationStack { NotificationsView() }
}
