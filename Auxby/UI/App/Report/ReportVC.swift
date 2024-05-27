//
//  ReportVC.swift
//  Auxby
//
//  Created by Eduard Hutu on 13.03.2023.
//

import UIKit
import L10n_swift

class ReportVC: UIViewController {
    
// MARK: - IBOutlets
    @IBOutlet private var checedImages: [UIImageView]!
    @IBOutlet private weak var reportView: UIView!
    @IBOutlet private weak var reportTextView: UITextView!
    @IBOutlet private weak var sendButton: MainButtonView!
    
    // MARK: - Public properties
    var vm: ReportVM!
    
    // MARK: - Private properties
    private var indicator: ActivityIndicator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        setObservable()
    }
    
    @IBAction func selectReport(_ sender: UIButton) {
        checedImages.forEach {
            let name = $0.tag == sender.tag ? "FilledCheck" : "EmptyCheck"
            $0.image = UIImage(named: name)
            vm.type = vm.typeList[sender.tag]
        }
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        dismissVC()
    }
}

private extension ReportVC {
    func setView() {
        hideKeyboardWhenTappedAround()
        delay(0.1) {
            self.reportView.roundCorners(corners: [.topLeft, .topRight], radius: 25)
        }
        reportTextView.isScrollEnabled = false
        reportTextView.textContainer.maximumNumberOfLines = 3
        reportTextView.textContainer.lineBreakMode = .byTruncatingTail
        sendButton.set(title: "send".l10n()) {
            self.vm.sendReport()
        }
    }
    
    func setObservable() {
        vm.$getReportState.sink { [unowned self] state in
            state.setStateActivityIndicator(&indicator)
            switch state {
            case .succeed:
                let congratsVC = CongratsVC.asVC() as! CongratsVC
                congratsVC.back = {
                    self.dismissVC()
                }
                presentVC(congratsVC)
            case .failed(let err):
                UIAlert.showOneButton(message: "somethingWentWrong".l10n())
                print(err.localizedDescription)
            default: break
            }
        }.store(in: &vm.cancellables)
    }
}
extension ReportVC: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        vm.content = textView.text
    }
}



