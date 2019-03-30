//
//  SignInViewModelRxTestSpec.swift
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

class SignInViewModelParseEventsAndTimesSpec: QuickSpec {

    override func spec() {
        describe("The SignInViewModel") {

            var sut: SignInViewModel!

            var emailText: TestableObservable<String>!
            var expectedEmailIsValidEvents: [Recorded<Event<Bool>>]!
            var emailIsValidObserver: TestableObserver<Bool>!

            var passwordText: TestableObservable<String>!
            var expectedPaswordIsValidEvents: [Recorded<Event<Bool>>]!
            var passwordIsValidObserver: TestableObserver<Bool>!

            var rememberEmail: TestableObservable<Bool>!

            var signInButtonTap: TestableObservable<Void>!
            var signInButtonEnabledObserver: TestableObserver<Bool>!
            var signInEnabledExpectedEvents: [Recorded<Event<Bool>>]!

            var signInActionObserver: TestableObserver<SignInResponse>!
            var signInActionExpectedEvents: [Recorded<Event<SignInResponse>>]!

            var signInAPI: SignInAPIFake!
            var disposeBag: DisposeBag!
            var scheduler: TestScheduler!

            beforeEach {
                signInAPI = SignInAPIFake()
                disposeBag = DisposeBag()
                sut = SignInViewModel(signInAPI: signInAPI, disposeBag: disposeBag)
                scheduler = TestScheduler(initialClock: 0)
                emailIsValidObserver = scheduler.createObserver(Bool.self)
                passwordIsValidObserver = scheduler.createObserver(Bool.self)
                signInActionObserver = scheduler.createObserver(SignInResponse.self)

                let emails = ["e1": "test@", "e2": "test@gmail.com"]
                let passwords = ["p1": "asd", "p2": "Asd123!!"]
                let rememberEmailEvent = ["r1": false]
                let signInButtonClick = ["s1": ()]

                let emailEvents =  scheduler.parseEventsAndTimes(timeline: "---e1----e2-----", values: emails).first!
                let passwordEvents =  scheduler.parseEventsAndTimes(timeline: "-----p1-----p2-----", values: passwords).first!
                let rememberEmailEvents = scheduler.parseEventsAndTimes(timeline: "-----------------r1---", values: rememberEmailEvent).first!
                let signInButtonTapEvents = scheduler.parseEventsAndTimes(timeline: "---------------------------s1-", values: signInButtonClick).first!

                let emailIsValid = ["v1": false, "v2": true]
                let passwordIsValid = ["u1" :false, "u2": true]
                let signInButtonEnabled = ["b1": false, "b2": false, "b3": false, "b4" :true]
                let signInResponseEvents = ["x1": SignInResponse(email: "test@gmail.com", account: "workable")]

                expectedEmailIsValidEvents = scheduler.parseEventsAndTimes(timeline: "---v1----v2-----", values: emailIsValid).first!
                expectedPaswordIsValidEvents = scheduler.parseEventsAndTimes(timeline: "-----u1-----u2-----", values: passwordIsValid).first!

                //see explanation in previous test
                //b3b4 => two events next to each other => limitation
                signInEnabledExpectedEvents = scheduler.parseEventsAndTimes(timeline: "b1---b2--b3-b4--", values: signInButtonEnabled).first!
                signInActionExpectedEvents = scheduler.parseEventsAndTimes(timeline: "---------------------------------x1-", values: signInResponseEvents).first!

                emailText = scheduler.createColdObservable(
                    emailEvents)
                passwordText = scheduler.createColdObservable(passwordEvents)
                rememberEmail = scheduler.createColdObservable(rememberEmailEvents)
                signInButtonTap = scheduler.createColdObservable(signInButtonTapEvents)

                sut.configure(emailText: emailText.asObservable(), passwordText: passwordText.asObservable(), signInButtonTap: signInButtonTap.asObservable(), rememberEmail: rememberEmail.asObservable())


                emailIsValidObserver = scheduler.record(source: sut.emailIsValid)
                passwordIsValidObserver = scheduler.record(source: sut.passwordIsValid)
                signInButtonEnabledObserver = scheduler.record(source: sut.signInButtonEnabled)
                signInActionObserver = scheduler.record(source: sut.signInAction)

                scheduler.scheduleAt(33, action: {
                    signInAPI.signInReturnValue.on(.next(SignInResponse(email: "test@gmail.com", account: "workable")))
                })
                scheduler.start()
            }

            it("should get the correct signInButtonEnabledEvents") {
                expect(signInButtonEnabledObserver.events).to(equal(signInEnabledExpectedEvents))
            }

            it("should get the correct emailIsValidExpectedEvents") {
                expect(emailIsValidObserver.events).to(equal(expectedEmailIsValidEvents))
            }


            it("should get the correct passwordIsValidExpectedEvents") {
                expect(passwordIsValidObserver.events).to(equal(expectedPaswordIsValidEvents))
            }

            it("a sign in request should be made") {
                expect(signInAPI.signInCalled).to(beTrue())
            }

            it("should get the correct signInActionObserver") {
                //cannot do expect(signInActionObserver.events).to(equal(signInActionExpectedEvents)) because it will get a completed() event and cannot have 2 types of events inside signInResponseEvents
                expect(signInActionObserver.events.first).to(equal(signInActionExpectedEvents.first))
            }
        }
    }

}
