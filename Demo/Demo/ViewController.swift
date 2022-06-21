//
//  ViewController.swift
//  Demo
//
//  Created by Dan ILCA on 21.06.2022.
//

import UIKit
import SwiftShare

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func clickAlertButton(_ sender: Any) {
        self.displayAlert(message: "Test message")
    }
    
}

