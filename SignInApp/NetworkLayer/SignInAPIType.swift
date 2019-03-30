//
//  SignUpAPI.swift
//  MovieRama
//
//  Created by Eleni Papanikolopoulou on 23/02/2019.
//  Copyright © 2019 Eleni Papanikolopoulou. All rights reserved.
//

import UIKit
import RxSwift

protocol SignInAPIType {
    func signIn(with signInDetails: SignInDetails) -> Observable<SignInResponse>
}

struct SignInResponse: Decodable {
    let email: String
    let account: String
}

class SignInAPI: SignInAPIType {
    let httpClient: HttpClient = HttpClient.sharedService

    func signIn(with signInDetails: SignInDetails) -> Observable<SignInResponse> {
//        let parameters: [String: Any] = [ "email:" : signUpDetails.emailText,
//                                          "password": signUpDetails.passwordText,
//                                          "rememberEmail": signUpDetails.rememberEmail
//        ]
//        return httpClient.loadRequestWithPath("/backend/apo/signin", parameters: parameters, method: .POST, headers: [])
        return Observable.just(SignInResponse(email: signInDetails.emailText, account: "Workable"))
    }
}
