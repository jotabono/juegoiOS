//
//  GameScene.swift
//  Flappy Bird
//
//  Stucom
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Personajes
    var nave = SKSpriteNode()
    
    // Recursos
    var bg = SKSpriteNode()
    var movingObjects = SKNode()
    // Variables
    var gameOver = false
    var timer = Timer()
    var enemyPosition = 0
    var score = 0
    var scoreLabel = SKLabelNode()
    var gameOverLabel = SKLabelNode()
    
    // Groups
    let naveGroup:UInt32 = 0x1 << 0
    let objectGroup:UInt32 = 2
    let enemyGroup:UInt32 = 0x1 << 1
    let limiteGroup:UInt32 = 1
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self;
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -5.0)
        
        if #available(iOS 9, *) {
            var backgroundMusic: SKAudioNode
            
            if let musicURL = Bundle.main.url(forResource: "xenonost", withExtension: "mp3") {
                backgroundMusic = SKAudioNode(url: musicURL)
                addChild(backgroundMusic)
            }
        }
        

        
        // SCORE LABEL CONFIG
        
        self.scoreLabel.fontName = "Helvetica"
        self.scoreLabel.fontSize = 60
        self.scoreLabel.text = "0"
        self.scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.size.height - 70)
        self.scoreLabel.zPosition = 20
        
        self.addChild(self.scoreLabel)
        
        // FUNCIÓN SET BACKGROUND
        self.makeBackground()
        
        self.addChild(movingObjects)
        
        
        let naveTexture = SKTexture(imageNamed: "nave1.png")
        let naveTexture2 = SKTexture(imageNamed: "nave2.png")
        
        // ANIMACIÓN NAVE FUEGO TRASERO
        let animation = SKAction.animate(with: [naveTexture, naveTexture2], timePerFrame: 0.1)
        let naveImpulso = SKAction.repeatForever(animation)
        
        // NAVE SPRITE NODE CONFIGURE
        nave = SKSpriteNode(texture: naveTexture)
        nave.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        nave.zPosition = 10
        nave.run(naveImpulso)
        
        nave.name = "naveNode"
        nave.physicsBody = SKPhysicsBody(texture: nave.texture!, size: nave.texture!.size())
        //nave.physicsBody?.isDynamic = true
        nave.physicsBody?.affectedByGravity = false
        nave.physicsBody?.allowsRotation = false
        nave.physicsBody?.usesPreciseCollisionDetection = true
        nave.physicsBody?.categoryBitMask = naveGroup
        //nave.physicsBody?.collisionBitMask = objectGroup
        //nave.physicsBody?.contactTestBitMask = objectGroup
        
        self.addChild(nave)
        
        let ground = SKNode()
        ground.position = CGPoint(x: 0, y: 0)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.size.width * 2, height: 1))
        ground.name = "suelo"
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = objectGroup
        ground.physicsBody?.collisionBitMask = objectGroup

        let left = SKNode()
        left.position = CGPoint(x: 0, y: 0)
        left.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 1, height: self.frame.size.height * 2))
        left.physicsBody?.isDynamic = false
        left.physicsBody?.categoryBitMask = objectGroup
        left.physicsBody?.collisionBitMask = objectGroup
        
        let right = SKNode()
        right.position = CGPoint(x: self.frame.size.width, y: 0)
        right.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 1, height: self.frame.size.height * 2))
        right.physicsBody?.isDynamic = false
        right.physicsBody?.categoryBitMask = objectGroup
        right.physicsBody?.collisionBitMask = objectGroup

        let top = SKNode()
        top.position = CGPoint(x: 0, y: self.frame.size.height)
        top.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.size.width * 2, height: 1))
        top.physicsBody?.isDynamic = false
        top.physicsBody?.categoryBitMask = objectGroup
        top.physicsBody?.collisionBitMask = objectGroup

        self.addChild(ground)
        self.addChild(left)
        self.addChild(right)
        self.addChild(top)

        self.timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(GameScene.showEnemies), userInfo: nil, repeats: true)

        if(nave.position.x - (nave.size.width/2) == 0 || (nave.position.x - (nave.size.width/2)) == frame.size.width){
            self.movingObjects.speed = 0
        }
    }
    
    func showEnemies() {
        
        let gapWidth = nave.size.height
        let movementAmount = arc4random_uniform(UInt32(self.frame.size.width / 2))
        //let movementAmountHeight = arc4random_uniform(UInt32(self.frame.size.width / 2))
        let pipeOffset = CGFloat(movementAmount) - self.frame.size.width / 4
        
        let malo1Texture = SKTexture(imageNamed: "malo.png")

        let malo1 = SKSpriteNode(texture: malo1Texture)
        let mueveMalos = SKAction.moveBy(x:0, y: -(self.frame.size.height) + (malo1Texture.size().height * 2), duration: TimeInterval(self.frame.size.height / 100))
        //let removeMalos = SKAction.removeFromParent()
        let moveAndRemoveMalos = SKAction.sequence([mueveMalos, mueveMalos])
        
        malo1.name = "malo"
        malo1.zPosition = 20
        malo1.position = CGPoint(x: self.frame.midX + (malo1.size.height / 2) + (gapWidth / 2) + pipeOffset, y: self.frame.size.height + malo1Texture.size().height)
        //malo1.physicsBody = SKPhysicsBody(rectangleOf: malo1.size)
        malo1.physicsBody = SKPhysicsBody(texture: malo1.texture!, size: malo1.texture!.size())
        malo1.physicsBody?.isDynamic = false
        malo1.physicsBody?.usesPreciseCollisionDetection = true
        malo1.physicsBody?.categoryBitMask = enemyGroup
        malo1.physicsBody?.collisionBitMask = enemyGroup | naveGroup
        malo1.physicsBody?.contactTestBitMask = enemyGroup | naveGroup

        enemyPosition = Int(malo1.position.y)
        
        malo1.run(moveAndRemoveMalos)
        
        self.movingObjects.addChild(malo1)
        
        malo1.physicsBody?.applyImpulse(CGVector(dx: 10, dy: 10))
        malo1.physicsBody?.linearDamping = 1
        malo1.physicsBody?.mass = 1

    }
    
    func makeBackground() {
        // SET FONDO
        let bgTexture = SKTexture(imageNamed: "bg.jpg")
        
        // MOVIMIENTO FONDO
        let moveBg = SKAction.moveBy(x: 0, y: -bgTexture.size().height, duration: 9)
        let replaceBg = SKAction.moveBy(x: 0, y: bgTexture.size().height, duration: 0)
        let moveBgForever = SKAction.repeatForever(SKAction.sequence([moveBg, replaceBg]))
        
        // POSICIÓN Y CONTRAINTS FONDO
        for i in 0 ..< 3 {
            bg = SKSpriteNode(texture: bgTexture)
            bg.position = CGPoint(x: self.frame.midX, y: (bgTexture.size().height / 2) + (bgTexture.size().height * CGFloat(i)))
            bg.size.width = self.frame.width
            bg.run(moveBgForever)
            
            self.movingObjects.addChild(bg)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let secondNode = contact.bodyB.node as! SKSpriteNode
        print("BODY A\(contact.bodyA.node)")
        print("BODY B\(contact.bodyB.node)")
        
        if (contact.bodyA.node!.name != "naveNode") &&
            (contact.bodyB.node!.name != "malo") {
            score += 1
            self.scoreLabel.text = "\(score)"
        }
        else if !gameOver {
            self.gameOver = true
            self.movingObjects.speed = 0
            timer.invalidate()
            let naveTextureDead = SKTexture(imageNamed: "naveDead.png")
            let maloTextureDead = SKTexture(imageNamed: "maloDead.png")

            let animation = SKAction.animate(with: [naveTextureDead, maloTextureDead], timePerFrame: 0.3)
            let explosion = SKAction.repeatForever(animation)
            nave.run(explosion)

            self.nave.texture = naveTextureDead
            
            self.gameOverLabel.fontName = "Helvetica"
            self.gameOverLabel.fontSize = 30
            self.gameOverLabel.text = "Has fracasado"
            self.gameOverLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
            self.gameOverLabel.zPosition = 20
            
            self.addChild(self.gameOverLabel)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(gameOver){
            score = 0
            scoreLabel.text = "0"
            movingObjects.removeAllChildren()
            makeBackground()
            self.timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(GameScene.showEnemies), userInfo: nil, repeats: true)
            nave.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
            nave.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            
            self.gameOverLabel.removeFromParent()
            self.movingObjects.speed = 1
            
            let naveTexture = SKTexture(imageNamed: "nave1.png")
            let naveTexture2 = SKTexture(imageNamed: "nave2.png")

            nave.texture = naveTexture

            let animation = SKAction.animate(with: [naveTexture, naveTexture2], timePerFrame: 0.1)
            let naveImpulso = SKAction.repeatForever(animation)
            nave.run(naveImpulso)
            
            gameOver = false
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

        for touch: AnyObject in touches {
                let pointOfTouch = touch.location(in: self)
                
                let middleScreen = self.frame.width/2
                let middleScreenHeight = self.frame.height/2
                
                if(pointOfTouch.x < middleScreen){
                    nave.physicsBody?.applyImpulse(CGVector(dx:-10, dy: 0))
                    nave.physicsBody?.linearDamping = 1
                    nave.physicsBody?.mass = 1
                    
                } else {
                    nave.physicsBody?.applyImpulse(CGVector(dx: 10, dy: 0))
                    nave.physicsBody?.linearDamping = 1
                    nave.physicsBody?.mass = 1
                }
            
                if(pointOfTouch.y < middleScreenHeight){
                    nave.physicsBody?.applyImpulse(CGVector(dx:0, dy: -10))
                    nave.physicsBody?.linearDamping = 1
                    nave.physicsBody?.mass = 1
                } else {
                    nave.physicsBody?.applyImpulse(CGVector(dx:0, dy: 10))
                    nave.physicsBody?.linearDamping = 1
                    nave.physicsBody?.mass = 1
            }
        }
    }
   
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */

    }
}
