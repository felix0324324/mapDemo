//
//  DateHelper.swift
//  MapController
//
//  Copyright © 2018年 . All rights reserved.
//

import UIKit

struct DateHelper {
    
    enum DateFormatEnum: String {
        /** yyyy-MM-dd'T'HH:mm:ss.SS */
        // case yyyymmdd_HypenType4 = "yyyy-MM-dd'T'HH:mm:ss.SS"
        /** yyyy-MM-dd'T'HH:mm:ss */
        case yyyymmdd_HypenType3 = "yyyy-MM-dd'T'HH:mm:ss"
        /** yyyy-MM-dd HH:mm*/
        case yyyymmdd_HypenType4 = "yyyy-MM-dd HH:mm"
        /** yyyy-MM-dd */
        case yyyymmdd_Hypen = "yyyy-MM-dd"
        /** yyyy年MM月dd日 */
        case yyyymmdd_Chinese = "yyyy年MM月dd日"
        /** yyyy年MM月dd日 HH:mm */
        case yyyymmddHHmm_Chinese = "yyyy年MM月dd日 HH:mm"
        /** MM-dd */
        case mmdd_Hypen = "MM-dd"
        /** MM月dd日*/
        case mmdd_Chinese = "MM月dd日"
        /** M月dd日*/
        case mdd_Chinese = "M月dd日"
        /** yyyy*/
        case yyyy = "yyyy"
        /** yyyy年*/
        case yyyy_Chinese = "yyyy年"
        /** dd/MM/yyyy */
        case ddmmyyyy_Slash = "dd/MM/yyyy"
        /** dd/MM/yyyy */
        case mmyyyy_Slash = "MM/yyyy"
        /** HH:mm */
        case hhmm = "HH:mm"
        /** MM月dd日yyyy年 */
        case mmddyyyy_Chinese = "MM月dd日yyyy年"
        
    }
    
    static func fmt(dateFormatEnum: DateFormatEnum? = .yyyymmdd_HypenType3) -> DateFormatter {
        let fmt = DateFormatter()
        fmt.calendar = Calendar(identifier: .iso8601)
        fmt.dateFormat = dateFormatEnum?.rawValue
        return fmt
    }
    
    // Common
    
//    static func convertDateFormat(string: String? = "", from: DateFormatEnum, toZh: DateFormatEnum, toEn: DateFormatEnum) -> String {
//        let aLanguage = (SYLanguage.getCurrentLanguage() == .English) ? toEn : toZh
//        return Self.convertDateFormat(string: string, from: from, to: aLanguage)
//    }
    
    static func convertDateFormat(string: String? = "", from: DateFormatEnum, to: DateFormatEnum) -> String {
        var dateString = ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = from.rawValue
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        if let date = dateFormatter.date(from: string ?? "") {
            dateFormatter.dateFormat = to.rawValue
            dateString = dateFormatter.string(from: date)
        }
        
        if dateString == "" && string?.count ?? 0 > 0 {
            print("DateHelper convertDateFormat - parse error from : \(String(describing: string))")
        }
        return dateString
    }
    
    static func convertDateToString(fromDate: Date, to: DateHelper.DateFormatEnum) -> String {
        let aFmt = DateHelper.fmt(dateFormatEnum: to)
        return aFmt.string(from: fromDate)
    }
    
    static func convertTimestampToDate(timeStamp: String) -> NSDate? {
        var aNSDate: NSDate?
        if let aTimeStampDouble = Double(timeStamp) {
            let unixTimeStamp: Double = aTimeStampDouble / 1000.0
            aNSDate = NSDate.init(timeIntervalSince1970: unixTimeStamp)
        }
        return aNSDate
    }
    
    static func convertTimestampDateToString(timeStamp: String, to: DateFormatEnum) -> String {
        var aString = ""
        if let exactDate = Self.convertTimestampToDate(timeStamp: timeStamp) {
            let dateFormatt = DateFormatter()
            dateFormatt.dateFormat = to.rawValue
            aString = dateFormatt.string(from: exactDate as Date)
        }
        return aString
    }
    
//    static func convertTimestampToString(timeStamp: String) -> String {
//        // "1591694549383" -> "今天" or "MM-dd" etc..
//        var aString = ""
//        if let firstDate = Self.convertTimestampToDate(timeStamp: timeStamp) {
//            // let dateFormatt = DateFormatter();
//            let calendar = Calendar.current
//            let secondDate = NSDate()
//            let date1 = calendar.startOfDay(for: firstDate as Date)
//            let date2 = calendar.startOfDay(for: secondDate as Date)
//            if let aDays = calendar.dateComponents([.day], from: date1, to: date2).day {
//                aString = Self.convertDayToString(days: aDays, timeStamp: timeStamp, isChatBot: true)
//            }
//        }
//        return aString
//    }
    
//    static func convertDayToString(days: Int, timeStamp: String? = nil, isChatBot: Bool) -> String {
//        var aString = ""
//        if days < 1 {
//            // 今天
//            aString = isChatBot ? "dateToday_STRING".localizedWithChatBotLang : "dateToday_STRING".localized // 今天
//        } else if days < 2 {
//            // 昨天
//            aString = isChatBot ? "dateYesterday_STRING".localizedWithChatBotLang : "dateYesterday_STRING".localized // 昨天
//        } else {
//            let isEng = SYLanguage.getCurrentLanguage() == .English
//            aString = Self.convertTimestampDateToString(timeStamp: timeStamp ?? "", to: isEng ? .yyyymmdd_Hypen : .yyyymmdd_Chinese) // "yyyy-MM-dd" or "yyyy年MM月dd日"
//        }
//        return aString
//    }
    static func getCurrentDate() -> Date {
        return Date()
    }
    
    static func getCurrentTimeStamp() -> TimeInterval {
        return NSDate().timeIntervalSince1970 * 1000
    }
    
    static func getCurrentTimeStampInt() -> Int {
        return Int(DateHelper.getCurrentTimeStamp()/1000)
    }
}

extension String {
    func convert(from: DateHelper.DateFormatEnum, to: DateHelper.DateFormatEnum) -> String {
        return DateHelper.convertDateFormat(string: self, from: from, to: to)
    }
}

extension Date {
    func convert(to: DateHelper.DateFormatEnum) -> String {
        return DateHelper.convertDateToString(fromDate: self, to: to)
    }
}
