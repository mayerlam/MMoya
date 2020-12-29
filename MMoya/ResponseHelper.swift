//
//  ResponseHelper.swift
//
//  Created by Mayer Lam on 2020/1/12.
//  Copyright © 2020 shootProj. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON

extension Response {
    
    func mapJSONWithExcetion() throws -> Any {
        guard let anyJson = try? self.mapJSON() else {
            throw SERVICE_ERROR
        }
        return anyJson
    }
    
    public func handle(
        codeKey : String = "code",
        dataKey : String = "data",
        msgKey  : String = "msg"
    ) throws -> (code: String, data: JSON, msg: String) {
        let anyJson = try self.mapJSONWithExcetion()
        let R = try JSON(anyJson).responseJsonHandleMaster(codeKey: codeKey, dataKey: dataKey, msgKey: msgKey)
        return R
    }
    
    @discardableResult
    func dataHandle(
        codeKey : String = "code",
        dataKey : String = "data",
        msgKey  : String = "msg",
        successStatus: String = "200"
    ) throws -> JSON {
        
        let R = try self.handle(codeKey: codeKey, dataKey: dataKey, msgKey: msgKey)

        guard R.code == successStatus else {
            throw DebugerError.CLIENT_ERROR(code: R.code, msg: R.msg)
        }
        
        return R.data
    }
    
    func toDictinaryObject() throws -> [String: Any] {
        let data = try dataHandle()
        let dict = try data.toDictionaryObject()
        return dict
    }
    
    func toDictionary() throws -> [String: JSON] {
        let data = try dataHandle()
        let dict = try data.toDictionary()
        return dict
    }
}

private extension JSON {
    
    /// 返回数据做统一处理
    /// - Parameter json: 传入的json数据
    func responseJsonHandleMaster(
        codeKey : String = "code",
        dataKey : String = "data",
        msgKey  : String = "msg"
    ) throws -> (code: String, data: JSON, msg: String) {
        
        //  获取code代码
        guard let code = (self[codeKey].int)?.description ?? self[codeKey].string else {
            throw SERVICE_ERROR
        }
        
        let msg = try self.toString(key: msgKey)
        let data = self[dataKey]
        return (code, data, msg)
    }
}
