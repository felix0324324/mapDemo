//
//  MapView.swift
//  CodeTest
//
//  Created by Alvis on 25/6/2021.
//

import UIKit
import RxCocoa
import RxSwift
import INTULocationManager
import FittedSheets
import BlocksKit

class MapViewController : ViewController {
//    var myHistoryModel: HistoryModel?
    static let kPullBarHeight: CGFloat = 24
    
    private let myHomeViewController = HomeViewController()
    private let myMapView: MapView = MapView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view = myMapView
        
        self.setupTextField()
        
        self.myHomeViewController.myNewLocationCallBack = { location, addRecord in
            if let aCoordinate = location?.coordinate {
                self.callAPIWeather(latLon: aCoordinate, addRecord: addRecord)
            }
        }
        
        self.myHomeViewController.myUpdatedLocationsCallBack = { historyModelArray in
            self.myMapView.renewMapPins(historModelArray: historyModelArray)
            self.myMapView.moveToPin(historyModel: historyModelArray.last)
        }
        
        self.myHomeViewController.myHomeView.rx
            .observe(CGRect.self, #keyPath(UIView.bounds))
            .debounce(.milliseconds(50), scheduler: MainScheduler.instance)
            .subscribe(onNext: {
                self.myMapView.renewMapViewBottom(bottom: $0?.height ?? 0)
            })
            .disposed(by: disposeBag)
        // Show Sheet
        self.showSheetViewController()
    }
    
    private func setupTextField() {
        self.myMapView.mySearchTextField.rx
            .controlEvent([.editingChanged, .valueChanged])
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] _ in
                let aText = self.myMapView.mySearchTextField.text ?? ""
                print("Updated Text : \(aText)")
                // self.myMapView.renewDescriptionView(model: nil)
                if aText.count > 0 {
                    if let aZip = Int(aText) {
                        self.callAPIWeather(zip: aZip, addRecord: true)
                    } else {
                        self.callAPIWeather(q: aText, addRecord: true)
                    }
                }
            }).disposed(by: disposeBag)
    }
    
    // Common
    
    private func showSheetViewController() {
        
        let options = SheetOptions(
            // The full height of the pull bar. The presented view controller will treat this area as a safearea inset on the top
            pullBarHeight: Self.kPullBarHeight,
            
            // The corner radius of the shrunken presenting view controller
            presentingViewCornerRadius: 20,
            
            // Extends the background behind the pull bar or not
            shouldExtendBackground: true,
            
            // Attempts to use intrinsic heights on navigation controllers. This does not work well in combination with keyboards without your code handling it.
            setIntrinsicHeightOnNavigationControllers: false,
            
            // Pulls the view controller behind the safe area top, especially useful when embedding navigation controllers
            useFullScreenMode: true,
            
            // Shrinks the presenting view controller, similar to the native modal
            shrinkPresentingViewController: true,
            
            // Determines if using inline mode or not
            useInlineMode: true,
            
            // Adds a padding on the left and right of the sheet with this amount. Defaults to zero (no padding)
            horizontalPadding: 0,
            
            // Sets the maximum width allowed for the sheet. This defaults to nil and doesn't limit the width.
            maxWidth: nil
        )
        
        let aHeight = options.pullBarHeight + myHomeViewController.myHomeView.rootFlexContainer.flex.intrinsicSize.height
        let sheet = SheetViewController(
            controller: myHomeViewController,
            sizes: [.fixed(aHeight),
                    .percent(0.25),
                    .percent(0.5),
                    .fullscreen],
            options: options)
        sheet.allowPullingPastMaxHeight = false
        sheet.allowPullingPastMinHeight = false
        
        sheet.dismissOnPull = false
        sheet.dismissOnOverlayTap = false
        sheet.overlayColor = UIColor.clear
        
        sheet.contentViewController.view.layer.shadowColor = UIColor.black.cgColor
        sheet.contentViewController.view.layer.shadowOpacity = 0.1
        sheet.contentViewController.view.layer.shadowRadius = 10
        sheet.allowGestureThroughOverlay = true
        
        sheet.handleScrollView(myHomeViewController.myHomeView.myTableView)
       
        sheet.animateIn(to: view, in: self, size: .fixed(0), duration: 0) {
            // Done Animate
            sheet.animateIn(size: sheet.sizes.first, duration: 0.3, completion: nil)
        }
    }
    
    // Call API
    func callAPIWeather(q: String? = nil, zip: Int? = nil, latLon: CLLocationCoordinate2D? = nil, addRecord: Bool = false) {
        // self.myMapView.renewDescriptionView()
        var aWeatherRequestModel = WeatherRequestModel()
        aWeatherRequestModel.q = q
        aWeatherRequestModel.appid = "95d190a434083879a6398aafd54d9e73"
        if let aZip = zip {
            aWeatherRequestModel.zip = String(aZip) // "94040,us"
        }
        aWeatherRequestModel.lang = "zh_tw"
        if let aLatlon = latLon {
            aWeatherRequestModel.lat = String(aLatlon.latitude)
            aWeatherRequestModel.lon = String(aLatlon.longitude)
        }
        APIManager.weather(model: aWeatherRequestModel) { [weak self] result in
            switch result {
            case .Success(let model):
                print("Search Success : \(model.kj.JSONString(prettyPrinted: true))")
                
                if addRecord {
                    if let aHistory = self?.myHomeViewController.addedItems(weatherMainModel: model) {
                        self?.myMapView.renewMapPins(historModelArray: self?.myHomeViewController.myItems.value ?? [])
                        self?.myMapView.moveToPin(historyModel: aHistory)
                    }
                } else if let aLatlon = latLon,
                          let aHistory = self?.myHomeViewController.myItems.value.filter({ (aHistory) -> Bool in
                            aHistory.weather?.locationCoordinate2D == aLatlon
                          }).first {
                    self?.myMapView.moveToPin(historyModel: aHistory)
                }
            default:
                break
            }
            
        }
    }
    
    
}
