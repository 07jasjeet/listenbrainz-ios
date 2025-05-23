//
//  TabBarAccessor.swift
//  Listenbrainz
//
//  Created by Jasjeet Singh on 12/04/25.
//

import SwiftUI
import UIKit

class InsetsHolder: ObservableObject {
    @Published var tabBarHeight: CGFloat = 0
}

struct TabBarAccessor: UIViewControllerRepresentable {
    var callback: (UITabBar) -> Void
    private let proxyController = ViewController()

    func makeUIViewController(context: UIViewControllerRepresentableContext<TabBarAccessor>) ->
                              UIViewController {
        proxyController.callback = callback
        return proxyController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<TabBarAccessor>) {
    }
    
    typealias UIViewControllerType = UIViewController

    private class ViewController: UIViewController {
        var callback: (UITabBar) -> Void = { _ in }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            if let tabBar = self.tabBarController {
                self.callback(tabBar.tabBar)
            }
        }
    }
}

extension View {
    func tabBarAccessor(_ callback: @escaping (UITabBar) -> Void) -> some View {
        background(TabBarAccessor(callback: callback))
    }
}
