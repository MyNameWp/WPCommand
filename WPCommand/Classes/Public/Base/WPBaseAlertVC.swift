//
//  WPBaseAlertVC.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/7/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import RxSwift

class RwaBaseAlertVC: UIViewController {
    /// 垃圾桶
    public let disposeBag = DisposeBag()
    /// 蒙板
    public let grayView = UIButton()
    /// 开始动画时间
    public var startDuration : CGFloat { return 0.3}
    /// 结束动画时间
    public var endDuration : CGFloat { return 0.3}
    /// 蒙板颜色
    public var maskColor = UIColor.init(0, 0, 0,0.15)
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        show()
    }

    required init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
        view.backgroundColor = .clear
        initSubView()
        initSubViewLayout()
        observeSubViewEvent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 初始化试图
    public func initSubView(){
        
        grayView.backgroundColor = .clear
        view.addSubview(grayView)
        
    }
    /// 初始化视图布局
    public func initSubViewLayout(){
        grayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    /// 监听子控件事件
    public func observeSubViewEvent(){
        grayView.rx.tap.subscribe(onNext: {[weak self]in
            self?.dismiss()
        }).disposed(by: disposeBag)
    }
    /// 显示弹窗
    public final func show(){
        willShow()

        showToLoacton()
        UIView.animate(withDuration: TimeInterval(startDuration), animations: {[weak self]in
            self?.showToAnimates()
            self?.grayView.backgroundColor = self?.maskColor
            self?.view.layoutIfNeeded()
            
        }, completion: {[weak self] complete in
            if complete{
                self?.didShow()
            }
        })
    }
    /// 隐藏弹窗
    public final func dismiss(completeAnimate:(()->Void)?=nil){
        willDismiss()
        dismissToLocation()
        UIView.animate(withDuration: TimeInterval(endDuration), animations: {[weak self]in
            self?.grayView.backgroundColor = .clear
            self?.dismissToAnimates()
            self?.view.layoutIfNeeded()
        }, completion: {[weak self] complete in
            if complete,let self = self{
                
                completeAnimate != nil ? completeAnimate!() : print()
                self.didDismiss()
            }
        })
    }
    /// 子类重写弹出的结束位置
    public func showToLoacton(){}
    /// 子类重写收回的结束位置
    public func dismissToLocation(){}
    /// 子类重写 将要收回回掉
    public func willDismiss(){}
    /// 子类重写收回回掉
    public func didDismiss(){}
    /// 子类重写 将要显示回调
    public func willShow(){}
    /// 子类重写弹出后回掉
    public func didShow(){}
    /// 子类重写动画正在执信
    public func showToAnimates(){}
    /// 子类重写动画正在执行
    public func dismissToAnimates(){}

}