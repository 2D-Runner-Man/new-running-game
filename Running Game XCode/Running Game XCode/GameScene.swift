
import SpriteKit
import UIKit

class GameScene: SKScene {

    // MARK: - Player
    var player = SKSpriteNode()

    let playerSpeed: CGFloat = 250
    let groundHeight: CGFloat = 70
    
    // MARK: - Scoring
    var score = 0
    var scoreTimer: TimeInterval = 0

    let scoreLabel = SKLabelNode(fontNamed: "Arial-BoldMT")

    // MARK: - Jumping
    var verticalVelocity: CGFloat = 0
    var isJumping = false

    let gravity: CGFloat = -1200
    let jumpVelocity: CGFloat = 750
    
    // MARK: - Coins
    var coins: [SKSpriteNode] = []

    var coinSpawnTimer: TimeInterval = 0
    let coinSpawnInterval: TimeInterval = 2.0

    let coinSpeed: CGFloat = 180
    let coinSize = CGSize(width: 30, height: 30)

    // MARK: - Movement
    var movingLeft = false
    var movingRight = false

    // MARK: - Touch Controls
    var leftButton = SKShapeNode()
    var jumpButton = SKShapeNode()
    var rightButton = SKShapeNode()

    // Track multiple fingers independently
    var activeTouches: [UITouch: String] = [:]

    // MARK: - Frame Timing
    var lastUpdateTime: TimeInterval = 0
  
    // MARK: - Scrolling Background
    var background1 = SKSpriteNode()
    var background2 = SKSpriteNode()

    let backgroundSpeed: CGFloat = 100
    let backgroundOverlap: CGFloat = 2
    
    var idleTextures: [SKTexture] = []
    var runTextures: [SKTexture] = []

    let jumpUpTexture = SKTexture(imageNamed: "jumpUp")
    let jumpFallTexture = SKTexture(imageNamed: "jumpFall")
    
    let controlsAreaHeight: CGFloat = 100

    var currentAnimation = ""
    var facingRight = true
    
    
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

        // MARK: - Scrolling Mountain Background

       backgroundColor = .black

       background1 = SKSpriteNode(
           imageNamed: "mountainBackground"
       )

       background2 = SKSpriteNode(
           imageNamed: "mountainBackground"
       )

       // Both backgrounds cover the entire game scene
        let gameAreaHeight = size.height - controlsAreaHeight

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

        // Ground
//        let ground = SKSpriteNode(
//            color: .green,
//            size: CGSize(
//                width: size.width,
//                height: groundHeight
//            )
//        )
//
//        ground.position = CGPoint(
//            x: size.width / 2,
//            y: groundHeight / 2
//        )
//
//        addChild(ground)
        
        setupScoreLabel()

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
    
    func spawnCoin() {

        let coin = SKSpriteNode(imageNamed: "coin")

        coin.size = coinSize
        coin.name = "coin"
        coin.zPosition = 5

        // Spawn just beyond the right side of the screen
        let spawnX = size.width + coinSize.width / 2

        // Keep coins above the ground
        let minimumY: CGFloat = 180

        // Prevent coins from spawning too close to the top
        let maximumY: CGFloat = 400

        coin.position = CGPoint(
            x: spawnX,
            y: CGFloat.random(in: minimumY...maximumY)
        )

        addChild(coin)
        coins.append(coin)
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
