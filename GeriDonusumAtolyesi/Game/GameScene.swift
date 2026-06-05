//
//  GameScene.swift
//  GeriDonusumAtolyesi
//
//  Ana oyun sahnesi - atıkların düştüğü, birleştiği alan
//

import SpriteKit
import SwiftUI
import SwiftData

class GameScene: SKScene {
    // Oyun durumu
    var currentLevel: Level?
    var score = 0
    var mistakes = 0
    var contamination: Double = 100.0 // %100 temiz başlar
    var isGameOver = false

    // Atık yönetimi
    var wasteNodes: [WasteNode] = []
    var selectedNode: WasteNode?
    var lastSpawnTime: TimeInterval = 0
    var spawnInterval: TimeInterval = 2.0

    // Oyun alanları
    var playArea: CGRect!
    var spawnArea: CGRect!
    var sortingArea: CGRect!

    // Delegate
    weak var gameDelegate: GameSceneDelegate?

    // UI güncellemeleri için
    var scoreLabel: SKLabelNode!
    var contaminationLabel: SKLabelNode!
    var goalLabel: SKLabelNode!

    override func didMove(to view: SKView) {
        setupScene()
        setupAreas()
        setupUI()
        setupPhysics()
    }

    private func setupScene() {
        backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.9, alpha: 1.0)
        scaleMode = .aspectFill
    }

    private func setupAreas() {
        let screenWidth = size.width
        let screenHeight = size.height

        // Spawn alanı (üst %20)
        spawnArea = CGRect(
            x: 0,
            y: screenHeight * 0.8,
            width: screenWidth,
            height: screenHeight * 0.2
        )

        // Oyun alanı (orta %60)
        playArea = CGRect(
            x: 0,
            y: screenHeight * 0.15,
            width: screenWidth,
            height: screenHeight * 0.65
        )

        // Sıralama alanı (alt %15)
        sortingArea = CGRect(
            x: 0,
            y: 0,
            width: screenWidth,
            height: screenHeight * 0.15
        )

        // Alan çizgilerini göster (geliştirme için)
        drawAreaBorders()
    }

    private func drawAreaBorders() {
        // Oyun alanı kenarlığı
        let playBorder = SKShapeNode(rect: playArea)
        playBorder.strokeColor = .lightGray
        playBorder.lineWidth = 2
        playBorder.fillColor = .clear
        addChild(playBorder)
    }

    private func setupUI() {
        // Skor etiketi
        scoreLabel = SKLabelNode(text: "Puan: 0")
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = .black
        scoreLabel.position = CGPoint(x: 70, y: size.height - 40)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)

        // Kontaminasyon barı
        contaminationLabel = SKLabelNode(text: "Temizlik: 100%")
        contaminationLabel.fontSize = 18
        contaminationLabel.fontColor = .green
        contaminationLabel.position = CGPoint(x: size.width - 90, y: size.height - 40)
        contaminationLabel.horizontalAlignmentMode = .right
        addChild(contaminationLabel)

        // Hedef göstergesi
        goalLabel = SKLabelNode(text: "Hedef: Yükleniyor...")
        goalLabel.fontSize = 16
        goalLabel.fontColor = .darkGray
        goalLabel.position = CGPoint(x: size.width / 2, y: size.height - 70)
        addChild(goalLabel)
    }

    private func setupPhysics() {
        physicsWorld.gravity = CGVector(dx: 0, dy: -5) // Hafif yerçekimi
        physicsWorld.contactDelegate = self
    }

    func startLevel(_ level: Level) {
        currentLevel = level
        spawnInterval = 1.0 / level.spawnRate

        // Hedefi göster
        if let firstGoal = level.goals.first {
            goalLabel.text = "Hedef: \(firstGoal.description)"
        }

        resetGame()
    }

    private func resetGame() {
        score = 0
        mistakes = 0
        contamination = 100.0
        isGameOver = false

        // Mevcut atıkları temizle
        wasteNodes.forEach { $0.removeFromParent() }
        wasteNodes.removeAll()

        updateUI()
    }

    override func update(_ currentTime: TimeInterval) {
        guard !isGameOver, let level = currentLevel else { return }

        // Atık spawn kontrolü
        if currentTime - lastSpawnTime > spawnInterval {
            spawnRandomWaste()
            lastSpawnTime = currentTime
        }

        // Hedef kontrolü
        checkGoals()

        // Oyun bitişi kontrolü
        if mistakes >= level.maxMistakes {
            gameOver(success: false)
        }
    }

    private func spawnRandomWaste() {
        guard let level = currentLevel else { return }

        // Rastgele kategori seç
        let category = level.allowedCategories.randomElement() ?? .plastic

        // Rastgele x pozisyonu
        let randomX = CGFloat.random(in: 50...(size.width - 50))
        let spawnY = size.height - 50

        // Atık oluştur
        let wasteItem = WasteItem(
            category: category,
            level: .level1,
            isDirty: Bool.random() && contamination > 50, // Temizlik yüksekse kirli gelebilir
            position: CGPoint(x: randomX, y: spawnY)
        )

        let wasteNode = WasteNode(wasteItem: wasteItem)
        addChild(wasteNode)
        wasteNodes.append(wasteNode)

        // Spawn animasyonu
        wasteNode.playSpawnAnimation()

        // Düşüş animasyonu
        wasteNode.physicsBody?.velocity = CGVector(dx: 0, dy: -100)
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        let touchedNodes = nodes(at: location)
        for node in touchedNodes {
            if let wasteNode = node as? WasteNode ?? node.parent as? WasteNode {
                selectedNode = wasteNode
                wasteNode.startDragging()
                break
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let selected = selectedNode else { return }
        let location = touch.location(in: self)
        selected.position = location
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let selected = selectedNode else { return }
        selected.stopDragging()

        // Birleştirme kontrolü
        checkForMerge(selected)

        selectedNode = nil
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }

    // MARK: - Game Logic

    private func checkForMerge(_ node: WasteNode) {
        // Yakındaki düğümleri kontrol et
        for otherNode in wasteNodes where otherNode != node {
            let distance = hypot(
                node.position.x - otherNode.position.x,
                node.position.y - otherNode.position.y
            )

            // Eğer çok yakınlarsa ve birleştirilebilirlerse
            if distance < (node.wasteItem.size + otherNode.wasteItem.size) / 2 + 10 {
                if node.wasteItem.canMerge(with: otherNode.wasteItem) {
                    performMerge(node, with: otherNode)
                    return
                } else if node.wasteItem.category != otherNode.wasteItem.category {
                    // Yanlış birleştirme
                    handleContamination()
                }
            }
        }
    }

    private func performMerge(_ node1: WasteNode, with node2: WasteNode) {
        guard let mergedItem = node1.wasteItem.merged() else { return }

        // Animasyon
        node1.playMergeAnimation {
            // Yeni birleşmiş düğüm oluştur
            let mergedNode = WasteNode(wasteItem: mergedItem)
            mergedNode.position = node1.position
            self.addChild(mergedNode)
            self.wasteNodes.append(mergedNode)

            // Eski düğümleri kaldır
            node1.removeFromParent()
            node2.removeFromParent()
            self.wasteNodes.removeAll { $0 == node1 || $0 == node2 }

            // Puan ekle
            self.addScore(mergedItem.pointValue)

            // Ses efekti (TODO)
        }
    }

    private func handleContamination() {
        mistakes += 1
        contamination = max(0, contamination - 5)
        updateUI()

        // Ekran titremesi
        let shake = SKAction.sequence([
            SKAction.moveBy(x: -8, y: 0, duration: 0.05),
            SKAction.moveBy(x: 16, y: 0, duration: 0.05),
            SKAction.moveBy(x: -16, y: 0, duration: 0.05),
            SKAction.moveBy(x: 8, y: 0, duration: 0.05)
        ])
        run(shake)

        // Kırmızı flash efekti
        let flashOverlay = SKSpriteNode(color: .red, size: size)
        flashOverlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        flashOverlay.alpha = 0
        flashOverlay.zPosition = 200
        addChild(flashOverlay)

        flashOverlay.run(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.1),
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.removeFromParent()
        ]))
    }

    private func addScore(_ points: Int) {
        score += points
        updateUI()
    }

    private func updateUI() {
        scoreLabel.text = "Puan: \(score)"

        let cleanlinessInt = Int(contamination)
        contaminationLabel.text = "Temizlik: \(cleanlinessInt)%"

        // Renk değiştir
        if contamination > 70 {
            contaminationLabel.fontColor = .green
        } else if contamination > 40 {
            contaminationLabel.fontColor = .orange
        } else {
            contaminationLabel.fontColor = .red
        }
    }

    private func checkGoals() {
        guard let level = currentLevel else { return }

        // Hedef kontrolü (basitleştirilmiş)
        for goal in level.goals {
            switch goal.type {
            case .scorePoints:
                if score >= goal.targetValue {
                    gameOver(success: true)
                }
            default:
                break
            }
        }
    }

    private func gameOver(success: Bool) {
        isGameOver = true

        // Delegate'e bildir
        gameDelegate?.gameDidEnd(score: score, success: success, stars: calculateStars())
    }

    private func calculateStars() -> Int {
        guard let level = currentLevel else { return 0 }

        if mistakes == 0 && contamination > 80 {
            return 3
        } else if mistakes <= 2 && contamination > 50 {
            return 2
        } else if mistakes < level.maxMistakes {
            return 1
        }
        return 0
    }
}

// MARK: - Physics Contact Delegate

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        // Çarpışma yönetimi (gelecekte genişletilebilir)
    }
}

// MARK: - Delegate Protocol

protocol GameSceneDelegate: AnyObject {
    func gameDidEnd(score: Int, success: Bool, stars: Int)
}
