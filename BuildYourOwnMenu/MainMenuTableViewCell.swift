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
        itemImageView.addImage(data: imageData)
        itemLabel.text = name
        if let priceText = price {
            itemPriceLabel.text = priceText
            itemPriceLabel.isHidden = false
        } else {
            itemPriceLabel.isHidden = true
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension UIImageView {
    func addImage(data: Data?) {
        if let imageData = data {
            DispatchQueue.global(qos: .background).async {
                let imageFetched = UIImage(data: imageData)
                DispatchQueue.main.async {[weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.image = imageFetched
                }
            }
        }
    }
}
