//
//  NavigationRouter.swift
//  Assets Bundling POC
//

import Observation
import SwiftUI

protocol NavigationRouter {
    var navigationRoute: NavigationRoute? { get }

    func push(route: NavigationRoute)
    func pop()
    func popAll()
    func set(navigationStack: [NavigationRoute])
}

@Observable final class LiveNavigationRouter: NavigationRouter {
    private(set) var presentedPopup: PopupRoute? = nil
    private(set) var presentedAlert: AlertRoute? = nil
    private(set) var navigationStack: [NavigationRoute] = []

    var navigationRoute: NavigationRoute? {
        navigationStack.last
    }

    // MARK: - Popups:

    func present(popup: PopupRoute) {
        presentedPopup = popup
    }

    func dismiss() {
        presentedPopup = nil
    }

    // MARK: - Inline navigation:

    func push(route: NavigationRoute) {
        navigationStack.append(route)
    }

    func pop() {
        guard !navigationStack.isEmpty else { return }
        navigationStack.removeLast()
    }

    func popAll() {
        navigationStack = []
    }

    func set(navigationStack: [NavigationRoute]) {
        self.navigationStack = navigationStack
    }

    // MARK: - Alerts:

    func show(alert: AlertRoute) {
        presentedAlert = alert
    }

    func hideCurrentAlert() {
        presentedAlert = nil
    }
}
