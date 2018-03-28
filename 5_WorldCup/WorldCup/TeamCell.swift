//
//  TeamCell.swift
//  WorldCup
//
//  Created by Reddy on 22/03/18.
//  Copyright © 2018 CleanHarbors. All rights reserved.
//

import UIKit

class TeamCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var teamLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var flagImageView: UIImageView!
    
    // MARK: - View Life Cycle
    override func prepareForReuse() {
        super.prepareForReuse()
        
        teamLabel.text = nil
        scoreLabel.text = nil
        flagImageView.image = nil
    }
}
