//
//  String+toDate.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 11.05.26.
//

import Foundation

extension String {

    func toDate(
        format: String = "yyyy-MM-dd"
    ) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = format

        return formatter.date(from: self)
    }

    func toTimeIntervalSince1970(
        format: String = "yyyy-MM-dd"
    ) -> TimeInterval? {
        toDate(format: format)?.timeIntervalSince1970
    }

    func formattedReleaseDate() -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        inputFormatter.dateFormat = "yyyy-MM-dd"

        guard let date = inputFormatter.date(from: self) else {
            return self
        }

        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        outputFormatter.dateFormat = "d MMMM yyyy"

        return outputFormatter.string(from: date).lowercased()
    }

}
