//
//  thirdViewController.swift
//  marchTo
//
//  Created by Ернат on 01.04.2025.
//
import UIKit

class MemoryGame5x5ViewController: UIViewController {
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var movesLabel: UILabel!
    @IBOutlet weak var mistakesLabel: UILabel!
    @IBOutlet weak var bestResultsLabel: UILabel!
    
    var images = ["1", "2", "3", "4", "5",
                  "1", "2", "3", "4", "5"] // 10 картинок: 5 пар коров
    var state = [Int](repeating: 0, count: 10) // Состояние 10 кнопок
    var winState = [[0,5], [1,6], [2,7], [3,8], [4,9]] // Пары (будет обновляться)
    var isActive = false
    
    var timer: Timer?
    var timeCount = 0
    var movesCount = 0
    var mistakesCount = 0
    
    // Структура для хранения лучшего результата
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
        updateBestResultsLabel() // Устанавливаем начальное значение для bestResults
    }
    
    @IBAction func game(_ sender: UIButton) {
        print(sender.tag)
        
        if timer == nil {
            startTimer()
        }
        
        if state[sender.tag - 1] != 0 || isActive {
            return
        }
        
        sender.setBackgroundImage(UIImage(named: images[sender.tag - 1]), for: .normal)
        sender.backgroundColor = UIColor.white
        state[sender.tag - 1] = 1
        
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
                if state[winArray[0]] == state[winArray[1]] && state[winArray[1]] == 1 {
                    state[winArray[0]] = 2
                    state[winArray[1]] = 2
                    isActive = false
                    isMatch = true
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
            if let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "SecondViewController") as? MemoryGame4x4ViewController {
                secondViewController.modalPresentationStyle = .fullScreen
                UIApplication.shared.windows.first?.rootViewController?.present(secondViewController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func x8Game(_ sender: Any) {
        dismiss(animated: true) {
            if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as? MemoryGame8x8ViewController {
                viewController.modalPresentationStyle = .fullScreen
                UIApplication.shared.windows.first?.rootViewController?.present(viewController, animated: true, completion: nil)
            }
        }
        
    }
    
    @IBAction func x10Game(_ sender: Any) {
        dismiss(animated: true) {
            if let thirdViewController = self.storyboard?.instantiateViewController(withIdentifier: "MemoryGame10x10ViewController") as? MemoryGame10x10ViewController {
                thirdViewController.modalPresentationStyle = .fullScreen
                UIApplication.shared.windows.first?.rootViewController?.present(thirdViewController, animated: true, completion: nil)
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
            let allMatched = state.allSatisfy { $0 == 2 } // Все карты должны быть найдены
            if allMatched {
                timer?.invalidate()
                timer = nil
                updateBestScore() // Обновляем лучший результат перед показом алерта
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
            state = [Int](repeating: 0, count: 10)
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
            
            for i in 0...9 { // 10 кнопок (теги 1-10)
                let button = view.viewWithTag(i + 1) as! UIButton
                button.setBackgroundImage(nil, for: .normal)
                button.backgroundColor = UIColor.systemMint
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
        }
        
        @objc func clear() {
            for i in 0...9 { // 10 кнопок
                if state[i] == 1 {
                    state[i] = 0
                    let button = view.viewWithTag(i + 1) as! UIButton
                    button.setBackgroundImage(nil, for: .normal)
                    button.backgroundColor = UIColor.systemMint
                }
            }
            isActive = false
        }
        
        // Функция для получения текущего лучшего результата из UserDefaults
        func getBestScore() -> BestScore {
            let defaults = UserDefaults.standard
            let time = defaults.integer(forKey: "bestTime5x5") // Уникальный ключ для 5x5
            let moves = defaults.integer(forKey: "bestMoves5x5")
            let mistakes = defaults.integer(forKey: "bestMistakes5x5")
            
            return BestScore(time: time, moves: moves, mistakes: mistakes)
        }
        
        // Функция для обновления лучшего результата
        func updateBestScore() {
            let currentScore = BestScore(time: timeCount, moves: movesCount, mistakes: mistakesCount)
            var bestScore = getBestScore()
            
            // Если это первая игра или текущий результат лучше (меньше времени, ходов, ошибок)
            if bestScore.time == 0 || (currentScore.time < bestScore.time) ||
                (currentScore.time == bestScore.time && currentScore.moves < bestScore.moves) ||
                (currentScore.time == bestScore.time && currentScore.moves == bestScore.moves && currentScore.mistakes < bestScore.mistakes) {
                let defaults = UserDefaults.standard
                defaults.set(currentScore.time, forKey: "bestTime5x5")
                defaults.set(currentScore.moves, forKey: "bestMoves5x5")
                defaults.set(currentScore.mistakes, forKey: "bestMistakes5x5")
                bestScore = currentScore
            }
            
            updateBestResultsLabel() // Обновляем отображение после проверки
        }
        
        // Функция для обновления текста в bestResults
        func updateBestResultsLabel() {
            let bestScore = getBestScore()
            if bestScore.time == 0 { // Если еще нет рекорда
                bestResultsLabel.text = "Best: None"
            } else {
                let hours = bestScore.time / 3600
                let minutes = (bestScore.time % 3600) / 60
                let seconds = bestScore.time % 60
                let timeString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
                bestResultsLabel.text = "Best result: \(timeString): Moves \(bestScore.moves): Mistakes \(bestScore.mistakes)"
            }
        }
    }

