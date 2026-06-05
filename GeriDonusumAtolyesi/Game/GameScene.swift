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

    // Combo sistemi
    var comboCount = 0
    var comboTimer: Timer?
    var lastMergeTime: TimeInterval = 0

    // Atık yönetimi
    var wasteNodes: [WasteNode] = []
    var selectedNode: WasteNode?
    var lastSpawnTime: TimeInterval = 0
    var spawnInterval: TimeInterval = 2.0
    let maxWasteNodes = 30 // Performans için limit

    // Oyun alanları
    var playArea: CGRect!
    var spawnArea: CGRect!
    var sortingArea: CGRect!

    // Temizleme istasyonu
    var cleaningStation: CleaningStation?

    // Bant sistemi
    var beltManager: ConveyorBeltManager?

    // Delegate
    weak var gameDelegate: GameSceneDelegate?

    // UI güncellemeleri için
    var scoreLabel: SKLabelNode!
    var contaminationLabel: SKLabelNode!
    var goalLabel: SKLabelNode!
    var comboLabel: SKLabelNode!

    override func didMove(to view: SKView) {
        print("🎬 GameScene didMove to view")
        setupScene()
        setupAreas()
        setupUI()
        setupPhysics()
        setupConveyorBelts()
        print("✅ GameScene setup complete")
    }

    private func setupConveyorBelts() {
        beltManager = ConveyorBeltManager(scene: self)

        // Ana bant (yatay - sağa doğru)
        let mainBelt = ConveyorBelt(
            width: size.width * 0.8,
            height: 80,
            speed: 50,
            direction: .right
        )
        mainBelt.position = CGPoint(x: size.width / 2, y: size.height * 0.5)
        beltManager?.addBelt(mainBelt)

        // Yan bant (dikey - yukarı)
        let sideBelt = ConveyorBelt(
            width: 80,
            height: size.height * 0.3,
            speed: 40,
            direction: .up
        )
        sideBelt.position = CGPoint(x: 80, y: size.height * 0.35)
        beltManager?.addBelt(sideBelt)
    }

    private func setupScene() {
        print("🎨 Setting up scene background")
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

        // Oyun alanı (orta %55)
        playArea = CGRect(
            x: 0,
            y: screenHeight * 0.2,
            width: screenWidth,
            height: screenHeight * 0.6
        )

        // Sıralama alanı (alt %20)
        sortingArea = CGRect(
            x: 0,
            y: 0,
            width: screenWidth,
            height: screenHeight * 0.2
        )

        // Temizleme istasyonu ekle
        let stationSize = CGSize(width: 100, height: 80)
        let stationPosition = CGPoint(
            x: screenWidth - 60,
            y: screenHeight * 0.15
        )
        cleaningStation = CleaningStation(position: stationPosition, size: stationSize)
        addChild(cleaningStation!)

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

        // Combo göstergesi
        comboLabel = SKLabelNode(text: "")
        comboLabel.fontSize = 20
        comboLabel.fontColor = .yellow
        comboLabel.fontName = "Arial-BoldMT"
        comboLabel.position = CGPoint(x: size.width / 2, y: size.height - 100)
        comboLabel.alpha = 0
        addChild(comboLabel)
    }

    private func setupPhysics() {
        physicsWorld.gravity = CGVector(dx: 0, dy: -5) // Hafif yerçekimi
        physicsWorld.contactDelegate = self
    }

    func startLevel(_ level: Level) {
        print("🎯 Starting level \(level.number)")
        currentLevel = level
        spawnInterval = 1.0 / level.spawnRate
        print("⏱️ Spawn interval: \(spawnInterval)s")

        // Hedefi göster
        if let firstGoal = level.goals.first {
            goalLabel.text = "Hedef: \(firstGoal.description)"
            print("🎯 Goal: \(firstGoal.description)")
        }

        resetGame()
        print("✅ Level \(level.number) started successfully")
    }

    func applyConveyorUpgrade(speedLevel: Int) {
        // Yükseltme seviyesine göre bant hızını artır
        let speedMultiplier = 1.0 + (CGFloat(speedLevel - 1) * 0.2) // %20 artış per level
        beltManager?.upgradeSpeed(multiplier: speedMultiplier)
        print("🚀 Conveyor speed upgraded to level \(speedLevel) (multiplier: \(speedMultiplier)x)")
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

        // Delta time hesapla
        let deltaTime = currentTime - lastSpawnTime

        // Bant sistemini güncelle
        beltManager?.update(deltaTime: deltaTime, nodes: wasteNodes.map { $0 as SKNode })

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

        // Performans için: Max node sayısını kontrol et
        if wasteNodes.count >= maxWasteNodes {
            // En alttaki (eski) atığı kaldır
            if let oldestNode = wasteNodes.first(where: { $0.position.y < 100 }) {
                oldestNode.removeFromParent()
                wasteNodes.removeAll { $0 == oldestNode }
            }
        }

        // Rastgele kategori seç
        let category = level.allowedCategories.randomElement() ?? .plastic

        // Rastgele x pozisyonu
        let randomX = CGFloat.random(in: 50...(size.width - 50))
        let spawnY = size.height - 50

        // Atık oluştur
        let wasteItem = WasteItem(
            category: category,
            level: .level1,
            isDirty: Bool.random() && contamination > 50,
            position: CGPoint(x: randomX, y: spawnY)
        )

        let wasteNode = WasteNode(wasteItem: wasteItem)
        addChild(wasteNode)
        wasteNodes.append(wasteNode)

        // Spawn animasyonu ve ses
        wasteNode.playSpawnAnimation()
        AudioManager.shared.playDropSound()

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

        // Temizleme istasyonu kontrolü
        if let station = cleaningStation, station.canCleanWaste(selected) {
            let distance = hypot(
                selected.position.x - station.position.x,
                selected.position.y - station.position.y
            )

            if distance < 60 {
                // Temizle
                station.cleanWaste(selected) { cleanedWaste in
                    selected.removeFromParent()
                    self.wasteNodes.removeAll { $0 == selected }
                    self.addChild(cleanedWaste)
                    self.wasteNodes.append(cleanedWaste)
                    cleanedWaste.position = station.position
                }
                selectedNode = nil
                return
            }
        }

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

        // Combo güncelle
        comboCount += 1
        lastMergeTime = Date().timeIntervalSince1970

        // Combo bonus hesapla
        let comboMultiplier = min(comboCount, 10) // Max 10x combo
        let basePoints = mergedItem.pointValue
        let bonusPoints = basePoints * comboMultiplier

        // Combo göstergesi
        if comboCount > 1 {
            showComboIndicator(at: node1.position, combo: comboCount)
        }

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

            // Puan ekle (combo bonusu ile)
            self.addScore(bonusPoints)
        }

        // Combo timer'ı resetle
        comboTimer?.invalidate()
        comboTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            self?.resetCombo()
        }
    }

    private func showComboIndicator(at position: CGPoint, combo: Int) {
        let comboLabel = SKLabelNode(text: "x\(combo) COMBO!")
        comboLabel.fontSize = 24 + CGFloat(min(combo, 10)) * 2
        comboLabel.fontColor = .yellow
        comboLabel.fontName = "Arial-BoldMT"
        comboLabel.position = position
        comboLabel.zPosition = 150
        addChild(comboLabel)

        // Animasyon
        let moveUp = SKAction.moveBy(x: 0, y: 50, duration: 1.0)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let scale = SKAction.scale(to: 1.5, duration: 0.3)

        comboLabel.run(SKAction.sequence([
            scale,
            SKAction.group([moveUp, fadeOut]),
            SKAction.removeFromParent()
        ]))
    }

    private func resetCombo() {
        comboCount = 0
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

        // Combo göster
        if comboCount > 1 {
            comboLabel.text = "x\(comboCount) COMBO!"
            comboLabel.alpha = 1.0
        } else {
            comboLabel.alpha = 0.0
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

        // Ses efekti
        if success {
            AudioManager.shared.playSuccessSound()
            AudioManager.shared.playHapticSuccess()
        } else {
            AudioManager.shared.playErrorSound()
            AudioManager.shared.playHapticError()
        }

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

    // MARK: - Booster Methods

    func applyMagnetBooster() {
        print("🧲 Magnet booster activated")

        var metalWastes: [WasteNode] = []
        for node in wasteNodes {
            if node.wasteItem.category == .metal {
                metalWastes.append(node)
            }
        }

        // Metal atıkları ekranın ortasına çek
        let centerPosition = CGPoint(x: size.width / 2, y: size.height / 2)

        for waste in metalWastes {
            let move = SKAction.move(to: centerPosition, duration: 0.5)
            move.timingMode = .easeIn
            waste.run(move)
        }

        // Manyetik partiküller
        showMagnetEffect(at: centerPosition)
    }

    func applyCleanSprayBooster() {
        print("💧 Clean spray booster activated")

        var cleanedCount = 0

        for node in wasteNodes where node.wasteItem.isDirty {
            var cleanItem = node.wasteItem
            cleanItem.isDirty = false

            let cleanNode = WasteNode(wasteItem: cleanItem)
            cleanNode.position = node.position

            node.removeFromParent()
            addChild(cleanNode)
            wasteNodes.append(cleanNode)
            wasteNodes.removeAll { $0 == node }

            cleanedCount += 1
        }

        if cleanedCount > 0 {
            showCleanSprayEffect()
        }
    }

    func applySuperPressBooster() {
        print("⚡ Super press booster activated")

        // Aynı kategori ve seviyedeki tüm atıkları bul ve birleştir
        var groupedWastes: [WasteCategory: [WasteLevel: [WasteNode]]] = [:]

        for node in wasteNodes {
            if !node.wasteItem.isDirty {
                if groupedWastes[node.wasteItem.category] == nil {
                    groupedWastes[node.wasteItem.category] = [:]
                }
                if groupedWastes[node.wasteItem.category]?[node.wasteItem.level] == nil {
                    groupedWastes[node.wasteItem.category]?[node.wasteItem.level] = []
                }
                groupedWastes[node.wasteItem.category]?[node.wasteItem.level]?.append(node)
            }
        }

        // Her gruptan 2 veya daha fazlasını birleştir
        for (category, levelDict) in groupedWastes {
            for (level, nodes) in levelDict {
                if nodes.count >= 2 {
                    // İlk iki düğümü birleştir
                    performMerge(nodes[0], with: nodes[1])
                }
            }
        }

        showSuperPressEffect()
    }

    func applyTimeSlowBooster() {
        print("⏰ Time slow booster activated")

        // Spawn rate'i yavaşlat
        let originalInterval = spawnInterval
        spawnInterval = spawnInterval * 3.0

        // Bantları yavaşlat
        for belt in beltManager?.getAllBelts() ?? [] {
            belt.activateBoostGlow(duration: 5.0)
        }
        beltManager?.upgradeSpeed(multiplier: 0.5)

        // 5 saniye sonra normale dön
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.spawnInterval = originalInterval
            self.beltManager?.upgradeSpeed(multiplier: 2.0) // Geri normale dön
        }

        showTimeSlowEffect()
    }

    func applyRobotArmBooster() {
        print("🤖 Robot arm booster activated")

        // Son hatayı geri al
        if mistakes > 0 {
            mistakes -= 1
            contamination = min(100, contamination + 10)
            updateUI()
        }

        showRobotArmEffect()
    }

    // MARK: - Booster Visual Effects

    private func showMagnetEffect(at position: CGPoint) {
        let magnetIcon = SKLabelNode(text: "🧲")
        magnetIcon.fontSize = 60
        magnetIcon.position = position
        magnetIcon.zPosition = 150

        addChild(magnetIcon)

        magnetIcon.run(SKAction.sequence([
            SKAction.scale(to: 1.5, duration: 0.3),
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.removeFromParent()
        ]))
    }

    private func showCleanSprayEffect() {
        for _ in 0..<20 {
            let droplet = SKShapeNode(circleOfRadius: 5)
            droplet.fillColor = .cyan
            droplet.position = CGPoint(x: CGFloat.random(in: 0...size.width), y: size.height)
            droplet.zPosition = 150

            addChild(droplet)

            droplet.run(SKAction.sequence([
                SKAction.moveBy(x: 0, y: -size.height, duration: 1.0),
                SKAction.removeFromParent()
            ]))
        }
    }

    private func showSuperPressEffect() {
        let flash = SKSpriteNode(color: .yellow, size: size)
        flash.position = CGPoint(x: size.width / 2, y: size.height / 2)
        flash.alpha = 0
        flash.zPosition = 200

        addChild(flash)

        flash.run(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.5, duration: 0.1),
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.removeFromParent()
        ]))
    }

    private func showTimeSlowEffect() {
        let clockIcon = SKLabelNode(text: "⏰")
        clockIcon.fontSize = 80
        clockIcon.position = CGPoint(x: size.width / 2, y: size.height - 150)
        clockIcon.zPosition = 150

        addChild(clockIcon)

        clockIcon.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 5.0),
            SKAction.removeFromParent()
        ]))
    }

    private func showRobotArmEffect() {
        let robotIcon = SKLabelNode(text: "🤖")
        robotIcon.fontSize = 60
        robotIcon.position = CGPoint(x: size.width / 2, y: size.height / 2)
        robotIcon.zPosition = 150

        addChild(robotIcon)

        robotIcon.run(SKAction.sequence([
            SKAction.scale(to: 1.5, duration: 0.3),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
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
