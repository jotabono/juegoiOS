//
//  GameScene.swift
//  Flappy Bird
//
//  Stucom
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var bird = SKSpriteNode()
    var bg = SKSpriteNode()
    var movingObjects = SKNode()
    
    var gameOver = false
    
    var timer = Timer()
    
    var score = 0
    var scoreLabel = SKLabelNode()
    var gameOverLabel = SKLabelNode()
    
    let birdGroup:UInt32 = 1
    let objectGroup:UInt32 = 2
    let gapGroup:UInt32 = 1 << 2
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self;
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -5.0)
        
       /* self.scoreLabel.fontName = "Helvetica"
        self.scoreLabel.fontSize = 60
        self.scoreLabel.text = "0"
        self.scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.size.height - 70)
        self.scoreLabel.zPosition = 20
        
        self.addChild(self.scoreLabel) */
        
        self.makeBackground()
        
        self.addChild(movingObjects)
        
        let birdTexture = SKTexture(imageNamed: "nave1.png")
        let birdTexture2 = SKTexture(imageNamed: "nave2.png")
        let birdTexture3 = SKTexture(imageNamed: "naveleft.png")
        let birdTexture4 = SKTexture(imageNamed: "naveright.png")
        
        let animation = SKAction.animate(with: [birdTexture, birdTexture2], timePerFrame: 0.1)
        let makeBirdFlap = SKAction.repeatForever(animation)
        
        bird = SKSpriteNode(texture: birdTexture)
        bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        bird.zPosition = 10
        
        bird.run(makeBirdFlap)
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.width / 2)
        bird.physicsBody?.isDynamic = true
        bird.physicsBody?.affectedByGravity = false
        bird.physicsBody?.allowsRotation = false
        bird.physicsBody?.categoryBitMask = birdGroup
        bird.physicsBody?.collisionBitMask = objectGroup
        bird.physicsBody?.contactTestBitMask = objectGroup | gapGroup
        
        self.addChild(bird)
        
        let ground = SKNode()
        ground.position = CGPoint(x: 0, y: 0)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.size.width * 2, height: 1))
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = objectGroup
        
        self.addChild(ground)
        
        self.timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(GameScene.createPipes), userInfo: nil, repeats: true)
    }
    
    func createPipes() {
        
        let gapWidth = bird.size.height
        let movementAmount = arc4random_uniform(UInt32(self.frame.size.width / 2))
        let movementAmountHeight = arc4random_uniform(UInt32(self.frame.size.width / 2))
        let pipeOffset = CGFloat(movementAmount) - self.frame.size.width / 4

        let malo1Texture = SKTexture(imageNamed: "malo.png")
        let mueveMalos = SKAction.moveBy(x:0, y: -(self.frame.size.height) + (malo1Texture.size().height * 2), duration: TimeInterval(self.frame.size.height / 100))
        let removeMalos = SKAction.removeFromParent()
        let moveAndRemoveMalos = SKAction.sequence([mueveMalos, removeMalos])
        
        let malo1 = SKSpriteNode(texture: malo1Texture)
        malo1.position = CGPoint(x: self.frame.midX + (malo1.size.height / 2) + (gapWidth / 2) + pipeOffset, y: self.frame.size.height + malo1Texture.size().height)
        malo1.physicsBody = SKPhysicsBody(rectangleOf: malo1.size)
        malo1.physicsBody?.isDynamic = false
        malo1.physicsBody?.categoryBitMask = objectGroup
        malo1.run(moveAndRemoveMalos)
        
        self.movingObjects.addChild(malo1)
        
        
        let MAX : UInt32 = 9
        let MIN : UInt32 = 1
        let random_number = Int(arc4random_uniform(MAX) + MIN)
        malo1.physicsBody?.applyImpulse(CGVector(dx: 10, dy: 10))
        malo1.physicsBody?.linearDamping = 1
        malo1.physicsBody?.mass = 1

        /*
        let gapHeight = bird.size.height * 4
        let movementAmount = arc4random_uniform(UInt32(self.frame.size.height / 2))
        let pipeOffset = CGFloat(movementAmount) - self.frame.size.height / 4
        
        let pipeTexture1 = SKTexture(imageNamed: "malo.png")
        let pipeTexture2 = SKTexture(imageNamed: "pipe2.png")
        
        let movePipes = SKAction.moveBy(x: -(self.frame.size.width + (pipeTexture1.size().width * 2)), y: 0, duration: TimeInterval(self.frame.size.width / 100))
        let removePipes = SKAction.removeFromParent()
        let moveAndRemovePipes = SKAction.sequence([movePipes, removePipes])
        
        
        let pipe1 = SKSpriteNode(texture: pipeTexture1)
        pipe1.position = CGPoint(x: self.frame.size.width + pipeTexture1.size().width, y: self.frame.midY + (pipe1.size.height / 2) + (gapHeight / 2) + pipeOffset)
        pipe1.physicsBody = SKPhysicsBody(rectangleOf: pipe1.size)
        pipe1.physicsBody?.isDynamic = false
        pipe1.physicsBody?.categoryBitMask = objectGroup
        
        pipe1.run(moveAndRemovePipes)
        
        self.movingObjects.addChild(pipe1)
        
        let pipe2 = SKSpriteNode(texture: pipeTexture2)
        pipe2.position = CGPoint(x: self.frame.size.width + pipeTexture1.size().width, y: self.frame.midY - (pipe2.size.height / 2) - (gapHeight / 2) + pipeOffset)
        pipe2.physicsBody = SKPhysicsBody(rectangleOf: pipe2.size)
        pipe2.physicsBody?.isDynamic = false
        pipe2.physicsBody?.categoryBitMask = objectGroup
        
        pipe2.run(moveAndRemovePipes)
        
        self.movingObjects.addChild(pipe2)
        
        let gap = SKNode()
        gap.position = CGPoint(x: self.frame.size.width + pipeTexture1.size().width, y: self.frame.midY + pipeOffset)
        gap.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipe1.size.width, height: gapHeight))
        gap.physicsBody?.isDynamic = false
        
        gap.physicsBody?.categoryBitMask = gapGroup
        
        gap.run(moveAndRemovePipes)
        
        gap.zPosition = 30
        
        self.movingObjects.addChild(gap)*/
    }
    
    func makeBackground() {
        let bgTexture = SKTexture(imageNamed: "bg.jpg")
        
        let moveBg = SKAction.moveBy(x: 0, y: -bgTexture.size().height, duration: 9)
        let replaceBg = SKAction.moveBy(x: 0, y: bgTexture.size().height, duration: 0)
        let moveBgForever = SKAction.repeatForever(SKAction.sequence([moveBg, replaceBg]))
        
        for i in 0 ..< 3 {
            bg = SKSpriteNode(texture: bgTexture)
            bg.position = CGPoint(x: self.frame.midX, y: (bgTexture.size().height / 2) + (bgTexture.size().height * CGFloat(i)))
            bg.size.height = self.frame.height
            bg.run(moveBgForever)
            
            self.movingObjects.addChild(bg)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == gapGroup || contact.bodyB.categoryBitMask == gapGroup {
            score += 1
            self.scoreLabel.text = "\(score)"
        }
        else if !gameOver {
            self.gameOver = true
            self.movingObjects.speed = 0
            timer.invalidate()
            
            self.gameOverLabel.fontName = "Helvetica"
            self.gameOverLabel.fontSize = 30
            self.gameOverLabel.text = "Toca para intentarlo de nuevo"
            self.gameOverLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
            self.gameOverLabel.zPosition = 20
            
            self.addChild(self.gameOverLabel)
        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

        for touch: AnyObject in touches {
            let pointOfTouch = touch.location(in: self)
            
            let middleScreen = self.frame.width/2
            let middleScreenHeight = self.frame.height/2
            
            if(pointOfTouch.x < middleScreen){
                bird.physicsBody?.applyImpulse(CGVector(dx:-10, dy: 0))
                bird.physicsBody?.linearDamping = 1
                bird.physicsBody?.mass = 1
            } else {
                bird.physicsBody?.applyImpulse(CGVector(dx: 10, dy: 0))
                bird.physicsBody?.linearDamping = 1
                bird.physicsBody?.mass = 1
            }
            
            if(pointOfTouch.y < middleScreenHeight){
                bird.physicsBody?.applyImpulse(CGVector(dx:0, dy: -10))
                bird.physicsBody?.linearDamping = 1
                bird.physicsBody?.mass = 1
            } else {
                bird.physicsBody?.applyImpulse(CGVector(dx:0, dy: 10))
                bird.physicsBody?.linearDamping = 1
                bird.physicsBody?.mass = 1
            }
            
        }
        /*
        if !gameOver {
            bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 100))
        }
        else {
            score = 0
            scoreLabel.text = "0"
            movingObjects.removeAllChildren()
            makeBackground()
            self.timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(GameScene.createPipes), userInfo: nil, repeats: true)
            bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
            bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            
            self.gameOverLabel.removeFromParent()
            self.movingObjects.speed = 1
            
            gameOver = false
        }*/
    }
   
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
}
