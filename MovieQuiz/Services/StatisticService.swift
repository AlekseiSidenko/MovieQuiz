//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Алексей Сиденко on 18.04.2024.
//

import Foundation

protocol StatisticService {
    func store(correct count: Int, total amount: Int)
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
}

final class StatisticServiceImplementation: StatisticService {
    
    private let userDefaults = UserDefaults.standard
    private enum Keys: String {
        case totalAccuracy, bestGame, gamesCount
    }
    
    
    func store(correct count: Int, total amount: Int) {
        self.gamesCount += 1
        self.totalAccuracy = (Double(count) / Double(amount) * 10000 + totalAccuracy * 100) / (Double(2) * 100)
        let gameResult = GameRecord(correct: count, total: amount, date: Date())
        if !self.bestGame.isBest(gameResult) {
            self.bestGame = gameResult
        }
    }
    
    
    var totalAccuracy: Double {
        get {
            guard let data = userDefaults.data(forKey: Keys.totalAccuracy.rawValue),
                let totalAccuracy = try? JSONDecoder().decode(Double.self, from: data) else {
                return 100
            }
            
            return totalAccuracy
        }

        set {
            
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            
            userDefaults.set(data, forKey: Keys.totalAccuracy.rawValue)
        }
    }
    
    var gamesCount: Int {
        get {
            guard let data = userDefaults.data(forKey: Keys.gamesCount.rawValue),
                let gamesCount = try? JSONDecoder().decode(Int.self, from: data) else {
                return 0
            }
            
            return gamesCount
        }

        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            
            return record
        }

        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
}
