//
//  util.swift
//  Ecommerce
//
//  Created by Mobileware on 5/12/15.
//  Copyright (c) 2015 Ashwinkarthik Srinivasan. All rights reserved.
//

import Foundation

class Set<T : Equatable> {
    var items : [T] = []
    
    func add(item : T) {
        if !contains(items, {$0 == item}) {
            items.append(item)
        }
    }
}

struct Stack<T> {
    var items = [T]()
    mutating func push(item: T) {
        items.append(item)
    }
    mutating func pop() -> T {
        return items.removeLast()
    }
}
