//
//  SignInViewController.swift
//  MovieRama
//
//  Created by Eleni Papanikolopoulou on 22/02/2019.
//  Copyright © 2019 Eleni Papanikolopoulou. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SignInViewController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var rememberEmailSwitch: UISwitch!

    private let disposeBag =  DisposeBag()
    private var viewModel: SignInViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        signInButton.layer.cornerRadius = 5
        signInButton.layer.borderWidth = 1
        signInButton.layer.borderColor = UIColor.pineGreen.cgColor


        let email = emailTextfield.rx.text.asObservable().filter({ !$0.isEmptyOrNil }).unwrap()
        let password = passwordTextField.rx.text.asObservable().filter({ !$0.isEmptyOrNil }).unwrap()
        let signInButtonTap = signInButton.rx.tap.asObservable()
        let rememberEmail = rememberEmailSwitch.rx.isOn.asObservable()

        viewModel = SignInViewModel(signInAPI: SignInAPI(), disposeBag: disposeBag)
        viewModel.configure(emailText: email, passwordText: password, signInButtonTap: signInButtonTap, rememberEmail: rememberEmail)

        viewModel.emailIsValid.bind(to: emailErrorLabel.rx.isHidden).disposed(by: disposeBag)
        viewModel.passwordIsValid.bind(to: passwordErrorLabel.rx.isHidden).disposed(by: disposeBag)
        viewModel.signInButtonEnabled.bind(to: signInButton.rx.isEnabled).disposed(by: disposeBag)

        viewModel.signInAction
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (response) in
                self?.showAlert(for: response)
            }).disposed(by: disposeBag)

    }


    private func showAlert(for response: SignInResponse) {
        let alert = UIAlertController(title: "", message: "\(response.email) has signed in succesfully in the \(response.account) account!", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: NSLocalizedString("OK", value: "OK",
                                                                   comment: ""),
                                          style: .default,
                                          handler: nil)
        alert.addAction(defaultAction)
        present(alert, animated: false, completion: nil)
    }



}
