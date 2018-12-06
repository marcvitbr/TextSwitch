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

        let colorWhenOn = UIColor(red: 126/255, green: 223/255, blue: 179/255, alpha: 1)
        let colorWhenOff = UIColor(red: 1, green: 154/255, blue: 155/255, alpha: 1)

        self.textSwitch = UITextSwitch()
        self.textSwitch.trailColorWhenOn = colorWhenOn
        self.textSwitch.trailColorWhenOff = colorWhenOff
        self.textSwitch.textWhenOn = "Do it!"
        self.textSwitch.textWhenOff = "Don't do it!"

        self.view.addSubview(self.textSwitch)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.textSwitch.center = self.view.center
    }
}
