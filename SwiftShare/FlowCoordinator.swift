//
//  FlowCoordinator.swift
//  LearnMore
//
//  Created by Dan ILCA on 05/01/2021.
//

import UIKit

public protocol FlowCoordinator: AnyObject {
    var childCoordinators: [FlowCoordinator] { get set }
    var parentCoordinator: FlowCoordinator? { get set }
    var navigationController: UINavigationController { get }

    func start()
    func childStart(_ child: FlowCoordinator)
    func childFinish(_ child: FlowCoordinator)
}

public extension FlowCoordinator {

    func childStart(_ child: FlowCoordinator) {
        child.parentCoordinator = self
        childCoordinators.append(child)
        child.start()
    }

    func childFinish(_ child: FlowCoordinator) {
        for (index, coordinator) in childCoordinators.enumerated() where coordinator === child {
            childCoordinators.remove(at: index)
            break
        }
    }
}
