//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Алексей Сиденко on 24.03.2024.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}
