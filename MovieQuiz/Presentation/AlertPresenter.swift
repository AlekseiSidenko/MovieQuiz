//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Алексей Сиденко on 15.04.2024.
//
import UIKit

final class AlertPresenter {
    
    weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func showAlert(_ result: AlertModel, onDidShown: @escaping () -> Void) {
        
        let alert = UIAlertController(
            title: result.title,
            message: result.message,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: result.buttonText, style: .default) {_ in
            onDidShown()
        }
        alert.addAction(action)
        viewController?.present(alert, animated: true, completion: nil)
    }
}
