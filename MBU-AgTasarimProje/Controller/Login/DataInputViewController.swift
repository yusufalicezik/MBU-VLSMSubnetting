//
//  VLSMViewController.swift
//  MBU-AgTasarimProje
//
//  Created by Yusuf ali cezik on 24.10.2019.
//  Copyright © 2019 Yusuf Ali Cezik. All rights reserved.
//

import UIKit
import SwiftyShadow

enum CalculatingType{
    case VLSM
    case FLSM
}
class DataInputViewController: UIViewController {

    @IBOutlet weak var agAdiTextField: UITextField!
    @IBOutlet weak var hostSayisiTextField: UITextField!
    @IBOutlet weak var ekleButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var hesaplaButton: UIButton!
    @IBOutlet weak var ipAddressTextField: UITextField!
    @IBOutlet weak var headerTitleLabel: UILabel!
    
    private var dataList:[Ag] = []
    public var calculatingType:CalculatingType = .VLSM //Default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        // Do any additional setup after loading the view.
    }
    func setupView(){
        
        switch self.calculatingType {
        case .VLSM:
            self.headerTitleLabel.text = "Değişken Alt Ağlara Bölme"
            print("VLSM Selected")
        default: //FLSM
            self.headerTitleLabel.text = "Sabit Alt Ağlara Bölme"
           print("FLSM selected")
        }
        
        
        self.agAdiTextField.layer.cornerRadius = 7
        self.hostSayisiTextField.layer.cornerRadius = 7
        self.hostSayisiTextField.layer.cornerRadius = 7
        self.ekleButton.layer.cornerRadius = 10
        self.ipAddressTextField.layer.cornerRadius = 10
        self.hesaplaButton.layer.cornerRadius = 10

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        
        
        self.agAdiTextField.layer.shadowRadius = 7
        self.agAdiTextField.layer.shadowOpacity = 0.10
        self.agAdiTextField.layer.shadowColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        self.agAdiTextField.layer.shadowOffset = CGSize.zero
        self.agAdiTextField.generateOuterShadow()
        
        self.hostSayisiTextField.layer.shadowRadius = 7
        self.hostSayisiTextField.layer.shadowOpacity = 0.10
        self.hostSayisiTextField.layer.shadowColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        self.hostSayisiTextField.layer.shadowOffset = CGSize.zero
        self.hostSayisiTextField.generateOuterShadow()
        
        self.ipAddressTextField.layer.shadowRadius = 7
        self.ipAddressTextField.layer.shadowOpacity = 0.14
        self.ipAddressTextField.layer.shadowColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        self.ipAddressTextField.layer.shadowOffset = CGSize.zero
        self.ipAddressTextField.generateOuterShadow()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden  = true
         UIApplication.shared.statusBarView?.backgroundColor = #colorLiteral(red: 0.2862745098, green: 0.5764705882, blue: 0.6588235294, alpha: 1)
         self.setNeedsStatusBarAppearanceUpdate()
        if self.dataList.count > 0{
            self.dataList.removeLast()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden  = false
    }

    @IBAction func ekleButtonClicked(_ sender: Any) {
        if let hostInt = Int(self.hostSayisiTextField.text!) {
            if !self.agAdiTextField.text!.isEmpty && !self.hostSayisiTextField.text!.isEmpty{
                self.dataList.append(Ag(agAdi: self.agAdiTextField.text!, hostSayisi: hostInt))
                self.dataList.sort { (ag1, ag2) -> Bool in
                    return ag1.hostSayisi > ag2.hostSayisi
                }
                self.tableView.reloadData()
                self.agAdiTextField.text = ""
                self.hostSayisiTextField.text = ""
            }
        }
    }
    
    @IBAction func hesaplaButtonClicked(_ sender: Any) {
        if !self.ipAddressTextField.text!.isEmpty && ipAdressFormat() && self.dataList.count > 0{
            switch self.calculatingType {
            case .VLSM:
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ResultVC") as? VLSMResultViewController
                    self.dataList.append(Ag(agAdi: "", hostSayisi: 1))
                    vc?.dataList = self.dataList
                    vc?.ipAdress = self.ipAddressTextField.text!
                    self.navigationController?.pushViewController(vc!, animated: true)
            default: //FLSM
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ResultVCFLSM") as? FLSMResultViewController
                    self.dataList.append(Ag(agAdi: "", hostSayisi: 1))
                    vc?.dataList = self.dataList
                    vc?.ipAdress = self.ipAddressTextField.text!
                    self.navigationController?.pushViewController(vc!, animated: true)
            }
        }
    }
    
    func ipAdressFormat()->Bool{
        let firstSep = (self.ipAddressTextField.text?.split(separator: "/"))! //ör: 192.168.1.1 / 16
        let ipList = getIpAdressInt(String(firstSep[0])) // 192.168.1.1
        return (ipList.count < 4) || (!(self.ipAddressTextField.text?.contains("/"))!) ? false : true
    }
    
    func getIpAdressInt(_ ipAdress:String)->[Int]{ //tüm oktetleri parçalayıp, integera dönüştürüp, liste halinde döndürür
        let resultIPListString = ipAdress.split(separator: ".")
        let resultIPList = resultIPListString.map({
            Int($0)
        })
        return resultIPList as! [Int]
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    
}
extension DataInputViewController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = Bundle.main.loadNibNamed("AgInfoCell", owner: self, options: nil)?.first as? AgInfoCell else {return UITableViewCell()}
        cell.agAdiLabel.text = self.dataList[indexPath.row].agAdi
        cell.hostSayisiLabel.text = String(self.dataList[indexPath.row].hostSayisi)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.dataList.remove(at: indexPath.row)
            self.tableView.reloadData()
        }
    }
    
    
}
extension UIApplication {
   var statusBarView: UIView? {
      if #available(iOS 13.0, *) {
          let tag = 38482
          let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first

          if let statusBar = keyWindow?.viewWithTag(tag) {
              return statusBar
          } else {
              guard let statusBarFrame = keyWindow?.windowScene?.statusBarManager?.statusBarFrame else { return nil }
              let statusBarView = UIView(frame: statusBarFrame)
              statusBarView.tag = tag
              keyWindow?.addSubview(statusBarView)
              return statusBarView
          }
      } else if responds(to: Selector(("statusBar"))) {
          return value(forKey: "statusBar") as? UIView
      } else {
          return nil
      }
    }
}
