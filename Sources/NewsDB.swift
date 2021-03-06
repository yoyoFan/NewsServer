//
//  NewsDB.swift
//  NewsServer
//
//  Created by bo on 2016/11/9.
//
//

import Foundation

//新闻
extension DB {
    
    //使用关键字搜索新闻
    static func getNewsTitles(key: String) -> [String:Any]{
        if key.isEmpty {
            return ResultDic(error: "参数错误")
        }
        let SQL = "select ID,title from News where title like '%\(key)%'"
        if let result = executeQuery(SQL: SQL) {
            var array = [[String:Any]]()
            result.forEachRow(callback: { (element) in
                var dic = [String:Any]()
                dic["ID"] = element[0]
                dic["title"] = element[1]
                array.append(dic)
            })
            return ResultDic(data: array)
        } else {
            return ResultDic(error: "请求错误")
        }
    }
    
    //使用ID查找新闻
    static func getNews(ID: String) -> [String:Any] {
        if ID.isEmpty {
            return ResultDic(error: "参数错误")
        }
        let SQL = "select * from News where ID = '\(ID)'"
        if let result = executeQuery(SQL: SQL) {
            var dic = [String: Any]()
            result.forEachRow(callback: { (element) in
                dic["ID"] = element[0]
                dic["title"] = element[1]
                dic["detail"] = element[2]
                dic["catagory"] = element[3]
                if let images = element[4], !images.isEmpty {
                    dic["images"] = images.components(separatedBy: ",")
                        .map({ (image) -> String in
                        return serverImagesPath + image
                    })
                } else {
                    dic["images"] = [String]()
                }
                dic["source"] = element[5]
                if let sourceImage = element[6] {
                    dic["sourceImage"] = serverImagesPath + sourceImage
                }
                dic["updateTime"] = DateFormatter.shared.date(from: element[7] ?? "")?.timeIntervalSince1970 ?? 0
                dic["commentCount"] = element[8]
            })
            return ResultDic(data: dic)
        } else {
            return ResultDic(error: "请求错误")
        }
    }
    
    //获取新闻评论数量
    static func getNewsCommentCount(ID: String) -> [String : Any]{
        if ID.isEmpty {
            return ResultDic(error: "参数错误")
        }
        let SQL = "select (commentCount) from News where ID = '\(ID)'"
        if let result = executeQuery(SQL: SQL){
            if result.numRows() == 0 {
                return ResultDic(error: "无此数据")
            } else {
                var count = "0"
                result.forEachRow(callback: { (element) in
                    count = element[0] ?? "0"
                })
                return ResultDic(data: ["count": count])
            }
        } else {
            return ResultDic(error: "查询错误")
        }
    }
    
    //新增新闻
    static func addNews(title: String, detail: String,catagory: String, images: String,source: String,sourceImage: String) -> UInt? {
        let SQL = "insert into News(title,detail,catagory,images,source,sourceImage) values('\(title)','\(detail)','\(catagory)','\(images)','\(source)','\(sourceImage)')"
        return executeInsert(SQL: SQL)
    }
    
    static func getNewsList(minTime: Int?, maxTime: Int?, catagory: String?, count: Int) -> [String:Any] {
        var SQL = "select * from News "
        var hasWhere = true
        if let minTime = minTime,let maxTime = maxTime {
            SQL += "where updateTime > from_unixtime(\(minTime)) and updateTime < from_unixtime(\(maxTime))"
        } else if let minTime = minTime{
            SQL += "where updateTime > from_unixtime(\(minTime))"
        } else if let maxTime = maxTime {
            SQL += "where updateTime < from_unixtime(\(maxTime))"
        } else {
            hasWhere = false
        }
        if let catagory = catagory {
            if hasWhere {
                SQL += " and catagory = '\(catagory)'"
            } else {
                SQL += "where catagory = '\(catagory)'"
            }
        }
        SQL += " order by updateTime desc limit \(count)"
        var array = [Any]()
        if let result = executeQuery(SQL: SQL) {
            result.forEachRow(callback: { (element) in
                var dic = [String:Any]()
                dic["ID"] = element[0]
                dic["title"] = element[1]
                dic["detail"] = element[2]
                dic["catagory"] = element[3]
                if let images = element[4], !images.isEmpty {
                    dic["images"] = images.components(separatedBy: ",")
                        .map({ (image) -> String in
                        return serverImagesPath + image
                    })
                } else {
                    dic["images"] = [String]()
                }
                dic["source"] = element[5]
                if let sourceImage = element[6] {
                    dic["sourceImage"] = serverImagesPath + sourceImage
                }
                dic["updateTime"] = DateFormatter.shared.date(from: element[7] ?? "")?.timeIntervalSince1970 ?? 0
                dic["commentCount"] = element[8]
                array.append(dic)
            })
        }
        return ResultDic(data: array)
    }
}
