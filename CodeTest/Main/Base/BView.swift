//
//  BView.swift
//
//  Created by Sunny Yeung on 2/9/2020.
//  Copyright © 2018年 Sunny Yeung. All rights reserved.
//

import UIKit
import FlexLayout
import PinLayout
import BlocksKit

public protocol BUIProtocol {
    func setupUI()
    func updateUI()
    func setupAutoLayout()
    func releaseMemory()
}

extension UIView: BUIProtocol {
    @objc public func setupUI() { }
    @objc public func updateUI() { }
    @objc public func setupAutoLayout() { }
    @objc public func releaseMemory() { }
}

open class BView: UIView {
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
        setupAutoLayout()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupAutoLayout()
    }
    
    deinit {
        print("deinit \(self)")
        // releaseMemory()
    }
    
    // MARK: - Open Function
    open override func setupUI() {
        backgroundColor = .white
    }
}
