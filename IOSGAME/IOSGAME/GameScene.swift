import SpriteKit
import UIKit

class GameScene: SKScene {
    private var player: SKShapeNode!
    private let forwardSpeed: CGFloat = 200.0
    private let jumpHeight: CGFloat = 150.0
    private var lastUpdateTime: TimeInterval = 0

    private var currentLane = 1
    private let lanePositions: [CGFloat] = [-100, 0, 100]

    override func didMove(to view: SKView) {
        backgroundColor = .black
        anchorPoint = CGPoint(x: 0.5, y: 0.5)

        setupLanes()
        setupPlayer()
        setupGestures(in: view)

        let cameraNode = SKCameraNode()
        camera = cameraNode
        addChild(cameraNode)
    }

    func setupLanes() {
        for x in lanePositions {
            let lane = SKShapeNode(rectOf: CGSize(width: 80, height: size.height))
            lane.strokeColor = .darkGray
            lane.lineWidth = 2
            lane.position = CGPoint(x: x, y: 0)
            addChild(lane)
        }
    }

    func setupPlayer() {
        player = SKShapeNode(rectOf: CGSize(width: 40, height: 40))
        player.fillColor = .white
        player.position = CGPoint(x: lanePositions[currentLane], y: -size.height / 4)
        addChild(player)
    }

    func setupGestures(in view: SKView) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tap)

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
    }

    @objc func handleTap() {
        guard player.action(forKey: "jump") == nil else { return }
        let jumpUp = SKAction.moveBy(x: 0, y: jumpHeight, duration: 0.2)
        jumpUp.timingMode = .easeOut
        let fall = SKAction.moveBy(x: 0, y: -jumpHeight, duration: 0.2)
        fall.timingMode = .easeIn
        let sequence = SKAction.sequence([jumpUp, fall])
        player.run(sequence, withKey: "jump")
    }

    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            currentLane = max(0, currentLane - 1)
        } else if gesture.direction == .right {
            currentLane = min(lanePositions.count - 1, currentLane + 1)
        }
        let move = SKAction.moveTo(x: lanePositions[currentLane], duration: 0.2)
        player.run(move)
    }

    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 { lastUpdateTime = currentTime }
        let dt = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        player.position.y += forwardSpeed * CGFloat(dt)
        camera?.position = player.position
    }
}

