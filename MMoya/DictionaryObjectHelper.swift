//
//  DictionaryObjectHelper.swift
//
//  Created by Mayer Lam on 2020/1/12.
//  Copyright © 2020 shootProj. All rights reserved.
//

import Foundation
import ObjectMapper

typealias DictionaryObject = [String: Any]

extension DictionaryObject {
    func json(with key: String) throws -> Any {
        if let any = self[key] {
            return any
        } else {
            throw SERVICE_ERROR
        }
    }

    func createInstance<T: Mappable>() throws -> T {
        if let obj = T.init(JSON: self) {
            return obj
        } else {
            throw SERVICE_ERROR
        }
    }
}
