//
//  MMoya.swift
//  TARtest
//
//  Created by Mayer Lam on 2020/3/9.
//  Copyright © 2020 Mayer Lam. All rights reserved.
//

import Foundation
import Moya

public protocol FaildProtocol {}

/// 设置测试的模式
public enum DebugMode {
    
    /// always:通透模式
    ///
    /// 不会请求任何网络，始终采用提供的测试数据直接运行
    case always
    
    /// auto: 自动模式
    ///
    /// 如果程序遇到数据捕捉错误，则会采用提供的测试数据替代运行
    case auto
    
    /// option:选项模式
    ///
    /// 如果程序遇到数据捕捉错误，则会弹出警告框
    /// 一共有三个选项，取消|日志|测试运行
    ///
    /// 取消：将按正常流程继续运行。
    /// 日志：跳转到错误日志
    /// 继续测试：使用测试数据继续运行
    case option
    
    /// never: 永远不用测试数据
    ///
    /// 程序将按正常流程运行
    case never
    
    /// shutdown: 关闭debuger
    ///
    /// 和never的区别在于，设置shutdown后
    /// 无法被某个实例对debugmode的设置覆盖
    /// 也就是debuger功能被永远关闭
    /// 在正式发布程序的时候，应该设置此一项
    ///
    /// 程序将按正常流程运行
    case shutdown
}

public var DEBUG_MODE: DebugMode = .shutdown

/// 这是一个方便开发人员进行测试的工具
/// 需要配合moya使用
///
/// 用来避免由于网络请求失败导致的程序中断
/// 开发人员可以使用这个工具，去忽略大部分的网络错误
/// 以便于对整个流程或者某个功能点进行测试
/// 在这之前，我建议你最好先对某个接口的功能完整性进行测试，然后再开启这个工具
///
/// usage:
/// 需要在全局环境中设置一个变量 例：public let DEBUG_MODE: DebugMode = .never
/// 然后，简单的 let myMoya = MMoya(sampleData: {()->someType}) { code } 就可以完成初始化
///
/// 设置错误处理的闭包
/// myMoya.setFaild { code }
///
/// 设置响应处理闭包
/// myMoya.setHandler { code }
///
/// 运行
/// myMoya.run(request: somerequest))
///
class MMoya<T> {
    
    /// debug模式
    ///
    /// 分类可以查看DebugMode的详细说明
    /// 可以设置一个全局变量DEBUG_MODE，作用于这个程序
    ///
    /// 也可以单独设置实例的这个属性，以覆盖全局的设置(除了shutdown)
    ///
    var debugMode : DebugMode {
        
        get {
            DEBUG_MODE == .shutdown ? DEBUG_MODE : _debugMode
        }
        
        set {
            _debugMode = newValue
        }
    }
    
    /// 开启这个开关，可以自动记录开始请求以及接受到回应的时间
    var markTimeEnable: Bool = false
    
    /// 局部的debug模式，默认与全局模式一致
    /// 可以通过设置上面的debugMode，来间接设置这个变量
    /// 但是并不会完全取到这个变量的值，要视全局的设置而定
    private lazy var _debugMode: DebugMode = DEBUG_MODE
    
    /// 网络请求错误时，将会使用这个错误信息
//    var netFaild : Error?
    
    /// 网络请求的结果
    private var response : Response?
    
    /// 样本数据A
    /// 其返回值为成功结果的测试数据
    ///
    /// 在初始化的时候，应该设置这一项
    /// 在数据获取不到，或者无效的时候，可以使用这个数据进行替代运行
    ///
    private var sampleDataA : (() -> T)
    
    /// 样本数据B
    /// 其返回值为失败结果的测试数据
    ///
    /// 这个数据只在option模式下有效
    /// 在数据获取不到，或者无效的时候
    /// option会提供两种测试数据提供用户选择
    ///
    private var sampleDataB : (() -> Error)?
    
