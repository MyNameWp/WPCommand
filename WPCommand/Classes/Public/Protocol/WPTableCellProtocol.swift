//
//  WPTableCellProtocol.swift
//  WPCommand
//
//  Created by WenPing on 2021/7/26.
//

import UIKit

private var WPitemPointer = "WPItemModelPointer"

public protocol WPTableCellProtocol: NSObjectProtocol, UITableViewCell {
    /// item模型创建时是什么item cell就会获得一个什么样的item
    var item: WPTableItem? { get set }
}

public extension WPTableCellProtocol {
    var item: WPTableItem? {
        get {
            return WPRunTime.get(self, &WPitemPointer)
        }
        set {
            return WPRunTime.set(self, newValue, &WPitemPointer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
