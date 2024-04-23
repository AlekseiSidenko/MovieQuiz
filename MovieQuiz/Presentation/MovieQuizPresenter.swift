//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Алексей Сиденко on 23.04.2024.
//

import UIKit

final class MovieQuizPresenter {

    var currentQuestionIndex = 0
    let questionsAmount: Int = 10
    var correctAnswers: Int = 0
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    var questionFactory: QuestionFactoryProtocol = QuestionFactory(moviesLoader: MoviesLoader())
    var statisticService: StatisticService = StatisticServiceImplementation()
    
    func yesButtonPress() {
        didAnswer(isYes: true)
    }
    
    func noButtonPress() {
        didAnswer(isYes: false)
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = isYes
        
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }

        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func showNextQuestionOrResults() {
       if self.isLastQuestion() {
           statisticService.store(correct: correctAnswers, total: self.questionsAmount)
           let text = """
           Ваш результат: \(correctAnswers)/\(self.questionsAmount)
           Количество сыграных квизов: \(statisticService.gamesCount)
           Рекорд \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
           Средняя точность \(String(format: "%.2f", statisticService.totalAccuracy))%
           """
           let viewModel = AlertModel(
               title: "Этот раунд окончен!",
               message: text,
               buttonText: "Сыграть ещё раз")
           viewController?.showAlertResults(alertContent: viewModel)
       } else {
           print(correctAnswers)
           questionFactory.requestNextQuestion()
           self.switchToNextQuestion()
       }
   }
    
}
