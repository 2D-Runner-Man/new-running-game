import SpriteKit
import UIKit
import AVFoundation

class GameScene: SKScene {
    
    // MARK: - Scrolling Background
    var background1 = SKSpriteNode()
    var background2 = SKSpriteNode()

    let backgroundSpeed: CGFloat = 100
    let backgroundOverlap: CGFloat = 2
    
//    var idleTextures: [SKTexture] =
//    [SKTexture(imageNamed: "idle1"),
//    SKTexture(imageNamed: "idle2")]
//    
//    var runTextures: [SKTexture] = []
//
//    let jumpUpTexture = SKTexture(imageNamed: "jumpUp")
//    let jumpFallTexture = SKTexture(imageNamed: "jumpFall")
//    
//    let controlsAreaHeight: CGFloat = 100
//
//    var currentAnimation = ""
//    var facingRight = true
    
    ///// MARK: - Red-haired Boy Frames

//    var idleTextures: [SKTexture] = [
//        SKTexture(imageNamed: "redBoyIdle1"),
//        SKTexture(imageNamed: "redBoyIdle2")
//    ]
//
//    var runTextures: [SKTexture] = []
//
//    let jumpUpTexture = SKTexture(imageNamed: "redBoyJumpUp")
//    let jumpFallTexture = SKTexture(imageNamed: "redBoyJumpFall")
//    let hitTexture = SKTexture(imageNamed: "redBoyHit")
//
//    var isHitAnimating = false
//    let hitAnimationDuration: TimeInterval = 0.35
    
    // MARK: - Character Animation Frames

    var idleTextures: [SKTexture] = []
    var runTextures: [SKTexture] = []
    var hitTextures: [SKTexture] = []

    var jumpUpTexture = SKTexture(imageNamed: "redBoyJumpUp")
    var jumpFallTexture = SKTexture(imageNamed: "redBoyJumpFall")

    var isHitAnimating = false
    let hitAnimationDuration: TimeInterval = 0.35

    var currentAnimation = ""
    var facingRight = true

    // MARK: - Player
    var player = SKSpriteNode()

    let playerSpeed: CGFloat = 250
    let groundHeight: CGFloat = 70
    
    // MARK: - Player Lives
    var lives = 5
    var isInvincible = false

    let invincibilityDuration: TimeInterval = 2.0
    var lifeIcons: [SKSpriteNode] = []

    // MARK: - Movement
    var movingLeft = false
    var movingRight = false
    
    // MARK: - Jumping
    var verticalVelocity: CGFloat = 0
    var isJumping = false

    let gravity: CGFloat = -1200
    let jumpVelocity: CGFloat = 750
    
    // MARK: - Jump
    func jump() {

        if !isJumping {
            verticalVelocity = jumpVelocity
            isJumping = true
        }
    }
    
    // MARK: - Touch Controls
    var leftButton = SKShapeNode()
    var jumpButton = SKShapeNode()
    var rightButton = SKShapeNode()

    // Track multiple fingers independently
    var activeTouches: [UITouch: String] = [:]

    // MARK: - Coins
    var coins: [SKSpriteNode] = []

    var coinSpawnTimer: TimeInterval = 0
    let coinSpawnInterval: TimeInterval = 3.0
    
    let coinSpeed: CGFloat = 180
    let coinSize = CGSize(width: 30, height: 30)
    
    // MARK: - Super Coins
    var superCoins: [SKSpriteNode] = []

    var superCoinSpawnTimer: TimeInterval = 0
    let superCoinSpawnInterval: TimeInterval = 1.5

    let superCoinSpeed: CGFloat = 180
    let superCoinSize = CGSize(width: 40, height: 40)
    
    // MARK: - Shared Coin Spawn Area
    let coinMinimumY: CGFloat = 180
    let coinMaximumY: CGFloat = 400
    
    // MARK: - Playable Characters
    enum PlayableCharacter: String, CaseIterable {
        case redBoy
        case chineseBoy
        case cat
    }

    var selectedCharacter: PlayableCharacter = .redBoy
    
    // MARK: - Skull-Biting Enemies
    var skullEnemies: [SKSpriteNode] = []
    var skullTextures: [SKTexture] = []

    var skullSpawnTimer: TimeInterval = 0
    let skullSpawnInterval: TimeInterval = 4.0

    let skullSpeed: CGFloat = 200
    let skullSize = CGSize(width: 55, height: 55)
    
    var skullSoundPlayer: AVAudioPlayer?
    
    // MARK: - Bee Enemies
    var beeEnemies: [SKSpriteNode] = []
    var beeSpawnTimer: TimeInterval = 0
    let beeSpawnInterval: TimeInterval = 5
    let beeSpeed: CGFloat = 250
    
    // MARK: - Scoring
    var score = 0
    var scoreTimer: TimeInterval = 0
    
    var highScore = UserDefaults.standard.integer(
        forKey: "runningGameHighScore"
    )

    let scoreLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
    
    // MARK: - Game Over
    var isGameOver = false

    // MARK: - Frame Timing
    var lastUpdateTime: TimeInterval = 0
    
    // MARK: - Background Music
    var backgroundMusic: AVAudioPlayer?
    
    var currentScreen: GameScreen = .start
    var playerName = ""
    
    // MARK: All Screens
    enum GameScreen {
        case start
        case controls
        case characterSelection
        case nameEntry
        case playing
        case scoreResults
        case gameOver
    }
    
    // MARK: - Play Background Music
    func playBackgroundMusic() {

        guard let musicURL = Bundle.main.url(
            forResource: "backgroundMusic",
            withExtension: "mp3"
        ) else {
            print("Background music file not found")
            return
        }

        do {
            backgroundMusic = try AVAudioPlayer(contentsOf: musicURL)

            backgroundMusic?.numberOfLoops = -1
            backgroundMusic?.volume = 0.5
            backgroundMusic?.prepareToPlay()
            backgroundMusic?.play()

        } catch {
            print("Unable to play background music: \(error)")
        }
    }
    
