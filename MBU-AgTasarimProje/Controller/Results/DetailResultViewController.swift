//
//  DetailResultViewController.swift
//  MBU-AgTasarimProje
//
//  Created by Yusuf ali cezik on 25.10.2019.
//  Copyright © 2019 Yusuf Ali Cezik. All rights reserved.
//

import UIKit
import SwiftyShadow

class DetailResultViewController: UIViewController {

    @IBOutlet weak var detailContainer: UIView!
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var agAdiLabel: UILabel!
    @IBOutlet weak var hostSayisiLabel: UILabel!
    @IBOutlet weak var ayrilanIPSayisiLabel: UILabel!
    @IBOutlet weak var kullanilanIPSayisiLabel: UILabel!
    @IBOutlet weak var bostaKalanIpSayisiLabel: UILabel!
    @IBOutlet weak var baslangicIPAdresiLabel: UILabel!
    @IBOutlet weak var agIPAdresiLabel: UILabel!
    @IBOutlet weak var bitisIPAdresiLabel: UILabel!
    @IBOutlet weak var yayınAdresiLabel: UILabel!
    @IBOutlet weak var altAgMaskesiLabel: UILabel!
    var propertyList = Array<String>()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
        self.detailContainer.layer.cornerRadius = 15
        setupViewInfo()
        headerTitle.text = propertyList[0]
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func setupViewInfo(){
        let views = [agAdiLabel,hostSayisiLabel,ayrilanIPSayisiLabel,kullanilanIPSayisiLabel,bostaKalanIpSayisiLabel,agIPAdresiLabel,baslangicIPAdresiLabel,bitisIPAdresiLabel,yayınAdresiLabel,altAgMaskesiLabel]
        if views.count == propertyList.count{ //+1 ağ adresi
            for i in 0..<propertyList.count{
                (views[i])?.text = propertyList[i]
            }
        }
        self.detailContainer.layer.shadowRadius = 10
        self.detailContainer.layer.shadowOpacity = 0.2
        self.detailContainer.layer.shadowColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        self.detailContainer.layer.shadowOffset = CGSize.zero
        self.detailContainer.generateOuterShadow()
    }
   
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
