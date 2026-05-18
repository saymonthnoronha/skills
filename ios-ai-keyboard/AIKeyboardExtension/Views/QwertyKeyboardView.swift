import SwiftUI

struct QwertyKeyboardView: View {
    @ObservedObject var viewModel: KeyboardViewModel
    @State private var isShifted: Bool = true
    @State private var isNumbers: Bool = false

    private let rowsLetters: [[String]] = [
        ["q","w","e","r","t","y","u","i","o","p"],
        ["a","s","d","f","g","h","j","k","l"],
        ["z","x","c","v","b","n","m"]
    ]
    private let rowsNumbers: [[String]] = [
        ["1","2","3","4","5","6","7","8","9","0"],
        ["-","/",":",";","(",")","$","&","@","\""],
        [".",",","?","!","'"]
    ]

    var body: some View {
        VStack(spacing: 6) {
            let rows = isNumbers ? rowsNumbers : rowsLetters
            ForEach(rows.indices, id: \.self) { idx in
                HStack(spacing: 4) {
                    if idx == 2 && !isNumbers {
                        modKey(systemImage: isShifted ? "shift.fill" : "shift") {
                            isShifted.toggle()
                        }
                    }
                    ForEach(rows[idx], id: \.self) { key in
                        letterKey(key)
                    }
                    if idx == 2 {
                        modKey(systemImage: "delete.left") {
                            viewModel.deleteBackward()
                        }
                    }
                }
            }

            HStack(spacing: 4) {
                modKey(text: isNumbers ? "ABC" : "123", width: 44) {
                    isNumbers.toggle()
                }
                modKey(systemImage: "globe", width: 38) {
                    viewModel.nextKeyboard()
                }
                spaceKey()
                modKey(text: "↵", width: 60) {
                    viewModel.insertReturn()
                }
            }
        }
        .padding(.horizontal, 4)
        .padding(.bottom, 4)
    }

    private func letterKey(_ char: String) -> some View {
        let display = isShifted && !isNumbers ? char.uppercased() : char
        return Button {
            viewModel.insertCharacter(display)
            if isShifted && !isNumbers { isShifted = false }
        } label: {
            Text(display)
                .font(.system(size: 20))
                .frame(maxWidth: .infinity, minHeight: 40)
                .background(Color(UIColor.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 5))
        }
        .buttonStyle(.plain)
    }

    private func modKey(systemImage: String? = nil, text: String? = nil, width: CGFloat? = nil, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Group {
                if let systemImage { Image(systemName: systemImage) }
                else if let text { Text(text).font(.system(size: 16)) }
            }
            .frame(maxWidth: width ?? .infinity, minHeight: 40)
            .background(Color(UIColor.tertiarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 5))
        }
        .buttonStyle(.plain)
        .frame(width: width)
    }

    private func spaceKey() -> some View {
        Button {
            viewModel.insertSpace()
        } label: {
            Text("espaço")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, minHeight: 40)
                .background(Color(UIColor.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 5))
        }
        .buttonStyle(.plain)
    }
}
