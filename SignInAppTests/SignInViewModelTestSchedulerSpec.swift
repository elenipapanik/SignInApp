//
//  SignInViewModelTestSchedulerSpec.swift
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

class SignInViewModelTestSchedulerSpec: QuickSpec {
    override func spec() {
        describe("The SignInViewModel") {

            var sut: SignInViewModel!

            var emailText: PublishSubject<String>!
            var passwordText: PublishSubject<String>!
            var signInButtonTap: PublishSubject<Void>!

            var signInAPI: SignInAPIFake!
            var disposeBag: DisposeBag!
            var scheduler: TestScheduler!
            
            var emailIsValidObserver: TestableObserver<Bool>!
            var passwordIsValidObserver: TestableObserver<Bool>!
            var signInButtonEnabledObserver: TestableObserver<Bool>!
            var signInObserver: TestableObserver<SignInResponse>!

            var emailIsValidExpectedEvents: [Recorded<Event<Bool>>]!
            var passwordIsValidExpectedEvents: [Recorded<Event<Bool>>]!
            var signInButtonEnabledExpectedEvents: [Recorded<Event<Bool>>]!
            var signInExpectedEvents: [Recorded<Event<SignInResponse>>]!


            beforeEach {
                signInAPI = SignInAPIFake()
                disposeBag = DisposeBag()
                emailText = PublishSubject<String>()
                passwordText = PublishSubject<String>()
                signInButtonTap = PublishSubject<Void>()
                sut = SignInViewModel(signInAPI: signInAPI, disposeBag: disposeBag)
                sut.configure(emailText: emailText, passwordText: passwordText, signInButtonTap: signInButtonTap)
                let scheduler = TestScheduler(initialClock: 0)
                emailIsValidObserver = scheduler.createObserver(Bool.self)
                passwordIsValidObserver = scheduler.createObserver(Bool.self)
                signInButtonEnabledObserver = scheduler.createObserver(Bool.self)
                signInObserver = scheduler.createObserver(SignInResponse.self)

                scheduler.scheduleAt(0, action: {
                    sut.emailIsValid.subscribe(emailIsValidObserver).disposed(by: disposeBag)
                    sut.passwordIsValid.subscribe(passwordIsValidObserver).disposed(by: disposeBag)
                    sut.signInButtonEnabled.subscribe(signInButtonEnabledObserver).disposed(by: disposeBag)
                    sut.signIn.subscribe(signInObserver).disposed(by: disposeBag)
                })

                emailIsValidExpectedEvents = [
                    .next(1, false),
                    .next(3, true)
                ]
                
                passwordIsValidExpectedEvents = [
                    .next(2, false),
                    .next(3, true)
                ]
                
                signInExpectedEvents = [
                    .next(5, SignInResponse(token: "fake_token")),
                    .completed(5)
                ]

                signInButtonEnabledExpectedEvents = [
                    .next(0, false) , // start with initial value
                    .next(2, false) , //password invalid type  (didn't get in email type becasue password didn't get an initial event and combine latest doesn't work)
                    .next(3, false), //for valid email and invalid password type
                    .next(3, true)  //for valid password type
                ]

                scheduler.scheduleAt(1, action: {
                    emailText.on(.next("test@"))
                })

                scheduler.scheduleAt(2, action: {
                    passwordText.on(.next("asd"))
                })

                scheduler.scheduleAt(3, action: {
                    emailText.on(.next("test@gmail.com"))
                    passwordText.on(.next("Asd123!!"))
                })

                scheduler.scheduleAt(4, action: {
                    signInButtonTap.on(.next(()))
                })

                scheduler.scheduleAt(5, action: {
                    signInAPI.signInReturnValue.on(.next(SignInResponse(token: "fake_token")))
                })

                scheduler.start()
            }

            it("should get the correct signInButtonEnabledEvents") {
                expect(signInButtonEnabledObserver.events).to(equal(signInButtonEnabledExpectedEvents))
            }

            it("should get the correct emailIsValidExpectedEvents") {
                expect(emailIsValidObserver.events).to(equal(emailIsValidExpectedEvents))
            }

            it("should get the correct passwordIsValidExpectedEvents") {
                expect(passwordIsValidObserver.events).to(equal(passwordIsValidExpectedEvents))
            }

            it("a sign in request should be made") {
                expect(signInAPI.signInCalled).to(beTrue())
            }

            it("should get the correct signInActionObserver") {
                expect(signInObserver.events).to(equal(signInExpectedEvents))
            }
        }
    }
}