    /// 对请求的处理闭包
    ///
    /// 返回值是一个元组
    /// 如果处理结果是成功的，应该设置元组的第一个值，第二个值保持nil，反则亦然
    ///
    private var handlerClosure : ((_ response: Response) throws -> T)?
    
    /// 错误处理闭包
    ///
    /// 由用户设置具体的内容
    /// 其参数是由handler返回的元组的第二个值
    ///
    private lazy var failderClosure : (_ faild: Error) -> () = {_ in }
    
    /// 成功的处理闭包
    ///
    /// 由用户设置具体的内容
    /// 其参数是由handler返回的元组的第——个值
    ///
    private var successClosure : (_ result: T)->()
    
    /// 初始化的时候，只提供成功结果的样本数据
    /// 以及对成功数据的处理方式
    ///
    /// - Parameter sampleData: 样本数据
    /// - Parameter success: 处理闭包
    init(sampleData: @escaping () -> T, successClosure: @escaping (_ result: T)->()) {
        self.sampleDataA = sampleData
        self.successClosure = successClosure
    }
    
    /// 初始化的时候，提供同时成功结果的样本数据和失败结果的样本数据
    /// - Parameter a: 成功样本数据
    /// - Parameter b: 失败样本数据
    /// - Parameter success: 处理成功结果的闭包
    init(
        sampleData a    : @escaping () -> T,
        _ b             : @escaping () -> Error,
        successClosure  : @escaping (_ result: T)->()) {
        
        self.sampleDataA = a
        self.sampleDataB = b
        self.successClosure = successClosure
    }
}

extension MMoya {
    
    /// 通过一定的初始化的设置后，执行这个函数
    /// 根据当前优先的设置，以确定是否执行请求以及如果处理请求的结构
    ///
    /// - Parameter request: 请求
    func run<T: TargetType>(_ request: T, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) {
        
        //MARK: 模式为always
        if self.debugMode == .always {
            //  不请求网络，直接使用样本数据
            useSampleDataA()
        } else {
            
            let group = DispatchGroup()
            
            group.enter()
            
            if markTimeEnable {
                markTime("\n\n################# Request Begin #################")
            }
            
            MoyaProvider<T>().request(request, callbackQueue: callbackQueue, progress: progress) {
                
                if self.markTimeEnable {
                    markTime("\n\n################# Request End #################")
                }
                
                switch $0 {
                case let .success(response):
                    self.response = response
                default:
                    break
                }
                group.leave()
            }
            
            group.notify(queue: .main) {
                
                switch self.debugMode {
                case .auto:
                    self._debuger_auto()
                case .option:
                    self._debuger_option(request)
                case .never, .shutdown:
                    self._debuger_never()
                default:
                    break
                }
            }
        }
    }

    /// 设置对响应的处理
    ///
    /// - Parameter handler: 处理闭包
    func setHandler(_ handler: @escaping (_ response: Response) throws -> T) {
        self.handlerClosure = handler
    }
    
    /// 设置对响应错误的处理
    /// - Parameter failder: 处理闭包
    func setFaild(_ failder: @escaping (_ faild: Error) -> ()) {
        self.failderClosure = failder
    }
    
    /// auto模式的处理
    ///
    /// 先判断当前请求是否成功，如果没有则使用样本数据
    ///
    private func _debuger_auto() {
        
        guard
            let _handle = handlerClosure,
            let _response = response
        else {
            useSampleDataA()
            return
        }
        
        do {
            //  获取请求数据，并且交由处理闭包处理，得到返回值
            let result = try _handle(_response)
            // 使用成功结果处理闭包处理成功数据
            successClosure(result)
        } catch {
            //  否则使用样本数据
            useSampleDataA()
        }
    }
    
