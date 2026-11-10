import SwiftUI
import SpriteKit

struct ContentView: View {
    var body: some View {
        GameView()
            .ignoresSafeArea()
    }
}

struct GameView: UIViewRepresentable {

    func makeUIView(context: Context) -> SKView {
        let view = SKView()

        // Keep the game targeting 60 FPS
        view.preferredFramesPerSecond = 60

        // Hide performance statistics
        view.showsFPS = false
        view.showsNodeCount = false

        let scene = GameScene(
            size: CGSize(width: 900, height: 500)
        )

        scene.scaleMode = .aspectFit

        view.presentScene(scene)

        return view
    }

    func updateUIView(_ uiView: SKView, context: Context) {}
}
