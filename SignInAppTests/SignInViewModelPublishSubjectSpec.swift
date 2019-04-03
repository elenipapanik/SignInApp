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

            var emailIsValidValue: Bool!
            var passwordIsValidValue: Bool!
            var signInButtonEnabledValue: Bool!
            var signInResponseValue: SignInResponse!

            beforeEach {

                signInAPI = SignInAPIFake()
                disposeBag = DisposeBag()

                emailText = PublishSubject<String>()
                passwordText = PublishSubject<String>()
                signInButtonTap = PublishSubject<Void>()

                sut = SignInViewModel(signInAPI: signInAPI, disposeBag: disposeBag)
                sut.configure(emailText: emailText.asObservable(), passwordText: passwordText.asObservable(), signInButtonTap: signInButtonTap.asObservable())

                sut.emailIsValid.subscribe(onNext: { (isValid) in
                    emailIsValidValue = isValid
                }).disposed(by: disposeBag)
                
                sut.passwordIsValid.subscribe(onNext: { (isValid) in
                    passwordIsValidValue = isValid
                }).disposed(by: disposeBag)

                sut.signInButtonEnabled.subscribe(onNext: { (enabled) in
                    signInButtonEnabledValue = enabled
                }).disposed(by: disposeBag)

                sut.signIn.subscribe(onNext: { (response) in
                    signInResponseValue = response
                }).disposed(by: disposeBag)
            }

            it("should get an initial event that sign in should not be enabled") {
                expect(signInButtonEnabledValue).to(beFalse())
            }

            context("when an invalid email is typed") {
                beforeEach {
                    emailText.on(.next("test@"))
                }


                it("should get an event that email is invalid") {
                    expect(emailIsValidValue).to(beFalse())
                }

                context("when an invalid password is typed") {
                    beforeEach {
                        passwordText.on(.next("asd"))
                    }

                    it("should get an event that password is invalid") {
                        expect(passwordIsValidValue).to(beFalse())
                    }

                    it("should get another event that sign in button should not be enabled") {
                        expect(signInButtonEnabledValue).to(beFalse())
                    }

                    context("when valid email and password are typed") {
                        beforeEach {
                            emailText.on(.next("test@gmail.com"))
                            passwordText.on(.next("Asd123!!"))
                        }

                        it("should get an event that email is valid") {
                            expect(emailIsValidValue).to(beTrue())
                        }

                        it("should get an event that password is valid") {
                            expect(passwordIsValidValue).to(beTrue())
                        }

                        it("should get an event that sign in button should be enabled") {
                            expect(signInButtonEnabledValue).to(beTrue())
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
                                    let signInResponse = SignInResponse(email: "test@gmail.com", account: "workable")
                                    signInAPI.signInReturnValue.on(.next(signInResponse))
                                }

                                it("should give an event with the correct sign in response") {
                                    expect(signInResponseValue.email).to(equal("test@gmail.com"))
                                    expect(signInResponseValue.account).to(equal("workable"))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
