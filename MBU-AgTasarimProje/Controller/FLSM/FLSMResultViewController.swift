//
//  FLSMResultViewController.swift
//  MBU-AgTasarimProje
//
//  Created by Yusuf ali cezik on 26.11.2019.
//  Copyright © 2019 Yusuf Ali Cezik. All rights reserved.
//

import UIKit

class FLSMResultViewController: UIViewController {

    @IBOutlet weak var kullanilanIPAdresi: UILabel!
    @IBOutlet weak var kullanilanIPBinary: UILabel!
    @IBOutlet weak var subnetBinary: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    public var dataList:[Ag] = []
    public var ipAdress:String?
    
    private var increase_count = 0
    private var allDatas = [String]()
    private var dataListResult:[AgResult] = []
    private var allCells = [AgInfoCell]()
    private var subnetCount = 0
    private var exp1_count = 0
    private var new_subnet_mask:String = ""
    fileprivate var firstTime = true
    private var subnetBinaryString = ""
    private var indexNo = 0
    private var kullanilanIPString = ""
    private var kullanilanSubnetString = ""
    private var kullanilanIPBinaryString = ""
    private var ayirilanIPCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        calculateFLSM()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        UIApplication.shared.statusBarView?.backgroundColor = #colorLiteral(red: 0.2862745098, green: 0.5764705882, blue: 0.6588235294, alpha: 1)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func setup(){
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tableButtonClicked(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "allVC") as? AllResultsViewController
        vc?.dataList = self.dataListResult
        self.navigationController?.pushViewController(vc!, animated: true)
    }

}

extension FLSMResultViewController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataListResult.count-1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = Bundle.main.loadNibNamed("AgInfoCell", owner: self, options: nil)?.first as? AgInfoCell else {return UITableViewCell()}
        cell.agAdiLabel.text = self.dataListResult[indexPath.row].agName
        cell.hostSayisiLabel.text = self.dataListResult[indexPath.row].agAgAdresi
        cell.detailicon.isHidden = false
        print(self.dataListResult[indexPath.row].agBitisIp)
        print(self.dataListResult[indexPath.row].agYayinAdresi)
        allCells.append(cell)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let detailsVC = storyboard?.instantiateViewController(withIdentifier: "DetailVC") as? DetailResultViewController
        let secilenAg = self.dataListResult[indexPath.row]
        detailsVC?.propertyList = [secilenAg.agName,secilenAg.agHostSayisi, secilenAg.ayrilanIPSayisi,secilenAg.kullanılanIPAdres, secilenAg.bostaKalanIPAdress,secilenAg.agAgAdresi,secilenAg.agBaslangicIp, secilenAg.agBitisIp, secilenAg.agYayinAdresi, secilenAg.agAltAgMaskesi]
        self.navigationController?.pushViewController(detailsVC!, animated: true)
    }
    
    
}

extension FLSMResultViewController{
    private func calculateFLSM(){
        
        self.subnetCount = self.dataList.count
        var currentExp = 0
        var last_i = 0
        for i in 0..<100{
            currentExp = 2.getExp(exp: i)
            if (currentExp) >= subnetCount-1{
                last_i = i
                break
            }
        }
        self.exp1_count = last_i // 6 alt ağ ise 3 olmalı
        var seperatedNetwork = ipAdress!.split(separator: "/")
        let subnetMask = Int(seperatedNetwork[1])! // /16
        self.new_subnet_mask = String(subnetMask+self.exp1_count) // 16 + 3
        print(new_subnet_mask)
        
        let ipAdressList = getIpAdressInt(String(seperatedNetwork[0]))//"192.168.1.10" luk kısımı ayrıp int dizisi olarak döndürür
        let subnedMaskListInt:[Int64] = getSubnetMaskString(Int64(subnetMask)) //16 tane 1 olan dizi döner.

        let starting_ip_address = AndTwoValue(ipAdressList,subnedMaskListInt)
        print(starting_ip_address) //tüm ağın baslangic ip adresi (andlenmiş vs.)
        
        let decimal_starting_ip_address = getDecimalIPAdress(starting_ip_address) //decimal
        //andlenmiş ip adres üzerinden;
        let decimal_and_ip_address_list = decimal_starting_ip_address.split(separator: ".")
        
        for i in 0..<decimal_and_ip_address_list.count{ //0 olan kısımı buluruz. 192.168.0.0 ise 2. index
            if Int(decimal_and_ip_address_list[i]) == 0{
                indexNo = i
                break
            }
        }
        print(indexNo)
        let mList = decimal_and_ip_address_list //andlenmiş decimal ip adress
        getIncreaseCount() //self.increase_count güncellenecek.
        var currentCounter = 0
        if indexNo == 1{
            for i in 0..<self.dataList.count{
                let addedString = "\(mList[0]).\(currentCounter).\(mList[2]).\(mList[3])"
            self.allDatas.append(addedString)
                currentCounter = self.increase_count*(i+1) //0, 32, 64 şeklinde sabit artış.
            }
        }else if indexNo == 2{
            for i in 0..<self.dataList.count{
                self.allDatas.append("\(mList[0]).\(mList[1]).\(currentCounter).\(mList[3])")
                currentCounter = self.increase_count*(i+1)
            }
        }else if indexNo == 3{
            for i in 0..<self.dataList.count{
                self.allDatas.append("\(mList[0]).\(mList[1]).\(mList[2]).\(currentCounter)")
                currentCounter = self.increase_count*(i+1)
            }
        }
        
        saveData()
        setupUI()
    }
    
