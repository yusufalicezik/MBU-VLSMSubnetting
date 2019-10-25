//
//  ViewController.swift
//  MBU-AgTasarimProje
//
//  Created by Yusuf ali cezik on 24.10.2019.
//  Copyright © 2019 Yusuf Ali Cezik. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var degiskenButton: UIButton!
    @IBOutlet weak var sabitButton: UIButton!
    @IBOutlet weak var altAgButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
        let mViews = [degiskenButton,sabitButton,altAgButton]
        for i in mViews{
            i?.layer.cornerRadius = 10
        }
        // Do any additional setup after loading the view.
    }

    @IBAction func vlsmClicked(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "vlsmVC") as? VLSMViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @IBAction func flsmClicked(_ sender: Any) {
    }
    @IBAction func subnetCalculateClicked(_ sender: Any) {
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
}

