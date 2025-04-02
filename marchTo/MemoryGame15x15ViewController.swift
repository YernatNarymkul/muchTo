//
//  MemoryGame15x15ViewController.swift
//  marchTo
//
//  Created by Ернат on 01.04.2025.
//

import UIKit
// MARK: - MemoryGame15x15ViewController
class MemoryGame15x15ViewController: UIViewController {
    
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var mistakeLabel: UILabel!
    @IBOutlet weak var movesLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var x10Button: UIButton!
    @IBOutlet weak var x8Button: UIButton!
    @IBOutlet weak var x5Button: UIButton!
    @IBOutlet weak var x4Button: UIButton!
    
    // 30 карт: 15 пар (1-15, каждая по два раза)
    var images = (1...15).flatMap { [$0, $0] }.map { String($0) }
    var state = [Int](repeating: 0, count: 30) // Состояние 30 кнопок: 0 - закрыта, 1 - открыта, 2 - совпадение
    var isActive = false
    
    var timer: Timer?
    var timeCount = 0
    var movesCount = 0
    var mistakesCount = 0
    
    struct BestScore {
        var time: Int
        var moves: Int
        var mistakes: Int
    }
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 1.0, green: 0.9, blue: 0.8, alpha: 1.0)
        timerLabel.text = "00:00:00"
        movesLabel.text = "Moves: 0"
        mistakeLabel.text = "Mistakes: 0"
        updateBestResultsLabel()
        
        shuffleImages() // Перемешиваем изображения при загрузке
        
        mistakeLabel.layer.cornerRadius = 10
        mistakeLabel.clipsToBounds = true
        
        movesLabel.layer.cornerRadius = 10
        movesLabel.clipsToBounds = true
        
        timerLabel.layer.cornerRadius = 10
        timerLabel.clipsToBounds = true
        
        x10Button.layer.cornerRadius = 10
        x10Button.clipsToBounds = true
        
        x8Button.layer.cornerRadius = 10
        x8Button.clipsToBounds = true
        
        x5Button.layer.cornerRadius = 10
        x5Button.clipsToBounds = true
        
        x4Button.layer.cornerRadius = 10
        x4Button.clipsToBounds = true
        
        // Закругление углов для всех игровых кнопок
        for i in 1...30 {
            if let button = view.viewWithTag(i) as? UIButton {
                button.layer.cornerRadius = 10
                button.clipsToBounds = true
            }
        }
        
        print("IBOutlets connected - timerLabel: \(timerLabel != nil), movesLabel: \(movesLabel != nil), mistakeLabel: \(mistakeLabel != nil), resultLabel: \(resultLabel != nil)")
    }
    
    // MARK: - game
    @IBAction func game(_ sender: UIButton) {
        let tag = sender.tag
        print("Button tag: \(tag)")
        
        guard tag >= 1 && tag <= 30 else {
            print("Error: Invalid tag \(tag). Expected range: 1-30")
            return
        }
        
        let index = tag - 1
        
        if state[index] != 0 || isActive {
            print("Button at index \(index) is already opened or game is active")
            return
        }
        
        if timer == nil {
            startTimer()
        }
        
        sender.setBackgroundImage(UIImage(named: images[index]), for: .normal)
        sender.backgroundColor = .white
        state[index] = 1
        
        let openedCards = state.enumerated().filter { $0.element == 1 }.map { $0.offset }
        
        if openedCards.count == 2 {
            isActive = true
            movesCount += 1
            movesLabel.text = "Moves: \(movesCount)"
            
            let firstIndex = openedCards[0]
            let secondIndex = openedCards[1]
            
            if images[firstIndex] == images[secondIndex] {
                print("Match found: [\(firstIndex), \(secondIndex)] with image \(images[firstIndex])")
                state[firstIndex] = 2
                state[secondIndex] = 2
                isActive = false
            } else {
                print("No match: [\(firstIndex), \(secondIndex)] - \(images[firstIndex]) vs \(images[secondIndex])")
                mistakesCount += 1
                mistakeLabel.text = "Mistakes: \(mistakesCount)"
                Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(clear), userInfo: nil, repeats: false)
            }
            
            checkWinCondition()
        }
    }
    
    // MARK: - x4Game
    @IBAction func x4Game(_ sender: Any) {
        transitionTo(viewControllerID: "SecondViewController")
    }
    
    // MARK: - x5Game
    @IBAction func x5Game(_ sender: Any) {
        transitionTo(viewControllerID: "ThirdViewController")
    }
    
    // MARK: - x8Game
    @IBAction func x8Game(_ sender: Any) {
        transitionTo(viewControllerID: "ViewController")
    }
    
    // MARK: - x10Game
    @IBAction func x10Game(_ sender: Any) {
        transitionTo(viewControllerID: "MemoryGame10x10ViewController")
    }
    
    // MARK: - startTimer()
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.timeCount += 1
            let hours = self.timeCount / 3600
            let minutes = (self.timeCount % 3600) / 60
            let seconds = self.timeCount % 60
            self.timerLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
    }
    
    // MARK: - checkWinCondition()
    func checkWinCondition() {
        if state.allSatisfy({ $0 == 2 }) {
            timer?.invalidate()
            timer = nil
            updateBestScore()
            print("Victory! Time: \(timerLabel.text ?? "00:00:00"), Moves: \(movesCount), Mistakes: \(mistakesCount)")
            showWinAlert()
        }
    }
    
    // MARK: - showWinAlert()
    func showWinAlert() {
        let alert = UIAlertController(
            title: "Победа!",
            message: "Время: \(timerLabel.text ?? "00:00:00")\nХодов: \(movesCount)\nОшибок: \(mistakesCount)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Начать заново", style: .default) { [weak self] _ in
            self?.restartGame()
        })
        present(alert, animated: true)
    }
    
    // MARK: - restartGame()
    func restartGame() {
        state = [Int](repeating: 0, count: 30)
        isActive = false
        timeCount = 0
        movesCount = 0
        mistakesCount = 0
        timer?.invalidate()
        timer = nil
        
        timerLabel.text = "00:00:00"
        movesLabel.text = "Moves: 0"
        mistakeLabel.text = "Mistakes: 0"
        
        shuffleImages()
        
        for i in 1...30 {
            if let button = view.viewWithTag(i) as? UIButton {
                button.setBackgroundImage(nil, for: .normal)
                button.backgroundColor = .systemMint
            } else {
                print("Error: Button with tag \(i) not found")
            }
        }
    }
    
    // MARK: - shuffleImages()
    func shuffleImages() {
        images.shuffle()
        print("Shuffled images: \(images)")
    }
    
    // MARK: - clear()
    @objc func clear() {
        for i in 0..<state.count {
            if state[i] == 1 {
                state[i] = 0
                if let button = view.viewWithTag(i + 1) as? UIButton {
                    button.setBackgroundImage(nil, for: .normal)
                    button.backgroundColor = .systemMint
                }
            }
        }
        isActive = false
    }
    
    // MARK: - getBestScore()
    func getBestScore() -> BestScore {
        let defaults = UserDefaults.standard
        return BestScore(
            time: defaults.integer(forKey: "bestTime15x15"),
            moves: defaults.integer(forKey: "bestMoves15x15"),
            mistakes: defaults.integer(forKey: "bestMistakes15x15")
        )
    }
    
    // MARK: - updateBestScore()
    func updateBestScore() {
        let currentScore = BestScore(time: timeCount, moves: movesCount, mistakes: mistakesCount)
        let bestScore = getBestScore()
        
        if bestScore.time == 0 || currentScore.time < bestScore.time ||
           (currentScore.time == bestScore.time && currentScore.moves < bestScore.moves) ||
           (currentScore.time == bestScore.time && currentScore.moves == bestScore.moves && currentScore.mistakes < bestScore.mistakes) {
            let defaults = UserDefaults.standard
            defaults.set(currentScore.time, forKey: "bestTime15x15")
            defaults.set(currentScore.moves, forKey: "bestMoves15x15")
            defaults.set(currentScore.mistakes, forKey: "bestMistakes15x15")
        }
        
        updateBestResultsLabel()
    }
    
    // MARK: - updateBestResultsLabel()
    func updateBestResultsLabel() {
        let bestScore = getBestScore()
        if bestScore.time == 0 {
            resultLabel.text = "Best: None"
        } else {
            let hours = bestScore.time / 3600
            let minutes = (bestScore.time % 3600) / 60
            let seconds = bestScore.time % 60
            let timeString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            resultLabel.text = "Best: \(timeString), Moves: \(bestScore.moves), Mistakes: \(bestScore.mistakes)"
        }
    }
    
    // MARK: - transitionTo()
    func transitionTo(viewControllerID: String) {
        dismiss(animated: true) {
            if let viewController = self.storyboard?.instantiateViewController(withIdentifier: viewControllerID) {
                viewController.modalPresentationStyle = .fullScreen
                UIApplication.shared.windows.first?.rootViewController?.present(viewController, animated: true)
            } else {
                print("Error: Could not instantiate view controller with ID: \(viewControllerID)")
            }
        }
    }
}
