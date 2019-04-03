//
//  SiginInViewModelSubscribeSpec.swift
//  SignInAppTests
//
//  Created by Eleni Papanikolopoulou on 03/04/2019.
//  Copyright © 2019 Eleni Papanikolopoulou. All rights reserved.
//

import Quick
import Nimble
import RxSwift
import RxTest
@testable import SignInApp

class SignInViewModelPublishSubjectSpec: QuickSpec {

    override func spec() {
        describe("The SignInViewModel") {

            var sut: SignInViewModel!
            var signInAPI: SignInAPIFake!
            var disposeBag: DisposeBag!

            var emailText: PublishSubject<String>!
            var passwordText: PublishSubject<String>!
            var signInButtonTap: PublishSubject<Void>!

            var emailIsValid: Bool!
            var passwordIsValid: Bool!
            var signInButtonEnabled: Bool!
            var signInResponse: SignInResponse!

            beforeEach {
                signInAPI = SignInAPIFake()
                disposeBag = DisposeBag()

                emailText = PublishSubject<String>()
                passwordText = PublishSubject<String>()
                signInButtonTap = PublishSubject<Void>()

                sut = SignInViewModel(signInAPI: signInAPI, disposeBag: disposeBag)
                sut.configure(emailText: emailText.asObservable(), passwordText: passwordText.asObservable(), signInButtonTap: signInButtonTap.asObservable())

                sut.emailIsValid.subscribe(onNext: { (isValid) in
                    emailIsValid = isValid
                }).disposed(by: disposeBag)
                
                sut.passwordIsValid.subscribe(onNext: { (isValid) in
                    passwordIsValid = isValid
                }).disposed(by: disposeBag)

                sut.signInButtonEnabled.subscribe(onNext: { (enabled) in
                    signInButtonEnabled = enabled
                }).disposed(by: disposeBag)

                sut.signIn.subscribe(onNext: { (response) in
                    signInResponse = response
                }).disposed(by: disposeBag)
            }

            it("should get an initial event that sign in should not be enabled") {
                expect(signInButtonEnabled).to(beFalse())
            }

            context("when an invalid email is typed") {
                beforeEach {
                    emailText.on(.next("test@"))
                }

                it("should get an event that email is invalid") {
                    expect(emailIsValid).to(beFalse())
                }

                context("when an invalid password is typed") {
                    beforeEach {
                        passwordText.on(.next("asd"))
                    }

                    it("should get an event that password is invalid") {
                        expect(passwordIsValid).to(beFalse())
                    }

                    it("should get another event that sign in button should not be enabled") {
                        expect(signInButtonEnabled).to(beFalse())
                    }

                    context("when valid email and password are typed") {
                        beforeEach {
                            emailText.on(.next("test@gmail.com"))
                            passwordText.on(.next("Asd123!!"))
                        }

                        it("should get an event that email is valid") {
                            expect(emailIsValid).to(beTrue())
                        }

                        it("should get an event that password is valid") {
                            expect(passwordIsValid).to(beTrue())
                        }

                        it("should get an event that sign in button should be enabled") {
                            expect(signInButtonEnabled).to(beTrue())
                        }

                        context("when sign in button is tapped") {
                            beforeEach {
                                signInButtonTap.on(.next(()))
                            }

                            it("a sign in request should be made") {
                                expect(signInAPI.signInCalled).to(beTrue())
                            }

                            context("when sign in response arrives") {
                                beforeEach {
                                    let signInResponse = SignInResponse(token: "fake_token")
                                    signInAPI.signInReturnValue.on(.next(signInResponse))
                                }

                                it("should give an event with the correct sign in response") {
                                    expect(signInResponse.token).to(equal("fake_token"))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
