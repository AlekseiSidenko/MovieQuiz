//
//  GameRecord.swift
//  MovieQuiz
//
//  Created by Алексей Сиденко on 18.04.2024.
//

import Foundation

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBest(_ gameResult: GameRecord) -> Bool {
        return correct > gameResult.correct
    }
}