    /// option模式的处理
    ///
    /// 先判断当前请求是否成功
    /// 如果不成功，则弹出警告框，让用户选择执行的方式
    ///
    /// - Parameter target: 捕捉当前的请求
    private func _debuger_option(_ target: TargetType) {
        
        guard
            let _handle = handlerClosure,
            let _response = response
        else {
            let alert = debugerMsgBox(log: "网络请求错误") {
                self.userNetFaild()
            }
            
            showDebugerMsgBox(alert: alert)
            return
        }

        do {
            //  获取请求数据，并且交由处理闭包处理，得到返回值
            let result = try _handle(_response)
            // 使用成功结果处理闭包处理成功数据
            successClosure(result)
        } catch {
            
//            let _faild = catchError(error)
            let logMsg =
                "服务器错误\n\n" +
                "apiPath : \(target.path)\n" +
                "response: \((try? _response.mapString()) ?? "" )"
            
            let alert = debugerMsgBox(log: logMsg) {
                self.failderClosure(error)
            }
            showDebugerMsgBox(alert: alert)
        }
    }
    
//    func catchError(_ error: Error) -> G {
//        print(error)
//        let err = error as! G
//        return err
//    }
    
    /// never模式的处理
    private func _debuger_never() {
        
        guard
            let _handle = handlerClosure,
            let _response = response
        else {
            userNetFaild()
            return
        }

        do {
            //  获取请求数据，并且交由处理闭包处理，得到返回值
            let result = try _handle(_response)
            // 使用成功结果处理闭包处理成功数据
            successClosure(result)
        } catch {
//            let _faild = catchError(error)
            failderClosure(error)
        }
    }
}

extension MMoya {
    
    /// 使用成功样本数据
    private func useSampleDataA() {
        let data = sampleDataA()
        successClosure(data)
    }
    
    /// 使用网络错误处理
    private func userNetFaild() {
        failderClosure(NETWORK_ERROR)
    }
    
    /// option模式下弹出警告框
    /// - Parameter alert: 警告控制器
    private func showDebugerMsgBox(alert: UIAlertController) {
        
        // 获取顶层视图
        guard let vc = getTopVC() else {
            return
        }
        vc.showMsgBox(alertController: alert)
    }
    
    /// 构造警告框
    /// - Parameter log: 日志信息
    /// - Parameter handler: 正常流程执行的闭包
    private func debugerMsgBox(log: String, handler: @escaping ()->()) -> UIAlertController {

        /// 创建“取消”选项
        let cancelAction = createAction("取消", .cancel) { (_) in
            //  点击取消则按照正常流程运行
            handler()
        }

        /// 创建“日志”选项
        let logAction = createAction("查看日志", .default) { (_) in
            guard let vc = getTopVC() else {
                return
            }
            //  跳转到日志显示页面
        vc.navigationController?.pushViewController(LogViewController(log: log), animated: true)
    
            print(log)
        }

        var actions = [logAction, cancelAction]

        /// 如果失败样本数据被设置，则提供两个测试数据选项
        if let _faild = self.sampleDataB {

            /// 创建测试数据1选项
            let testAction1 = createAction("使用测试数据1运行", .destructive) { (_) in
                self.useSampleDataA()
            }

            /// 创建测试数据2
            let testAction2 = createAction("使用测试数据2运行", .destructive) { (_) in
                self.failderClosure(_faild())
            }
            actions.insert(testAction2, at: 0)
            actions.insert(testAction1, at: 0)

        } else {

            /// 创建测试数据
            let testAction = createAction("使用测试数据运行", .destructive) { (_) in
                self.useSampleDataA()
            }
            actions.insert(testAction, at: 0)
        }

        /// 创建警告控制器
        let alert = createMsgBox(_message: "已开启Debug模式\n可通过以下选项，忽略错误继续运行", _title: "遇到了错误", acitons: actions)
        return alert
    }
}

func markTime(_ log: String = "") {
    print("\(log)\ntimestamp: \(Date().timeIntervalSince1970)\n\n")
}
