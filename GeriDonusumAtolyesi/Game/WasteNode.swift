//
//  WasteNode.swift
//  GeriDonusumAtolyesi
//
//  Ekranda görünen atık objeleri
//

import SpriteKit

class WasteNode: SKShapeNode {
    var wasteItem: WasteItem
    var isBeingDragged = false

    init(wasteItem: WasteItem) {
        self.wasteItem = wasteItem
        super.init()

        setupAppearance()
        setupPhysics()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupAppearance() {
        // Yuvarlak atık şekli
        let size = wasteItem.size
        let circle = SKShapeNode(circleOfRadius: size / 2)

        // Kategori rengini uygula
        circle.fillColor = UIColor(wasteItem.category.color)
        circle.strokeColor = .white
        circle.lineWidth = 2

        // Kirli ise üzerine gölge ekle
        if wasteItem.isDirty {
            circle.alpha = 0.7
            let dirtOverlay = SKShapeNode(circleOfRadius: size / 2)
            dirtOverlay.fillColor = UIColor.brown.withAlphaComponent(0.3)
            dirtOverlay.strokeColor = .clear
            circle.addChild(dirtOverlay)
        }

        // İkon ekle
        let label = SKLabelNode(text: wasteItem.category.icon)
        label.fontSize = size * 0.5
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: 0)
        circle.addChild(label)

        // Seviye göstergesi (küçük rozet)
        if wasteItem.level.rawValue > 1 {
            let levelBadge = SKShapeNode(circleOfRadius: size * 0.2)
            levelBadge.fillColor = .white
            levelBadge.strokeColor = .black
            levelBadge.lineWidth = 1
            levelBadge.position = CGPoint(x: size * 0.3, y: size * 0.3)

            let levelLabel = SKLabelNode(text: "\(wasteItem.level.rawValue)")
            levelLabel.fontSize = size * 0.25
            levelLabel.fontColor = .black
            levelLabel.verticalAlignmentMode = .center
            levelBadge.addChild(levelLabel)

            circle.addChild(levelBadge)
        }

        addChild(circle)
        self.position = wasteItem.position
    }

    private func setupPhysics() {
        let size = wasteItem.size
        physicsBody = SKPhysicsBody(circleOfRadius: size / 2)
        physicsBody?.isDynamic = true
        physicsBody?.categoryBitMask = 1
        physicsBody?.contactTestBitMask = 1
        physicsBody?.collisionBitMask = 1
        physicsBody?.restitution = 0.3 // Hafif zıplama
        physicsBody?.friction = 0.5
        physicsBody?.linearDamping = 1.0 // Hava direnci
        physicsBody?.angularDamping = 1.0 // Dönme direnci

        name = "waste"
    }

    func startDragging() {
        isBeingDragged = true
        physicsBody?.isDynamic = false

        // Sürüklenirken biraz büyüt
        let scaleUp = SKAction.scale(to: 1.1, duration: 0.1)
        run(scaleUp)

        // Ön plana getir
        zPosition = 100
    }

    func stopDragging() {
        isBeingDragged = false
        physicsBody?.isDynamic = true

        // Normal boyuta dön
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
        run(scaleDown)

        zPosition = 1
    }

    func playMergeAnimation(completion: @escaping () -> Void) {
        // Parıltı efekti
        let flash = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.5, duration: 0.1),
            SKAction.fadeAlpha(to: 1.0, duration: 0.1)
        ])

        // Büyüme animasyonu
        let grow = SKAction.scale(to: 1.3, duration: 0.2)
        let shrink = SKAction.scale(to: 1.0, duration: 0.2)

        // Dönme
        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 0.3)

        let sequence = SKAction.sequence([
            SKAction.group([flash, grow]),
            SKAction.group([shrink, rotate])
        ])

        run(sequence) {
            completion()
        }
    }

    func updateAppearance() {
        // Mevcut görünümü temizle
        removeAllChildren()
        // Yeniden oluştur
        setupAppearance()
    }
}
