import SwiftUI

public struct ToastMessage: Equatable {
    public let text: String
    public let colorHex: String?
}

public struct ToastView: View {
    let message: ToastMessage

    public var body: some View {
        HStack(spacing: 7) {
            Image(systemName: "checkmark")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.green)

            if let hex = message.colorHex {
                Circle()
                    .fill(Color(hex: hex))
                    .frame(width: 10, height: 10)
                    .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 1))
            }

            Text(message.text)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color(NSColor.windowBackgroundColor).opacity(0.92))
                .overlay(
                    Capsule().stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 3)
        )
        .transition(.scale(scale: 0.95).combined(with: .opacity))
    }
}


