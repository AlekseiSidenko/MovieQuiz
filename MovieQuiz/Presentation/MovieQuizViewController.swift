import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - IBOutlet
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var questionLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    private var correctAnswers = 0
    private var currentQuestion: QuizQuestion?
    private var questionFactory: QuestionFactoryProtocol = QuestionFactory(moviesLoader: MoviesLoader())
    lazy var alertPresenter = AlertPresenter(viewController: self)
    private var statisticService: StatisticService = StatisticServiceImplementation()
    private let presenter = MovieQuizPresenter()
    
    // MARK: - Lifecycle
    override var preferredStatusBarStyle: UIStatusBarStyle {
          return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.backgroundColor = UIColor.YPBlack
        imageView.layer.cornerRadius = 20
        getDataForQuestionFactory()
    }
    
    // MARK: - QuestionFactoryDelegate

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }

        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        questionFactory.requestNextQuestion()
        hideLoadingIndicator()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - IBAction
    @IBAction private func noButtonPress() {
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == false)
    }
    
    @IBAction private func yesButtonPress() {
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == true)
    }
    
    // MARK: - Private Methods
    
    private func getDataForQuestionFactory() {
        showLoadingIndicator()
        let questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        self.questionFactory = questionFactory
        questionFactory.loadData()
    }
    
    private func showLoadingIndicator() {
        activityIndicator.style = .large
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.YPWhite
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        DispatchQueue.main.async {[weak self] in
            guard let self = self else { return }
            activityIndicator.isHidden = true
        }
    }
 
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        DispatchQueue.main.async {[weak self] in
            guard let self = self else { return }
            let errorModel = AlertModel(title: "Ошибка",
                                   message: message,
                                   buttonText: "Попробовать еще раз")
            alertPresenter.showAlert(errorModel, onDidShown: { [weak self] in
                self?.presenter.resetQuestionIndex()
                self?.correctAnswers = 0
                self?.showLoadingIndicator()
                self?.getDataForQuestionFactory()
            })
        }
    }
    
    private func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        questionLabel.text = step.question
    }
    
    private func showNextQuestionOrResults() {
        yesButton.isEnabled = true
        noButton.isEnabled = true
        imageView.layer.borderWidth = 0
        if presenter.isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
            let text = """
            Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)
            Количество сыграных квизов: \(statisticService.gamesCount)
            Рекорд \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
            Средняя точность \(String(format: "%.2f", statisticService.totalAccuracy))%
            """
            let viewModel = AlertModel(
                title: "Этот раунд окончен!",
                message: text,
                buttonText: "Сыграть ещё раз")
            alertPresenter.showAlert(viewModel, onDidShown: { [weak self] in
                self?.presenter.resetQuestionIndex()
                self?.correctAnswers = 0
                self?.questionFactory.requestNextQuestion()
            })
        } else {
            presenter.switchToNextQuestion()
            questionFactory.requestNextQuestion()
        }
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        yesButton.isEnabled = false
        noButton.isEnabled = false
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.YPGreen.cgColor : UIColor.YPRed.cgColor
        if isCorrect {
            self.correctAnswers += 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {[weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
}

/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
*/