    // MARK: - Stop Background Music
    func stopBackgroundMusic() {
        backgroundMusic?.stop()
        backgroundMusic = nil
    }
    
    func showStartScreen() {

        currentScreen = .start

        let overlay = SKNode()
        overlay.name = "startScreen"
        overlay.zPosition = 300

        // Title screen background image
        let titleBackground = SKSpriteNode(
            // imageNamed: "titleScreenBackground"
            imageNamed: "titleBackgroundScreen"
        )

        titleBackground.position = CGPoint(
            x: size.width / 2,
            y: size.height / 2
        )

        titleBackground.size = size
        titleBackground.zPosition = 0

        overlay.addChild(titleBackground)

        let playButton = SKShapeNode(
            rectOf: CGSize(width: 180, height: 55),
            cornerRadius: 10
        )

        playButton.name = "playButton"
        playButton.fillColor = .white
        playButton.strokeColor = .black
        playButton.lineWidth = 3
        playButton.position = CGPoint(
            // Old Title Screen
            // x: size.width / 2 + 100,  // Move right
            // y: size.width / 2 - 330  // Move down
            // New Title Screen
            x: size.width / 2 - 300,  // Move right
            y: size.width / 2 - 360  // Move down
        )

        let playLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        playLabel.text = "PLAY"
        playLabel.name = "playButton"
        playLabel.fontSize = 25
        playLabel.fontColor = .black
        playLabel.verticalAlignmentMode = .center

        playButton.addChild(playLabel)
        overlay.addChild(playButton)
        
        // Slowly zoom the PLAY button in and out
        let zoomIn = SKAction.scale(to: 1.20, duration: 1.0)
        let zoomOut = SKAction.scale(to: 1.0, duration: 1.0)

        let pulseAnimation = SKAction.sequence([
            zoomIn,
            zoomOut
        ])

        playButton.run(
            SKAction.repeatForever(pulseAnimation),
            withKey: "playButtonPulse"
        )

        addChild(overlay)
    }
    
    func showControlsScreen() {
        currentScreen = .controls

        let overlay = SKNode()
        overlay.name = "controlsScreen"
        overlay.zPosition = 300

        // Controls screen background
        let controlsBackground = SKSpriteNode(
            imageNamed: "controlsScreenBackground"
        )

        controlsBackground.position = CGPoint(
            x: size.width / 2,
            y: size.height / 2
        )

        controlsBackground.size = size
        controlsBackground.zPosition = 0

        overlay.addChild(controlsBackground)

        addChild(overlay)
    }
    
    // MARK: - Character Selection Screen
    func showCharacterSelectionScreen() {

        currentScreen = .characterSelection

        let overlay = SKNode()
        overlay.name = "characterSelectionScreen"
        overlay.zPosition = 300

        // Background
        let background = SKSpriteNode(
            color: .darkGray,
            size: size
        )

        background.position = CGPoint(
            x: size.width / 2,
            y: size.height / 2
        )

        overlay.addChild(background)

        // Title
        let title = SKLabelNode(fontNamed: "Arial-BoldMT")
        title.text = "SELECT YOUR CHARACTER"
        title.fontSize = 40
        title.fontColor = .white

        title.position = CGPoint(
            x: size.width / 2,
            y: size.height - 75
        )

        title.zPosition = 1
        overlay.addChild(title)

        let characters: [(PlayableCharacter, String, String)] = [
            (.redBoy, "Red-haired Boy", "redBoyIdle"),
            (.chineseBoy, "Jumping Boy", "chineseBoyIdle"),
            (.cat, "Mascot Cat", "catIdle")
        ]

        let spacing = size.width / CGFloat(characters.count + 1)

        for (index, character) in characters.enumerated() {

            let x = spacing * CGFloat(index + 1)

            // Character selection card
            let card = SKShapeNode(
                rectOf: CGSize(width: 160, height: 180),
                cornerRadius: 15
            )

            card.name = "character_\(character.0.rawValue)"
            card.fillColor = .black
            card.strokeColor = selectedCharacter == character.0
                ? .green : .white
            card.lineWidth = 3

            card.position = CGPoint(
                x: x,
                y: size.height / 2 - 25
            )

            card.zPosition = 2

            // Character preview
            let preview = SKSpriteNode(
                imageNamed: "\(character.2)1"
            )

            preview.size = CGSize(width: 75, height: 125)
            preview.position.y = 20
            preview.zPosition = 1

            let frames = (1...2).map {
                SKTexture(imageNamed: "\(character.2)\($0)")
            }

            preview.run(
                .repeatForever(
                    .animate(with: frames, timePerFrame: 0.15)
                )
            )

            card.addChild(preview)

            overlay.addChild(card)
        }

        // Continue button
        let continueButton = SKShapeNode(
            rectOf: CGSize(width: 200, height: 55),
            cornerRadius: 10
        )

        continueButton.name = "characterContinueButton"
        continueButton.fillColor = .systemGreen
        continueButton.strokeColor = .white
        continueButton.lineWidth = 3

        continueButton.position = CGPoint(
            x: size.width / 2,
            y: 65
        )

        continueButton.zPosition = 2

        let continueLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        continueLabel.text = "CONTINUE"
        continueLabel.fontSize = 25
        continueLabel.fontColor = .white
        continueLabel.verticalAlignmentMode = .center
        continueLabel.zPosition = 1

        continueButton.addChild(continueLabel)
        overlay.addChild(continueButton)

        addChild(overlay)
    }

