//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Алексей Сиденко on 23.04.2024.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        app = XCUIApplication()
        app.launch()
        
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        app.terminate()
        app = nil
    }

    func testYesButton() {
        
        sleep(3)
        
        let firstPoster = app.images["Poster"]
        XCTAssertTrue(firstPoster.exists)
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["Yes"].tap()
        
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        XCTAssertTrue(secondPoster.exists)
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        let indexLabel = app.staticTexts["Index"]
        XCTAssertEqual(indexLabel.label, "2/10") 
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }
    
    func testNoButton() {
        
        sleep(3)
        
        let firstPoster = app.images["Poster"]
        XCTAssertTrue(firstPoster.exists)
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        XCTAssertTrue(secondPoster.exists)
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        let indexLabel = app.staticTexts["Index"]
        XCTAssertEqual(indexLabel.label, "2/10")
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }
    
    func testShowingAlert() {
        sleep(3)
        for _ in 1...10 {
            app.buttons["Yes"].tap()
            sleep(3)
        }

        let alert = app.alerts["Alert Presenter"]
        
                        XCTAssertTrue(alert.exists)
        XCTAssertTrue(alert.label == "Этот раунд окончен!")
        XCTAssertTrue(alert.buttons.firstMatch.label == "Сыграть ещё раз")
    }
    
    func testDismissAlert() {
        sleep(3)
        for _ in 1...10 {
            app.buttons["Yes"].tap()
            sleep(3)
        }
        
        let alert = app.alerts["Alert Presenter"]
        alert.buttons.firstMatch.tap()
        
        sleep(3)
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertFalse(alert.exists)
        XCTAssertTrue(indexLabel.label == "1/10")
    }
}


