//
//  MapView.swift
//  CodeTest
//
//  Created by Alvis on 25/6/2021.
//

import UIKit
import MapKit
import FlexLayout
import PinLayout

class MapView: BView, MKMapViewDelegate {
    let rootFlexContainer = UIView()
    
    var mySearchView: BView = BView()
    var mySearchTextBGView: BView = BView()
    var mySearchTextField: UITextField = UITextField()
    var myMapView: MKMapView = MKMapView()
    var myMapBottomSpaceView: BView = BView()
    
    override func setupUI() {
        super.setupUI()
        
        setupSearchView()
        setupSearchTextBGView()
        setupSearchTextField()
    }
    
    private func setupSearchView() {
//        self.mySearchView.backgroundColor = .blue
    }
    
    private func setupSearchTextBGView() {
        self.mySearchTextBGView.layer.cornerRadius = 8
    }
    private func setupSearchTextField() {
        self.mySearchTextField.placeholder = "Search"
    }
    
    // renew
    
    func renewMapViewBottom(bottom: CGFloat) {
        myMapBottomSpaceView.flex.height(bottom)
        rootFlexContainer.flex.layout()
    }
    
    func renewMapPins(historModelArray: [HistoryModel]) {
        self.removeMapAllPin()
        // Pin
        historModelArray.forEach {
            
            if let aLat = $0.weather?.coord?.lat,
               let aLon = $0.weather?.coord?.lon {
                var aStringArray: [String] = []
                if let aName = $0.weather?.name {
                    var aString = aName
                    $0.weather?.weather?.forEach {
                        if let aWeatherDescription = $0.weatherDescription {
                            aString.append(", " + aWeatherDescription)
                        }
                    }
                    aStringArray.append(aString)
                }
                
                aStringArray.append("\(aLat), \(aLon)")
                
                let aString = aStringArray.joined(separator:"\n")
                
                let aMyPointAnnotation = MKPointAnnotation()
                aMyPointAnnotation.coordinate = CLLocationCoordinate2D.init(latitude: aLat, longitude: aLon)
                aMyPointAnnotation.title = aString
                self.myMapView.addAnnotation(aMyPointAnnotation)
            }
        }
        
        self.myMapView.showAnnotations(self.myMapView.annotations, animated: true)
    }
    
    func moveToPin(historyModel: HistoryModel? = nil) {
        var isExit = false
        self.myMapView.annotations.forEach {
            if historyModel?.weather?.locationCoordinate2D == $0.coordinate && !isExit {
                self.myMapView.showAnnotations([$0], animated: true)
                isExit = true
            }
        }
    }
    
    func removeMapAllPin() {
        self.myMapView.removeAnnotations(self.myMapView.annotations)
    }
    
    // setupAutoLayout
    
    override func setupAutoLayout() {
        super.setupAutoLayout()
        
        rootFlexContainer.flex.direction(.column).define { (flex1) in
            flex1.addItem(mySearchView).direction(.row).padding(10).alignItems(.center).define { (flex2) in
                flex2.addItem(mySearchTextBGView).direction(.row).alignItems(.center).grow(1).backgroundColor(UIColor.gray.withAlphaComponent(0.3)).define { (flex3) in
                    flex3.addItem(mySearchTextField).height(30).marginHorizontal(10).marginVertical(4).grow(1)
                }
            }
            
            flex1.addItem(myMapView).backgroundColor(.white).shrink(1).grow(1)
            flex1.addItem(myMapBottomSpaceView).height(0)
        }
        addSubview(rootFlexContainer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        rootFlexContainer.pin.top(pin.safeArea).horizontally().bottom(pin.safeArea)
        rootFlexContainer.flex.layout()
    }
}
