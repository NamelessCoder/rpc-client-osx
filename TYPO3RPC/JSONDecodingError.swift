//
//  ActionsEmptyError.swift
//  TYPO3RPC
//
//  Created by Claus Due on 08/05/16.
//  Copyright © 2016 Claus Due. All rights reserved.
//

import Foundation

enum JSONDecodingErrorType: ErrorType {
    case Invalid
    case Unsupported(String)
    case BadResponse(String)
}

class JSONDecodingError: NSError {
    
}