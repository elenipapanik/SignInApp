//
//  SignInViewModelColdObservableSpec.swift
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

class SignInViewModelTestableObservableSpec: QuickSpec {

    override func spec() {
        describe("The SignInViewModel") {

            var sut: SignInViewModel!

            var emailText: TestableObservable<String>!
            var emailIsValidExpectedEvents: [Recorded<Event<Bool>>]!
            var emailIsValidObserver: TestableObserver<Bool>!

            var passwordText: TestableObservable<String>!
            var passwordIsValidExpectedEvents: [Recorded<Event<Bool>>]!
            var passwordIsValidObserver: TestableObserver<Bool>!

            var signInButtonTap: TestableObservable<Void>!
            var signInButtonEnabledObserver: TestableObserver<Bool>!
            var signInButtonEnabledExpectedEvents: [Recorded<Event<Bool>>]!

            var signInAction: TestableObservable<SignInResponse>!
            var signInObserver: TestableObserver<SignInResponse>!
            var signInExpectedEvents: [Recorded<Event<SignInResponse>>]!

            var signInAPI: SignInAPIFakeObservable!
            var disposeBag: DisposeBag!
            var scheduler: TestScheduler!

            beforeEach {
                signInAPI = SignInAPIFakeObservable()
                disposeBag = DisposeBag()
                sut = SignInViewModel(signInAPI: signInAPI, disposeBag: disposeBag)
                scheduler = TestScheduler(initialClock: 0)
                emailIsValidObserver = scheduler.createObserver(Bool.self)
                passwordIsValidObserver = scheduler.createObserver(Bool.self)
                signInButtonEnabledObserver = scheduler.createObserver(Bool.self)
                signInObserver = scheduler.createObserver(SignInResponse.self)

                emailText = scheduler.createHotObservable(
                    [.next(1, "test@"),
                     .next(3, "test@gmail.com")])

                emailIsValidExpectedEvents = [
                    .next(1, false),
                    .next(3, true)
                ]

                passwordText = scheduler.createHotObservable([.next(2, "asd"),
                                                               .next(3, "Asd123!!")])
                passwordIsValidExpectedEvents = [
                    .next(2, false),
                    .next(3, true)
                ]

                signInButtonTap = scheduler.createHotObservable([.next(4, ())])

                let signInResponse = SignInResponse(token: "fake_token")
                signInAction = scheduler.createColdObservable([.next(0, signInResponse)])
                signInAPI.signInReturnValue = signInAction.asObservable()

                signInButtonEnabledExpectedEvents = [
                    .next(0, false) , // start with initial value
                    .next(2, false) , //password invalid type  (didn't get in email type becasue password didn't get an initial event and combine latest doesn't work)
                    .next(3, false), //for valid email and invalid password type
                    .next(3, true)  //for valid password type
                ]

                signInExpectedEvents = [
                    .next(4, SignInResponse(token: "fake_token")),
                    .completed(4)
                ]

                //input
                sut.configure(emailText: emailText.asObservable(), passwordText: passwordText.asObservable(), signInButtonTap: signInButtonTap.asObservable())

                scheduler.scheduleAt(0, action: {
                    sut.emailIsValid.subscribe(emailIsValidObserver).disposed(by: disposeBag)
                    sut.passwordIsValid.subscribe(passwordIsValidObserver).disposed(by: disposeBag)
                    sut.signInButtonEnabled.subscribe(signInButtonEnabledObserver).disposed(by: disposeBag)
                    sut.signIn.subscribe(signInObserver).disposed(by: disposeBag)
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


extension SignInResponse: Equatable {
    public static func == (lhs: SignInResponse, rhs: SignInResponse) -> Bool {
        return lhs.token == rhs.token
    }
}