    private func setupUI(){
        self.kullanilanIPAdresi.text = self.ipAdress!
        self.kullanilanIPBinary.text = self.kullanilanIPBinaryString
        self.subnetBinary.text = self.kullanilanSubnetString
    }
    
    private func saveData(){
        for i in 0..<self.allDatas.count{
                let ag = AgResult()
                ag.agName = self.dataList[i].agAdi
                ag.agHostSayisi = String(self.dataList[i].hostSayisi)
                ag.agAltAgMaskesi = "/\(self.new_subnet_mask)"
                ag.agAgAdresi = self.allDatas[i]
                ag.agBaslangicIp = getBitisIP(indexNo: indexNo, baslangicIP: self.allDatas[i], forBaslangic: true)
                ag.agBitisIp = getBitisIP(indexNo:indexNo, baslangicIP:self.allDatas[i])
                ag.agYayinAdresi = getYayinIP(indexNo:indexNo, baslangicIP:self.allDatas[i])
                ag.ayrilanIPSayisi = "\(self.ayirilanIPCount-2)" //128 ise 126 (baslangic ve yayin haric)
                ag.kullanılanIPAdres = String(self.dataList[i].hostSayisi)
                ag.bostaKalanIPAdress = "\((self.ayirilanIPCount-2)-self.dataList[i].hostSayisi)"
                self.dataListResult.append(ag)
        }
    }
    
    private func getBitisIP(indexNo:Int, baslangicIP:String, forBaslangic:Bool = false)->String{
        var returnedString = ""
        if indexNo == 2{
            self.ayirilanIPCount = 255*increase_count // örn: 32.255
            let splittedIP = baslangicIP.split(separator: ".")
            var splittedInt = splittedIP.map{Int($0)}
            
            if forBaslangic{
                splittedInt[indexNo+1] = splittedInt[indexNo+1]!+1
            }else{
                splittedInt[indexNo] = splittedInt[indexNo]! + self.increase_count-1
                if indexNo != 3{
                    splittedInt[indexNo+1] = 254
                }
            }
            
            for i in 0..<splittedInt.count{
                if i != splittedInt.count-1{
                    returnedString += "\(splittedInt[i]!)."
                }else{
                    returnedString += "\(splittedInt[i]!)"
                }
            }
        }else if indexNo == 1{
            self.ayirilanIPCount = 255*255*increase_count
            let splittedIP = baslangicIP.split(separator: ".")
            var splittedInt = splittedIP.map{Int($0)}
            
            if forBaslangic{
                splittedInt[indexNo+2] = splittedInt[indexNo+2]!+1
            }else{
                splittedInt[indexNo] = splittedInt[indexNo]! + self.increase_count-1
                if indexNo != 2{
                    splittedInt[indexNo+1] = 255
                    splittedInt[indexNo+2] = 254
                }
            }
            
            for i in 0..<splittedInt.count{
                if i != splittedInt.count-1{
                    returnedString += "\(splittedInt[i]!)."
                }else{
                    returnedString += "\(splittedInt[i]!)"
                }
            }
        }else if indexNo == 3{
            self.ayirilanIPCount = increase_count
            let splittedIP = baslangicIP.split(separator: ".")
            var splittedInt = splittedIP.map{Int($0)}
            
            if forBaslangic{
                splittedInt[indexNo] = splittedInt[indexNo]! + 1
            }else{
                splittedInt[indexNo] = splittedInt[indexNo]! + self.increase_count-2
            }
            
            for i in 0..<splittedInt.count{
                if i != splittedInt.count-1{
                    returnedString += "\(splittedInt[i]!)."
                }else{
                    returnedString += "\(splittedInt[i]!)"
                }
            }
        }
        
        return returnedString
    }
    
