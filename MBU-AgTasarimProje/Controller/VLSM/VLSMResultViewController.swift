//
//  ResultViewController.swift
//  MBU-AgTasarimProje
//
//  Created by Yusuf ali cezik on 25.10.2019.
//  Copyright © 2019 Yusuf Ali Cezik. All rights reserved.
//

import UIKit
import ViewAnimator
class VLSMResultViewController: UIViewController {
    
    @IBOutlet weak var kullanilanIPAdresi: UILabel!
    @IBOutlet weak var kullanilanIPBinary: UILabel!
    @IBOutlet weak var subnetTitleCIDR: UILabel!
    @IBOutlet weak var subnetBinary: UILabel!
    @IBOutlet weak var tableView: UITableView!

    public var dataList:[Ag] = []
    public var ipAdress:String?
    
    private var dataListResult:[AgResult] = []
    private var sayac = 0
    private var kullanilanIPAdresiString = ""
    private var kullanilanIPBinaryString = ""
    private var subnetTitleCIDRString = ""
    private var subnetBinaryString = ""
    fileprivate var fromAnimation : AnimationType?
    fileprivate var allCells = [AgInfoCell]()
    fileprivate var firstTime = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fromAnimation = AnimationType.from(direction: .left, offset: 40.0)
        setupView()
        self.calculate()
        UIView.animate(views: tableView.visibleCells,
                       animations: [self.fromAnimation!], delay: 0.45)
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
        UIApplication.shared.statusBarView?.backgroundColor = #colorLiteral(red: 0.2862745098, green: 0.5764705882, blue: 0.6588235294, alpha: 1)
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
extension VLSMResultViewController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataListResult.count-1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = Bundle.main.loadNibNamed("AgInfoCell", owner: self, options: nil)?.first as? AgInfoCell else {return UITableViewCell()}
        cell.agAdiLabel.text = self.dataListResult[indexPath.row].agName
        cell.hostSayisiLabel.text = self.dataListResult[indexPath.row].agAgAdresi
        cell.detailicon.isHidden = false
//        print(self.dataListResult[indexPath.row].agBitisIp)
//        print(self.dataListResult[indexPath.row].agYayinAdresi)
        allCells.append(cell)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let detailsVC = storyboard?.instantiateViewController(withIdentifier: "DetailVC") as? DetailResultViewController
        let secilenAg = self.dataListResult[indexPath.row]
        detailsVC?.propertyList = [secilenAg.agName,secilenAg.agHostSayisi, secilenAg.ayrilanIPSayisi,secilenAg.kullanılanIPAdres, secilenAg.bostaKalanIPAdress,secilenAg.agAgAdresi,secilenAg.agBaslangicIp, secilenAg.agBitisIp, secilenAg.agYayinAdresi, secilenAg.agAltAgMaskesi] //seçilen ağın özelliklerini gönderdik.
        self.navigationController?.pushViewController(detailsVC!, animated: true)
    }
}

extension VLSMResultViewController{
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
            let withSubnetIpAdress = getWithSubnetIpAdress(self.ipAdress!) //ip adresini subnet ile andleyip, binary dönüştürür. (11000000.10101000.00000000.00000000)
            self.kullanilanIPBinaryString = withSubnetIpAdress
            let decimalIPAdress = getDecimalIPAdress(withSubnetIpAdress) //andlenmiş binary adresini decimal dönüştür. 192.168.0.0
            kullanilanIPAdresiString = ""
            for i in 0...decimalIPAdress.count-2{
                self.kullanilanIPAdresiString+=decimalIPAdress[i] //arayüz için. -2 sebebi sonunda . var
            }
            //1000 ağ için, 1024, decimal andlenmiş ip adresi ve ağ adi
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
            totalNetworkCount+=ipExpItem //toplam host sayısını güncelle
        }
        var ipAddressList = getIpAdressInt(ipAdress) //. ya göre split işlemi yapar ve her 4 lük biti ayırır. int olarak döndürür.
        if totalNetworkCount < 255{
            for i in -1..<ipExps.count-1{
                if i == -1{
                    //ipAddressList[ipAddressList.count-1]
                }else{
                    ipAddressList[ipAddressList.count-1]+=ipExps[i] //192.168.1.0 örn, 255 den küçükse 0 kısmını totalNework kadar arttır.
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
                    if total > 255{
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
    
    // MARK: - Gelen IP Adresi : 192.168.1.1/16
    func getWithSubnetIpAdress(_ ipAdress:String)->String{
        var returnedIP = ""
        let seperatedNetwork = ipAdress.split(separator: "/") //192.168.1.1 ve 16 yı ayırdık.
        let ipAdressList = getIpAdressInt(String(seperatedNetwork[0]))//"192.168.1.1" lik kısımı ayrıp int dizisi olarak döndürür
        self.subnetTitleCIDRString = String(seperatedNetwork[1])
        let subnetMask = Int64(seperatedNetwork[1])! // "/16 ise 16yı int olarak aldık"
        let subnedMaskListInt:[Int64] = getSubnetMaskString(subnetMask) // 16 ise 16 tane 1 olan binary getir.
        returnedIP = AndTwoValue(ipAdressList,subnedMaskListInt)
        for i in subnedMaskListInt{
            print(i)
        }
        return returnedIP
    }
    
    //MARK: - Gelen ip adresini (192.168.1.1) [192, 168, 1, 1] int dizisine çevir
    func getIpAdressInt(_ ipAdress:String)->[Int]{
        let resultIPListString = ipAdress.split(separator: ".")
        let resultIPList = resultIPListString.map({
            Int($0)
        })
        return resultIPList as! [Int]
    }
    
    //MARK: - 16 gelir, [11111111,11111111,00000000,00000000] 16 tane 1 olan dizi döner.
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
    
    //MARK: - İp adresi ile subnetin andlenme işlemi
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
    
    //MARK: - integer ip adres listini, binary string listesine dönüştürür.
    // gelen : [192, 168, 1, 1] ise [11000000, 10100000, vs..] döner. andleme yapılabilsin diye
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
                //8 bite tamamlamak için, eğer yukarıda çıkan 2 liğin uzunluğu 8 den azsa, geri kalanını sıfır yap 8 bite tamamla.
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
    
    //MARK: - [11111111,11111111,00000000,00000000] gelir, aynısı string olarak döner.
    func getSubnetMaskForByteList(_ subnetList:[Int64])->[String]{
        var returnetByteList = [String]()
        for i in subnetList{
            var stringItem = String(i)
            //yine 8 den az ise, 8 e tamamla 0 koyarak.
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
        // CIDR arayüzde gösterimi için, aralara nokta koy. bunu bir kez yapsın diye firstTime koşulu
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
    
    //MARK: - Gelen 11111111.0000000 vs, decimal string döndür.
    func getDecimalIPAdress(_ withSubnetIpAdress:String)->String{
        var decimalString = ""
        let binaryList = withSubnetIpAdress.split(separator: ".") //gelen binary listi . ya göre ayır.
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


extension VLSMResultViewController{
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
