//
//  TestingExtensions.swift
//  SignInAppTests
//
//  Created by Eleni Papanikolopoulou on 12/03/2019.
//  Copyright © 2019 Eleni Papanikolopoulou. All rights reserved.
//
import RxSwift
import RxTest
import RxCocoa
import Nimble
@testable import SignInApp

class SignInAPIFake: SignInAPIType {
    var signInCalled = false
    var signInReturnValue: PublishSubject<SignInResponse>!

    func signIn(with signInDetails: SignInDetails) -> Observable<SignInResponse> {
        signInReturnValue = PublishSubject()
        return signInReturnValue
            .do(onSubscribe: {[weak self] in
                self?.signInCalled = true
            })
    }
}

class SignInAPIFakeObservable: SignInAPIType {
    var signInCalled = false
    var signInReturnValue: Observable<SignInResponse>!

    func signIn(with signInDetails: SignInDetails) -> Observable<SignInResponse> {
        return signInReturnValue
            .do(onSubscribe: {[weak self] in
                self?.signInCalled = true
            })
    }
}

class SignInAPIFakeReplaySubject: SignInAPIType {
    var signInCalled = false
    var signInReturnValue: ReplaySubject<SignInResponse>!

    func signIn(with signInDetails: SignInDetails) -> Observable<SignInResponse> {
        return signInReturnValue
            .do(onSubscribe: {[weak self] in
                self?.signInCalled = true
            })
    }
}

