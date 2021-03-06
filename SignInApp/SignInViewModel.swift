//
//  SignInViewModel.swift
//  MovieRama
//
//  Created by Eleni Papanikolopoulou on 22/02/2019.
//  Copyright © 2019 Eleni Papanikolopoulou. All rights reserved.
//

import UIKit
import RxSwift
import RxSwiftExt

struct SignInDetails {
    let emailText: String
    let passwordText: String
}

class SignInViewModel {

    //input
    let signInAPI: SignInAPIType
    private var disposeBag: DisposeBag

    //output
    var emailIsValid: Observable<Bool>!
    var passwordIsValid: Observable<Bool>!
    var signInButtonEnabled: Observable<Bool>!
    var signIn: Observable<SignInResponse>!


    init(signInAPI: SignInAPIType, disposeBag: DisposeBag) {
        self.signInAPI = signInAPI
        self.disposeBag = disposeBag
    }

    func configure(
        emailText: Observable<String>,
        passwordText: Observable<String>,
        signInButtonTap: Observable<Void>) {

        // Email
        let emailRegexMatcher = RegexMatcher(regex: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
        emailIsValid = emailText.map({
            return emailRegexMatcher.matches(string: $0)
        })

        // Password
        let passwordRegexMatcher = RegexMatcher(regex: "^(?=.*([ !\"#$%&'()*+,-.//:;<=>?@\\[\\]^_`{|}~]|[0-9]))(?=.*[a-zA-Z]).{8,}$")
        passwordIsValid = passwordText
            .map({ return passwordRegexMatcher.matches(string: $0) })

        //SignIn Button
        signInButtonEnabled = Observable.combineLatest(emailIsValid, passwordIsValid) { (emailIsValid, passwordIsValid) -> Bool in
            return emailIsValid && passwordIsValid
            }
            .startWith(false)

        
        signIn = Observable.combineLatest(emailText,
                                                emailIsValid,
                                                passwordText,
                                                passwordIsValid,
                                                signInButtonTap,
                                                resultSelector: { (emailText, emailIsValid, passwordText, passwordIsValid, signInTap) -> SignInDetails? in

                                                    guard emailIsValid, passwordIsValid else { return nil }
                                                    return SignInDetails(emailText: emailText, passwordText: passwordText)
        }).unwrap()
        .flatMapLatest({[weak self](signUpDetails) -> Observable<SignInResponse> in
            guard let strongSelf = self else { return .empty() }
            return strongSelf.signInAPI.signIn(with: signUpDetails)
        }).take(1)
    }
}

struct RegexMatcher {
    let regex: String

    func matches(string: String) -> Bool {
        let reguralExpression = try? NSRegularExpression(pattern: regex, options: .caseInsensitive)
        return reguralExpression?.firstMatch(in: string, options: [], range: NSRange(location: 0, length: string.count)) != nil
    }

}


extension Optional where Wrapped: StringType {
    var isEmptyOrNil: Bool {
        return self?.get.isEmpty ?? true
    }
}

protocol StringType {
    var get: String { get }
}

extension String: StringType {
    var get: String { return self }
}


extension UIColor {
    @nonobjc class var pineGreen: UIColor {
        return UIColor(red: 0.0, green: 117.0 / 255.0, blue: 106.0 / 255.0, alpha: 0.4)
    }
}
