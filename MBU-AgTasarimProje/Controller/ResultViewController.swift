//
//  ResultViewController.swift
//  MBU-AgTasarimProje
//
//  Created by Yusuf ali cezik on 25.10.2019.
//  Copyright © 2019 Yusuf Ali Cezik. All rights reserved.
//

import UIKit

//2 sorun: 1:/16 ya göre andleme yapılarak ip oymuş gibi devam edilecek.
// 2: eğer tek bir ağ varsa bitiş ve yayın vs almıyor, if datacount == 0 sa özel durum uygulanacak,
//ayrıca en sonunkinde de de aynı sorunvar. belki fazladan ağ eklenir ama gösteirlmez. onun başlangıcı bulunur bitişi de verilir.
class ResultViewController: UIViewController {
    
    @IBOutlet weak var kullanilanIPAdresi: UILabel!
    @IBOutlet weak var kullanilanIPBinary: UILabel!
    @IBOutlet weak var subnetTitleCIDR: UILabel!
    @IBOutlet weak var subnetBinary: UILabel!
    
    var dataList:[Ag] = []
    var dataListResult:[AgResult] = []
    var ipAdress:String?
    var sayac = 0
    var kullanilanIPAdresiString = ""
    var kullanilanIPBinaryString = ""
    var subnetTitleCIDRString = ""
    var subnetBinaryString = ""
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        self.calculate()
    }
    func setupView(){
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        UIApplication.shared.statusBarView?.backgroundColor = #colorLiteral(red: 0.05490196078, green: 0.1607843137, blue: 0.2274509804, alpha: 1)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
extension ResultViewController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataListResult.count-1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = Bundle.main.loadNibNamed("AgInfoCell", owner: self, options: nil)?.first as? AgInfoCell else {return UITableViewCell()}
        cell.agAdiLabel.text = self.dataListResult[indexPath.row].agName
        cell.hostSayisiLabel.text = self.dataListResult[indexPath.row].agAgAdresi
        cell.accessoryType = .disclosureIndicator
        print(self.dataListResult[indexPath.row].agBitisIp)
        print(self.dataListResult[indexPath.row].agYayinAdresi)
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

extension ResultViewController{
    func calculate(){
        sayac = 0
        guard let _ = self.ipAdress else {return}
        if self.dataList.count <= 0 {return}
        var ipExps = [Int]()
        for networkItem in self.dataList {
            var currentExp = 0
            var lasti = 0
            for i in 0..<100{
                currentExp = 2.getExp(exp: i)
                if (currentExp-2) >= (networkItem.hostSayisi){
                    print("Sonuc \(currentExp)") // 64, 32, 16, 16, 4,4,4 hangi aralıklar. verilen alt ağ maskelerinde. ayrıca 32-i den de alt ağ maskesini buluruz. sonuc toplam 1 sayısıdır.
                    ipExps.append(currentExp)
                    lasti = i
                    break
                }
            }
            let withSubnetIpAdress = getWithSubnetIpAdress(self.ipAdress!)
            print(withSubnetIpAdress) //gelen 2 lik gerçek(dönüştürülmüş) ağ adresi. andlenmiş. Bu 10 luğa çevirilip yollanacak.
            self.kullanilanIPBinaryString = withSubnetIpAdress
            let decimalIPAdress = getDecimalIPAdress(withSubnetIpAdress)
            print(decimalIPAdress) //10 luk andlenmiş dönüştürülmüş adres
            kullanilanIPAdresiString = ""
            for i in 0...decimalIPAdress.count-2{
                self.kullanilanIPAdresiString+=decimalIPAdress[i]
            }
            self.showIpRange(ipExps,decimalIPAdress, networkItem.agAdi)
            self.dataListResult[sayac].agName = networkItem.agAdi
            self.dataListResult[sayac].agHostSayisi = String(networkItem.hostSayisi)
            self.dataListResult[sayac].ayrilanIPSayisi = String(currentExp-2)
            
            let binarySubnet = getSubnetMaskString(Int64(32-lasti)) // /14 yollarım binary list alırım.
            let subnetMaskString = getSubnetMaskForByteList(binarySubnet) //birleşmiş 0 lı stringe dönüştü
            self.dataListResult[sayac].agAltAgMaskesi = convertStringBinaryListToDecimalString(subnetMaskString)
            
            self.dataListResult[sayac].kullanılanIPAdres = self.dataListResult[sayac].agHostSayisi
            self.dataListResult[sayac].bostaKalanIPAdress = String(Int(self.dataListResult[sayac].ayrilanIPSayisi)!-Int(self.dataListResult[sayac].agHostSayisi)!)

            sayac+=1
        }
        self.tableView.reloadData()
        self.kullanilanIPAdresi.text = kullanilanIPAdresiString + " / " + subnetTitleCIDRString
        self.kullanilanIPBinary.text = kullanilanIPBinaryString
        self.subnetBinary.text = subnetBinaryString
    }
    
    func showIpRange(_ ipExps:[Int], _ ipAdress:String, _ agAdi:String){
        let tempAgResult = AgResult()
        var totalNetworkCount = 0
        for ipExpItem in ipExps{
            totalNetworkCount+=ipExpItem
        }
        var ipAddressList = getIpAdressInt(ipAdress) //. ya göre split işlemi yapar ve her 4 lük biti ayırır. int olarak döndürür.
        if totalNetworkCount < 255{
            for i in -1..<ipExps.count-1{
                if i == -1{
                    //ipAddressList[ipAddressList.count-1]
                }else{
                    ipAddressList[ipAddressList.count-1]+=ipExps[i]
                }
                print(ipAddressList[0],".",ipAddressList[1],".",ipAddressList[2],".",ipAddressList[3])
            }
            tempAgResult.agName = agAdi
            tempAgResult.agAgAdresi = "\(ipAddressList[0]).\(ipAddressList[1]).\(ipAddressList[2]).\(ipAddressList[3])"
            if ipAddressList[3] < 255{
                tempAgResult.agBaslangicIp = "\(ipAddressList[0]).\(ipAddressList[1]).\(ipAddressList[2]).\(ipAddressList[3]+1)"
            }else if ipAddressList[3] == 255 && ipAddressList[2]<255{
                tempAgResult.agBaslangicIp = "\(ipAddressList[0]).\(ipAddressList[1]).\(ipAddressList[2]+1).\(0)"
            }else if ipAddressList[3] == 255 && ipAddressList[2] == 255 && ipAddressList[1]<255{
                tempAgResult.agBaslangicIp = "\(ipAddressList[0]).\(ipAddressList[1]+1).\(0).\(0)"
            }else{
                tempAgResult.agBaslangicIp = "\(ipAddressList[0]+1).\(0).\(0).\(0)"
            }
            dataListResult.append(tempAgResult)
            if self.sayac > 0{
                //bir öncekinin yayın, bitiş adresi vs. değiştir.
                if ipAddressList[3] != 0{ // != 1 denilip agBitis adresi hesaplanacak.
                    self.dataListResult[sayac-1].agBitisIp = "\(ipAddressList[0]).\(ipAddressList[1]).\(ipAddressList[2]).\(ipAddressList[3]-2)"
                    self.dataListResult[sayac-1].agYayinAdresi = "\(ipAddressList[0]).\(ipAddressList[1]).\(ipAddressList[2]).\(ipAddressList[3]-1)"
                }else if ipAddressList[3] == 0 && ipAddressList[2] != 0{
                    self.dataListResult[sayac-1].agBitisIp = "\(ipAddressList[0]).\(ipAddressList[1]).\(ipAddressList[2]-1).\(254)"
                    self.dataListResult[sayac-1].agYayinAdresi = "\(ipAddressList[0]).\(ipAddressList[1]).\(ipAddressList[2]-1).\(255)"
                }else if ipAddressList[3] == 0 && ipAddressList[2] == 0 && ipAddressList[1] != 0{
                    self.dataListResult[sayac-1].agBitisIp = "\(ipAddressList[0]).\(ipAddressList[1]-1).\(255).\(254)"
                    self.dataListResult[sayac-1].agYayinAdresi = "\(ipAddressList[0]).\(ipAddressList[1]-1).\(255).\(255)"
                }
            }
        }else{
            for i in -1..<ipExps.count-1{
                if i == -1{
                    //ipAddressList[ipAddressList.count-1]
                }else{
                    var total = ipAddressList[3]+ipExps[i]
                    if total > 255{ // while ekle, extra 255 den kucuk olana kadar. sayac kadar da arttır.
                        var sayac = 0
                        while(total>255){
                            total = total-256
                            sayac+=1
                        }
                        var sayac2 = 0
                        if sayac > 255{
                            while(sayac>255){
                                sayac = sayac-256
                                sayac2+=1
                            }
                        }
                        ipAddressList[1]+=sayac2
                        ipAddressList[2]+=sayac
                        ipAddressList[3]=total
                    }else{
                        ipAddressList[ipAddressList.count-1]+=ipExps[i]
                    }
                }
              print(ipAddressList[0],".",ipAddressList[1],".",ipAddressList[2],".",ipAddressList[3])
            }
            tempAgResult.agName = agAdi
            tempAgResult.agAgAdresi = "\(ipAddressList[0]).\(ipAddressList[1]).\(ipAddressList[2]).\(ipAddressList[3])"
            if ipAddressList[3] < 255{
                tempAgResult.agBaslangicIp = "\(ipAddressList[0]).\(ipAddressList[1]).\(ipAddressList[2]).\(ipAddressList[3]+1)"
            }else if ipAddressList[3] == 255 && ipAddressList[2]<255{
                tempAgResult.agBaslangicIp = "\(ipAddressList[0]).\(ipAddressList[1]).\(ipAddressList[2]+1).\(0)"
            }else if ipAddressList[3] == 255 && ipAddressList[2] == 255 && ipAddressList[1]<255{
                tempAgResult.agBaslangicIp = "\(ipAddressList[0]).\(ipAddressList[1]+1).\(0).\(0)"
            }else{
                tempAgResult.agBaslangicIp = "\(ipAddressList[0]+1).\(0).\(0).\(0)"
            }
            dataListResult.append(tempAgResult)
            if self.sayac > 0{
                //bir öncekinin yayın, bitiş adresi vs. değiştir.
                if ipAddressList[3] != 0{
                    self.dataListResult[sayac-1].agBitisIp = "\(ipAddressList[0]).\(ipAddressList[1]).\(ipAddressList[2]).\(ipAddressList[3]-2)"
                    self.dataListResult[sayac-1].agYayinAdresi = "\(ipAddressList[0]).\(ipAddressList[1]).\(ipAddressList[2]).\(ipAddressList[3]-1)"
                }else if ipAddressList[3] == 0 && ipAddressList[2] != 0{
                    self.dataListResult[sayac-1].agBitisIp = "\(ipAddressList[0]).\(ipAddressList[1]).\(ipAddressList[2]-1).\(254)"
                    self.dataListResult[sayac-1].agYayinAdresi = "\(ipAddressList[0]).\(ipAddressList[1]).\(ipAddressList[2]-1).\(255)"
                }else if ipAddressList[3] == 0 && ipAddressList[2] == 0 && ipAddressList[1] != 0{
                    self.dataListResult[sayac-1].agBitisIp = "\(ipAddressList[0]).\(ipAddressList[1]-1).\(255).\(254)"
                    self.dataListResult[sayac-1].agYayinAdresi = "\(ipAddressList[0]).\(ipAddressList[1]-1).\(255).\(255)"
                }
                
            }
        }
    }
    func getIpAdressInt(_ ipAdress:String)->[Int]{
        let resultIPListString = ipAdress.split(separator: ".")
        let resultIPList = resultIPListString.map({
            Int($0)
        })
        return resultIPList as! [Int]
    }

    ////////////////////////////-------------///////////////////
    func getWithSubnetIpAdress(_ ipAdress:String)->String{
        var returnedIP = ""
        var seperatedNetwork = ipAdress.split(separator: "/")
        let ipAdressList = getIpAdressInt(String(seperatedNetwork[0]))//"192.168.1.10" luk kısımı ayrıp int olarak döndürür
        self.subnetTitleCIDRString = String(seperatedNetwork[1])
        let subnetMask = Int64(seperatedNetwork[1])! // "/16 ise 16yı int olarak aldık"
        let subnedMaskListInt:[Int64] = getSubnetMaskString(subnetMask)
        returnedIP = AndTwoValue(ipAdressList,subnedMaskListInt)
        for i in subnedMaskListInt{
            print(i)
        }
        return returnedIP
    }
    func getSubnetMaskString(_ subnetMask:Int64)->[Int64]{
        var returnedMask:String = ""
        self.subnetBinaryString = ""
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
        for i in 0...returnetByteList.count-1{
            self.subnetBinaryString+=returnetByteList[i]
            if i != returnetByteList.count-1{
                self.subnetBinaryString+="."
            }
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


extension ResultViewController{
    func convertStringBinaryListToDecimalString( _ binaryString: [String] )->String{
        var birlesmisString = ""
        var returnetString = ""
        for i in 0..<binaryString.count{
            if i != binaryString.count-1{
                birlesmisString+=binaryString[i]+"."
            }else{
                birlesmisString+=binaryString[i]
            }
        }
        returnetString = getDecimalIPAdress(birlesmisString)
        returnetString.removeLast()// son . yı sil
        return returnetString
    }
}
