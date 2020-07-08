//
//  GameScene.swift
//  FlappyDragon
//
//  Created by Edwy Lugo on 06/03/19.
//  Copyright © 2019 SDvirtua Marketing Digital. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var floor: SKSpriteNode!
    var intro: SKSpriteNode!
    var player: SKSpriteNode!
    var gameArea: CGFloat = 410.0
    var velocity: Double = 100.0
    var gameFinished = false
    var gameStarted = false
    var restart = false
    var scoreLabel: SKLabelNode!
    var score: Int = 0
    var flyForce: CGFloat = 30.0
    var timer: Timer!
    
    //mascaras de bits que sao atribuidas ao objeto
    var playerCategory: UInt32 = 1 // vinculada ao jogador
    var enemyCategory: UInt32 = 2
    var scoreCategory: UInt32 = 4
    
    weak var gameViewController: GameViewController?
    let scoreSound = SKAction.playSoundFileNamed("score.mp3", waitForCompletion: false)
    let gameOverSound = SKAction.playSoundFileNamed("hit.mp3", waitForCompletion: false)
    
    override func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self
        
        
        addBackground() // Adiciona o fundo na view
        addFloor() // Adiciona o chão na view
        addIntro() // Adiciona tela de abertura do Game
        addPlayer() //Adiciona o personagem na tela e anima
        moveFloor() // Animar o Chao
    }
    
    func addBackground() {
        let background = SKSpriteNode(imageNamed: "background") //setando background no jogo
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2) //Ajusta a imagem de fundo na view
        background.zPosition = 0 //Meu fundo é a primeira imagem na hierarquia
        addChild(background)
    }
    
    func addFloor() {
        floor = SKSpriteNode(imageNamed: "floor")
        floor.zPosition = 2
        floor.position = CGPoint(x: floor.size.width/2, y: size.height - gameArea - floor.size.height/2)
        addChild(floor)
        
        
        //Configurar chao
        let invisibleFloor = SKNode()
        invisibleFloor.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width, height: 1))
        invisibleFloor.physicsBody?.isDynamic = false
        invisibleFloor.physicsBody?.categoryBitMask = enemyCategory
        invisibleFloor.physicsBody?.contactTestBitMask = playerCategory
        invisibleFloor.position = CGPoint(x: size.width/2, y: size.height - gameArea)
        invisibleFloor.zPosition = 2
        addChild(invisibleFloor)
        
        //Configurar teto
        let invisibleRoof = SKNode()
        invisibleRoof.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width, height: 1))
        invisibleRoof.physicsBody?.isDynamic = false
        invisibleRoof.position = CGPoint(x: size.width/2, y: size.height)
        invisibleRoof.zPosition = 2
        addChild(invisibleRoof)
    }
    
    func addIntro() {
        intro = SKSpriteNode(imageNamed: "intro")
        intro.zPosition = 3
        intro.position = CGPoint(x: size.width/2, y: size.height - 210)
        addChild(intro)
    }
    
    func addPlayer() {
        player = SKSpriteNode(imageNamed: "player1")
        player.zPosition = 4
        player.position = CGPoint(x: 60, y: size.height - gameArea/2)
        addChild(player)
        
        var playerTextures = [SKTexture]() //Classe que representa uma textura
        for i in 1...4 {
            playerTextures.append(SKTexture(imageNamed: "player\(i)")) //Muda a imagem do personagem
        }
        let animationAction = SKAction.animate(with: playerTextures, timePerFrame: 0.09)
        let repeatAction = SKAction.repeatForever(animationAction) //repetir a acao eternamente
        player.run(repeatAction)//Rodar a acao
    }
    
    func moveFloor() {
        let duration = Double(floor.size.width/2)/velocity
        let moveFloorAction = SKAction.moveBy(x: -floor.size.width/2, y: 0, duration: duration)
        let resetXAction = SKAction.moveBy(x: floor.size.width/2, y: 0, duration: 0)
        let sequenceAction = SKAction.sequence([moveFloorAction, resetXAction])
        let repeatAction = SKAction.repeatForever(sequenceAction)
        floor.run(repeatAction)
    }
    
    //Adiciona a pontuação na tela com a posicao e font do objeto.
    func addScore() {
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.fontSize = 94
        scoreLabel.text = "\(score)"
        scoreLabel.zPosition = 5
        scoreLabel.position = CGPoint(x: size.width/2, y: size.height - 100)
        scoreLabel.alpha = 0.8
        addChild(scoreLabel)
    }
    
    //Gerar inimigos
    func spawnEnemies() {
        let initialPosition = CGFloat(arc4random_uniform(132) + 74)
        let enemyNumber = Int(arc4random_uniform(4) + 1)
        let enemiesDistance = self.player.size.height * 2.5//espaco entre o inimigo de cima e debaixo
        
        let enemyTop = SKSpriteNode(imageNamed: "enemytop\(enemyNumber)")
        let enemyWidth = enemyTop.size.width
        let enemyHeight = enemyTop.size.height
        
        enemyTop.position = CGPoint(x: size.width + enemyWidth/2, y: size.height - initialPosition + enemyHeight/2)
        enemyTop.zPosition = 1
        enemyTop.physicsBody = SKPhysicsBody(rectangleOf: enemyTop.size)
        enemyTop.physicsBody?.isDynamic = false
        enemyTop.physicsBody?.categoryBitMask = enemyCategory
        enemyTop.physicsBody?.contactTestBitMask = playerCategory // contato com o jogador
        
        let enemyBottom = SKSpriteNode(imageNamed: "enemybottom\(enemyNumber)")
        
        
        enemyBottom.position = CGPoint(x: size.width + enemyWidth/2, y: enemyTop.position.y - enemyTop.size.height - enemiesDistance)
        enemyBottom.zPosition = 1
        enemyBottom.physicsBody = SKPhysicsBody(rectangleOf: enemyTop.size)
        enemyBottom.physicsBody?.isDynamic = false
        enemyBottom.physicsBody?.categoryBitMask = enemyCategory
        enemyBottom.physicsBody?.contactTestBitMask = playerCategory // contato com o jogador
        
        
        let laser = SKNode()
        laser.position = CGPoint(x: enemyTop.position.x + enemyWidth/2, y: enemyTop.position.y - enemyTop.size.height/2 - enemiesDistance/2)
        laser.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 1, height: enemiesDistance))
        laser.physicsBody?.isDynamic = false
        laser.physicsBody?.categoryBitMask = scoreCategory
        
        let distance = size.width + enemyWidth
        let duration = Double(distance)/velocity
        let moveAction = SKAction.moveBy(x: -distance, y: 0, duration: duration)
        let removeAction = SKAction.removeFromParent()
        let sequenceAction = SKAction.sequence([moveAction, removeAction])
        
        enemyTop.run(sequenceAction)
        enemyBottom.run(sequenceAction)
        laser.run(sequenceAction)
        
        addChild(enemyTop)
        addChild(enemyBottom)
        addChild(laser)
    }
    
    func gameOver(){
    
        timer.invalidate()
        player.zRotation = 0
        player.texture = SKTexture(imageNamed: "playerDead")
        for node in self.children {
            node.removeAllActions()
        }
        player.physicsBody?.isDynamic = false
        gameFinished = true
        gameStarted = false
        
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { (timer) in
            let gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")
            gameOverLabel.fontColor = .red
            gameOverLabel.fontSize = 40
            gameOverLabel.text = "Game Over"
            gameOverLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
            gameOverLabel.zPosition = 5
            self.addChild(gameOverLabel)
            self.restart = true
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       
        if !gameFinished {
            if !gameStarted {
                intro.removeFromParent() //Tira o nó da cena que é encontrado.
                addScore()
                
                player.physicsBody = SKPhysicsBody (circleOfRadius: player.size.width/2 - 10) // adiciona elemento circulo no objeto
                player.physicsBody?.isDynamic = true //Cair e sofre gravidade
                player.physicsBody?.allowsRotation = true // Rotacionar caso necessário
                player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: flyForce)) // Aplicar impulso no objeto
                player.physicsBody?.categoryBitMask = playerCategory // mascara de bits
                player.physicsBody?.contactTestBitMask = scoreCategory // vai fazer contato com laser invicivel para somar no score
                player.physicsBody?.collisionBitMask = enemyCategory // vai colidir com os inimigos
                
                gameStarted = true
                
                timer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { (timer) in
                    self.spawnEnemies()
                }
                
            } else {
                player.physicsBody?.velocity = CGVector.zero
                player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: flyForce))
            }
        } else {
            if restart {
                restart = false
                gameViewController?.presentScene()
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if gameStarted {
            let yVelocity = player.physicsBody!.velocity.dy * 0.001 as CGFloat //empinar ou inclinar
            player.zRotation = yVelocity // Rotaciona num angulo baixo
        }
        
    }
}


extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        if gameStarted {
            if contact.bodyA.categoryBitMask == scoreCategory || contact.bodyB.categoryBitMask == scoreCategory {
                score += 1
                scoreLabel.text = "\(score)"
                
                run(scoreSound)
            } else if contact.bodyA.categoryBitMask == enemyCategory || contact.bodyB.categoryBitMask == enemyCategory {
                score += 1
                gameOver()
                run(gameOverSound)
            }
        }
    }
}
