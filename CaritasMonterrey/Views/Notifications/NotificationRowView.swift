//
//  NotificationRowView.swift
//  CaritasMonterrey
//
//  Created by José de Jesùs Jiménez Martínez on 23/11/25.
//

import Foundation
import SwiftUI

struct NotificationRowView: View {
    let notification: AppNotification

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(notification.type.iconColor.opacity(0.1))
                    .frame(width: 44, height: 44)
                Image(systemName: notification.type.iconName)
                    .font(.headline)
                    .foregroundColor(notification.type.iconColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(notification.title)
                    .font(.headline)

                Text(notification.message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                if let createdAt = notification.created_at {
                    Text(createdAt, style: .relative)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            if !notification.isRead {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 10, height: 10)
            }
        }
        .padding(.vertical, 4)
    }
}

