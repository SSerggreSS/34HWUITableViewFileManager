//
//  FolderCell.swift
//  34HWUITableViewFileManager
//
//  Created by Сергей on 18.02.2020.
//  Copyright © 2020 Sergei. All rights reserved.
//

import UIKit

class FolderCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
