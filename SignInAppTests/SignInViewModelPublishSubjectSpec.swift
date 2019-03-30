//
//  SignInViewModelPublishSubjectSpec.swift
//  SignInAppTests
//
//  Created by Eleni Papanikolopoulou on 12/03/2019.
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
            var scheduler: TestScheduler!

            var emailText: PublishSubject<String>!
            var passwordText: PublishSubject<String>!
            var rememberEmail: PublishSubject<Bool>!
            var signInButtonTap: PublishSubject<Void>!

            var emailIsValidObserver: TestableObserver<Bool>!
            var passwordIsValidObserver: TestableObserver<Bool>!
            var signInButtonEnabledObserver: TestableObserver<Bool>!
            var signInActionObserver: TestableObserver<SignInResponse>!


            beforeEach {

                signInAPI = SignInAPIFake()
                disposeBag = DisposeBag()
                scheduler = TestScheduler(initialClock: 0)

                emailText = PublishSubject<String>()
                passwordText = PublishSubject<String>()
                rememberEmail = PublishSubject<Bool>()
                signInButtonTap = PublishSubject<Void>()

                sut = SignInViewModel(signInAPI: signInAPI, disposeBag: disposeBag)
                sut.configure(emailText: emailText.asObservable(), passwordText: passwordText.asObservable(), signInButtonTap: signInButtonTap.asObservable(), rememberEmail: rememberEmail.asObservable())

                emailIsValidObserver = scheduler.createObserver(Bool.self)
                passwordIsValidObserver = scheduler.createObserver(Bool.self)
                signInButtonEnabledObserver = scheduler.createObserver(Bool.self)
                signInActionObserver = scheduler.createObserver(SignInResponse.self)

                //record the events
                sut.emailIsValid.subscribe(emailIsValidObserver).disposed(by: disposeBag)
                sut.passwordIsValid.subscribe(passwordIsValidObserver).disposed(by: disposeBag)
                sut.signInButtonEnabled.subscribe(signInButtonEnabledObserver).disposed(by: disposeBag)
                sut.signInAction.subscribe(signInActionObserver).disposed(by: disposeBag)

            }

            it("should get an initial event that sign in should not be enabled") {
                expect(signInButtonEnabledObserver.events.first?.value.element).to(beFalse())
            }

            context("when an invalid email is typed") {
                beforeEach {
                    emailText.on(.next("test@"))
                }


                it("should get an event that email is invalid") {
                    expect(emailIsValidObserver.events.first?.value.element).to(beFalse())
                }

                context("when an invalid password is typed") {
                    beforeEach {
                        passwordText.on(.next("asd"))
                    }

                    it("should get an event that password is invalid") {
                        expect(passwordIsValidObserver.events.first?.value.element).to(beFalse())
                    }

                    it("should get another event that sign in button should not be enabled") {
                        let secondEvent = signInButtonEnabledObserver.events[1].value.element
                        expect(secondEvent).to(beFalse())
                    }

                    context("when valid email and password are typed") {
                        beforeEach {
                            emailText.on(.next("test@gmail.com"))
                            passwordText.on(.next("Asd123!!"))
                        }

                        it("should get an event that email is valid") {
                            let secondEvent = emailIsValidObserver.events[1].value.element
                            expect(secondEvent).to(beTrue())
                        }

                        it("should get an event that password is valid") {
                            let secondEvent = emailIsValidObserver.events[1].value.element
                            expect(secondEvent).to(beTrue())
                        }

                        it("should get an event that sign in button should be enabled") {
                            let secondEvent = signInButtonEnabledObserver.events[3].value.element
                            expect(secondEvent).to(beTrue())
                        }

                        context("when sign in button is tapped") {
                            beforeEach {
                                rememberEmail.on(.next(false))
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
                                    let events = signInActionObserver.events.first?.value.element
                                    expect(events?.email).to(equal("test@gmail.com"))
                                    expect(events?.account).to(equal("workable"))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