    func showNameEntryScreen() {

        currentScreen = .nameEntry

        let overlay = SKNode()
        overlay.name = "nameEntryScreen"
        overlay.zPosition = 300

        // Background
        let background = SKShapeNode(rectOf: size)
        background.fillColor = UIColor(
            red: 32 / 255,
            green: 32 / 255,
            blue: 32 / 255,
            alpha: 1
        )
        background.strokeColor = .clear
        background.position = CGPoint(
            x: size.width / 2,
            y: size.height / 2
        )
        overlay.addChild(background)

        // Title
        let title = SKLabelNode(fontNamed: "Arial-BoldMT")
        title.text = "Enter your name"
        title.fontSize = 45
        title.fontColor = .white
        title.position = CGPoint(
            x: size.width / 2,
            y: size.height / 2 + 100
        )
        overlay.addChild(title)

        // Name display
        let nameLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        nameLabel.name = "playerNameLabel"
        nameLabel.text = "Tap here to enter your name"
        nameLabel.fontSize = 25
        nameLabel.fontColor = .white
        nameLabel.position = CGPoint(
            x: size.width / 2,
            y: size.height / 2
        )
        overlay.addChild(nameLabel)

        // Start Game button
        let startButton = SKShapeNode(
            rectOf: CGSize(width: 200, height: 55),
            cornerRadius: 10
        )

        startButton.name = "startGameButton"
        startButton.fillColor = UIColor(
            red: 0 / 255,
            green: 166 / 255,
            blue: 37 / 255,
            alpha: 1
        )
        startButton.strokeColor = .white
        startButton.lineWidth = 3
        startButton.position = CGPoint(
            x: size.width / 2,
            y: size.height / 2 - 100
        )

        let startLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        startLabel.text = "START GAME"
        startLabel.name = "startGameButton"
        startLabel.fontSize = 23
        startLabel.fontColor = .white
        startLabel.verticalAlignmentMode = .center

        startButton.addChild(startLabel)
        overlay.addChild(startButton)

        addChild(overlay)
    }
    
    func promptForPlayerName() {

        guard let viewController = view?.window?.rootViewController else {
            return
        }

        let alert = UIAlertController(
            title: "Player Name",
            message: "Enter your name",
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.placeholder = "Your name"
            textField.text = self.playerName
            textField.autocapitalizationType = .words
            textField.returnKeyType = .done
        }

        let saveAction = UIAlertAction(
            title: "Save",
            style: .default
        ) { [weak self] _ in

            guard let self = self else { return }

            let enteredName = alert.textFields?.first?.text?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

            self.playerName = enteredName

            if let nameLabel = self.childNode(
                withName: "//playerNameLabel"
            ) as? SKLabelNode {

                nameLabel.text = enteredName.isEmpty
                    ? "Tap here to enter your name"
                    : enteredName
            }
        }

        alert.addAction(saveAction)

        alert.addAction(
            UIAlertAction(title: "Cancel", style: .cancel)
        )

        viewController.present(alert, animated: true)
    }

    func loadSkullAnimations() {

        skullTextures = (1...11).map {
            SKTexture(imageNamed: "skull-\($0)")
        }
    }
    
    func setupScoreLabel() {

        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .white

        // Position score in the top-left corner
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.verticalAlignmentMode = .center

        scoreLabel.position = CGPoint(
            x: 20,
            y: size.height - 35
        )

        scoreLabel.zPosition = 100

        addChild(scoreLabel)
    }

    // MARK - Create Animation Frames
//    func loadPlayerAnimations() {
//        idleTextures = (1...2).map {
//            SKTexture(imageNamed: "idle\($0)")
//        }
//
//        runTextures = (1...6).map {
//            SKTexture(imageNamed: "run\($0)")
//        }
//    }
    
    func loadPlayerAnimations() {

        switch selectedCharacter {
            
        case .redBoy:

            idleTextures = (1...2).map {
                SKTexture(imageNamed: "redBoyIdle\($0)")
            }

            runTextures = (1...6).map {
                SKTexture(imageNamed: "redBoyRun\($0)")
            }

            jumpUpTexture = SKTexture(imageNamed: "redBoyJumpUp")
            jumpFallTexture = SKTexture(imageNamed: "redBoyJumpFall")

            hitTextures = [
                SKTexture(imageNamed: "redBoyHit")
            ]

        case .chineseBoy:

            idleTextures = (1...2).map {
                SKTexture(imageNamed: "chineseBoyIdle\($0)")
            }

            runTextures = (1...6).map {
                SKTexture(imageNamed: "chineseBoyRun\($0)")
            }

            jumpUpTexture = SKTexture(imageNamed: "chineseBoyJumpUp")
            jumpFallTexture = SKTexture(imageNamed: "chineseBoyJumpFall")

            hitTextures = [
                SKTexture(imageNamed: "chineseBoyHit")
            ]

        case .cat:

            idleTextures = (1...2).map {
                SKTexture(imageNamed: "catIdle\($0)")
            }

            runTextures = (1...5).map {
                SKTexture(imageNamed: "catRun\($0)")
            }

            jumpUpTexture = SKTexture(imageNamed: "catJumpUp")
            jumpFallTexture = SKTexture(imageNamed: "catJumpFall")

            hitTextures = (1...2).map {
                SKTexture(imageNamed: "catHit\($0)")
            }
        }
    }
    
    // MARK: - Player Hit Animation
    func playHitAnimation() {

        // Skip if the character has no hit sprites
        guard !hitTextures.isEmpty else { return }

        isHitAnimating = true

        player.removeAction(forKey: "playerAnimation")

        currentAnimation = "hit"

        player.size.width = 55
        player.size.height = 90

        player.texture = hitTextures[0]

        let hitAnimation = SKAction.animate(
            with: hitTextures,
            timePerFrame: hitAnimationDuration /
                Double(hitTextures.count)
        )

        let finish = SKAction.run { [weak self] in
            self?.isHitAnimating = false
            self?.currentAnimation = ""
        }

        player.run(
            SKAction.sequence([
                hitAnimation,
                finish
            ]),
            withKey: "hitAnimation"
        )
    }
    
