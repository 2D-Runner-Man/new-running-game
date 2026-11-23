
import SpriteKit
import UIKit

class GameScene: SKScene {
    
    // MARK: - Scrolling Background
    var background1 = SKSpriteNode()
    var background2 = SKSpriteNode()

    let backgroundSpeed: CGFloat = 100
    let backgroundOverlap: CGFloat = 2
    
    var idleTextures: [SKTexture] =
    [SKTexture(imageNamed: "idle1"),
    SKTexture(imageNamed: "idle2")]
    
    var runTextures: [SKTexture] = []

    let jumpUpTexture = SKTexture(imageNamed: "jumpUp")
    let jumpFallTexture = SKTexture(imageNamed: "jumpFall")
    
    let controlsAreaHeight: CGFloat = 100

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
    
    // MARK: - Skull-Biting Enemies
    var skullEnemies: [SKSpriteNode] = []
    var skullTextures: [SKTexture] = []

    var skullSpawnTimer: TimeInterval = 0
    let skullSpawnInterval: TimeInterval = 4.0

    let skullSpeed: CGFloat = 200
    let skullSize = CGSize(width: 55, height: 55)

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
    
    var currentScreen: GameScreen = .start
    var playerName = ""
    
    // MARK: All Screens
    enum GameScreen {
        case start
        case controls
        case nameEntry
        case playing
        case scoreResults
        case gameOver
    }
    
    func showStartScreen() {

        currentScreen = .start

        let overlay = SKNode()
        overlay.name = "startScreen"
        overlay.zPosition = 300

        // Title screen background image
        let titleBackground = SKSpriteNode(
            imageNamed: "titleScreenBackground"
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
            x: size.width / 2 + 100,  // Move right
            y: size.width / 2 - 330  // Move down
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
    func loadPlayerAnimations() {
        idleTextures = (1...2).map {
            SKTexture(imageNamed: "idle\($0)")
        }

        runTextures = (1...6).map {
            SKTexture(imageNamed: "run\($0)")
        }
    }
    
    
    func playAnimation(_ animation: String) {
        guard currentAnimation != animation else { return }

        currentAnimation = animation
        player.size.width = 50
        player.removeAction(forKey: "playerAnimation")

        switch animation {
        case "idle":
            player.run(
                .repeatForever(
                    .animate(with: idleTextures, timePerFrame: 0.15)
                ),
                withKey: "playerAnimation"
            )

        case "running":
            player.run(
                .repeatForever(
                    .animate(with: runTextures, timePerFrame: 0.08)
                ),
                withKey: "playerAnimation"
            )

        case "jumpUp":
            player.texture = jumpUpTexture

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
           imageNamed: "mountainBackground"
       )

       background2 = SKSpriteNode(
           imageNamed: "mountainBackground"
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
            imageNamed: "idle1"
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
            y: size.height / 2 + 10
        )
        overlay.addChild(finalScoreLabel)

        // High score
        let highScoreLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        highScoreLabel.text = "High Score: \(highScore)"
        highScoreLabel.fontSize = 32
        highScoreLabel.fontColor = .darkGray
        highScoreLabel.position = CGPoint(
            x: size.width / 2,
            y: size.height / 2 - 40
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
            y: size.height / 2 - 115
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

        // Remove one life icon
        if let lastLife = lifeIcons.popLast() {
            lastLife.removeFromParent()
        }

        if lives == 0 {
            player.removeAllActions()
            player.alpha = 1.0

            // Stop gameplay
            isGameOver = true

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
            showNameEntryScreen()
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
