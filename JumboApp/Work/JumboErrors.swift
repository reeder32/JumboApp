//
//  JumboErrors.swift
//  JumboApp
//
//  Created by Nicholas Reeder on 1/27/20.
//  Copyright © 2020 Nicholas Reeder. All rights reserved.
//

import Foundation

enum JumboError: Error {
    case unsupportedURL
    case invalidResponse
    case connectionError
    case unableToDownloadFile
    case dataIncorrectFormat
}

extension JumboError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .unsupportedURL:
            return NSLocalizedString("Invalid url string", comment: "")
        case .invalidResponse:
            return NSLocalizedString("Received invalid response from server", comment: "")
        case .connectionError:
            return NSLocalizedString("Unable to connect", comment: "")
        case .unableToDownloadFile:
            return NSLocalizedString("Unable to download file", comment: "")
        case .dataIncorrectFormat:
            return NSLocalizedString("Data is in wrong format", comment: "")
        }
    }
}
