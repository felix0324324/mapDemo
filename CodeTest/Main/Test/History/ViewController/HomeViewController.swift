//
//  TestViewController.swift
//  CodeTest
//
//  Created by Alvis on 22/6/2021.
//

import UIKit
import RxCocoa
import RxSwift
import INTULocationManager
import FittedSheets

class HomeViewController : ViewController, UITableViewDelegate {
    // Block
    var myNewLocationCallBack : ((CLLocation?, Bool) -> Void)?
    var myMoveLocationCallBack : ((CLLocation) -> Void)?
//    var myRemoveLocationCallBack : ((HistoryModel) -> Void)?
//    var myRemoveAllLocationCallBack : (() -> Void)?
    var myUpdatedLocationsCallBack : (([HistoryModel]) -> Void)?
    
    // Data
    var myLocationID: Int = 0
    let myLocationManager = INTULocationManager.sharedInstance()
    var myItems = BehaviorRelay<[HistoryModel]>(value: [])
    
    // View
    var myHomeView: HomeView = HomeView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view = myHomeView
        
        loadCachedData()
        
        myHomeView.myTableView.register(HouseCell.self, forCellReuseIdentifier: HouseCell.reuseIdentifier)
        
        myItems.bind(to: myHomeView.myTableView.rx.items(cellIdentifier: HouseCell.reuseIdentifier, cellType: HouseCell.self)) { (row, element, cell) in
            cell.renewUI(historyModel: element)
            cell.backgroundColor = row % 2 == 0 ? UIColor.gray.withAlphaComponent(0.5) : UIColor.white
        }.disposed(by: disposeBag)
        
        
        myHomeView.myTableView.rx
            .modelSelected(HistoryModel.self)
            .subscribe(onNext:  { value in
                if let aCrood = value.weather?.coord,
                   let aLat = aCrood.lat,
                   let aLon = aCrood.lon {
                    let aCLLocation = CLLocation.init(latitude: aLat, longitude: aLon)
                    self.myNewLocationCallBack?(aCLLocation, false)
                }
                // DefaultWireframe.presentAlert("Tapped `\(value.weather?.name ?? "")`")
            }).disposed(by: disposeBag)
        
        myHomeView.myTableView.rx
            .itemDeleted
            .subscribe(onNext: { [unowned self] indexPath in
                // For update map pins
                
                // Remove item
                self.myItems.remove(at: indexPath.row)
                
                self.myUpdatedLocationsCallBack?(self.myItems.value)
//                self.myNewLocationCallBack?(self.myItems.value)
            }).disposed(by: disposeBag)
        
        self.myHomeView.myDeleteAllButton.bk_addEventHandler({ _ in
            // Remove all map pins
//            self.myRemoveAllLocationCallBack?()
            
            // Rmove All Items
            self.myItems.removeAll()
            
            // Update Values
            self.myUpdatedLocationsCallBack?(self.myItems.value)
            
            // Save myItems Value
            StorageManager.saveModelArray(storageKey: .HistoryLocations, model: self.myItems.value)
        }, for: .touchUpInside)
        
        self.myHomeView.myAddButton.bk_addEventHandler({ _ in
            print("clicked myAddButton ")
            self.myLocationManager.cancelLocationRequest(self.myLocationID)
            self.myLocationID = self.myLocationManager.requestLocation(withDesiredAccuracy: .house, desiredActivityType: .fitness, timeout: 1, delayUntilAuthorized: false) { [weak self] (location, accu, status) in
                 self?.myNewLocationCallBack?(location, true)
            }
            
        }, for: .touchUpInside)
    }
    
    private func loadCachedData() {
        if let aArray = StorageManager.loadModelArray(storageKey: .HistoryLocations,
                                                      model: HistoryModel.self) {
            self.myItems.accept(aArray)
            
            // Update all map pins
            self.myUpdatedLocationsCallBack?(self.myItems.value)
        }
    }
    
    func addedItems(weatherMainModel: WeatherMainModel? = nil) -> HistoryModel? {
        if let aModel = weatherMainModel {
            let aIndex = (self.myItems.value.last?.index ?? 0) + 1
            let aColorHex = String(format: "%06X", Int(arc4random() % 65535))
            let aModel = HistoryModel(index: aIndex, weather: aModel, hexColorString: aColorHex)
            self.myItems.insert(aModel, at: self.myItems.value.count)
            
            // Save myItems Value
            StorageManager.saveModelArray(storageKey: .HistoryLocations, model: self.myItems.value)
            
            // Scroll To Last
            let aRow = self.myItems.value.count - 1
            self.myHomeView.myTableView.scrollToRow(at: .init(row: aRow, section: 0), at: .middle, animated: true)
            return aModel
        }
        return nil
    }
    
}

