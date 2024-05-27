//
//  UpdateService.swift
//  Auxby
//
//  Created by Eduard Hutu on 22.03.2023.
//

import Foundation
import Combine

class UpdateService {
    var timer: Timer?
    static let shared = UpdateService()
    @Published private(set) var getOffersState = RequestState<[Offer]>.idle
    @Published private(set) var getCategoriesState = RequestState<[CategoryDetails]>.idle
    var cancellables: Set<AnyCancellable> = []
    
    init() {
        setObservable()
    }
    
    func startTimer() {
            getOffersBy(getIds())
            getCategoriesDetails()
            timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [unowned self] _ in
                getOffersBy(getIds())
            }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func setObservable() {
        $getOffersState.sink { [unowned self] state in
            switch state {
            case .succeed(let offers):
                replaceOffers(newOffers: offers)
                NotifyCenter.post(.updateOffers)
            case .failed(let err):
                print(err.localizedDescription)
            default:
                break
            }
        }.store(in: &cancellables)
        
        $getCategoriesState.sink {  state in
            switch state {
            case .succeed(let newCategories):
                Offline.encode(newCategories, key: .categoryDetails)
            case .failed(let err):
                print(err.localizedDescription)
            default: break
            }
        }.store(in: &cancellables)
    }
    
    func getIds() -> [Int] {
        var ids: [Int] = []
        if let offers = Offline.decode(key: .offers, type: [Offer].self) {
            offers.forEach {
                if $0.isOnAuction {
                    ids.append($0.id)
                }
            }
        }
        return ids
    }
    
    func replaceOffers(newOffers: [Offer]) {
        if var offers = Offline.decode(key: .offers, type: [Offer].self) {
            newOffers.forEach { newOffer in
                if let index = offers.firstIndex(where: { $0.id == newOffer.id}) {
                    offers[index] = newOffer
                }
            }
            Offline.encode(offers, key: .offers)
            replaceFavorites(newOffers: newOffers)
            replaceUserOffers(newOffers: newOffers)
            replaceUserBids(newOffers: newOffers)
        }
    }
    
    func replaceFavorites(newOffers: [Offer]) {
        if var offers = Offline.decode(key: .favorites, type: [Offer].self) {
            newOffers.forEach { newOffer in
                if let index = offers.firstIndex(where: { $0.id == newOffer.id}) {
                    offers[index] = newOffer
                }
            }
            Offline.encode(offers, key: .favorites)
        }
    }
    
    func replaceUserOffers(newOffers: [Offer]) {
        if var offers = Offline.decode(key: .userOffers, type: [Offer].self) {
            newOffers.forEach { newOffer in
                if let index = offers.firstIndex(where: { $0.id == newOffer.id}) {
                    offers[index] = newOffer
                }
            }
            Offline.encode(offers, key: .userOffers)
        }
    }
    
    func replaceUserBids(newOffers: [Offer]) {
        if var offers = Offline.decode(key: .userBids, type: [Offer].self) {
            newOffers.forEach { newOffer in
                if let index = offers.firstIndex(where: { $0.id == newOffer.id}) {
                    offers[index] = newOffer
                }
            }
            Offline.encode(offers, key: .userBids)
        }
    }
    
    func getOffersBy(_ ids: [Int]) {
        if !ids.isEmpty {
            getOffersState = .loading
            Network.shared.request(endpoint: .getOffersByIDs(ids: ids))
                .assign(to: &$getOffersState)
        }
    }
    
    func getCategoriesDetails() {
        getCategoriesState = .loading
        Network.shared.request(endpoint: .getCategoriesDetails)
            .assign(to: &$getCategoriesState)
    }
}
