//
//  GameViewController.swift
//  FlappyDragon
//
//  Created by Edwy Lugo on 06/03/19.
//  Copyright © 2019 SDvirtua Marketing Digital. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import AVKit


class GameViewController: UIViewController {
    
    var stage: SKView!
    var musicPlayer: AVAudioPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        stage = view as! SKView //monta o palco
        stage.ignoresSiblingOrder = true // Deixa que eu ordeno os objetos um na frente do outro
        
        presentScene() //Mostra a cena do jogo
        playMusic()
        
    }
    
    func playMusic() {
        if let musicURL = Bundle.main.url(forResource: "music", withExtension: "m4a") {
            musicPlayer = try! AVAudioPlayer(contentsOf: musicURL)
            musicPlayer.numberOfLoops = -1
            musicPlayer.volume = 0.4
            musicPlayer.play()
        }
        
    }
    
    func presentScene() {
        let scene = GameScene(size: CGSize(width: 320, height: 568))
        scene.gameViewController = self
        scene.scaleMode = .aspectFill
        stage.presentScene(scene, transition: .doorsOpenVertical(withDuration: 0.2))
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
