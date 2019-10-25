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
    
    var dataList:[Ag] = []
    var dataListResult:[AgResult] = []
    var ipAdress:String?
    var sayac = 0
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
        UIApplication.shared.statusBarView?.backgroundColor = #colorLiteral(red: 0.05490196078, green: 0.1607843137, blue: 0.2274509804, alpha: 1)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
extension ResultViewController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataListResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = Bundle.main.loadNibNamed("AgInfoCell", owner: self, options: nil)?.first as? AgInfoCell else {return UITableViewCell()}
        cell.agAdiLabel.text = self.dataListResult[indexPath.row].agName
        cell.hostSayisiLabel.text = self.dataListResult[indexPath.row].agBaslangicIp
        cell.accessoryType = .disclosureIndicator
        print(self.dataListResult[indexPath.row].agBitisIp)
        print(self.dataListResult[indexPath.row].agYayinAdresi)

        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let detailsVC = storyboard?.instantiateViewController(withIdentifier: "DetailVC") as? DetailResultViewController
        let secilenAg = self.dataListResult[indexPath.row]
        detailsVC?.propertyList = [secilenAg.agName,"hostSayisi", "AyrilanAg","kullanilanAg", "BostaKalanAg",secilenAg.agBaslangicIp, secilenAg.agBitisIp, secilenAg.agYayinAdresi, "altAgMaskesi"]
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
            for i in 0..<100{
                currentExp = 2.getExp(exp: i)
                if (currentExp-2) >= (networkItem.hostSayisi){
                    print("Sonuc \(currentExp)") // 64, 32, 16, 16, 4,4,4 hangi aralıklar. verilen alt ağ maskelerinde. ayrıca 32-i den de alt ağ maskesini buluruz. sonuc toplam 1 sayısıdır.
                    ipExps.append(currentExp)
                    break
                }
            }
            let withSubnetIpAdress = getWithSubnetIpAdress(self.ipAdress!)
            print(withSubnetIpAdress) //gelen 2 lik gerçek(dönüştürülmüş) ağ adresi. andlenmiş. Bu 10 luğa çevirilip yollanacak.
            let decimalIPAdress = getDecimalIPAdress(withSubnetIpAdress)
            print(decimalIPAdress) //10 luk andlenmiş dönüştürülmüş adres
            self.showIpRange(ipExps,decimalIPAdress, networkItem.agAdi)
            sayac+=1
        }
        self.tableView.reloadData()
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
            tempAgResult.agBaslangicIp = "\(ipAddressList[0]).\(ipAddressList[1]).\(ipAddressList[2]).\(ipAddressList[3])"
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
        }else{
            //eğer toplam 255 i geçiyorsa 255 e gelene kadar sağ taraf artırılır. eğer bir sonraki toplam 255 i geçiyorsa 255 e kadar olanı eklenir daha sonra soldaki 1 arttırılıp kalanı eklenir. 1.25 örn.
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
            tempAgResult.agBaslangicIp = "\(ipAddressList[0]).\(ipAddressList[1]).\(ipAddressList[2]).\(ipAddressList[3])"
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
        let ipAdressList = getIpAdressInt(String(seperatedNetwork[0])) //"192.168.1.10" luk kısımı ayrıp int olarak döndürür
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