    func playAnimation(_ animation: String) {
        guard !isHitAnimating else { return }
        guard currentAnimation != animation else { return }

        currentAnimation = animation
        player.size.width = 50
        player.size.height = 90
        player.removeAction(forKey: "playerAnimation")

        switch animation {
    
        case "idle":

            // Individual idle widths
            switch selectedCharacter {

            case .redBoy:
                player.size.width = 55

            case .chineseBoy:
                player.size.width = 55

            case .cat:
                player.size.width = 55
            }

            player.run(
                .repeatForever(
                    .animate(with: idleTextures, timePerFrame: 0.15)
                ),
                withKey: "playerAnimation"
            )
            player.run(
                .repeatForever(
                    .animate(with: idleTextures, timePerFrame: 0.15)
                ),
                withKey: "playerAnimation"
            )

        case "running":
            
            // Individual idle widths
            switch selectedCharacter {

            case .redBoy:
                player.size.width = 50

            case .chineseBoy:
                player.size.width = 50

            case .cat:
                player.size.width = 50
            }
            
            player.run(
                .repeatForever(
                    .animate(with: runTextures, timePerFrame: 0.08)
                ),
                withKey: "playerAnimation"
            )
            
        case "jumpUp":
            player.texture = jumpUpTexture
            player.size.width = 55

        case "jumpFall":
            player.texture = jumpFallTexture
            player.size.width = 55

        default:
            break
        }
    }
    
    // MARK: - Scene Setup
    override func didMove(to view: SKView) {
        
       setupScoreLabel()

       // MARK: - Scrolling Mountain Background
       backgroundColor = .black

       background1 = SKSpriteNode(
           imageNamed: "mountainBackground2"
       )

       background2 = SKSpriteNode(
           imageNamed: "mountainBackground2"
       )

        background1.size = CGSize(
            width: 900,
            height: 500
        )

        background2.size = CGSize(
            width: 900,
            height: 500
        )

       // Position backgrounds side by side
        background1.position = CGPoint(
            x: size.width / 2,
            y: size.height / 2
        )

        background2.position = CGPoint(
            x: size.width * 1.5 - backgroundOverlap,
            y: size.height / 2
        )

       // Keep mountains behind the game
       background1.zPosition = -1
       background2.zPosition = -1

       addChild(background1)
       addChild(background2)

        // Player
        player = SKSpriteNode(
            imageNamed: "redBoyIdle1"
        )

        player.size = CGSize(width: 45, height: 90)
        
        player.position = CGPoint(
            x: 150,
            y: groundHeight + player.size.height / 2
        )

        // Manual movement: no physics body
        player.physicsBody = nil

        player.zPosition = 2
        addChild(player)
        
        loadPlayerAnimations()
        playAnimation("idle")
        loadSkullAnimations()
        setupLives()
        
        // Touch Controls
        leftButton = createButton(
            title: "LEFT",
            x: 65,
            width: 100
        )

        jumpButton = createButton(
            title: "JUMP",
            x: size.width / 2,
            width: 120
        )
        
        // Move JUMP button slightly upward
        jumpButton.position.y += 5

        rightButton = createButton(
            title: "RIGHT",
            x: size.width - 65,
            width: 100
        )
        
        if currentScreen == .start {
            showStartScreen()
        }

        // Start background music as soon as the app opens
        playBackgroundMusic()
    }
    
    func animateButtonPress(
        _ button: SKNode,
        completion: @escaping () -> Void
    ) {
        let popUp = SKAction.scale(to: 1.12, duration: 0.10)
        let popDown = SKAction.scale(to: 1.0, duration: 0.12)

        let animation = SKAction.sequence([
            popUp,
            popDown,
            SKAction.run(completion)
        ])

        button.removeAction(forKey: "buttonPop")
        button.run(animation, withKey: "buttonPop")
    }
    
    // MARK: - Create Touch Button
    func createButton(
        title: String,
        x: CGFloat,
        width: CGFloat
    ) -> SKShapeNode {

        let button = SKShapeNode(
            rectOf: CGSize(width: width, height: 55),
            cornerRadius: 10
        )

        button.position = CGPoint(x: x, y: 30)
        button.fillColor = .black.withAlphaComponent(0.65)
        button.strokeColor = .white
        button.lineWidth = 2
        button.zPosition = 10

        button.name = title

        let label = SKLabelNode(text: title)
        label.fontName = "Helvetica-Bold"
        label.fontSize = 22
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.zPosition = 11

        button.addChild(label)
        addChild(button)

        return button
    }
    
    func setupLives() {

        for index in 0..<lives {

            let life = SKSpriteNode(imageNamed: "lives")

            life.size = CGSize(width: 25, height: 25)

            life.position = CGPoint(
                x: 35 + CGFloat(index) * 35,
                y: size.height - 75
            )

            life.zPosition = 100

            addChild(life)
            lifeIcons.append(life)
        }
    }

    func spawnCoin() {

        let coin = SKSpriteNode(imageNamed: "coin")

        coin.size = coinSize
        coin.name = "coin"
        coin.zPosition = 5

        // Spawn just beyond the right side of the screen
        let spawnX = size.width + coinSize.width / 2

        coin.position = CGPoint(
            x: spawnX,
            y: CGFloat.random(in: coinMinimumY...coinMaximumY)
        )

        addChild(coin)
        coins.append(coin)
    }
    
    func spawnSuperCoin() {

        let superCoin = SKSpriteNode(imageNamed: "superCoin")

        superCoin.size = superCoinSize
        superCoin.name = "superCoin"
        superCoin.zPosition = 5

        // Spawn beyond the right edge
        let spawnX = size.width + superCoinSize.width / 2

        superCoin.position = CGPoint(
            x: spawnX,
            y: CGFloat.random(in: coinMinimumY...coinMaximumY)
        )

        // Prevent overlap with existing coins
        let overlapsRegularCoin = coins.contains { coin in
            superCoin.frame.intersects(coin.frame)
        }

        if overlapsRegularCoin {
            return
        }

        addChild(superCoin)
        superCoins.append(superCoin)
    }
    
