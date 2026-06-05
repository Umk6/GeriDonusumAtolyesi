//
//  WasteNode.swift
//  GeriDonusumAtolyesi
//
//  Ekranda görünen atık objeleri - gelişmiş animasyonlar ve efektler
//

import SpriteKit
import SwiftUI

class WasteNode: SKShapeNode {
    var wasteItem: WasteItem
    var isBeingDragged = false
    private var glowNode: SKShapeNode?
    private var idleAnimation: SKAction?

    init(wasteItem: WasteItem) {
        self.wasteItem = wasteItem
        super.init()

        setupAppearance()
        setupPhysics()
        startIdleAnimation()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupAppearance() {
        let size = wasteItem.size
        let circle = SKShapeNode(circleOfRadius: size / 2)

        // Gradient benzeri katmanlı renk efekti
        let baseColor = UIColor(wasteItem.category.color)
        circle.fillColor = baseColor
        circle.strokeColor = .white
        circle.lineWidth = 3
        circle.glowWidth = 2

        // Glow efekti için alt katman
        let glowCircle = SKShapeNode(circleOfRadius: size / 2 + 5)
        glowCircle.fillColor = .clear
        glowCircle.strokeColor = baseColor.withAlphaComponent(0.5)
        glowCircle.lineWidth = 2
        glowCircle.glowWidth = 8
        glowCircle.alpha = 0.6
        glowCircle.zPosition = -1
        self.glowNode = glowCircle
        addChild(glowCircle)

        // Parlama efekti (küçük yıldız)
        let sparkle = SKShapeNode(circleOfRadius: size * 0.15)
        sparkle.fillColor = .white
        sparkle.strokeColor = .clear
        sparkle.alpha = 0.8
        sparkle.position = CGPoint(x: size * 0.25, y: size * 0.25)
        sparkle.zPosition = 2
        circle.addChild(sparkle)

        // Sparkle animasyonu
        let sparkleAnim = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.5),
            SKAction.fadeAlpha(to: 1.0, duration: 0.5)
        ])
        sparkle.run(SKAction.repeatForever(sparkleAnim))

        // Kirli atık efekti
        if wasteItem.isDirty {
            circle.alpha = 0.8
            let dirtOverlay = SKShapeNode(circleOfRadius: size / 2)
            dirtOverlay.fillColor = UIColor.brown.withAlphaComponent(0.4)
            dirtOverlay.strokeColor = UIColor.brown.withAlphaComponent(0.6)
            dirtOverlay.lineWidth = 2
            circle.addChild(dirtOverlay)

            // Kirli etiket
            let dirtyLabel = SKLabelNode(text: "!")
            dirtyLabel.fontSize = size * 0.3
            dirtyLabel.fontColor = .red
            dirtyLabel.fontName = "Arial-BoldMT"
            dirtyLabel.position = CGPoint(x: -size * 0.3, y: size * 0.2)
            circle.addChild(dirtyLabel)
        }

        // İkon - daha büyük ve belirgin
        let label = SKLabelNode(text: wasteItem.category.icon)
        label.fontSize = size * 0.6
        label.verticalAlignmentMode = .center
        label.zPosition = 1
        circle.addChild(label)

        // Seviye rozeti - daha şık
        if wasteItem.level.rawValue > 1 {
            let badgeSize = size * 0.25
            let levelBadge = SKShapeNode(circleOfRadius: badgeSize)
            levelBadge.fillColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0) // Altın rengi
            levelBadge.strokeColor = .white
            levelBadge.lineWidth = 2
            levelBadge.position = CGPoint(x: size * 0.35, y: size * 0.35)
            levelBadge.zPosition = 3

            let levelLabel = SKLabelNode(text: "\(wasteItem.level.rawValue)")
            levelLabel.fontSize = size * 0.3
            levelLabel.fontColor = .black
            levelLabel.fontName = "Arial-BoldMT"
            levelLabel.verticalAlignmentMode = .center
            levelBadge.addChild(levelLabel)

            circle.addChild(levelBadge)

            // Rozet parlaması
            let badgeGlow = SKAction.sequence([
                SKAction.scale(to: 1.1, duration: 0.3),
                SKAction.scale(to: 1.0, duration: 0.3)
            ])
            levelBadge.run(SKAction.repeatForever(badgeGlow))
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
        physicsBody?.restitution = 0.4
        physicsBody?.friction = 0.6
        physicsBody?.linearDamping = 1.2
        physicsBody?.angularDamping = 1.5
        physicsBody?.mass = CGFloat(wasteItem.level.rawValue) * 0.1

        name = "waste"
    }

    private func startIdleAnimation() {
        // Hafif yüzen animasyon
        let float = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 3, duration: 1.5),
            SKAction.moveBy(x: 0, y: -3, duration: 1.5)
        ])
        idleAnimation = SKAction.repeatForever(float)
    }

    func startDragging() {
        isBeingDragged = true
        physicsBody?.isDynamic = false

        // Animasyonlu büyüme
        let scaleUp = SKAction.scale(to: 1.15, duration: 0.15)
        scaleUp.timingMode = .easeOut
        run(scaleUp)

        // Glow'u artır
        glowNode?.run(SKAction.fadeAlpha(to: 1.0, duration: 0.1))

        // Haptic feedback (ses efekti yerine geçici)
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.05),
            SKAction.scale(to: 1.15, duration: 0.05)
        ])
        run(pulse)

        zPosition = 100
    }

    func stopDragging() {
        isBeingDragged = false
        physicsBody?.isDynamic = true

        // Yumuşak küçülme
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.2)
        scaleDown.timingMode = .easeInEaseOut
        run(scaleDown)

        // Glow'u azalt
        glowNode?.run(SKAction.fadeAlpha(to: 0.6, duration: 0.2))

        zPosition = 1
    }

    func playMergeAnimation(completion: @escaping () -> Void) {
        // Ses için placeholder (şimdilik görsel)
        let soundIndicator = SKLabelNode(text: "✨")
        soundIndicator.fontSize = 30
        soundIndicator.position = CGPoint(x: 0, y: 0)
        addChild(soundIndicator)
        soundIndicator.run(SKAction.sequence([
            SKAction.moveBy(x: 0, y: 50, duration: 0.5),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))

        // Parıltı patlaması
        createSparkleExplosion()

        // Ana animasyon
        let grow = SKAction.scale(to: 1.5, duration: 0.15)
        grow.timingMode = .easeOut

        let shrink = SKAction.scale(to: 0.8, duration: 0.1)
        shrink.timingMode = .easeIn

        let bounce = SKAction.scale(to: 1.0, duration: 0.1)
        bounce.timingMode = .easeOut

        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 0.4)

        let flash = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.05),
            SKAction.fadeAlpha(to: 1.0, duration: 0.05),
            SKAction.fadeAlpha(to: 0.5, duration: 0.05),
            SKAction.fadeAlpha(to: 1.0, duration: 0.05)
        ])

        let sequence = SKAction.sequence([
            SKAction.group([grow, flash, rotate]),
            shrink,
            bounce
        ])

        run(sequence) {
            completion()
        }
    }

    private func createSparkleExplosion() {
        let sparkleCount = 12
        let baseColor = UIColor(wasteItem.category.color)

        for i in 0..<sparkleCount {
            let angle = (CGFloat(i) / CGFloat(sparkleCount)) * .pi * 2
            let distance: CGFloat = 30

            let sparkle = SKShapeNode(circleOfRadius: 3)
            sparkle.fillColor = baseColor
            sparkle.strokeColor = .white
            sparkle.lineWidth = 1
            sparkle.position = position
            sparkle.zPosition = 50

            let moveX = cos(angle) * distance
            let moveY = sin(angle) * distance

            let moveOut = SKAction.moveBy(x: moveX, y: moveY, duration: 0.5)
            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            let scale = SKAction.scale(to: 0.1, duration: 0.5)

            sparkle.run(SKAction.group([moveOut, fadeOut, scale])) {
                sparkle.removeFromParent()
            }

            parent?.addChild(sparkle)
        }
    }

    func playSpawnAnimation() {
        // Düşme animasyonu
        alpha = 0
        setScale(0.1)

        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.3)
        scaleUp.timingMode = .easeOut

        run(SKAction.group([fadeIn, scaleUp]))
    }

    func playErrorShake() {
        // Hata titremesi
        let shake = SKAction.sequence([
            SKAction.moveBy(x: -5, y: 0, duration: 0.05),
            SKAction.moveBy(x: 10, y: 0, duration: 0.05),
            SKAction.moveBy(x: -10, y: 0, duration: 0.05),
            SKAction.moveBy(x: 10, y: 0, duration: 0.05),
            SKAction.moveBy(x: -5, y: 0, duration: 0.05)
        ])

        // Kızarma efekti
        let redTint = SKAction.sequence([
            SKAction.colorize(with: .red, colorBlendFactor: 0.5, duration: 0.1),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.2)
        ])

        run(SKAction.group([shake, redTint]))
    }

    func updateAppearance() {
        removeAllChildren()
        setupAppearance()
    }
}
