//
//  LastTableViewController.swift
//  MBU-AgTasarimProje
//
//  Created by Yusuf ali cezik on 25.10.2019.
//  Copyright © 2019 Yusuf Ali Cezik. All rights reserved.
//

import UIKit

class AllResultsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var dataList = [AgResult]()
    override func viewDidLoad() {
        super.viewDidLoad()
        let value = UIInterfaceOrientation.landscapeRight.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        self.setNeedsStatusBarAppearanceUpdate()
        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}
extension AllResultsViewController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count-1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? AllResultsCell
        cell?.agAdiLabel.text = self.dataList[indexPath.row].agName
        cell?.hostSayisiLabel.text = self.dataList[indexPath.row].agHostSayisi
        cell?.baslangicIPLabel.text = self.dataList[indexPath.row].agBaslangicIp
        cell?.bitisIPLabel.text = self.dataList[indexPath.row].agBitisIp
        cell?.yayinAdresLabel.text = self.dataList[indexPath.row].agYayinAdresi
        cell?.altAgMaskesiLabel.text = self.dataList[indexPath.row].agAltAgMaskesi
        cell?.agAdresi.text = self.dataList[indexPath.row].agAgAdresi
        return cell!
    }
    
    
}
