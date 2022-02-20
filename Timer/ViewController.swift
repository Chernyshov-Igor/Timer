//
//  ViewController.swift
//  Timer
//
//  Created by Игорь Чернышов on 20.02.2022.
//

import UIKit

class ViewController: UIViewController {

    private lazy var parentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Metric.parentStackViewSpacing

        return stackView
    }()

    //     MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        animationCircle()
        setupHierarchy()
        setupLayout()
        setupView()

        timerButton.addTarget(self, action: #selector(actionTimerButton), for: .touchUpInside)
        updateTimerText()
    }

    @objc func actionTimerButton() {
        if isStarted {
            if isPaused {
                timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
                isPaused = false
                updateTimerButton()
                resumeAnimation()
            } else {
                timer.invalidate()
                isPaused = true
                updateTimerButton()
                pauseAnimation()
            }
        } else {
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            timerButton.setImage(pauseButtonImage, for: .normal)
            isStarted = true
            isPaused = false
            updateTimerButton()
            basicAnimation()
        }
    }

    private func setupView() {
        view.backgroundColor = .white
    }

    private func setupHierarchy() {
        view.layer.addSublayer(shapeLayer)
        view.addSubview(parentStackView)

        parentStackView.addArrangedSubview(timerLabel)
        parentStackView.addArrangedSubview(timerButton)
    }

    private func setupLayout() {
        parentStackView.translatesAutoresizingMaskIntoConstraints = false
        parentStackView.clipsToBounds = true

        parentStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        parentStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

//     MARK: - Flags

    var isStarted = false
    var isWorkLap = true
    var isPaused = false

//     MARK: - Private func

    private lazy var timerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Metric.timerFont)
        label.textAlignment = .center
        label.textColor = .red

        return label
    }()

    private lazy var timerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(playButtonImage, for: .normal)
        button.tintColor = .red

        return button
    }()

    private func createSystemImage(name: String) -> UIImage {
        guard let image = UIImage(systemName: name)
            else {
                return UIImage.remove }

        return image
    }

    private lazy var playButtonImage = createSystemImage(name: ImageName.play)
    private lazy var pauseButtonImage = createSystemImage(name: ImageName.pause)

//      MARK: - Timer

    var timerTime = Metric.workLap

    var timer = Timer()

    func changeTimer() {
        timer.invalidate()
        isStarted = false
        timerButton.setImage(playButtonImage, for: .normal)

        if isWorkLap {
            timerTime = Metric.restLap
            isWorkLap = false
            timerLabel.textColor = .green
            timerButton.tintColor = .green
            shapeLayer.strokeColor = UIColor.green.cgColor
        } else {
            timerTime = Metric.workLap
            isWorkLap = true
            timerLabel.textColor = .red
            timerButton.tintColor = .red
            shapeLayer.strokeColor = UIColor.red.cgColor
        }
        updateTimerText()
    }

    @objc func updateTimer() {
        timerTime -= 1
        updateTimerText()

        if timerTime == 0 {
            changeTimer()
        }
    }

    func updateTimerText() {
        let minutes = String(format: "%02d", ((timerTime / 60) >= 10 ? (timerTime / 60) : (timerTime / 60)))
        let seconds = String(format: "%02d", (timerTime % 60))
        timerLabel.text = "\(minutes):\(seconds)"
    }

    func updateTimerButton() {
        if isStarted {
            if isPaused {
                timerButton.setImage(playButtonImage, for: .normal)
            } else {
                timerButton.setImage(pauseButtonImage, for: .normal)
            }
        } else {
            timerButton.setImage(playButtonImage, for: .normal)
        }
    }

//      MARK: - progress bar

    let shapeLayer = CAShapeLayer()

    func animationCircle() {
        let center = view.center

        let circlePath = UIBezierPath(arcCenter: center, radius: 138, startAngle: -(.pi) / 2.01, endAngle: -(.pi) / 2, clockwise: true)

        shapeLayer.path = circlePath.cgPath
        shapeLayer.lineWidth = 20
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeEnd = 1
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        shapeLayer.strokeColor = UIColor.red.cgColor
    }

    func basicAnimation() {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.toValue = 0
        basicAnimation.duration = CFTimeInterval(timerTime)
        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
        basicAnimation.isRemovedOnCompletion = true
        shapeLayer.add(basicAnimation, forKey: "basicAnimation")
    }

    func pauseAnimation(){
        let pausedTime : CFTimeInterval = shapeLayer.convertTime(CACurrentMediaTime(), from: nil)
        shapeLayer.speed = 0.0
        shapeLayer.timeOffset = pausedTime
    }

    func resumeAnimation(){
        let pausedTime = shapeLayer.timeOffset
        shapeLayer.speed = 1.0
        shapeLayer.timeOffset = 0.0
        shapeLayer.beginTime = 0.0
        let timeSincePause = shapeLayer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        shapeLayer.beginTime = timeSincePause
    }
}

//      MARK: - enum

enum ImageName {
    static let play = "play"
    static let pause = "pause"
    static let circle = "circle"
}

enum Metric {
    static let workLap = 1500
    static let restLap = 300
    static let timerFont: CGFloat = 30
    static let parentStackViewSpacing: CGFloat = 20
}
