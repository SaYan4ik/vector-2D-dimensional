//
//  RealmManager.swift
//  vector-2D-dimensional
//
//  Created by Александр Янчик on 15.03.25.
//

import Foundation
import RealmSwift

class RealmManager {
    private let realm = try! Realm()
    static var shared = RealmManager()
    
    func write<T: Object> (_ object: T) {
        try? realm.write {
            realm.add(object)
        }
    }
    
    func update(realmBlock: @escaping (Realm) -> Void) {
        try? realm.write {
            realmBlock(realm)
        }
    }
    
    func read<T: Object>(ofType: T.Type) -> [T] {
        return Array(realm.objects(T.self))
    }
    
    func delete(object: VectorModel) {
        try? realm.write {
            realm.delete(object)
        }
    }
}
