//
//  DetailResultViewController.swift
//  MBU-AgTasarimProje
//
//  Created by Yusuf ali cezik on 25.10.2019.
//  Copyright © 2019 Yusuf Ali Cezik. All rights reserved.
//

import UIKit

class DetailResultViewController: UIViewController {

    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var agAdiLabel: UILabel!
    @IBOutlet weak var hostSayisiLabel: UILabel!
    @IBOutlet weak var ayrilanIPSayisiLabel: UILabel!
    @IBOutlet weak var kullanilanIPSayisiLabel: UILabel!
    @IBOutlet weak var bostaKalanIpSayisiLabel: UILabel!
    @IBOutlet weak var baslangicIPAdresiLabel: UILabel!
    @IBOutlet weak var bitisIPAdresiLabel: UILabel!
    @IBOutlet weak var yayınAdresiLabel: UILabel!
    @IBOutlet weak var altAgMaskesiLabel: UILabel!
    var propertyList = Array<String>()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewInfo()
        headerTitle.text = propertyList[0]
    }
    
    func setupViewInfo(){
        let views = [agAdiLabel,hostSayisiLabel,ayrilanIPSayisiLabel,kullanilanIPSayisiLabel,bostaKalanIpSayisiLabel,baslangicIPAdresiLabel,bitisIPAdresiLabel,yayınAdresiLabel,altAgMaskesiLabel]
        if views.count == propertyList.count{
            for i in 0..<propertyList.count{
                (views[i])?.text = propertyList[i]
            }
        }
    }
   
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
