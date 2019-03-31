//
//  SignInViewModelRxBlockingSpec.swift
//  SignInAppTests
//
//  Created by Eleni Papanikolopoulou on 12/03/2019.
//  Copyright © 2019 Eleni Papanikolopoulou. All rights reserved.
//

import Quick
import Nimble
import RxSwift
import RxTest
import RxCocoa
import RxBlocking
@testable import SignInApp

class SignInViewModelRxBlockingSpec: QuickSpec {

    override func spec() {
        describe("The SignInViewModel") {
            //https://github.com/ReactiveX/RxSwift/issues/1480
            var sut: SignInViewModel!
            var emailText: ReplaySubject<String>!
            var passwordText: ReplaySubject<String>!
            var rememberEmail: ReplaySubject<Bool>!
            var signInButtonTap: ReplaySubject<Void>!
            //var signInAPI: SignInAPIFake!
            var signInAPI: SignInAPIFakeReplaySubject!
            var disposeBag: DisposeBag!
            var scheduler: TestScheduler!
            var signInActionObserver: TestableObserver<SignInResponse>!

            beforeEach {
                //signInAPI = SignInAPIFake()
                signInAPI = SignInAPIFakeReplaySubject()
                disposeBag = DisposeBag()
                emailText = ReplaySubject<String>.create(bufferSize: 10)

                passwordText = ReplaySubject<String>.create(bufferSize: 10)
                rememberEmail = ReplaySubject<Bool>.create(bufferSize: 10)
                signInButtonTap = ReplaySubject<Void>.create(bufferSize: 10)
                //this is because if initialized inside signInApi it was desposed before getting a .completed event
                signInAPI.signInReturnValue = ReplaySubject.create(bufferSize: 10)

                scheduler = TestScheduler(initialClock: 0)
                signInActionObserver = scheduler.createObserver(SignInResponse.self)

                sut = SignInViewModel(signInAPI: signInAPI, disposeBag: disposeBag)
                sut.configure(emailText: emailText.asObservable(), passwordText: passwordText.asObservable(), signInButtonTap: signInButtonTap.asObservable(), rememberEmail: rememberEmail.asObservable())

                sut.signInAction.subscribe(signInActionObserver).disposed(by: disposeBag)

            }

            it("should get an initial event that sign in should not be enabled") {
                let signInButtonEnabled = try! sut.signInButtonEnabled.toBlocking().first()
                expect(signInButtonEnabled).to(beFalse())
            }

            context("when an invalid email is typed") {
                beforeEach {
                    emailText.on(.next("test@"))
                    emailText.on(.completed)
                }

                it("should get an event that email is invalid") {
                    let emailIsValid = try! sut.emailIsValid.toBlocking().first()
                    expect(emailIsValid).to(beFalse())
                }

                context("when an invalid password is typed") {
                    beforeEach {
                        passwordText.on(.next("asd"))
                        passwordText.on(.completed)
                    }

                    it("should get an event that password is invalid") {
                        let passwordIsValid = try! sut.passwordIsValid.toBlocking().first()
                        expect(passwordIsValid).to(beFalse())
                    }

                    it("should get another event that sign in button should not be enabled") {
                        let signInButtonEnabled = try! sut.signInButtonEnabled.toBlocking().toArray()
                        expect(signInButtonEnabled).to(equal([false, false]))
                    }
                }
            }

            context("when valid email and password are typed") {
                beforeEach {
                    emailText.on(.next("test@gmail.com"))
                    emailText.on(.completed)
                    passwordText.on(.next("Asd123!!"))
                    passwordText.on(.completed)

                }

                it("should get an event that email is valid") {
                    let emailIsValidSecondEvent = try! sut.emailIsValid.toBlocking().first()
                    expect(emailIsValidSecondEvent).to(beTrue())

                }

                it("should get an event that password is valid") {
                    let passwordIsValidSecondEvent = try! sut.passwordIsValid.toBlocking().first()
                    expect(passwordIsValidSecondEvent).to(beTrue())
                }

                it("should get an event that sign in button should be enabled") {
                    let signInButtonEnabled = try! sut.signInButtonEnabled.toBlocking().toArray()
                    expect(signInButtonEnabled).to(equal([false, true]))
                }


                context("when sign in button is tapped") {
                    beforeEach {
                        rememberEmail.on(.next(false))
                        rememberEmail.on(.completed)
                        signInButtonTap.on(.next(()))
                        signInButtonTap.on(.completed)
                    }

                    it("a sign in request should be made") {
                        expect(signInAPI.signInCalled).to(beTrue())
                    }

                    context("when response arrives") {
                        beforeEach {
                            signInAPI.signInReturnValue.on(.next(SignInResponse(email: "test@gmail.com", account: "workable")))
                            signInAPI.signInReturnValue.onCompleted()
                        }

                        it("should have the correct response emition") {
                            let signInAction = try? sut.signInAction.toBlocking().first()
                            expect(signInAction).to(equal(SignInResponse(email: "test@gmail.com", account: "workable")))
                        }
                    }
                }
            }
        }
    }

}
