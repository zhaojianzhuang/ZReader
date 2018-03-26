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

class ZParserUtilties:NSObject {
    //   config
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
    
    //     config bounds 获得frame
    class func parser(content:String, config:ZReaderConfig, bounds:CGRect) -> CTFrame {
        let attributeString = NSMutableAttributedString(string: content)
        let attributes = self.parser(config: config)
        attributeString.setAttributes(attributes, range: NSRange(location: 0, length: attributeString.length))
        let frameSetter = CTFramesetterCreateWithAttributedString(attributeString)
        let path = CGPath(rect: bounds, transform: nil)
        let frameR = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, nil)
        return frameR
    }
    
    //    给定一个长按的点 得到选中的rect
    class func parser(point:CGPoint, selectRange: inout NSRange, frameR:CTFrame) ->CGRect {
        let path = CTFrameGetPath(frameR)
        let bounds = path.boundingBox
        let linesO = CTFrameGetLines(frameR) as? Array<CTLine>
        var rect = CGRect(x: 0, y: 0, width: 0, height: 0)
        guard let lines = linesO else {
            return rect
        }
        
        let count = lines.count;
        if count > 0 {
            var originsArray = [CGPoint](repeating: CGPoint(x: 0, y: 0 ), count: count)
            CTFrameGetLineOrigins(frameR, CFRangeMake(0, 0), &originsArray)
            for i in 0..<count {
                let linePoint = originsArray[i]
                let line = lines[i]
                var ascent:CGFloat = 0
                var descent:CGFloat = 0
                var lineGap:CGFloat = 0
                let lineWidth = CTLineGetTypographicBounds(line, &ascent, &descent, &lineGap)
                let lineFrame = CGRect(x: linePoint.x, y: bounds.height - linePoint.y - ascent, width: CGFloat(lineWidth), height: ascent + descent + lineGap + ZReaderConfig.default.lineSpace)
                if lineFrame.contains(point) {
                    let stringRange = CTLineGetStringRange(line)
                    let index = CTLineGetStringIndexForPosition(line, point)
                    var start = CTLineGetOffsetForStringIndex(line, index, nil)
                    var end:CGFloat = 0
                    if index > stringRange.location + stringRange.length - 2 {
                        end = start
                        start = CTLineGetOffsetForStringIndex(line, index - 2, nil)
                        selectRange.location = index - 2
                    } else {
                        selectRange.location = index
                    }
                    selectRange.length = 2
                    rect = CGRect(x: originsArray[i].x + start, y: linePoint.y - descent, width: fabs(start - end), height: ascent + descent)
                    break
                }
            }
        }
        return rect
    }
    
    class func parser(point:CGPoint, frameR:CTFrame) -> CFIndex {
        var index = -1
        let path = CTFrameGetPath(frameR)
        let bounds = path.boundingBox
        let linesO = CTFrameGetLines(frameR) as? Array<CTLine>
        guard let lines = linesO else {
            return index
        }
        let count = lines.count
        var origins = [CGPoint](repeating: CGPoint(x: 0, y: 0 ), count: count)
        if count > 0 {
            CTFrameGetLineOrigins(frameR, CFRangeMake(0, 0), &origins)
            for i in 0..<count {
                let linePoint = origins[i]
                let line = lines[i]
                var ascent:CGFloat = 0
                var descent:CGFloat = 0
                var lineGap:CGFloat = 0
                let lineWidth = CTLineGetTypographicBounds(line, &ascent, &descent, &lineGap)
                let lineFrame = CGRect(x: linePoint.x, y: bounds.height - linePoint.y - ascent, width: CGFloat(lineWidth), height: ascent + descent + lineGap + ZReaderConfig.default.lineSpace)
                if lineFrame.contains(point) {
                    index = CTLineGetStringIndexForPosition(line, point)
                    break
                }
            }
        }
        return index
    }
    
    class func parser(point:CGPoint, range:inout NSRange, frameR:CTFrame, path:Array<CGRect>,  direction:ZPanDirection) -> Array<CGRect> {
        var index = -1
        let linesO = CTFrameGetLines(frameR) as? Array<CTLine>
        guard let lines = linesO else {
            return path
        }
        let count = lines.count
        var origins = [CGPoint](repeating: CGPoint.zero, count: count)
        index = parser(point: point, frameR: frameR)
        if index == -1 {
            return path
        }
        if direction == .right   {
            
            if !(index > range.location) {
                range.length = range.location - index + range.length
                range.location = index
            } else {
                range.length = index - range.location
            }
        } else {
            if (!(index > range.location + range.length)) {
                range.length = range.location - index + range.length;
                range.location = index;
            }
        }
        var rectArray = [CGRect]()
        if count > 0 {
            CTFrameGetLineOrigins(frameR, CFRangeMake(0, 0), &origins)
            for i in 0..<count {
                let linePoint = origins[i]
                let line = lines[i]
                var ascent:CGFloat = 0
                var descent:CGFloat = 0
                var lineGap:CGFloat = 0
                CTLineGetTypographicBounds(line, &ascent, &descent, &lineGap)
                let stringRange = CTLineGetStringRange(line)
                let drawRange = selected(selectedRange: NSMakeRange(range.location, range.length) , lineRange: NSMakeRange(stringRange.location, stringRange.length))
                if drawRange.length > 0 {
                    let start = CTLineGetOffsetForStringIndex(line, drawRange.location, nil)
                    let end = CTLineGetOffsetForStringIndex(line, drawRange.location + drawRange.length, nil)
                    let rect = CGRect(x: start, y: linePoint.y - descent, width: fabs(start - end), height: ascent + descent)
                    if rect.height == 0 || rect.width == 0  {
                        continue
                    }
                    rectArray.append(rect)
                }
            }
        }
        return rectArray
    }
    
    class func selected(selectedRange:NSRange, lineRange:NSRange) -> NSRange {
        var selectedRange = selectedRange
        var lineRange = lineRange
        var range = NSRange(location: NSNotFound, length: 0)
        if lineRange.location > selectedRange.location {
            let tmp = lineRange
            lineRange = selectedRange
            selectedRange = tmp
        }
        if selectedRange.location < lineRange.location + lineRange.length {
            range.location = selectedRange.location
            
            range.length = min(selectedRange.location+selectedRange.length, lineRange.location+lineRange.length) - range.location
        }
        return range
    }
    
}

class ZReaderUtilites: NSObject {
    
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

