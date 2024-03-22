//
//  fetchingProcessState.swift
//  SwiftSNSPractice
//
//  Created by 武林慎太郎 on 2024/02/10.
//

import Foundation

enum FetchingProcessState {
    case loading
    case loaded
    case error(Error)
    case empty
}

enum CreatingState {
    case idle
    case working
    case success
    case failed(Error)
}

enum SignInProcess {
    case sleep
    case working
    case failed(Error)
    case success
}

enum CreateAccountProcess {
    case sleep
    case working
    case failed(Error)
    case success
}
