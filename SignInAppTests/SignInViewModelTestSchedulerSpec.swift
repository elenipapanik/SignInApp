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
            var rememberEmail: PublishSubject<Bool>!
            var signInButtonTap: PublishSubject<Void>!

            var signInAPI: SignInAPIFake!
            var disposeBag: DisposeBag!
            var scheduler: TestScheduler!
            
            var emailIsValidObserver: TestableObserver<Bool>!
            var passwordIsValidObserver: TestableObserver<Bool>!
            var signInButtonEnabledObserver: TestableObserver<Bool>!
            var signInActionObserver: TestableObserver<SignInResponse>!


            beforeEach {
                signInAPI = SignInAPIFake()
                disposeBag = DisposeBag()
                emailText = PublishSubject<String>()
                passwordText = PublishSubject<String>()
                rememberEmail = PublishSubject<Bool>()
                signInButtonTap = PublishSubject<Void>()
                sut = SignInViewModel(signInAPI: signInAPI, disposeBag: disposeBag)
                sut.configure(emailText: emailText.asObservable(), passwordText: passwordText.asObservable(), signInButtonTap: signInButtonTap.asObservable(), rememberEmail: rememberEmail.asObservable())
                scheduler = TestScheduler(initialClock: 0)
                emailIsValidObserver = scheduler.createObserver(Bool.self)
                passwordIsValidObserver = scheduler.createObserver(Bool.self)
                signInButtonEnabledObserver = scheduler.createObserver(Bool.self)
                signInActionObserver = scheduler.createObserver(SignInResponse.self)

                scheduler.scheduleAt(0, action: {
                    sut.emailIsValid.subscribe(emailIsValidObserver).disposed(by: disposeBag)
                    sut.passwordIsValid.subscribe(passwordIsValidObserver).disposed(by: disposeBag)
                    sut.signInButtonEnabled.subscribe(signInButtonEnabledObserver).disposed(by: disposeBag)
                    sut.signInAction.subscribe(signInActionObserver).disposed(by: disposeBag)
                })

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
                    rememberEmail.on(.next(false))
                    signInButtonTap.on(.next(()))
                })

                scheduler.scheduleAt(5, action: {
                    signInAPI.signInReturnValue.on(.next(SignInResponse(email: "test@gmail.com", account: "workable")))
                })

                scheduler.start()
            }

            it("should get an initial event that sign in should not be enabled") {
                expect(signInButtonEnabledObserver.events.first?.value.element).to(beFalse())
            }

            it("should get an event that email is invalid") {
                expect(emailIsValidObserver.events.first?.value.element).to(beFalse())
            }

            it("should get an event that password is invalid") {
                expect(passwordIsValidObserver.events.first?.value.element).to(beFalse())
            }

            it("should get an event that sign in button should not be enabled") {
                let secondEvent = signInButtonEnabledObserver.events[1].value.element
                expect(secondEvent).to(beFalse())
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


            it("a sign in request should be made") {
                expect(signInAPI.signInCalled).to(beTrue())
            }


            it("should give an event with the correct sign in response") {
                expect(signInActionObserver.events.first?.value.element?.email).to(equal("test@gmail.com"))
                expect(signInActionObserver.events.first?.value.element?.account).to(equal("workable"))
            }
        }
    }
}
