import SwiftUI
import SpriteKit

struct ContentView: View {

    var scene: SKScene {
        let scene = GameScene(size: CGSize(width: 900, height: 500))
        scene.scaleMode = .aspectFit
        return scene
    }

    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
    }
}