    // MARK: - Coin Collection Effect
    func showCoinCollectionEffect(
        at position: CGPoint,
        isSuperCoin: Bool = false
    ) {

        // Create sparkle image
        let sparkle = SKSpriteNode(
            imageNamed: "coinSparkle"
        )

        sparkle.position = position

        // Make the effect larger for super coins
        if isSuperCoin {
            sparkle.size = CGSize(width: 65, height: 75)
        } else {
            sparkle.size = CGSize(width: 40, height: 50)
        }

        sparkle.zPosition = 20

        addChild(sparkle)

        // Keep sparkle visible for one second
        sparkle.run(
            SKAction.sequence([
                SKAction.wait(forDuration: 0.35),
                SKAction.removeFromParent()
            ])
        )

        // Play coin collection sound
        run(
            SKAction.playSoundFileNamed(
                "coinGet.mp3",
                waitForCompletion: false
            )
        )
    }
    
    // MARK: - Skull Sound
    func playSkullSound() {
        guard let soundURL = Bundle.main.url(
            forResource: "skull-sound",
            withExtension: "wav"
        ) else {
            return
        }

        do {
            skullSoundPlayer = try AVAudioPlayer(contentsOf: soundURL)
            skullSoundPlayer?.volume = 0.10
            skullSoundPlayer?.prepareToPlay()
            skullSoundPlayer?.play()
        } catch {
            print("Unable to play skull sound: \(error)")
        }
    }
    
    func spawnSkullEnemy() {

        guard !skullTextures.isEmpty else { return }

        let skull = SKSpriteNode(texture: skullTextures[0])

        skull.size = skullSize
        skull.name = "skullEnemy"
        skull.zPosition = 5

        // Spawn outside the right edge
        skull.position = CGPoint(
            x: size.width + skullSize.width / 2,
            y: groundHeight + skullSize.height / 2
        )

        // Animate the biting skull continuously
        let bitingAnimation = SKAction.animate(
            with: skullTextures,
            timePerFrame: 4.0 / 60.0
        )

        skull.run(
            SKAction.repeatForever(bitingAnimation),
            withKey: "skullBiting"
        )

        addChild(skull)
        skullEnemies.append(skull)
        
        // Play skull sound when it appears
        playSkullSound()
    }
    
    func checkSkullCollisions() {

        guard !isInvincible, lives > 0 else { return }

        for skull in skullEnemies {

            if player.frame.intersects(skull.frame) {

                takeDamage()
                break
            }
        }
    }
    
    // MARK: - Bee Animation
    func createBeeAnimation() -> SKAction {

        let beeFrames = [
            SKTexture(imageNamed: "bee1"),
            SKTexture(imageNamed: "bee2")
        ]

        // Alternate between the two wing positions
        let animation = SKAction.animate(
            with: beeFrames,
            timePerFrame: 0.15
        )

        // Keep the bee flying continuously
        return SKAction.repeatForever(animation)
    }
    
    // MARK: - Spawn Bee Enemy
    func spawnBeeEnemy() {

        let bee = SKSpriteNode(imageNamed: "bee1")

        bee.size = CGSize(width: 55, height: 55)
        bee.position = CGPoint(
            x: size.width + 40,
            y: groundHeight + 180
        )

        bee.zPosition = 5

        // Start the wing animation
        bee.run(createBeeAnimation())

        addChild(bee)
        beeEnemies.append(bee)
    }
    
    // MARK: - Update Bee Enemies
    func updateBeeEnemies(deltaTime: CGFloat) {

        for bee in beeEnemies.reversed() {

            // Move the bee toward the left
            bee.position.x -= beeSpeed * deltaTime

            // Check if the bee hits the player
            if bee.frame.intersects(player.frame) {

                // Damage the player without removing the bee
                takeDamage()

                if isGameOver {
                    return
                }
            }
            
            // Remove bees that leave the screen
            else if bee.position.x < -50 {
                
                // Remove the bee after it leaves the screen
                   bee.removeFromParent()
                   beeEnemies.removeAll { $0 === bee }
            }
        }
    }
    
    func addScrollingResultsBackground(to overlay: SKNode) {

        let backgroundContainer = SKNode()
        backgroundContainer.zPosition = -10

        let backgroundWidth = size.height * 2.0

        for index in 0..<2 {
            let background = SKSpriteNode(
                imageNamed: "resultsSkyBackground"
            )

            background.size = CGSize(
                width: backgroundWidth,
                height: size.height
            )

            background.position = CGPoint(
                x: size.width / 2 + CGFloat(index) * backgroundWidth,
                y: size.height / 2
            )

            backgroundContainer.addChild(background)
        }

        overlay.addChild(backgroundContainer)

        let scroll = SKAction.moveBy(
            x: -backgroundWidth,
            y: 0,
            duration: 30
        )

        let reset = SKAction.moveTo(
            x: 0,
            duration: 0
        )

        backgroundContainer.run(
            SKAction.repeatForever(
                SKAction.sequence([scroll, reset])
            )
        )
    }
    
