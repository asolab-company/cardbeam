import SwiftUI

struct CardView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> CardsManager {

        return CardsManager(url: url)
    }

    func updateUIViewController(
        _ uiViewController: CardsManager,
        context: Context
    ) {

    }
}
