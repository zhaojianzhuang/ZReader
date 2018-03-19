//
//  ZReaderUtilites.swift
//  ZJZReader
//
//  Created by jianzhuangzhao on 2018/3/16.
//  Copyright © 2018年 ZJZ. All rights reserved.
//

import UIKit
// swift 4.0 substring 已经被废弃, array支持切片, 利用切片实现之前的substring
extension String {
    
    func z_range(nsRange:NSRange) -> String {
        let range = Range(nsRange, in: self)
        guard let _ = range else {
            return ""
        }
        return z_range(range: range!)
    }
    
    func z_range(location:Int, length:Int) -> String {
        let nsRange = NSMakeRange(location, length)
        return  z_range(nsRange: nsRange)
    }
    
    func z_range(range:Range<String.Index>) -> String {
        return String(self[range])
    }
}


class ZReaderUtilites: NSObject {
    class func parser(config:ZReaderConfig) -> Dictionary<NSAttributedStringKey, Any> {
        var dict = Dictionary<NSAttributedStringKey, Any>()
        dict[NSAttributedStringKey.font] = UIFont.systemFont(ofSize: config.fontSize)
        dict[NSAttributedStringKey.foregroundColor] = config.fontColor
        //        dict[NSAttributedStringKey.backgroundColor] = config.themeColor
        let paragraph =  NSMutableParagraphStyle()
        paragraph.lineSpacing = config.lineSpace
        paragraph.alignment = NSTextAlignment.justified
        dict[NSAttributedStringKey.paragraphStyle] = paragraph
        return dict
    }
    
    class func parser(content:String, config:ZReaderConfig, bounds:CGRect) -> CTFrame {
        let attributeString = NSMutableAttributedString(string: content)
        let attributes = self.parser(config: config)
        attributeString.setAttributes(attributes, range: NSRange(location: 0, length: attributeString.length))
        let frameSetter = CTFramesetterCreateWithAttributedString(attributeString)
        let path = CGPath(rect: bounds, transform: nil)
        let frameR = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, nil)
        return frameR
    }
    
//    拿到分章节
    class func separator(content:String, chapters:inout Array<ZChapterModel>) -> Void {
        chapters.removeAll()
        let pattern = "第[0-9一二三四五六七八九十百千]*[章回].*"
        
        do {
            let regular =  try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
            let matchs = regular.matches(in: content, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSRange(location: 0, length: content.count))
            
            var lastRange = NSMakeRange(0, 0)
            
            guard matchs.count != 0  else {
                let chapterModel = ZChapterModel()
                chapterModel.content = content
                chapters.append(chapterModel)
                return
            }
            
            for (offset, result) in matchs.enumerated() {
                let range = result.range
                let local = range.location
                let chapterModel = ZChapterModel()

                if offset == 0 {
                    chapterModel.title = "开始"
                    let length = local
                    chapterModel.content = content.z_range(location: 0, length: length)
                }
                if offset > 0 {
                    chapterModel.title = content.z_range(nsRange: lastRange)
                    let length = local - lastRange.location
                    chapterModel.content =  content.z_range(location: lastRange.location, length: length)
                    print(chapterModel.title)
                }
                if offset == matchs.count - 1 {
                    chapterModel.title = content.z_range(location: local, length: range.length)
                    chapterModel.content = content.z_range(location: local, length: content.count - local - 1)
                }
                
                chapters.append(chapterModel)
                lastRange = range
            }
            
        } catch{
            print(error)
        }
    }
//    处理content url
    class func encode(url:URL?) -> String {
        guard let _ = url  else {
            return ""
        }
        var content = try? String(contentsOf: url!, encoding: String.Encoding.utf8)
        if content == nil {
            content = try? String(contentsOf: url!, encoding: String.Encoding(rawValue: 0x80000632))
        }
        if content == nil {
            content = try? String(contentsOf: url!, encoding: String.Encoding(rawValue: 0x80000631))
        }
        
        return content!
    }
    
    
}