    func showScoreResultsScreen() {

        currentScreen = .scoreResults

        let isNewHighScore = score > highScore

        if isNewHighScore {
            highScore = score

            UserDefaults.standard.set(
                highScore,
                forKey: "runningGameHighScore"
            )
        }

        let overlay = SKNode()
        overlay.name = "scoreResultsScreen"
        overlay.zPosition = 300

        addScrollingResultsBackground(to: overlay)

        // Title
        let title = SKLabelNode(fontNamed: "Arial-BoldMT")
        title.text = "YOUR RESULTS"
        title.fontSize = 50
        title.fontColor = .black
        title.position = CGPoint(
            x: size.width / 2,
            y: size.height / 2 + 110
        )
        overlay.addChild(title)

        // Final score
        let finalScoreLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        finalScoreLabel.text = "Final Score: \(score)"
        finalScoreLabel.fontSize = 32
        finalScoreLabel.fontColor = .black
        finalScoreLabel.position = CGPoint(
            x: size.width / 2,
            y: size.height / 2 - 10
        )
        overlay.addChild(finalScoreLabel)

        // High score
        let highScoreLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        highScoreLabel.text = "High Score: \(highScore)"
        highScoreLabel.fontSize = 32
        highScoreLabel.fontColor = .darkGray
        highScoreLabel.position = CGPoint(
            x: size.width / 2,
            y: size.height / 2 - 65
        )
        overlay.addChild(highScoreLabel)
        
        // Restart button
        let restartButton = SKShapeNode(
            rectOf: CGSize(width: 180, height: 55),
            cornerRadius: 10
        )

        restartButton.name = "resultsRestartButton"
        restartButton.fillColor = .black
        restartButton.strokeColor = .white
        restartButton.lineWidth = 3
        restartButton.position = CGPoint(
            x: size.width / 2,
            y: size.height / 2 - 145
        )

        let restartLabel = SKLabelNode(
            fontNamed: "Arial-BoldMT"
        )

        restartLabel.text = "RESTART"
        restartLabel.name = "resultsRestartButton"
        restartLabel.fontSize = 24
        restartLabel.fontColor = .white
        restartLabel.verticalAlignmentMode = .center

        restartButton.addChild(restartLabel)
        overlay.addChild(restartButton)
        
        // Display NEW HIGH SCORE message
        if isNewHighScore {

            let newHighScoreLabel = SKLabelNode(
                fontNamed: "Arial-BoldMT"
            )

            newHighScoreLabel.text = "NEW HIGH SCORE!"
            newHighScoreLabel.fontSize = 30
            newHighScoreLabel.fontColor = .yellow

            newHighScoreLabel.position = CGPoint(
                x: size.width / 2,
                y: size.height / 2 + 50
            )

            newHighScoreLabel.zPosition = 10

            overlay.addChild(newHighScoreLabel)

            // Blinking animation
            let fadeOut = SKAction.fadeAlpha(
                to: 0.2,
                duration: 0.5
            )

            let fadeIn = SKAction.fadeAlpha(
                to: 1.0,
                duration: 0.5
            )

            let blinkAnimation = SKAction.repeatForever(
                SKAction.sequence([
                    fadeOut,
                    fadeIn
                ])
            )

            newHighScoreLabel.run(blinkAnimation)
        }
        // Add the Results Screen to the scene
            addChild(overlay)
    }

    func showGameOverScreen() {

        guard childNode(withName: "gameOverOverlay") == nil else {
            return
        }

        currentScreen = .gameOver

        let overlay = SKNode()
        overlay.name = "gameOverOverlay"
        overlay.zPosition = 200

        // Original Game Over image
        let gameOverImage = SKSpriteNode(
            imageNamed: "gameOverScreen"
        )
        gameOverImage.position = CGPoint(
            x: size.width / 2,
            y: size.height / 2 + 20
        )
        gameOverImage.zPosition = 2
        overlay.addChild(gameOverImage)

        // Damage message
        let message = SKLabelNode(fontNamed: "Arial-BoldMT")
        message.text = "You got hit too many times"
        message.fontSize = 35
        message.fontColor = .white
        message.position = CGPoint(
            x: size.width / 2,
            y: size.height / 2 - 30
        )
        message.zPosition = 3
        overlay.addChild(message)

        // Continue button
        let continueButton = SKShapeNode(
            rectOf: CGSize(width: 180, height: 55),
            cornerRadius: 10
        )

        continueButton.name = "gameOverContinueButton"
        continueButton.fillColor = UIColor(
            red: 67 / 255,
            green: 127 / 255,
            blue: 181 / 255,
            alpha: 1
        )
        continueButton.strokeColor = .white
        continueButton.lineWidth = 3
        continueButton.position = CGPoint(
            x: size.width / 2,
            y: size.height / 2 - 110
        )
        continueButton.zPosition = 4

        let continueLabel = SKLabelNode(
            fontNamed: "Arial-BoldMT"
        )
        continueLabel.text = "CONTINUE"
        continueLabel.name = "gameOverContinueButton"
        continueLabel.fontSize = 25
        continueLabel.fontColor = .white
        continueLabel.verticalAlignmentMode = .center

        continueButton.addChild(continueLabel)
        overlay.addChild(continueButton)

        addChild(overlay)
    }
    
    func takeDamage() {

        guard !isInvincible, lives > 0 else { return }

        lives -= 1
        isInvincible = true

        // Play the character's hit animation
        playHitAnimation()

        // Remove one life icon
        if let lastLife = lifeIcons.popLast() {
            lastLife.removeFromParent()
        }

        if lives == 0 {
            player.removeAllActions()
            player.alpha = 1.0

            // Stop gameplay
            isGameOver = true

            // Stop background music
            stopBackgroundMusic()

            // Display Game Over Screen
            showGameOverScreen()

            return
        }

        // Flash the player after taking damage
        let fadeOut = SKAction.fadeAlpha(to: 0.2, duration: 0.1)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.1)

        let flash = SKAction.sequence([fadeOut, fadeIn])

        let repeatFlash = SKAction.repeat(
            flash,
            count: Int(invincibilityDuration / 0.2)
        )

        let finishInvincibility = SKAction.run { [weak self] in
            self?.player.alpha = 1.0
            self?.isInvincible = false
        }

