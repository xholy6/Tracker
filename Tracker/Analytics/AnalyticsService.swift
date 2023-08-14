//
//  AnalyticsService.swift
//  Tracker
//
//  Created by D on 15.08.2023.
//

import YandexMobileMetrica

enum Event: String {
    case open, close, click
}

enum Screen: String {
    case trackersList = "trackers_list"
}

enum Item: String {
    case addTracker = "add_tracker"
    case filter, edit, delete
}

struct AnalyticsService {
    static func activate() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "") else { return }
        YMMYandexMetrica.activate(with: configuration)
    }

    func report(event: Event, screen: Screen, item: Item?) {
        var params: [AnyHashable: Any] = ["screen": screen.rawValue]
        if event == .click, let item {
            params["item"] = item.rawValue
        }

        YMMYandexMetrica.reportEvent(event.rawValue, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}
