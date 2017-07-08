//
//  GameScene.swift
//  Breakout
//
//  Created by Ye Lu on 2017-07-05.
//  Copyright © 2017 Codenlight. All rights reserved.
//

import SpriteKit
#if os(watchOS)
    import WatchKit
    // SKColor typealias does not seem to be exposed on watchOS SpriteKit
    typealias SKColor = UIColor
#endif
import AVFoundation
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var ball:SKSpriteNode!
    var paddle:SKSpriteNode!
    var firstTime = true
    var scoreLabel:SKLabelNode!
    var score:Int = 0 {
        didSet {
            scoreLabel.text = "Score:\(score)"
        }
    }
    
    var audioPlayer:AVAudioPlayer!
    
    class func newGameScene() -> GameScene {
        // Load 'GameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            print("Failed to load GameScene.sks")
            abort()
        }
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        
        return scene
    }

    override func didMove(to view: SKView) {
        ball = self.childNode(withName: "Ball") as! SKSpriteNode
        paddle = self.childNode(withName: "Paddle") as! SKSpriteNode
        scoreLabel = self.childNode(withName: "Score") as! SKLabelNode
        
        let urlPath = Bundle.main.url(forResource: "brick", withExtension: "wav")
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: urlPath!)
            audioPlayer.prepareToPlay()
        } catch {
            print("Error loading brick sound effect")
        }
        
        let border = SKPhysicsBody(edgeLoopFrom: (view.scene?.frame)!)
        border.friction = 0
        self.physicsBody = border
        
        self.physicsWorld.contactDelegate = self
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyAName = contact.bodyA.node?.name
        let bodyBName = contact.bodyB.node?.name
        
        if bodyAName == "Ball" && bodyBName == "Brick" ||
           bodyAName == "Brick" && bodyBName == "Ball" {
            if bodyAName == "Brick" {
                contact.bodyA.node?.removeFromParent()
            } else {
                contact.bodyB.node?.removeFromParent()
            }
            score += 1
            audioPlayer.play()
        }
        
        if bodyAName == "Ball" || bodyBName == "Ball" {
            let v:CGVector! = ball.physicsBody?.velocity
            let negative = arc4random() % 2
            let factor:CGFloat = negative  == 0 ? -0.1 : 0.1
            if v.dx == 0 {
                ball.physicsBody?.velocity = CGVector(dx:v.dy*factor, dy:v.dy)
            }
            
            if v.dy == 0 {
                ball.physicsBody?.velocity = CGVector(dx:v.dx, dy:v.dx*factor)
            }
            
            // Losing Logic
            if ball.position.y < paddle.position.y {
                scoreLabel.text = "You Lost!"
                self.view?.isPaused = true
                ball.removeFromParent()
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Winning Logic
        if score == 12 {
            scoreLabel.text = "You Won!!!"
            self.view?.isPaused = true
            ball.removeFromParent()
        }
    }
}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension GameScene {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.location(in: self)
            paddle.position.x = touchLocation.x
        }
        paddle.position.x = max(paddle.position.x, -self.size.width/2.0+paddle.size.width/2.0)
        paddle.position.x = min(paddle.position.x, self.size.width/2.0-paddle.size.width/2.0)
        if firstTime {
            ball.position.x = paddle.position.x
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.location(in: self)
            paddle.position.x = touchLocation.x
        }
        paddle.position.x = max(paddle.position.x, -self.size.width/2.0+paddle.size.width/2.0)
        paddle.position.x = min(paddle.position.x, self.size.width/2.0-paddle.size.width/2.0)
        if firstTime {
            ball.position.x = paddle.position.x
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if firstTime {
            ball.physicsBody?.applyImpulse(CGVector(dx: 30, dy: 20))
            firstTime = false
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
   
}
#endif

#if os(OSX)
// Mouse-based event handling
extension GameScene {

    override func mouseDown(with event: NSEvent) {
       
        paddle.position.x = event.location(in: self).x
        paddle.position.x = max(paddle.position.x, -self.size.width/2.0+paddle.size.width/2.0)
        paddle.position.x = min(paddle.position.x, self.size.width/2.0-paddle.size.width/2.0)
        if firstTime {
            ball.position.x = paddle.position.x
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        paddle.position.x = event.location(in: self).x
        paddle.position.x = max(paddle.position.x, -self.size.width/2.0+paddle.size.width/2.0)
        paddle.position.x = min(paddle.position.x, self.size.width/2.0-paddle.size.width/2.0)
        if firstTime {
            ball.position.x = paddle.position.x
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        if firstTime {
            ball.physicsBody?.applyImpulse(CGVector(dx: 30, dy: 20))
            firstTime = false
        }
    }

}
#endif

