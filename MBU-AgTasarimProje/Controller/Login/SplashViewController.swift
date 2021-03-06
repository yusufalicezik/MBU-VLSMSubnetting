//
//  ViewController.swift
//  MBU-AgTasarimProje
//
//  Created by Yusuf ali cezik on 24.10.2019.
//  Copyright © 2019 Yusuf Ali Cezik. All rights reserved.
//

import UIKit


class SplashViewController: UIViewController {
    
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
        let inputVC = storyboard?.instantiateViewController(withIdentifier: "InputVC") as? DataInputViewController
        inputVC?.calculatingType = .VLSM
        self.navigationController?.pushViewController(inputVC!, animated: true)
    }
    
    @IBAction func flsmClicked(_ sender: Any) {
        let inputVC = storyboard?.instantiateViewController(withIdentifier: "InputVC") as? DataInputViewController
        inputVC?.calculatingType = .FLSM
        self.navigationController?.pushViewController(inputVC!, animated: true)
    }
    @IBAction func subnetCalculateClicked(_ sender: Any) {
        let inputVC = storyboard?.instantiateViewController(withIdentifier: "SubnetVC") as? SubnetCalculateViewController
        self.navigationController?.pushViewController(inputVC!, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden  = true
        UIApplication.shared.statusBarView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden  = false

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