    private func getYayinIP(indexNo:Int, baslangicIP:String)->String{
        var returnedString = ""
        if indexNo == 2{
            let splittedIP = baslangicIP.split(separator: ".")
            var splittedInt = splittedIP.map{Int($0)}
            splittedInt[indexNo] = splittedInt[indexNo]! + self.increase_count-1
            if indexNo != 3{
                splittedInt[indexNo+1] = 255
            }
            
            for i in 0..<splittedInt.count{
                if i != splittedInt.count-1{
                    returnedString += "\(splittedInt[i]!)."
                }else{
                    returnedString += "\(splittedInt[i]!)"
                }
            }
        }else if indexNo == 1{
            let splittedIP = baslangicIP.split(separator: ".")
            var splittedInt = splittedIP.map{Int($0)}
            splittedInt[indexNo] = splittedInt[indexNo]! + self.increase_count-1
            if indexNo != 2{
                splittedInt[indexNo+1] = 255
                splittedInt[indexNo+2] = 255
            }
            
            for i in 0..<splittedInt.count{
                if i != splittedInt.count-1{
                    returnedString += "\(splittedInt[i]!)."
                }else{
                    returnedString += "\(splittedInt[i]!)"
                }
            }
        }else if indexNo == 3{
            let splittedIP = baslangicIP.split(separator: ".")
            var splittedInt = splittedIP.map{Int($0)}
            splittedInt[indexNo] = splittedInt[indexNo]! + self.increase_count-1

            
            for i in 0..<splittedInt.count{
                if i != splittedInt.count-1{
                    returnedString += "\(splittedInt[i]!)."
                }else{
                    returnedString += "\(splittedInt[i]!)"
                }
            }
        }
        
        return returnedString
    }
    
    private func getIncreaseCount(){
        var currentCount = 256
        for i in 0...exp1_count{
            if i != 1{
                currentCount/=2
            }
        }
        print("artis: \(currentCount)")
        self.increase_count = currentCount
    }
    
    private func getIpAdressInt(_ ipAdress:String)->[Int]{
        let resultIPListString = ipAdress.split(separator: ".")
        let resultIPList = resultIPListString.map({
            Int($0)
        })
        return resultIPList as! [Int]
    }
    
    func getSubnetMaskString(_ subnetMask:Int64)->[Int64]{
        var returnedMask:String = ""
        var returnedMaskList = [Int64]()
        for i in 1...32{
            if i<=subnetMask{
                returnedMask+="1"
            }else{
                returnedMask+="0"
            }
            if i%8 == 0{
                returnedMaskList.append(Int64(returnedMask)!)
                returnedMask = ""
            }
        }
        return returnedMaskList
    }
    
    func AndTwoValue(_ ipAdressList:[Int], _ subnedMaskListInt:[Int64])->String{
        var lastIpAdresWithSubnet = ""
        let ipAddressByteList = getIpAdressListForByteList(ipAdressList) //string olarak aldık 111111, 000000
        let subnetMaskByteList = getSubnetMaskForByteList(subnedMaskListInt)
        
        subnetMaskByteList.forEach{self.kullanilanSubnetString+="\($0)."}
        self.kullanilanSubnetString.removeLast()
        
        ipAddressByteList.forEach{self.kullanilanIPBinaryString+="\($0)."}
        self.kullanilanIPBinaryString.removeLast()
        
        print(kullanilanIPBinaryString)
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
    
    func getIpAdressListForByteList(_ ipAdressList:[Int])->[String]{
        var returnetByteList = [String]()
        for i in 0..<ipAdressList.count{
            var byteInt = ""
            var ipOktetItem = ipAdressList[i]
            if ipOktetItem == 0{
                byteInt = "00000000"
            }else{
                while(ipOktetItem>0){
                    let kalan = ipOktetItem%2
                    byteInt=String(kalan)+byteInt
                    ipOktetItem = ipOktetItem/2
                }
                var newByteInt = ""
                if byteInt.count < 8{
                    let fark = 8-byteInt.count
                    for _ in 0..<fark{
                        newByteInt += "0"
                    }
                    byteInt = newByteInt+byteInt
                }
            }
            returnetByteList.append(byteInt)
        }
        return returnetByteList
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
        //for CIDR
        if firstTime{
            for i in 0...returnetByteList.count-1{
                self.subnetBinaryString+=returnetByteList[i]
                if i != returnetByteList.count-1{
                    self.subnetBinaryString+="."
                }
            }
            self.firstTime = false
        }
        return returnetByteList
    }
    
    
    func getDecimalIPAdress(_ withSubnetIpAdress:String)->String{
        var decimalString = ""
        let binaryList = withSubnetIpAdress.split(separator: ".")
        for oktet in binaryList{
            var oktetSumResult = 0
            for j in 0...7{
                if String(oktet)[j] == "1"{
                    let val = 2.getExp(exp: (7-j))
                    oktetSumResult+=val
                }
            }
            decimalString+=String(oktetSumResult)
            //if oktet != binaryList[binaryList.count-1]{
            decimalString+="."
            //}
        }
        return decimalString
    }
}
