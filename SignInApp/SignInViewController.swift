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

        viewModel = SignInViewModel(signInAPI: SignInAPI(), disposeBag: disposeBag)
        viewModel.configure(emailText: email, passwordText: password, signInButtonTap: signInButtonTap)

        viewModel.emailIsValid.bind(to: emailErrorLabel.rx.isHidden).disposed(by: disposeBag)
        viewModel.passwordIsValid.bind(to: passwordErrorLabel.rx.isHidden).disposed(by: disposeBag)
        viewModel.signInButtonEnabled.bind(to: signInButton.rx.isEnabled).disposed(by: disposeBag)

        viewModel.signIn
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] (response) in
                    self?.showAlert(for: response)
                }, onError: { [weak self] error in
                    self?.showAlert(for: error)
                }
            ).disposed(by: disposeBag)

    }


    private func showAlert(for response: SignInResponse) {
        let alert = UIAlertController(title: "", message: "You have signed in succesfully!", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: NSLocalizedString("OK", value: "OK",
                                                                   comment: ""),
                                          style: .default,
                                          handler: nil)
        alert.addAction(defaultAction)
        present(alert, animated: false, completion: nil)
    }

    private func showAlert(for error: Error) {
        let alert = UIAlertController(title: "", message: "\(error.localizedDescription)", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: NSLocalizedString("OK", value: "OK",
                                                                   comment: ""),
                                          style: .default,
                                          handler: nil)
        alert.addAction(defaultAction)
        present(alert, animated: false, completion: nil)
    }

}
