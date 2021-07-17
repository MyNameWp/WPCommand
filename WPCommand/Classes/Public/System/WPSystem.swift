//
//  WPSystem.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/7/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation
import Photos
import CoreTelephony
import RxCocoa
import RxSwift

/// 默认View边距
public let wp_viewEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: -16, right: -16)
/// 屏幕尺寸
public let wp_Screen = UIScreen.main.bounds
/// 导航栏高度
public var wp_navigationHeight : CGFloat =  UIApplication.shared.statusBarFrame.size.height + UINavigationController().navigationBar.frame.size.height
/// 安全距离
public let wp_safeAreaI = wp_isFullScreen ? UIEdgeInsets(top: 44.0, left: 0.0, bottom: 34.0, right: 0.0) : UIEdgeInsets.zero
/// 是否是刘海屏
public var wp_isFullScreen: Bool{
    if #available(iOS 11, *) {
          guard let w = UIApplication.shared.delegate?.window, let unwrapedWindow = w else {
              return false
          }

          if unwrapedWindow.safeAreaInsets.left > 0 || unwrapedWindow.safeAreaInsets.bottom > 0 {
              print(unwrapedWindow.safeAreaInsets)
              return true
          }
    }
    return false
}


open class WPSystem: NSObject {
    
    /// 垃圾桶
    let disposeBag = DisposeBag()

    /// 单例
   public static var share : WPSystem = {
       let manager = WPSystem()
       return manager
    }()
    
    /// 键盘相关
    let keyboard : WPSystem.keyBoard = .init()

    /// 键盘
    public struct keyBoard {
        /// 键盘将要显示通知
        public let willShow : BehaviorRelay<Notification?> = .init(value: nil)
        /// 键盘已经显示通知
        public let didShow : BehaviorRelay<Notification?> = .init(value: nil)
        /// 键盘将要收回通知
        public let willHide : BehaviorRelay<Notification?> = .init(value: nil)
        /// 键盘已经收回通知
        public let didHide : BehaviorRelay<Notification?> = .init(value: nil)
        /// 键盘高度改变通知
        public let willChangeFrame : BehaviorRelay<Notification?> = .init(value: nil)
        /// 键盘高度已经改变通知
        public let didChangeFrame : BehaviorRelay<Notification?> = .init(value: nil)
    }


    public override init() {
        super.init()
        
        // 监听键盘即将弹出通知
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification).skip(1).bind(to: keyboard.willShow).disposed(by: disposeBag)
        
        // 监听键盘以及弹出通知
        NotificationCenter.default.rx.notification(UIResponder.keyboardDidShowNotification).skip(1).bind(to: keyboard.willShow).disposed(by: disposeBag)
        
        // 监听键盘即将收回通知
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification).skip(1).bind(to: keyboard.willHide).disposed(by: disposeBag)
        
        // 监听键盘已经收回通知
        NotificationCenter.default.rx.notification(UIResponder.keyboardDidHideNotification).skip(1).bind(to: keyboard.didHide).disposed(by: disposeBag)
        
        // 键盘高度即将改变通知
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillChangeFrameNotification).skip(1).bind(to: keyboard.willChangeFrame).disposed(by: disposeBag)
        
        // 键盘高度已经改变通知
        NotificationCenter.default.rx.notification(UIResponder.keyboardDidChangeFrameNotification).skip(1).bind(to: keyboard.didChangeFrame).disposed(by: disposeBag)
        

    }
}


public extension WPSystem{
    
    /// 打开系统设置页面
    func pushSystemController(){
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
        }
    }
    
    
    /// 拨打电话
    /// - Parameters:
    ///   - phone: 电话
    ///   - failed: 拨打失败
    func callPhone(phone:String,failed:(()->Void)? = nil){
        let phoneStr = "tel://" + phone.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
        if let phoneURL = URL(string: phoneStr), UIApplication.shared.canOpenURL(phoneURL) {
             UIApplication.shared.openURL(phoneURL)
        }else{
            failed != nil ? failed!() : print("")
        }
    }
    
    /// 检测是否开启定位权限
    /// - Parameters:
    ///   - open: 开启
    ///   - close: 关闭
    /// - Returns: 是否开启
    func isOpenLocation(open:(()->Void)?=nil,close:(()->Void)?=nil){
        let authStatus = CLLocationManager.authorizationStatus()
        let resault = (authStatus != .restricted && authStatus != .denied)
        if resault {
            open != nil ? open!() : print()
        }else{
            close != nil ? close!() : print()
        }
    }
    
    /// 检测是否开启相册权限
    /// - Parameters:
    ///   - open: 开启
    ///   - close: 关闭
    /// - Returns: 是否开启
    func isOpenAlbum(open:(()->Void)?=nil,close:(()->Void)?=nil){
        let authStatus = PHPhotoLibrary.authorizationStatus()
        let resault = (authStatus != .restricted && authStatus != .denied)
        
         if authStatus == .notDetermined {
            if #available(iOS 14, *){
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                    
                    DispatchQueue.main.async {
                        if status == .authorized || status == .limited{
                            open != nil ? open!() : print()
                        }else{
                            close != nil ? close!() : print()
                        }
                    }
                }
            }  else{
                PHPhotoLibrary.requestAuthorization { status in
                    DispatchQueue.main.async {
                        if status == .authorized{
                            open != nil ? open!() : print()
                        }else{
                            close != nil ? close!() : print()
                        }
                    }
                }
            }
         }else{
            if resault {
                open != nil ? open!() : print()
            }else{
                close != nil ? close!() : print()
            }
         }
    }
    
    /// 判断是否有打开相机权限
    /// - Parameters:
    ///   - open: 打开
    ///   - close: 关闭
    /// - Returns: 结果
    func isOpenCamera(open:(()->Void)?=nil,close:(()->Void)?=nil){

        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        let resault = (authStatus == .authorized)

        if resault {
            open != nil ? open!() : print("")
        }else if authStatus == .notDetermined{
            AVCaptureDevice .requestAccess(for: .video, completionHandler: { granted in
                if granted{
                    DispatchQueue.main.async {
                        open != nil ? open!() : print("")
                    }
                }else{
                    DispatchQueue.main.async {
                        close != nil ? close!() : print("")
                    }
                }
            })
        }else{
            close != nil ? close!() : print("")
        }
    }
    
    /// 是否打开网络
    /// - Parameters:
    ///   - open: 打开
    ///   - close: 关闭
    func isOpenNet(open:(()->Void)?=nil,close:(()->Void)?=nil){
        let mainThreeOpen = {
            DispatchQueue.main.sync {
                open != nil ? open!() : print()
            }
        }
        
        let mainThreeClose = {
            DispatchQueue.main.sync {
                close != nil ? close!() : print()
            }
        }
        
        let cellularData = CTCellularData()
        cellularData.cellularDataRestrictionDidUpdateNotifier = { (state) in
            if state == CTCellularDataRestrictedState.restrictedStateUnknown ||  state == CTCellularDataRestrictedState.notRestricted {
                mainThreeClose()
            } else {
                mainThreeOpen()
            }
        }
        let state = cellularData.restrictedState
        if state == CTCellularDataRestrictedState.restrictedStateUnknown ||  state == CTCellularDataRestrictedState.notRestricted {
            mainThreeClose()
        } else {
            mainThreeOpen()
        }
    }
}

