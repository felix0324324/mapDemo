//
//  HouseCell.swift
//  CodeTest
//
//  Created by Alvis on 22/6/2021.
//

import UIKit
import PinLayout
import FlexLayout

class HouseCell: UITableViewCell {
    static let reuseIdentifier = "MethodCell"
    fileprivate let padding: CGFloat = 10
    
    fileprivate let nameLabel = UILabel()
//    fileprivate let descriptionLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        separatorInset = .zero
        
        let iconImageView = UIImageView(image: UIImage(named: "method"))
        iconImageView.backgroundColor = .red
        
        nameLabel.font = UIFont.boldSystemFont(ofSize: 14)
//        nameLabel.backgroundColor = .green
        nameLabel.numberOfLines = 0

        // Use contentView as the root flex container
        contentView.flex.padding(padding).define { (flex) in
            flex.addItem().direction(.row).define { (flex) in
                flex.addItem(iconImageView).size(30)
                flex.addItem(nameLabel).marginLeft(padding) .grow(1)
            }

            // flex.addItem(descriptionLabel).marginTop(padding)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func renewUI(historyModel: HistoryModel) {
        var aStringArray: [String] = []
        if let aIndex = historyModel.index {
            aStringArray.append("Index : \(aIndex)")
        }
        
        if let aWeather = historyModel.weather {
            if let aName = aWeather.name {
                aStringArray.append("Name : \(aName)")
            }
            if let aLat = aWeather.coord?.lat, let aLon = aWeather.coord?.lon {
                aStringArray.append("Lat : \(aLat), Lon : \(aLon)")
            }
            if let aWeatherArray = aWeather.weather {
                aWeatherArray.forEach {
                    if let aMain = $0.main {
                        aStringArray.append("Main : \(aMain)")
                    }
                    if let aWeatherDescription = $0.weatherDescription {
                        aStringArray.append("Description : \(aWeatherDescription)")
                    }
                }
            }
        }
        
        if let aDate = historyModel.date {
            aStringArray.append(DateHelper.convertDateToString(fromDate: aDate, to: .yyyymmddHHmm_Chinese))
        }
        
        let aString = aStringArray.joined(separator:"\n")
        self.renewNameLabel(string: aString)
        self.renewNameLabelColor(hexString: historyModel.hexColorString)
    }
    
    private func renewNameLabel(string: String) {
        nameLabel.text = string
        nameLabel.flex.markDirty()
        // nameLabel.textColor = .black
        setNeedsLayout()
    }
    
    private func renewNameLabelColor(hexString: String? = nil) {
        if let aHex = hexString {
            self.nameLabel.textColor = UIColor(hex: aHex)
        } else {
            self.nameLabel.textColor = .black
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    fileprivate func layout() {
        contentView.flex.layout(mode: .adjustHeight)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        // 1) Set the contentView's width to the specified size parameter
        contentView.pin.width(size.width)
        
        // 2) Layout contentView flex container
        layout()
        
        // Return the flex container new size
        return contentView.frame.size
    }
}
