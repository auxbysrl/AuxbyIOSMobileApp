//
//  MyOffersVC.swift
//  Auxby
//
//  Created by Eduard Hutu on 27.03.2023.
//

import UIKit

class MyOffersVC: PageControllerDataSource {
    
    // MARK: - IBOutlets
    @IBOutlet weak var segmentControl: SegmentControlView!
    @IBOutlet weak var containerView: UIView!
    
    // MARK: - Private properties
    private var lastSelectedSegmentIndex = 0
    private var activeOffers: ActiveOffersVC!
    private var innactiveOffers: InnactiveOffersVC!
    
    var vm = MyOffersVM()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let _ = Offline.currentUser {
            
        } else {
            popVC()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
    }
    
    // MARK: - IBActions
    @IBAction func back(_ sender: UIButton) {
        popVC()
    }
}

private extension MyOffersVC {
    func setView() {
        self.hideKeyboardWhenTappedAround()
        setPageControllers()
        setObservable()
    }
    
    func setObservable() {
        NotifyCenter.observable(for: .updateOffers).sink { [unowned self] _ in
            vm.getUsersOffers()
        }.store(in: &vm.cancellables)
    }
    
    func setPageControllers() {
        setPageVCs()
        
        segmentControl.action = { [unowned self] firstIndex in
            let index = firstIndex ? 0 : 1
            lastSelectedSegmentIndex = index
            goTo(index: index)
        }
        vm.selectAction = { [unowned self] firstIndex in
            segmentControl.setButtons(isFirst: firstIndex)
        }
        setPageController(vcs: [activeOffers, innactiveOffers], containerView: containerView)
        goTo(index: lastSelectedSegmentIndex, animated: false)
        
    }
    
    func setPageVCs() {
        if activeOffers == nil {
            activeOffers = ActiveOffersVC.asVC() as? ActiveOffersVC
            activeOffers.vm = vm
        }
        if innactiveOffers == nil {
            innactiveOffers = InnactiveOffersVC.asVC() as? InnactiveOffersVC
            innactiveOffers.vm = vm
        }
    }
}
