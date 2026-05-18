import UIKit
import SwiftUI
import SwiftData

final class KeyboardViewController: UIInputViewController {

    private var hostingController: UIHostingController<KeyboardRootView>?
    private var viewModel: KeyboardViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        let container = SharedModelContainer.shared
        viewModel = KeyboardViewModel(
            modelContext: container.mainContext,
            proxy: textDocumentProxy,
            advanceAction: { [weak self] in self?.advanceToNextInputMode() },
            dismissAction: { [weak self] in self?.dismissKeyboard() }
        )

        let root = KeyboardRootView(viewModel: viewModel)
            .modelContainer(container)

        let host = UIHostingController(rootView: root)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        host.view.backgroundColor = .clear
        addChild(host)
        view.addSubview(host.view)
        NSLayoutConstraint.activate([
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        host.didMove(toParent: self)
        hostingController = host
    }

    override func textWillChange(_ textInput: UITextInput?) {}

    override func textDidChange(_ textInput: UITextInput?) {
        viewModel.refreshContext()
    }
}
