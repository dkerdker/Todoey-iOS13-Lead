//
//  Category.swift
//  Todoey
//
//  Created by Dee Ker Khoo on 20/04/2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var colour: String = ""
    ////let array = Array<Int>()
    let items = List<Item>()
}
