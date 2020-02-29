//
//  ExtensionUITableView.swift
//  34HWUITableViewFileManager
//
//  Created by Сергей on 24.02.2020.
//  Copyright © 2020 Sergei. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
    func reloadDataWithTransitionFade(duration: TimeInterval) {
        let transition = CATransition()
        transition.type = .fade
        transition.duration = duration
        self.layer.add(transition, forKey: "UITableViewReloadDataWithTransition")
        self.reloadData()
    }
}
