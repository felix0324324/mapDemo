//
//  BucketList.swift
//  CodeTest
//
//  Created by Alvis on 22/6/2021.
//

import Foundation

struct BucketList: ModelProtocol {
    public var name: String?
    public var date: Date?
    public var completed: Bool? // = false
    public var givenUp: Bool?// = false
}
