//
//  ZReaderConfig.swift
//  ZJZReader
//
//  Created by jianzhuangzhao on 2018/3/16.
//  Copyright © 2018年 ZJZ. All rights reserved.
//

import UIKit

let SCREEN_WIDTH:CGFloat = UIScreen.main.bounds.size.width
let SCREEN_HEIGHT:CGFloat = UIScreen.main.bounds.size.height

//配置信息
class ZReaderConfig: NSObject {
    
    //    单利
    static let `default` = ZReaderConfig()
    
    //    边距
    open var topMargin:CGFloat = 20
    open var leftMargin:CGFloat = 10
    open var rightMargin:CGFloat = 10
    open var bottomMargin:CGFloat = 20
    
    //    字体大小
    open var fontSize:CGFloat = 14
    //    边距
    open var lineSpace:CGFloat = 10
    //    字体颜色
    open var fontColor = UIColor.red
    //    主题的颜色
    open var themeColor = UIColor.cyan
    
    //    阅读view有效的frame
    func effectiveFrame() -> CGRect {
        return CGRect(x: leftMargin, y: topMargin, width: SCREEN_WIDTH - leftMargin - rightMargin, height: SCREEN_HEIGHT - topMargin - bottomMargin)
    }
    //    阅读view有效的bounds
    func effectiveBounds() -> CGRect {
        return CGRect(x: 0, y: 0, width: SCREEN_WIDTH - leftMargin - rightMargin, height: SCREEN_HEIGHT - topMargin - bottomMargin)
    }
}

