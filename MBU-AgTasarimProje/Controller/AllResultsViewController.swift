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
    @IBAction func pdfButton(_ sender: Any) {
        self.saveAsPDF()
        print("kaydedildi")
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
    
    
    func saveAsPDF(){
        createPdfFromTableView()
    }
    func createPdfFromTableView()
    {
        //let text = "Alt Ağlara Bölme Sonuçları"
        let url:URL = URL(string: "www.whatsa.com.tr")!
        let imgOfScreen = UIApplication.shared.screenShot

        
        let vc = UIActivityViewController(activityItems: [imgOfScreen!,url], applicationActivities: [])
        if let popoverController = vc.popoverPresentationController{
            popoverController.sourceView = self.view
            popoverController.sourceRect = self.view.bounds
        }
        self.present(vc, animated: true, completion: nil)
        
        
//        let priorBounds: CGRect = self.tableView.bounds
//        let fittedSize: CGSize = self.tableView.sizeThatFits(CGSize(width: priorBounds.size.width, height: self.tableView.contentSize.height))
//        self.tableView.bounds = CGRect(x: 0, y: 0, width: fittedSize.width, height: fittedSize.height)
//        self.tableView.reloadData()
//        let pdfPageBounds: CGRect = CGRect(x: 0, y: 0, width: fittedSize.width, height: (fittedSize.height))
//        let pdfData: NSMutableData = NSMutableData()
//        UIGraphicsBeginPDFContextToData(pdfData, pdfPageBounds, nil)
//        UIGraphicsBeginPDFPageWithInfo(pdfPageBounds, nil)
//        self.tableView.layer.render(in: UIGraphicsGetCurrentContext()!)
//        UIGraphicsEndPDFContext()
//        
//        let fileManager = FileManager.default
//        do {
//            let documentDirectory  = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//            let documentsFileName = documentDirectory.absoluteString + "/" + "denemePDF2"
//            pdfData.write(toFile: documentsFileName, atomically: true)
//            print(documentsFileName)
//        } catch {
//            print(error)
//        }
        
        
    }
}
extension UIApplication {
    
    var screenShot: UIImage?  {
        
        if let layer = keyWindow?.layer {
            let scale = UIScreen.main.scale
            
            UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
            if let context = UIGraphicsGetCurrentContext() {
                layer.render(in: context)
                let screenshot = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                return screenshot
            }
        }
        return nil
    }
}
