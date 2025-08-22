import SwiftUI

struct TabLimitSettingRow: View {
    let title: String
    let description: String
    let value: Int
    let range: ClosedRange<Int>
    let onChange: (Int) -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.custom("Inter-Regular", size: 14))
                    .fontWeight(.medium)
                    .foregroundColor(.white)

                Text(description)
                    .font(.custom("Inter-Regular", size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }

            Spacer()

            TabLimitPicker(
                value: value,
                range: range,
                onChange: onChange
            )
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}



struct TabLimitPicker: View {
    let value: Int
    let range: ClosedRange<Int>
    let onChange: (Int) -> Void

    var body: some View {
        HStack(spacing: 6) {
            Button(action: {
                if value > range.lowerBound {
                    onChange(value - 1)
                }
            }) {
                Image(systemName: "minus")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(width: 20, height: 20)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(value <= range.lowerBound)

            Text("\(value) tab\(value == 1 ? "" : "s")")
                .font(.custom("Inter-Regular", size: 12))
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.9))
                .frame(minWidth: 60)

            Button(action: {
                if value < range.upperBound {
                    onChange(value + 1)
                }
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(width: 20, height: 20)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(value >= range.upperBound)
        }
    }
}
