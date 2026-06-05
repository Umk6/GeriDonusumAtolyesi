//
//  ObjectPool.swift
//  GeriDonusumAtolyesi
//
//  Object pooling için generic pool
//

import Foundation

class ObjectPool<T> {
    private var pool: [T] = []
    private let createNew: () -> T
    private let maxSize: Int

    init(maxSize: Int = 50, factory: @escaping () -> T) {
        self.maxSize = maxSize
        self.createNew = factory
    }

    func get() -> T {
        if pool.isEmpty {
            return createNew()
        } else {
            return pool.removeLast()
        }
    }

    func `return`(_ object: T) {
        if pool.count < maxSize {
            pool.append(object)
        }
    }

    func clear() {
        pool.removeAll()
    }

    var count: Int {
        return pool.count
    }
}
