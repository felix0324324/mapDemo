//
//  HomeView.swift
//  CodeTest
//
//  Created by Alvis on 23/6/2021.
//

import UIKit
import FlexLayout
import BlocksKit
import PinLayout

class HomeView: BView {
    let rootFlexContainer = UIView()
    
    var myTableView: UITableView = UITableView()
    let myFlex1View = UIView()
    let myDeleteAllButton = UIButton()
    let myAddButton = UIButton()
    
    override func setupUI() {
        super.setupUI()
        
        setupTableView()
        self.myDeleteAllButton.setTitle("Delete All", for: .normal)
        self.myDeleteAllButton.layer.cornerRadius = 6
        self.myAddButton.setTitle("Current", for: .normal)
        self.myAddButton.layer.cornerRadius = 6
        
        rootFlexContainer.flex.direction(.column).define { (flex1) in
            
            flex1.addItem(myFlex1View).direction(.row).alignItems(.center).define { (flex2) in
                flex2.addItem().direction(.row).padding(10).justifyContent(.spaceAround).grow(1).backgroundColor(.white).define { (flex3) in
                    flex3.addItem(myDeleteAllButton).height(40).grow(1).backgroundColor(.gray).marginRight(5)
                    flex3.addItem(myAddButton).height(40).grow(1).backgroundColor(.gray).marginLeft(5)
                }
            }
            flex1.addItem(myTableView).shrink(1).grow(1)
        }
        addSubview(rootFlexContainer)
    }
    
    private func setupTableView() {
        self.myTableView.separatorStyle = .none
        self.myTableView.separatorColor = .clear
        self.myTableView.alwaysBounceVertical = false
        self.myTableView.bounces = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        rootFlexContainer.pin.top(pin.safeArea).horizontally().bottom(pin.safeArea)
        rootFlexContainer.flex.layout()
    }
}


