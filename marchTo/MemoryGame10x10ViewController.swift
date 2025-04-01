//
//  MemoryGame10x10ViewController.swift
//  marchTo
//
//  Created by Ернат on 01.04.2025.
//

import UIKit

class MemoryGame10x10ViewController: UIViewController {
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var movesLabel: UILabel!
    @IBOutlet weak var mistakesLabel: UILabel!
    @IBOutlet weak var bestResults: UILabel!
    
    var images = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10",
                  "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"] // 20 картинок: 10 пар
    var state = [Int](repeating: 0, count: 20) // Состояние 20 кнопок
    var winState = [[0,10], [1,11], [2,12], [3,13], [4,14], [5,15], [6,16], [7,17], [8,18], [9,19]] // Пары (будет обновляться)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 1.0, green: 0.9, blue: 0.8, alpha: 1.0)
        timerLabel.text = "00:00:00"
        movesLabel.text = "Moves: 0"
        mistakesLabel.text = "Mistakes: 0"
        updateBestResultsLabel()
        
        // Проверка подключения IBOutlets
        print("timerLabel: \(timerLabel != nil), movesLabel: \(movesLabel != nil), mistakesLabel: \(mistakesLabel != nil), bestResults: \(bestResults != nil)")
    }
    
    @IBAction func game(_ sender: UIButton) {
        let tag = sender.tag
        print("Button tag: \(tag)")
        
        guard tag >= 1 && tag <= 20 else {
            print("Error: Invalid tag \(tag). Expected range: 1-20")
            return
        }
        
        let index = tag - 1
        
        if timer == nil {
            startTimer()
        }
        
        if state[index] != 0 || isActive {
            print("Button at index \(index) is already opened or game is active")
            return
        }
        
        sender.setBackgroundImage(UIImage(named: images[index]), for: .normal)
        sender.backgroundColor = UIColor.white
        state[index] = 1
        
        var count = 0
        for item in state {
            if item == 1 {
                count += 1
            }
        }
        
        if count == 2 {
            isActive = true
            movesCount += 1
            movesLabel.text = "Moves: \(movesCount)"
            
            var isMatch = false
            for winArray in winState {
                if state[winArray[0]] == 1 && state[winArray[1]] == 1 {
                    print("Match found at indices: \(winArray)")
                    state[winArray[0]] = 2
                    state[winArray[1]] = 2
                    isActive = false
                    isMatch = true
                    break
                }
            }
            
            if !isMatch {
                mistakesCount += 1
                mistakesLabel.text = "Mistakes: \(mistakesCount)"
                Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(clear), userInfo: nil, repeats: false)
            }
        }
        
        checkWinCondition()
    }
    
    @IBAction func x4Game(_ sender: Any) {
        dismiss(animated: true) {
            if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SecondViewController") as? UIViewController {
                viewController.modalPresentationStyle = .fullScreen
                UIApplication.shared.windows.first?.rootViewController?.present(viewController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func x8Game(_ sender: Any) {
        dismiss(animated: true) {
            if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as? UIViewController {
                viewController.modalPresentationStyle = .fullScreen
                UIApplication.shared.windows.first?.rootViewController?.present(viewController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func x5(_ sender: Any) {
        dismiss(animated: true) {
            if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ThirdViewController") as? UIViewController {
                viewController.modalPresentationStyle = .fullScreen
                UIApplication.shared.windows.first?.rootViewController?.present(viewController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func x15(_ sender: Any) {
        dismiss(animated: true) {
            if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MemoryGame15x15ViewController") as? UIViewController {
                viewController.modalPresentationStyle = .fullScreen
                UIApplication.shared.windows.first?.rootViewController?.present(viewController, animated: true, completion: nil)
            }
        }
    }
    
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
    
    func checkWinCondition() {
        let allMatched = state.allSatisfy { $0 == 2 }
        if allMatched {
            timer?.invalidate()
            timer = nil
            updateBestScore()
            print("Победа! Время: \(timerLabel.text ?? "00:00:00"), Ходов: \(movesCount), Ошибок: \(mistakesCount)")
            showWinAlert()
        }
    }
    
    func showWinAlert() {
        let alert = UIAlertController(
            title: "Победа!",
            message: "Время: \(timerLabel.text ?? "00:00:00")\nХодов: \(movesCount)\nОшибок: \(mistakesCount)",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Начать заново", style: .default) { [weak self] _ in
            self?.restartGame()
        })
        
        present(alert, animated: true, completion: nil)
    }
    
    func restartGame() {
        state = [Int](repeating: 0, count: 20)
        isActive = false
        timeCount = 0
        movesCount = 0
        mistakesCount = 0
        timer?.invalidate()
        timer = nil
        
        timerLabel.text = "00:00:00"
        movesLabel.text = "Moves: 0"
        mistakesLabel.text = "Mistakes: 0"
        
        shuffleImagesAndUpdateWinState()
        
        for i in 0...19 {
            if let button = view.viewWithTag(i + 1) as? UIButton {
                button.setBackgroundImage(nil, for: .normal)
                button.backgroundColor = UIColor.systemMint
            } else {
                print("Error: Button with tag \(i + 1) not found")
            }
        }
    }
    
    func shuffleImagesAndUpdateWinState() {
        images.shuffle()
        
        var newWinState: [[Int]] = []
        var usedIndices = Set<Int>()
        
        for i in 0..<images.count {
            if usedIndices.contains(i) {
                continue
            }
            
            for j in (i + 1)..<images.count {
                if images[i] == images[j] && !usedIndices.contains(j) {
                    newWinState.append([i, j])
                    usedIndices.insert(i)
                    usedIndices.insert(j)
                    break
                }
            }
        }
        
        winState = newWinState
        print("Updated winState: \(winState)")
    }
    
    @objc func clear() {
        for i in 0...19 {
            if state[i] == 1 {
                state[i] = 0
                if let button = view.viewWithTag(i + 1) as? UIButton {
                    button.setBackgroundImage(nil, for: .normal)
                    button.backgroundColor = UIColor.systemMint
                }
            }
        }
        isActive = false
    }
    
    func getBestScore() -> BestScore {
        let defaults = UserDefaults.standard
        let time = defaults.integer(forKey: "bestTime10x10")
        let moves = defaults.integer(forKey: "bestMoves10x10")
        let mistakes = defaults.integer(forKey: "bestMistakes10x10")
        
        return BestScore(time: time, moves: moves, mistakes: mistakes)
    }
    
    func updateBestScore() {
        let currentScore = BestScore(time: timeCount, moves: movesCount, mistakes: mistakesCount)
        var bestScore = getBestScore()
        
        if bestScore.time == 0 || (currentScore.time < bestScore.time) ||
           (currentScore.time == bestScore.time && currentScore.moves < bestScore.moves) ||
           (currentScore.time == bestScore.time && currentScore.moves == bestScore.moves && currentScore.mistakes < bestScore.mistakes) {
            let defaults = UserDefaults.standard
            defaults.set(currentScore.time, forKey: "bestTime10x10")
            defaults.set(currentScore.moves, forKey: "bestMoves10x10")
            defaults.set(currentScore.mistakes, forKey: "bestMistakes10x10")
            bestScore = currentScore
        }
        
        updateBestResultsLabel()
    }
    
    func updateBestResultsLabel() {
        let bestScore = getBestScore()
        if bestScore.time == 0 {
            bestResults.text = "Best: None"
        } else {
            let hours = bestScore.time / 3600
            let minutes = (bestScore.time % 3600) / 60
            let seconds = bestScore.time % 60
            let timeString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            bestResults.text = "Best result: \(timeString): Moves \(bestScore.moves): Mistakes \(bestScore.mistakes)"
        }
    }
}
