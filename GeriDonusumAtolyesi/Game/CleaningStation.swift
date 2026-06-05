//
//  CleaningStation.swift
//  GeriDonusumAtolyesi
//
//  Temizleme istasyonu - kirli atıkları temizler
//

import SpriteKit
import SwiftUI

class CleaningStation: SKNode {
    private var stationSprite: SKShapeNode!
    private var isActive = false
    private var cleaningParticles: SKEmitterNode?

    init(position: CGPoint, size: CGSize) {
        super.init()
        self.position = position
        setupStation(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupStation(size: CGSize) {
        // İstasyon arka planı
        let background = SKShapeNode(rectOf: size, cornerRadius: 15)
        background.fillColor = UIColor(red: 0.4, green: 0.7, blue: 0.9, alpha: 0.3)
        background.strokeColor = UIColor(red: 0.2, green: 0.5, blue: 0.8, alpha: 0.8)
        background.lineWidth = 3
        background.zPosition = -1
        stationSprite = background
        addChild(background)

        // İkon
        let icon = SKLabelNode(text: "💧")
        icon.fontSize = 40
        icon.verticalAlignmentMode = .center
        icon.zPosition = 1
        addChild(icon)

        // Label
        let label = SKLabelNode(text: "Temizleme")
        label.fontSize = 14
        label.fontColor = .white
        label.position = CGPoint(x: 0, y: -size.height/2 - 15)
        label.zPosition = 1
        addChild(label)

        // Idle animasyon
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.05, duration: 1.0),
            SKAction.scale(to: 1.0, duration: 1.0)
        ])
        background.run(SKAction.repeatForever(pulse))

        name = "cleaningStation"
    }

    func canCleanWaste(_ waste: WasteNode) -> Bool {
        return waste.wasteItem.isDirty
    }

    func cleanWaste(_ waste: WasteNode, completion: @escaping (WasteNode) -> Void) {
        isActive = true

        // Temizleme animasyonu
        playCleaningAnimation(at: waste.position)

        // Ses efekti
        AudioManager.shared.playCleanSound()

        // Temiz atık oluştur
        var cleanedItem = waste.wasteItem
        cleanedItem.isDirty = false

        let cleanedWaste = WasteNode(wasteItem: cleanedItem)
        cleanedWaste.position = waste.position

        // Animasyon sonrası
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isActive = false
            completion(cleanedWaste)
        }
    }

    private func playCleaningAnimation(at position: CGPoint) {
        // Su damlası partikülleri
        for _ in 0..<10 {
            let droplet = SKShapeNode(circleOfRadius: 3)
            droplet.fillColor = .cyan
            droplet.strokeColor = .clear
            droplet.position = self.position
            droplet.zPosition = 100

            let randomX = CGFloat.random(in: -30...30)
            let randomY = CGFloat.random(in: -30...30)

            let move = SKAction.moveBy(x: randomX, y: randomY, duration: 0.5)
            let fade = SKAction.fadeOut(withDuration: 0.5)

            droplet.run(SKAction.sequence([
                SKAction.group([move, fade]),
                SKAction.removeFromParent()
            ]))

            parent?.addChild(droplet)
        }

        // Parlama efekti
        let flash = SKSpriteNode(color: .cyan, size: CGSize(width: 80, height: 80))
        flash.position = position
        flash.alpha = 0
        flash.zPosition = 99

        flash.run(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.6, duration: 0.2),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))

        parent?.addChild(flash)
    }

    func highlight() {
        stationSprite.run(SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.2),
            SKAction.scale(to: 1.0, duration: 0.2)
        ]))
    }
}
