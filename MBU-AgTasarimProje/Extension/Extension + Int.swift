//
//  Extension + Int.swift
//  MBU-AgTasarimProje
//
//  Created by Yusuf ali cezik on 25.10.2019.
//  Copyright © 2019 Yusuf Ali Cezik. All rights reserved.
//

import Foundation
extension Int{
    func getExp(exp:Int)->Int{
        var result = self
        if exp == 0{
            result = 1
        }else{
            for _ in 1..<exp{
                result *= self
            }
        }
        return result
    }
}
