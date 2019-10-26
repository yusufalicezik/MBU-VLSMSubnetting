//
//  VLSMViewController.swift
//  MBU-AgTasarimProje
//
//  Created by Yusuf ali cezik on 24.10.2019.
//  Copyright © 2019 Yusuf Ali Cezik. All rights reserved.
//

import UIKit
import SwiftyShadow

class VLSMViewController: UIViewController {

    @IBOutlet weak var agAdiTextField: UITextField!
    @IBOutlet weak var hostSayisiTextField: UITextField!
    @IBOutlet weak var ekleButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var hesaplaButton: UIButton!
    @IBOutlet weak var ipAddressTextField: UITextField!
    var dataList:[Ag] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        // Do any additional setup after loading the view.
    }
    func setupView(){
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
         UIApplication.shared.statusBarView?.backgroundColor = #colorLiteral(red: 0.2862745098, green: 0.5764705882, blue: 0.6588235294, alpha: 1)
         self.setNeedsStatusBarAppearanceUpdate()
        if self.dataList.count > 0{
            self.dataList.removeLast()
        }
    }

    @IBAction func ekleButtonClicked(_ sender: Any) {
        if let hostInt = Int(self.hostSayisiTextField.text!) {
            if !self.agAdiTextField.text!.isEmpty && !self.hostSayisiTextField.text!.isEmpty{
                self.dataList.append(Ag(agAdi: self.agAdiTextField.text!, hostSayisi: hostInt))
                self.dataList.sort { (ag1, ag2) -> Bool in
                    return ag1.hostSayisi > ag2.hostSayisi
                }
                self.tableView.reloadData()
            }
        }
    }
    @IBAction func hesaplaButtonClicked(_ sender: Any) {
        if !self.ipAddressTextField.text!.isEmpty && ipAdressFormat() && self.dataList.count > 0{
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ResultVC") as? ResultViewController
            self.dataList.append(Ag(agAdi: "", hostSayisi: 1))
            vc?.dataList = self.dataList
            vc?.ipAdress = self.ipAddressTextField.text!
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    func ipAdressFormat()->Bool{
        let firstSep = (self.ipAddressTextField.text?.split(separator: "/"))!
        let ipList = getIpAdressInt(String(firstSep[0]))
     
        return (ipList.count < 4) || (!(self.ipAddressTextField.text?.contains("/"))!) ? false : true
    }
    func getIpAdressInt(_ ipAdress:String)->[Int]{
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
extension VLSMViewController:UITableViewDelegate, UITableViewDataSource{
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
        if responds(to: Selector("statusBar")) {
            return value(forKey: "statusBar") as? UIView
        }
        return nil
    }
}
