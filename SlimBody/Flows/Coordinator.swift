//
//  Coordinator.swift
//  SlimBody
//
//  Created by Anastasia Kravchenko on 22.09.2023.
//

import UIKit

protocol Coordinator {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }

    func start()
}
