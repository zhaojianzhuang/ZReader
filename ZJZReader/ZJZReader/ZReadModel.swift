//
//  ZReadModel.swift
//  ZJZReader
//
//  Created by jianzhuangzhao on 2018/3/16.
//  Copyright © 2018年 ZJZ. All rights reserved.
//

import UIKit
//章节
struct PageParameter {
    var chapter:Int = 0
    var page:Int = 0
    mutating func set(parameter:PageParameter) -> Void {
        set(chapter: parameter.chapter, page: parameter.page)
    }
    
    mutating func set(chapter:Int, page:Int) -> Void {
        set(chapter: chapter)
        set(page:page)
    }
    
    mutating func set(chapter:Int) -> Void {
        self.chapter = chapter
    }
    
    mutating func set(page:Int) -> Void {
        self.page = page
    }
}


class ZReadModel: NSObject {
    //    内容
    open var content:String = ""

    //    页码参数
    open var currentPage = PageParameter(chapter: 0, page: 0)
    
    var chapterCount:Int {
        get{
            return chapters.count
        }
    }
    //    章节的数组
    private var chapters:Array<ZChapterModel> = []
    
    //    MARK:- init
    init(content:String) {
        self.content = content
        ZReaderUtilites.separator(content: content, chapters: &chapters)
        super.init()
    }
    
    convenience init(url:URL) {
        self.init(content: ZReaderUtilites.encode(url: url))
    }
    
}
//MARk:- open
extension ZReadModel {
    
    //   下一页的章节以及页码 并不会改变内部currenPage的值
    func parameterAfter() -> PageParameter? {
        return parameterAfter(currentChapter: currentPage.chapter, currentPage: currentPage.page)
    }
    
    //    上一页的章节以及页码 并不会改变内部currenPage的值
    func parameterBefore() -> PageParameter? {
        return  parameterBefore(currentChapter: currentPage.chapter, currentPage: currentPage.page)
    }
    //    获取章节model
    func chapter(chapter:Int) -> ZChapterModel? {
        guard effectiveArgs(chapterN: chapter, pageN: 0) else {
            return nil
        }
        return self.chapters[chapter]
    }
    
    func currentContent() -> String? {
        return content(chapter: currentPage.chapter, page: currentPage.page)
    }
}
//MARK:- private
private extension ZReadModel {
    
    
    //    传入章节的页码是否有效
    func effectiveArgs(parameter:PageParameter) -> Bool {
        return effectiveArgs(chapterN: parameter.chapter, pageN: parameter.page)
    }
    
    //    传入章节的页码是否有效
    func effectiveArgs(chapterN:Int, pageN:Int) -> Bool {
        if !((0..<self.chapterCount).contains(pageN)) {
            return false
        }
        
        let chapter = self.chapters[chapterN]
        if !((0..<chapter.pageCount).contains(pageN)){
            return false
        }
        return true
    }
    //    传入页码得到内容
    func content(chapter:Int, page:Int) -> String? {
        guard effectiveArgs(chapterN: chapter, pageN: page) else {
            return nil
        }
        return chapters[chapter].content(page: page)
        
    }
    
    //    传入页码得到下一页的页码
    func parameterBefore(currentChapter:Int, currentPage:Int) -> PageParameter? {
        guard effectiveArgs(chapterN: currentChapter, pageN: currentPage) else {
            return nil
        }
        var lastChapter = currentChapter
        var lastPage = currentPage
        
        guard !(lastPage == 0 && lastChapter == 0) else {
            print("到开头了")
            return nil
        }
        
        if lastPage == 0 {
            lastChapter -= 1
            lastPage = chapters[lastChapter].pageCount - 1
        } else {
            lastPage -= 1
        }
        return PageParameter(chapter: lastChapter, page: lastPage)
    }
    //    传入页码得到上一页的页码
    func parameterAfter(currentChapter:Int, currentPage:Int ) -> PageParameter? {
        var nextPage = currentPage
        var nextChapter = currentChapter
        guard effectiveArgs(chapterN: currentChapter, pageN: currentPage) else {
            return nil
        }
        let chapter = chapters[currentChapter]
        
        guard !(chapter.pageCount - 1 == currentPage && chapterCount - 1 == currentChapter) else {
            print("到最后了")
            return nil
        }
        
        if chapter.pageCount - 1 == currentPage {
            nextChapter += 1
            nextPage = 0
        } else {
            nextPage += 1
        }
        
        return PageParameter(chapter: nextChapter, page: nextPage)
    }
}