        player.run(
            SKAction.sequence([
                repeatFlash,
                finishInvincibility
            ]),
            withKey: "invincibility"
        )
    }

    func updateCoins(deltaTime: CGFloat) {

        for coin in coins {

            // Move coin from right to left
            coin.position.x -= coinSpeed * deltaTime

            // Check whether the player collected it
            if coin.frame.intersects(player.frame) {

                score += 100
                scoreLabel.text = "Score: \(score)"

                // Show sparkle and play sound
                showCoinCollectionEffect(
                    at: coin.position
                )

                coin.removeFromParent()

            } else if coin.position.x < -coin.size.width {

                // Remove coins that leave the screen
                coin.removeFromParent()
            }
        }

        // Keep only coins that remain in the scene
        coins.removeAll { $0.parent == nil }
    }
    
    func updateSuperCoins(deltaTime: CGFloat) {

        for superCoin in superCoins {

            // Move from right to left
            superCoin.position.x -= superCoinSpeed * deltaTime

            // Check player collision
            if superCoin.frame.intersects(player.frame) {

                score += 500
                scoreLabel.text = "Score: \(score)"

                // Show sparkle and play sound
                showCoinCollectionEffect(
                    at: superCoin.position,
                    isSuperCoin: true
                )

                superCoin.removeFromParent()

            } else if superCoin.position.x < -superCoin.size.width {

                // Remove off-screen super coins
                superCoin.removeFromParent()
            }
        }

        // Remove collected or expired coins from array
        superCoins.removeAll { $0.parent == nil }
    }
    
    func updateSkullEnemies(deltaTime: CGFloat) {

        for skull in skullEnemies {

            // Move toward the player
            skull.position.x -= skullSpeed * deltaTime

            // Remove skulls after leaving the screen
            if skull.position.x < -skull.size.width {
                skull.removeFromParent()
            }
        }

        skullEnemies.removeAll { $0.parent == nil }
    }

    func restartGame() {

        guard let view = self.view else { return }

        let newScene = GameScene(size: size)
        newScene.scaleMode = scaleMode

        // Preserve the selected character
        newScene.selectedCharacter = selectedCharacter

        // Preserve the player's name
        newScene.playerName = playerName

        // Skip the Start Screen when restarting
        newScene.currentScreen = .playing

        view.presentScene(
            newScene,
            transition: SKTransition.fade(withDuration: 0.5)
        )
    }

    // MARK: - Update Game
    override func update(_ currentTime: TimeInterval) {
        
        guard currentScreen == .playing && !isGameOver else {
            lastUpdateTime = currentTime
            return
        }

        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
            return
        }

        let deltaTime = min(
            CGFloat(currentTime - lastUpdateTime),
            1.0 / 60.0
        )

        lastUpdateTime = currentTime
        
        // MARK: - Automatic Scoring
        scoreTimer += deltaTime

        while scoreTimer >= 1.0 {
            score += 100
            scoreTimer -= 1.0
            scoreLabel.text = "Score: \(score)"
        }
        
        // Scroll mountains continuously
        scrollBackground(deltaTime: deltaTime)

        // Horizontal movement
        if movingLeft {
            player.position.x -= playerSpeed * deltaTime
        }

        if movingRight {
            player.position.x += playerSpeed * deltaTime
        }

        // Keep player inside screen
        let halfWidth = player.size.width / 2

        player.position.x = max(
            halfWidth,
            min(size.width - halfWidth, player.position.x)
        )

        // Gravity
        verticalVelocity += gravity * deltaTime

        player.position.y += verticalVelocity * deltaTime

        // Ground collision
        let groundLevel = groundHeight + player.size.height / 2

        if player.position.y <= groundLevel {
            player.position.y = groundLevel
            verticalVelocity = 0
            isJumping = false
        }
        
        if isJumping {
            if verticalVelocity > 0 {
                playAnimation("jumpUp")
            } else {
                playAnimation("jumpFall")
            }
        } else if movingLeft || movingRight {
            playAnimation("running")
        } else {
            playAnimation("idle")
        }

        if movingRight && !movingLeft {
            facingRight = true
        } else if movingLeft && !movingRight {
            facingRight = false
        }

        player.xScale = facingRight ? 1 : -1
        
        // MARK: - Coin Spawning
        coinSpawnTimer += deltaTime

        if coinSpawnTimer >= coinSpawnInterval {
            spawnCoin()
            coinSpawnTimer = 0
        }

        // Move coins and detect collection
        updateCoins(deltaTime: deltaTime)
        
        // MARK: - Super Coin Spawning
        superCoinSpawnTimer += deltaTime

        if superCoinSpawnTimer >= superCoinSpawnInterval {
            spawnSuperCoin()
            superCoinSpawnTimer = 0
        }

        // Move and collect super coins
        updateSuperCoins(deltaTime: deltaTime)
        
        
        // MARK: - Skull Enemy Spawning
        skullSpawnTimer += deltaTime

        if skullSpawnTimer >= skullSpawnInterval {
            spawnSkullEnemy()
            skullSpawnTimer = 0
        }

        // Move skull enemies
        updateSkullEnemies(deltaTime: deltaTime)
        
        // Spawn bees every 5 seconds
        beeSpawnTimer += deltaTime

        if beeSpawnTimer >= beeSpawnInterval {
            spawnBeeEnemy()
            beeSpawnTimer = 0
        }

        // Update existing bees
        updateBeeEnemies(deltaTime: CGFloat(deltaTime))
        
        checkSkullCollisions()
    }
    
    // MARK: - Scroll Background
    func scrollBackground(deltaTime: CGFloat) {

        let movement = backgroundSpeed * deltaTime
        let spacing = size.width - backgroundOverlap
        let halfWidth = size.width / 2

        // Move both backgrounds to the left
        background1.position.x -= movement
        background2.position.x -= movement

        // Reposition background 1
        if background1.position.x <= -halfWidth {
            background1.position.x =
                background2.position.x + spacing
        }

        // Reposition background 2
        if background2.position.x <= -halfWidth {
            background2.position.x =
                background1.position.x + spacing
        }
    }

    // MARK: - Determine Touch Action
    func actionForTouch(_ touch: UITouch) -> String? {

        let location = touch.location(in: self)

        if leftButton.contains(location) {
            return "LEFT"
        }

        if jumpButton.contains(location) {
            return "JUMP"
        }

        if rightButton.contains(location) {
            return "RIGHT"
        }

        return nil
    }

    // MARK: - Update Movement Controls
    func updateMovementControls() {

        movingLeft = activeTouches.values.contains("LEFT")
        movingRight = activeTouches.values.contains("RIGHT")
    }

    // MARK: - Touch Began
    
    override func touchesBegan(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {

        if currentScreen == .start {
            for touch in touches {
                let location = touch.location(in: self)
                let touchedNodes = nodes(at: location)

                if touchedNodes.contains(where: {
                    $0.name == "playButton" ||
                    $0.parent?.name == "playButton"
                }) {

                    if let playButton = childNode(withName: "//playButton") {
                        animateButtonPress(playButton) {
                            self.childNode(withName: "startScreen")?.removeFromParent()
                            self.showControlsScreen()
                        }
                    }

                    return
                }
            }

            return
        }

        // MARK: - CONTROLS SCREEN
        if currentScreen == .controls {
            childNode(withName: "controlsScreen")?.removeFromParent()
            showCharacterSelectionScreen()
            return
        }
        
        // MARK: - CHARACTER SELECTION SCREEN
        if currentScreen == .characterSelection {

            for touch in touches {

                let location = touch.location(in: self)
                let touchedNodes = nodes(at: location)

                for character in PlayableCharacter.allCases {

                    let characterName = "character_\(character.rawValue)"

                    if touchedNodes.contains(where: {
                        $0.name == characterName ||
                        $0.parent?.name == characterName
                    }) {

                        selectedCharacter = character

                        // Update selection border
                        for option in PlayableCharacter.allCases {

                            if let card = childNode(
                                withName: "//character_\(option.rawValue)"
                            ) as? SKShapeNode {

                                card.strokeColor =
                                    option == selectedCharacter
                                    ? .green : .white
                            }
                        }

                        return
                    }
                }

                // Continue to name entry
                if touchedNodes.contains(where: {
                    $0.name == "characterContinueButton" ||
                    $0.parent?.name == "characterContinueButton"
                }) {

                    if let button = childNode(
                        withName: "//characterContinueButton"
                    ) {

                        animateButtonPress(button) {

                            self.loadPlayerAnimations()

                            self.currentAnimation = ""
                            self.playAnimation("idle")

                            self.childNode(
                                withName: "characterSelectionScreen"
                            )?.removeFromParent()

                            self.showNameEntryScreen()
                        }
                    }

                    return
                }
            }

            return
        }

        // MARK: - NAME ENTRY SCREEN

        if currentScreen == .nameEntry {
            for touch in touches {
                let location = touch.location(in: self)
                let touchedNodes = nodes(at: location)

                // Tap the name label to enter a name
                if touchedNodes.contains(where: {
                    $0.name == "playerNameLabel" ||
                    $0.parent?.name == "playerNameLabel"
                }) {
                    promptForPlayerName()
                    return
                }

                // Start gameplay
                if touchedNodes.contains(where: {
                    $0.name == "startGameButton" ||
                    $0.parent?.name == "startGameButton"
                }) {

                    guard !playerName
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        .isEmpty else {
                        promptForPlayerName()
                        return
                    }

                    if let startGameButton = childNode(
                        withName: "//startGameButton"
                    ) {
                        animateButtonPress(startGameButton) {
                            self.childNode(withName: "nameEntryScreen")?.removeFromParent()
                            self.currentScreen = .playing
                            self.lastUpdateTime = 0
                        }
                    }

                    return
                }
            }

            return
        }

        // MARK: - RESULTS SCREEN
        if currentScreen == .scoreResults {
            for touch in touches {
                let location = touch.location(in: self)
                let touchedNodes = nodes(at: location)

                if touchedNodes.contains(where: {
                    $0.name == "resultsRestartButton" ||
                    $0.parent?.name == "resultsRestartButton"
                }) {

                    if let restartButton = childNode(
                        withName: "//resultsRestartButton"
                    ) {
                        animateButtonPress(restartButton) {
                            self.restartGame()
                        }
                    }

                    return
                }
            }

            return
        }

        // MARK: - GAME OVER SCREEN

        if isGameOver {
            for touch in touches {
                let location = touch.location(in: self)
                let touchedNodes = nodes(at: location)

                if touchedNodes.contains(where: {
                    $0.name == "gameOverContinueButton" ||
                    $0.parent?.name == "gameOverContinueButton"
                }) {

                    if let continueButton = childNode(
                        withName: "//gameOverContinueButton"
                    ) {
                        animateButtonPress(continueButton) {

                            // Remove the Game Over screen
                            self.childNode(
                                withName: "gameOverOverlay"
                            )?.removeFromParent()

                            // Display the Results Screen
                            self.showScoreResultsScreen()
                        }
                    }

                    return
                }
            }

            return
        }

        // MARK: - GAMEPLAY CONTROLS

        for touch in touches {
            if let action = actionForTouch(touch) {
                activeTouches[touch] = action

                if action == "JUMP" {
                    jump()
                }
            }
        }

        updateMovementControls()
    }

    // MARK: - Touch Moved
    override func touchesMoved(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        
        guard !isGameOver else { return }

        for touch in touches {

            let oldAction = activeTouches[touch]
            let newAction = actionForTouch(touch)

            if newAction == "JUMP" && oldAction != "JUMP" {
                jump()
            }

            if let newAction = newAction {
                activeTouches[touch] = newAction
            } else {
                activeTouches.removeValue(forKey: touch)
            }
        }

        updateMovementControls()
    }

    // MARK: - Touch Ended
    override func touchesEnded(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        guard !isGameOver else { return }

        for touch in touches {
            activeTouches.removeValue(forKey: touch)
        }

        updateMovementControls()
    }

    // MARK: - Touch Cancelled
    override func touchesCancelled(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {

        for touch in touches {
            activeTouches.removeValue(forKey: touch)
        }

        updateMovementControls()
    }

}
