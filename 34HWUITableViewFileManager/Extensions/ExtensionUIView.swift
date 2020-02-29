//
//  ExtensionUIView.swift
//  34HWUITableViewFileManager
//
//  Created by Сергей on 18.02.2020.
//  Copyright © 2020 Sergei. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func superCell() -> UITableViewCell? {

        if self.superview == nil {
            return nil
        }
        
        if self.superview?.isKind(of: UITableViewCell.self) ?? false {
            return self.superview as? UITableViewCell
        }
        
        return self.superview?.superCell()
    }
    
}
