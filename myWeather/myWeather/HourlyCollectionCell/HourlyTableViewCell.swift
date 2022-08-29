//
//  HourlyTableViewCell.swift
//  myWeather
//
//  Created by M1 on 12.08.2022.
//

import UIKit

class HourlyTableViewCell: UITableViewCell {
    
    @IBOutlet var collectionView: UICollectionView!
    
    private var models = [Current]()

    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.register(WeatherCollectionViewCell.nib(), forCellWithReuseIdentifier: "WeatherCollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    static let identifier = "HourlyTableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "HourlyTableViewCell", bundle: nil)
    }
    
    func configure(with models: [Current]) {
        self.models = models
        collectionView.reloadData()
    }
}

extension HourlyTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeatherCollectionViewCell.identifier, for: indexPath) as! WeatherCollectionViewCell
        cell.configure(with: [models[indexPath.row]])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        models.count
    }
    
}

extension HourlyTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 100, height: 100)
    }
}
