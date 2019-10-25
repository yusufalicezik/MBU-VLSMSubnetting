//
//  AllResultsCell.swift
//  MBU-AgTasarimProje
//
//  Created by Yusuf ali cezik on 25.10.2019.
//  Copyright © 2019 Yusuf Ali Cezik. All rights reserved.
//

import UIKit

class AllResultsCell: UITableViewCell {

    @IBOutlet weak var agAdiLabel: UILabel!
    @IBOutlet weak var hostSayisiLabel: UILabel!
    @IBOutlet weak var baslangicIPLabel: UILabel!
    @IBOutlet weak var bitisIPLabel: UILabel!
    @IBOutlet weak var yayinAdresLabel: UILabel!
    @IBOutlet weak var altAgMaskesiLabel: UILabel!
    @IBOutlet weak var agAdresi: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
