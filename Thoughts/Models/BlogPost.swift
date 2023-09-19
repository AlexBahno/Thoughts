//
//  BlogPost.swift
//  Thoughts
//
//  Created by Alexandr Bahno on 28.08.2023.
//

import Foundation

struct BlogPost {
    let identifier: String
    let title: String
    let timestamp: TimeInterval
    let headerImageUrl: URL?
    let text: String
    let emailOfOwner: String
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.setLocalizedDateFormatFromTemplate("MMMMdYYYY")
        return formatter
    }()
    
    var date: String {
        let date = Date(timeIntervalSince1970: self.timestamp)
        return BlogPost.dateFormatter.string(from: date)
    }
}
