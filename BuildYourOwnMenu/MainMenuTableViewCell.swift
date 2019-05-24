//
//  MainMenuTableViewCell.swift
//  BuildYourOwnMenu
//
//  Created by Balakumaran Srirangaswamy on 5/22/19.
//  Copyright © 2019 Bala. All rights reserved.
//

import UIKit

class MainMenuTableViewCell: UITableViewCell {

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupCell(name: String?, price: String?, imageData: Data?) {
        itemLabel.text = name
        if let priceText = price {
            itemPriceLabel.text = priceText
            itemPriceLabel.isHidden = false
        } else {
            itemPriceLabel.isHidden = true
        }
        if let imgData = imageData {
            DispatchQueue.global(qos: .background).async {
                let image = UIImage(data: imgData)
                DispatchQueue.main.async {[unowned self] in
                    self.itemImageView.image = image
                }
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
