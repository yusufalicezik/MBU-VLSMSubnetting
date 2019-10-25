//
//  VLSMViewController.swift
//  MBU-AgTasarimProje
//
//  Created by Yusuf ali cezik on 24.10.2019.
//  Copyright © 2019 Yusuf Ali Cezik. All rights reserved.
//

import UIKit

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
        self.agAdiTextField.layer.cornerRadius = 5
        self.hostSayisiTextField.layer.cornerRadius = 5
        self.hostSayisiTextField.layer.cornerRadius = 5
        self.ekleButton.layer.cornerRadius = 10
        self.ipAddressTextField.layer.cornerRadius = 10
        self.hesaplaButton.layer.cornerRadius = 10

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         UIApplication.shared.statusBarView?.backgroundColor = #colorLiteral(red: 0.05490196078, green: 0.1607843137, blue: 0.2274509804, alpha: 1)
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
