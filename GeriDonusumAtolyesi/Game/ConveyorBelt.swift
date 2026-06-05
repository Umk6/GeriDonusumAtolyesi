//
//  ConveyorBelt.swift
//  GeriDonusumAtolyesi
//
//  Hareketli bant sistemi - atıkları otomatik taşır
//

import SpriteKit

class ConveyorBelt: SKNode {
    private var beltShape: SKShapeNode!
    private var animationLines: [SKShapeNode] = []
    private var moveAction: SKAction?

    let width: CGFloat
    let height: CGFloat
    var beltSpeed: CGFloat // pixels per second
    var direction: BeltDirection

    enum BeltDirection {
        case left, right, up, down

        var vector: CGVector {
            switch self {
            case .left: return CGVector(dx: -1, dy: 0)
            case .right: return CGVector(dx: 1, dy: 0)
            case .up: return CGVector(dx: 0, dy: 1)
            case .down: return CGVector(dx: 0, dy: -1)
            }
        }
    }

    init(width: CGFloat, height: CGFloat, beltSpeed: CGFloat = 50, direction: BeltDirection = .right) {
        self.width = width
        self.height = height
        self.beltSpeed = beltSpeed
        self.direction = direction
        super.init()

        setupBelt()
        startAnimation()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupBelt() {
        // Ana bant şekli
        let path = CGPath(roundedRect: CGRect(x: -width/2, y: -height/2, width: width, height: height),
                         cornerWidth: 10,
                         cornerHeight: 10,
                         transform: nil)

        beltShape = SKShapeNode(path: path)
        beltShape.fillColor = SKColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.8)
        beltShape.strokeColor = SKColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        beltShape.lineWidth = 3
        addChild(beltShape)

        // Hareket çizgileri (animasyon için)
        createAnimationLines()

        // Yön oku
        addDirectionArrow()
    }

    private func createAnimationLines() {
        let lineCount = 8
        let isHorizontal = direction == .left || direction == .right

        for i in 0..<lineCount {
            let line = SKShapeNode()

            if isHorizontal {
                let lineWidth: CGFloat = 3
                let lineHeight: CGFloat = height * 0.6
                let path = CGPath(rect: CGRect(x: -lineWidth/2, y: -lineHeight/2, width: lineWidth, height: lineHeight), transform: nil)
                line.path = path

                // Çizgileri bantın uzunluğuna dağıt
                let spacing = width / CGFloat(lineCount)
                line.position.x = -width/2 + spacing * CGFloat(i)
            } else {
                let lineWidth: CGFloat = width * 0.6
                let lineHeight: CGFloat = 3
                let path = CGPath(rect: CGRect(x: -lineWidth/2, y: -lineHeight/2, width: lineWidth, height: lineHeight), transform: nil)
                line.path = path

                // Çizgileri bantın uzunluğuna dağıt
                let spacing = height / CGFloat(lineCount)
                line.position.y = -height/2 + spacing * CGFloat(i)
            }

            line.fillColor = .yellow
            line.strokeColor = .clear
            line.alpha = 0.6
            beltShape.addChild(line)
            animationLines.append(line)
        }
    }

