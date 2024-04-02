//
//  String+localized.swift
//  SlimBody
//
//  Created by Anastasia Kravchenko on 22.09.2023.
//

import Foundation

extension String {

    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }

}
