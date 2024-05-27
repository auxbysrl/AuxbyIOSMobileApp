//
//  ReportVM.swift
//  Auxby
//
//  Created by Eduard Hutu on 16.05.2023.
//

import Foundation
import Combine

class ReportVM {
    var offerID: Int
    var type: String = ""
    var content: String = ""
    var typeList = ["Abuse", "Deceptive ad", "Dirty language"]
    @Published private(set) var getReportState = RequestState<Void>.idle
    var cancellables: Set<AnyCancellable> = []
    
    init(offerID: Int) {
        self.offerID = offerID
    }
    
    func sendReport() {
        getReportState = .loading
        Network.shared.voidRequest(endpoint: .reportOffer(id: offerID, type: type, comment: content))
            .assign(to: &$getReportState)
    }
}