    private func addDirectionArrow() {
        let arrowSize: CGFloat = 20
        let arrow = SKShapeNode()

        let path = CGMutablePath()
        switch direction {
        case .right:
            path.move(to: CGPoint(x: -arrowSize/2, y: 0))
            path.addLine(to: CGPoint(x: arrowSize/2, y: arrowSize/3))
            path.addLine(to: CGPoint(x: arrowSize/2, y: -arrowSize/3))
            path.closeSubpath()
        case .left:
            path.move(to: CGPoint(x: arrowSize/2, y: 0))
            path.addLine(to: CGPoint(x: -arrowSize/2, y: arrowSize/3))
            path.addLine(to: CGPoint(x: -arrowSize/2, y: -arrowSize/3))
            path.closeSubpath()
        case .up:
            path.move(to: CGPoint(x: 0, y: arrowSize/2))
            path.addLine(to: CGPoint(x: arrowSize/3, y: -arrowSize/2))
            path.addLine(to: CGPoint(x: -arrowSize/3, y: -arrowSize/2))
            path.closeSubpath()
        case .down:
            path.move(to: CGPoint(x: 0, y: -arrowSize/2))
            path.addLine(to: CGPoint(x: arrowSize/3, y: arrowSize/2))
            path.addLine(to: CGPoint(x: -arrowSize/3, y: arrowSize/2))
            path.closeSubpath()
        }

        arrow.path = path
        arrow.fillColor = .white
        arrow.strokeColor = .clear
        arrow.alpha = 0.4
        arrow.position = CGPoint(x: width/2 - 30, y: height/2 - 30)
        beltShape.addChild(arrow)

        // Parlama animasyonu
        let pulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.7, duration: 0.5),
            SKAction.fadeAlpha(to: 0.4, duration: 0.5)
        ])
        arrow.run(SKAction.repeatForever(pulse))
    }

    private func startAnimation() {
        let isHorizontal = direction == .left || direction == .right
        let distance = isHorizontal ? width : height
        let duration = TimeInterval(distance / beltSpeed)

        for (index, line) in animationLines.enumerated() {
            let spacing = distance / CGFloat(animationLines.count)
            let delay = Double(index) * (duration / Double(animationLines.count))

            let moveAction: SKAction
            if isHorizontal {
                let resetX = direction == .right ? -width/2 : width/2
                let targetX = direction == .right ? width/2 : -width/2
                moveAction = SKAction.sequence([
                    SKAction.wait(forDuration: delay),
                    SKAction.repeatForever(SKAction.sequence([
                        SKAction.moveTo(x: targetX, duration: duration),
                        SKAction.moveTo(x: resetX, duration: 0)
                    ]))
                ])
            } else {
                let resetY = direction == .up ? -height/2 : height/2
                let targetY = direction == .up ? height/2 : -height/2
                moveAction = SKAction.sequence([
                    SKAction.wait(forDuration: delay),
                    SKAction.repeatForever(SKAction.sequence([
                        SKAction.moveTo(y: targetY, duration: duration),
                        SKAction.moveTo(y: resetY, duration: 0)
                    ]))
                ])
            }

            line.run(moveAction)
        }
    }

    // Bir node'un bant üzerinde olup olmadığını kontrol et
    func contains(point: CGPoint) -> Bool {
        let localPoint = convert(point, from: parent!)
        return abs(localPoint.x) <= width/2 && abs(localPoint.y) <= height/2
    }

    // Bant üzerindeki node'u hareket ettir
    func moveNode(_ node: SKNode, deltaTime: TimeInterval) {
        let movement = beltSpeed * CGFloat(deltaTime)
        let vector = direction.vector
        node.position.x += vector.dx * movement
        node.position.y += vector.dy * movement
    }

    // Hızı değiştir (yükseltmeler için)
    func setSpeed(_ newSpeed: CGFloat) {
        beltSpeed = newSpeed
        // Animasyonu güncelle
        animationLines.forEach { $0.removeAllActions() }
        startAnimation()
    }

    // Yönü değiştir
    func changeDirection(_ newDirection: BeltDirection) {
        direction = newDirection
        // Görsel güncellemesi için yeniden oluştur
        removeAllChildren()
        setupBelt()
        startAnimation()
    }

    // Glow efekti ekle (booster kullanıldığında)
    func activateBoostGlow(duration: TimeInterval) {
        let glow = SKShapeNode(path: beltShape.path!)
        glow.strokeColor = .cyan
        glow.lineWidth = 8
        glow.glowWidth = 10
        glow.alpha = 0
        insertChild(glow, at: 0)

        let fadeIn = SKAction.fadeAlpha(to: 0.8, duration: 0.2)
        let fadeOut = SKAction.fadeAlpha(to: 0, duration: 0.3)
        let pulse = SKAction.sequence([fadeIn, fadeOut])
        let pulseCount = Int(duration / 0.5)

        glow.run(SKAction.sequence([
            SKAction.repeat(pulse, count: pulseCount),
            SKAction.removeFromParent()
        ]))
    }
}

// MARK: - Bant Yöneticisi

class ConveyorBeltManager {
    private var belts: [ConveyorBelt] = []
    private weak var scene: SKScene?

    init(scene: SKScene) {
        self.scene = scene
    }

    func addBelt(_ belt: ConveyorBelt) {
        belts.append(belt)
        scene?.addChild(belt)
    }

    func removeBelt(_ belt: ConveyorBelt) {
        belt.removeFromParent()
        belts.removeAll { $0 === belt }
    }

    func update(deltaTime: TimeInterval, nodes: [SKNode]) {
        for belt in belts {
            for node in nodes {
                if belt.contains(point: node.position) {
                    belt.moveNode(node, deltaTime: deltaTime)
                }
            }
        }
    }

    func upgradeSpeed(multiplier: CGFloat) {
        for belt in belts {
            belt.setSpeed(belt.beltSpeed * multiplier)
        }
    }

    func getAllBelts() -> [ConveyorBelt] {
        return belts
    }

    func clearAll() {
        belts.forEach { $0.removeFromParent() }
        belts.removeAll()
    }
}
