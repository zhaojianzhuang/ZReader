//
//  ChpaterListViewController.swift
//  ZJZReader
//
//  Created by jianzhuangzhao on 2018/4/2.
//  Copyright © 2018年 ZJZ. All rights reserved.
//

import UIKit

class ChapterListViewController: PresentBaseViewController {
    
    
    let readModel:ZReadModel
    let tableView_Identify = "ChapterListViewControllerId"
    init(readModel:ZReadModel, sponsorVC:UIViewController) {
        self.readModel = readModel
        super.init(sponsorVC: sponsorVC, originFrame:CGRect(x: 0, y: 0, width: 0, height: SCREEN_HEIGHT) , finallFrame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH - 100 , height: SCREEN_HEIGHT))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let tableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.grouped)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTable()
        view.backgroundColor = UIColor.red
    }
}

private extension ChapterListViewController {
    
    func setTable() -> Void {
        tableView.frame = view.bounds
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: tableView_Identify)
    }
}

extension ChapterListViewController:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableView_Identify, for: indexPath)
        let chapterModel = readModel.chapter(chapter: indexPath.row)
        cell.textLabel?.text = chapterModel?.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return readModel.chapterCount
    }
}

