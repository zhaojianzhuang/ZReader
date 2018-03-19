//
//  ZChapterModel.swift
//  ZJZReader
//
//  Created by jianzhuangzhao on 2018/3/16.
//  Copyright © 2018年 ZJZ. All rights reserved.
//

import UIKit

class ZChapterModel: NSObject {
    //    只读属性的构建
    private var _content = ""
    open var content:String {
        get {
            return _content
        }
        set {
            _content = newValue
            self.paginate(bounds: ZReaderConfig.default.effectiveFrame())
        }
    }
    //    title
    open var title:String = ""
    //    pageCount
    open var pageCount = 0
    //    pageArray, 存储当前页数里的range的length
    private var pageArray:Array<Int>=[]
    
    override init() {
        super.init()
    }
    
    init(content:String, title:String) {
        super.init()
        self.title = title
        self.content = content
        
    }
}

//MARK:- open
extension ZChapterModel {
    
    //    通过bounds将model内的内容进行处理, 分页
    func paginate(bounds:CGRect) -> Void {
        pageArray.removeAll()
        let attrStr = NSMutableAttributedString(string: content)
        let attributes = ZReaderUtilites.parser(config: ZReaderConfig.default)
        attrStr.setAttributes(attributes, range: NSRange(location: 0, length: attrStr.length) )
        let attrString = attrStr
        let frameSetter = CTFramesetterCreateWithAttributedString(attrString as CFAttributedString)
        let path = CGPath.init(rect: bounds, transform: nil)
        var currentOffset = 0
        var currentInnerOffset = 0
        var hasMorePages = true
        let preventDeadLoopsign = currentOffset
        var samePlaceRepeatCount = 0
        while hasMorePages {
            if preventDeadLoopsign == currentOffset {
                samePlaceRepeatCount = samePlaceRepeatCount + 1
            } else {
                samePlaceRepeatCount =  0
            }
            
            if samePlaceRepeatCount > 1 {
                if pageArray.count == 0 {
                    pageArray.append(currentOffset)
                } else {
                    let lastOffset = pageArray.last
                    if lastOffset != currentOffset {
                        pageArray.append(currentOffset)
                    }
                }
                break
            }
            pageArray.append(currentOffset)
            let frame = CTFramesetterCreateFrame(frameSetter,CFRangeMake(currentOffset, 0) , path, nil)
            let range  = CTFrameGetVisibleStringRange(frame)
            if range.location + range.length != attrString.length {
                currentOffset += range.length
                currentInnerOffset += range.length
            } else {
                hasMorePages = false
            }
        }
        pageCount = pageArray.count
    }
    //    通过页数获得内容
    func content(page:Int) -> String {
        let local = pageArray[page]
        
        var length = 0
        if page < (self.pageCount - 1) {
            length = pageArray[page + 1] - pageArray[page]
        } else {
            length = content.count - pageArray[page]
        }
        
        guard length >= 0 else {
            return ""
        }
        return content.z_range(location: local, length: length)
    }
}




