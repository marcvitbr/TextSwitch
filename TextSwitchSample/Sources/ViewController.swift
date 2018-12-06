//
//  ViewController.swift
//  TextSwitchSample
//
//  Created by Marcelo Vitoria on 06/12/18.
//  Copyright © 2018 Marcelo Vitoria. All rights reserved.
//

import UIKit
import TextSwitch

class ViewController: UIViewController {
    var textSwitch: UITextSwitch!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.textSwitch = UITextSwitch()

        self.view.addSubview(self.textSwitch)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.textSwitch.center = self.view.center
    }
}

