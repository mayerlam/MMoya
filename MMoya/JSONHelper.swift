//
//  JSONHelper.swift
//  ShaGuaJi
//
//  Created by Mayer Lam on 2020/1/12.
//  Copyright © 2020 shootProj. All rights reserved.
//

import Foundation
import SwiftyJSON
import ObjectMapper

enum DebugerError: Error, FaildProtocol  {
    case SERVICE_ERROR
    case NETWORK_ERROR
    case CLIENT_ERROR(code: String, msg: String)
}

let SERVICE_ERROR = DebugerError.SERVICE_ERROR
let NETWORK_ERROR = DebugerError.NETWORK_ERROR

extension JSON {
    
    /// 将JSON转为JSON数组
    func toArray() throws -> [JSON] {
        if let array = self.array {
            return array
        } else {
            throw SERVICE_ERROR
        }
    }
    
    /// 用键值获取JSON数组
    /// - Parameter key: 键值
    func toArray(key: String) throws -> [JSON] {
        if let array = self[key].array {
            return array
        } else {
            throw SERVICE_ERROR
        }
    }
    
    /// 用键值获取JSON中的整型值
    /// - Parameter key: 键值
    func toInt(key: String) throws -> Int {
        if let number = self[key].int {
            return number
        } else {
            throw SERVICE_ERROR
        }
    }
    
    /// 将JSON转为整型
    func toInt() throws -> Int {
        if let number = self.int {
            return number
        } else {
            throw SERVICE_ERROR
        }
    }

    /// 将JSON转为字符串
    func toString() throws -> String {
        if let number = self.string {
            return number
        } else {
            throw SERVICE_ERROR
        }
    }
    /// 用键值获取JSON中的字符串
    /// - Parameter key: 键值
    func toString(key: String) throws -> String {
        if let number = self[key].string {
            return number
        } else {
            throw SERVICE_ERROR
        }
    }
    
    /// 将JSON转为值为JSON的字典
    func toDictionary() throws -> [String: JSON] {
        if let dict = self.dictionary {
            return dict
        } else {
            throw SERVICE_ERROR
        }
    }
    
    /// 将JSON转为值为Any的字典
    func toDictionaryObject() throws -> DictionaryObject {
        if let dict = self.dictionaryObject {
            return dict
        } else {
            throw SERVICE_ERROR
        }
    }
    
    /// 通过键值将JSON转为值为JSON的字典
    /// - Parameter key: 键值
    func toDictionaryObject(key: String) throws -> DictionaryObject {
        if let dict = self[key].dictionaryObject {
            return dict
        } else {
            throw SERVICE_ERROR
        }
    }
    
    /// 将JSON实例化对象
    func createInstance<T: Mappable>() throws -> T {
        let json = try self.toDictionaryObject()
        let obj: T = try json.createInstance()
        return obj
    }
    
    /// 通过键值将JSON实例化对象
    func createInstance<T: Mappable>(JSONKey: String) throws -> T {
        let json = try self.toDictionaryObject(key: JSONKey)
        let obj: T = try json.createInstance()
        return obj
    }
}
