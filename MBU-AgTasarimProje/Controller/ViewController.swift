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
    @IBOutlet weak var backgroundImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupParallax()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    func setupParallax(){
        let min = CGFloat(-30)
        let max = CGFloat(30)
        let xMotion = UIInterpolatingMotionEffect(keyPath: "layer.transform.translation.x", type: .tiltAlongHorizontalAxis)
        xMotion.minimumRelativeValue = min
        xMotion.maximumRelativeValue = max
        
        let yMotion = UIInterpolatingMotionEffect(keyPath: "layer.transform.translation.y", type: .tiltAlongVerticalAxis)
        yMotion.minimumRelativeValue = min
        yMotion.maximumRelativeValue = max
        
        let motionEffectGroup = UIMotionEffectGroup()
        motionEffectGroup.motionEffects = [xMotion, yMotion]
        self.backgroundImage.addMotionEffect(motionEffectGroup)
        
    }
    
}

