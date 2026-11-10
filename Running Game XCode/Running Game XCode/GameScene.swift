
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

    let scoreLabel = SKLabelNode(fontNamed: "Arial-BoldMT")

    // MARK: - Frame Timing
    var lastUpdateTime: TimeInterval = 0
    
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

        rightButton = createButton(
            title: "RIGHT",
            x: size.width - 65,
            width: 100
        )

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

            // We'll add the Game Over screen next
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

    // MARK: - Update Game
    override func update(_ currentTime: TimeInterval) {

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

    // MARK: - Jump
    func jump() {

        if !isJumping {
            verticalVelocity = jumpVelocity
            isJumping = true
        }
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
