//
//  SubnetCalculateViewController.swift
//  MBU-AgTasarimProje
//
//  Created by Yusuf ali cezik on 26.11.2019.
//  Copyright © 2019 Yusuf Ali Cezik. All rights reserved.
//

import UIKit

class SubnetCalculateViewController: UIViewController {

    @IBOutlet weak var inputTxtField: UITextField!
    @IBOutlet weak var calculateButton: UIButton!
    @IBOutlet weak var agAdresiLabel: UILabel!
    @IBOutlet weak var agAdresiBinaryLabel: UILabel!
    
    private let calculate = GlobalFuncstions.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarView?.backgroundColor = #colorLiteral(red: 0.2862745098, green: 0.5764705882, blue: 0.6588235294, alpha: 1)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    private func setupUI(){
        self.inputTxtField.layer.cornerRadius = 10
        self.calculateButton.layer.cornerRadius = 10
    }
    
    @IBAction func calculateButtonClicked(_ sender: Any) {
        if !inputTxtField.text!.isEmpty{
            calculateSubnetMask(inputTxtField.text!)
        }
    }
    
    @IBAction func backbuttonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
       }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func calculateSubnetMask(_ ipAddress:String){
        let seperatedNetwork = ipAddress.split(separator: "/")
        let subnetMask = Int(seperatedNetwork[1])!
        let ipAdressList = calculate.getIpAdressInt(String(seperatedNetwork[0]))
        let subnedMaskListInt:[Int64] = calculate.getSubnetMaskString(Int64(subnetMask))
        let sub_ip_address = AndTwoValue(ipAdressList,subnedMaskListInt)
        print(sub_ip_address)
        
        var decimal_sub_ip_address = calculate.getDecimalIPAdress(sub_ip_address)
        decimal_sub_ip_address.removeLast() //. yı silmek için
        print(decimal_sub_ip_address)
        
        DispatchQueue.main.async {
            self.agAdresiLabel.text = decimal_sub_ip_address
            self.agAdresiBinaryLabel.text = sub_ip_address
        }
        
    }
}

extension SubnetCalculateViewController{

    func AndTwoValue(_ ipAdressList:[Int], _ subnedMaskListInt:[Int64])->String{
        var lastIpAdresWithSubnet = ""
        let ipAddressByteList = calculate.getIpAdressListForByteList(ipAdressList) //string olarak aldık 111111, 000000
        let subnetMaskByteList = getSubnetMaskForByteList(subnedMaskListInt)
        
        for i in 0..<ipAddressByteList.count{
            let ipOktet = ipAddressByteList[i]
            let subnetOktet = subnetMaskByteList[i]
            for j in 0..<8{
                if ipOktet[j] == "1" && subnetOktet[j] == "1"{
                    lastIpAdresWithSubnet+="1"
                }else{
                    lastIpAdresWithSubnet+="0"
                }
            }
            if i != ipAddressByteList.count-1{
                lastIpAdresWithSubnet+="."
            }
        }
        return lastIpAdresWithSubnet
    }
    
    
    func getSubnetMaskForByteList(_ subnetList:[Int64])->[String]{
        var returnetByteList = [String]()
        for i in subnetList{
            var stringItem = String(i)
            if stringItem.count<8{
                let fark = 8-stringItem.count
                var newByteInt = ""
                for _ in 0..<fark{
                    newByteInt+="0"
                }
                stringItem = newByteInt+stringItem
            }
            returnetByteList.append(stringItem)
        }
        return returnetByteList
    }
}
