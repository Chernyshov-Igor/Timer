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
            } else {
                timer.invalidate()
                isPaused = true
                updateTimerButton()
            }
        } else {
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            timerButton.setImage(pauseButtonImage, for: .normal)
            isStarted = true
            isPaused = false
            updateTimerButton()
        }
    }

    private func setupView() {
        view.backgroundColor = .white
    }

    private func setupHierarchy() {
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
    private lazy var circleImage = createSystemImage(name: ImageName.circle)

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
        } else {
            timerTime = Metric.workLap
            isWorkLap = true
            timerLabel.textColor = .red
            timerButton.tintColor = .red
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
