//
//  HttpClient.swift
//  MovieRama
//
//  Created by Eleni Papanikolopoulou on 18/02/2019.
//  Copyright © 2019 Eleni Papanikolopoulou. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


class HttpClient {
    let session: URLSession

    static var sharedService = HttpClient(URLSession: URLSession.shared)

    init(URLSession: Foundation.URLSession) {
        self.session = URLSession
    }
}
