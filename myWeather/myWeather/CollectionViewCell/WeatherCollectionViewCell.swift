//
//  WeatherCollectionViewCell.swift
//  myWeather
//
//  Created by M1 on 18.08.2022.
//

import UIKit

class WeatherCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "WeatherCollectionViewCell"
    
    static func nib() -> UINib {
        UINib(nibName: "WeatherCollectionViewCell", bundle: nil)
    }
    
    @IBOutlet private var iconImageView: UIImageView!
    @IBOutlet private var tempLabel: UILabel!
    @IBOutlet private var timeLabel: UILabel!
    
    func configure(with model: [Current]) {
        if let temp = model.first?.temp {
            tempLabel.text = "\(Int(temp))°"
        }
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.image = UIImage(named: "clear sky")
        if let time = model.first?.dt {
            timeLabel.text = "\(getDayForDate(Date(timeIntervalSince1970: Double(time))))"
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func getDayForDate(_ date: Date?) -> String {
        guard let inputDate = date else { return "" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = .init(identifier: "en_US_POSIX")
        return formatter.string(from: inputDate)
    }

}
