import XCTest

class Image_FeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app.launch()
    }
    
    func testAuth() throws {
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["WebView"]
        
        XCTAssertTrue(webView.waitForExistence(timeout: 60))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 60))
        
        loginTextField.tap()
        loginTextField.typeText("macar.sidor@yandex.ru")
        webView.swipeUp()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        if app.buttons["Next keyboard"].exists {
            app.buttons["Next keyboard"].tap()
        } else if app.buttons["globe"].exists {
            app.buttons["globe"].tap()
        }
        sleep(2) // даем время на переключение
        passwordTextField.typeText("12345678")
        webView.swipeUp()
        
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        let tablesQuery = app.tables
        
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
        
        sleep(2)
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        
        cellToLike.buttons["like button off"].tap()
        cellToLike.buttons["like button on"].tap()
        
        sleep(2)
        
        cellToLike.tap()
        
        sleep(2)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        // Zoom in
        image.pinch(withScale: 3, velocity: 1) // zoom in
        // Zoom out
        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButtonWhiteButton = app.buttons["back_button"]
        navBackButtonWhiteButton.tap()
    }
    
    
    func testProfile() throws {
        let app = XCUIApplication()
        app.launch()
        sleep(5)
        
        
        let tabBar = app.tabBars["TabBar"]
        XCTAssertTrue(tabBar.waitForExistence(timeout: 10), "TabBar не найден")
        
        let profileButton = tabBar.buttons.element(boundBy: 1)
        XCTAssertTrue(profileButton.waitForExistence(timeout: 5), "Кнопка профиля не найдена")
        profileButton.tap()
        
        
        let nameLabel = app.staticTexts["user name"]
        let loginLabel = app.staticTexts["user login"]
        let bioLabel = app.staticTexts["user bio"]
        
        
        XCTAssertTrue(nameLabel.waitForExistence(timeout: 10), "Имя пользователя не отображается")
        XCTAssertTrue(loginLabel.waitForExistence(timeout: 10), "Логин пользователя не отображается")
        
        
        XCTAssertFalse(nameLabel.label.isEmpty, "Имя пользователя пустое")
        XCTAssertFalse(loginLabel.label.isEmpty, "Логин пользователя пустой")
        
        
        let logoutButton = app.buttons["logout button"]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 5), "Кнопка выхода не найдена")
        logoutButton.tap()
        
        
        let alert = app.alerts.firstMatch
        if alert.waitForExistence(timeout: 3) {
            alert.buttons["Да"].tap()
        }
        
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 10), "Экран авторизации не открылся")
    }
}
