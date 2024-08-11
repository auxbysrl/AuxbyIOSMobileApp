//
//  ConversationVC.swift
//  Auxby
//
//  Created by Eduard Hutu on 30.05.2023.
//

import UIKit
import L10n_swift

class ConversationVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var messageHeight: NSLayoutConstraint!
    @IBOutlet weak var placeHolderLabel: UILabel!
    
    @IBOutlet weak var offerImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var offerTitleLabel: UILabel!
    @IBOutlet weak var activeLabel: UILabel!
    @IBOutlet weak var messageSV: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK: - Public properties
    var vm: ConversationVM!
    var timer: Timer?
    
    // MARK: - Private properties
    private var indicator: ActivityIndicator?
    
    // MARK: Overriden Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [unowned self] _ in
            vm.getMessages()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        vm.getMessages()
        setReadTime()
        messageTextView.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - IBActions
    @IBAction func back(_ sender: UIButton) {
        popVC()
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        if !vm.text.isEmpty {
           vm.sendMessage(message: vm.text)
            vm.text = ""
            messageTextView.text = ""
            textViewDidChange(messageTextView)
            textViewDidEndEditing(messageTextView)
           
        }
    }
}
// MARK: - Private Methods
private extension ConversationVC {
    func setView() {
        hideKeyboardWhenTappedAround()
        bottomView.setBottomConstraintToTopOfKeyboard()
        messageTextView.textContainerInset = UIEdgeInsets(top: 12, left: 16, bottom: 0, right: 16)
        placeHolderLabel.text = "message".l10n() + "..."
        setTopView()
        setMessages()
        setObservable()
    }
    
    func setReadTime() {
        if var readChats = Offline.decode(key: .readedChats, type: [CompleteChat].self) {
            if let index = readChats.firstIndex(where: { $0.chat.roomId == vm.chat.roomId }) {
                readChats[index] = CompleteChat(chat: vm.chat, readDate: Date())
                Offline.encode(readChats, key: .readedChats)
            } else {
                readChats.append(CompleteChat(chat: vm.chat, readDate: Date()))
                Offline.encode(readChats, key: .readedChats)
            }
        } else {
            let readChats = [CompleteChat(chat: vm.chat, readDate: Date())]
            Offline.encode(readChats, key: .readedChats)
        }
    }
    
    func setObservable() {
        NotifyCenter.observable(for: .newMessage).sink { [unowned self] in
            vm.getMessages()
        }.store(in: &vm.cancellables)
        vm.$sendMessagesState.sink { [unowned self] state in
            state.setStateActivityIndicator(&indicator)
            switch state {
            case .succeed:
                vm.getMessages()
                setReadTime()
            case .failed(let err):
                UIAlert.showOneButton(message: "errorSending".l10n())
                print(err.localizedDescription)
            default:
                break
            }
        }.store(in: &vm.cancellables)
        
        vm.$getMessagesState.sink { [unowned self] state in
            if vm.isFirst {
                state.setStateActivityIndicator(&indicator)
            }
            switch state {
            case .succeed(let messages):
                vm.messages = messages
                setReadTime()
                splitMessagesByDate()
                vm.isFirst = false
                NotifyCenter.post(.updateNotifications)
            case .failed(let err):
                if err.errorStatus == 403 {
                    UIAlert.showOneButton(message: "expireToken".l10n()) {
                        self.popVC()
                    }
                } else {
                    UIAlert.showOneButton(message: "somethingWentWrong".l10n()) {
                        self.popVC()
                    }
                }
                print(err.localizedDescription)
            default:
                break
            }
        }.store(in: &vm.cancellables)
    }
    
    func setTopView() {
        offerImage.setImage(from: vm.chat.chatImage)
        if let currentUser = Offline.currentUser {
            if vm.chat.guest == "\(currentUser.firstName) \(currentUser.lastName)" {
                userNameLabel.text = vm.chat.host
            } else {
                userNameLabel.text = vm.chat.guest
            }
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "ro_RO")
        guard let givenDate = dateFormatter.date(from: vm.chat.lastMessageTime) else {
            fatalError("Invalid date format")
        }
        dateFormatter.dateFormat = "dd.MM"
        let formattedDateString = dateFormatter.string(from: givenDate)
        activeLabel.text = formattedDateString
        offerTitleLabel.text = vm.chat.roomName
    }
    
    func splitMessagesByDate() {
        vm.lastDate = ""
        vm.completeListMessages = []
        for message in vm.messages {
            if vm.lastDate == "" {
                vm.lastDate = message.messageTime
                vm.completeListMessages.append(Message(messageText: "", sender: message.sender, messageTime: vm.lastDate))
            } else {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                dateFormatter.locale = Locale(identifier: "ro_RO")
                guard let lastDate = dateFormatter.date(from: vm.lastDate), let currentDate = dateFormatter.date(from: message.messageTime) else {
                    fatalError("Invalid date format")
                }
                
                if lastDate.day != currentDate.day {
                    vm.completeListMessages.append(Message(messageText: "", sender: message.sender, messageTime: message.messageTime))
                }
            }
            
            vm.completeListMessages.append(message)
            vm.lastDate = message.messageTime
        }
        setMessages()
    }
    
    func setMessages() {
        messageSV.removeAllSubviews()
        if let user = Offline.currentUser {
            for currentMessage in vm.completeListMessages {
                if currentMessage.messageText == "" {
                    let view = DateMessageView()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    dateFormatter.locale = Locale(identifier: "ro_RO")
                    guard let currentDate = dateFormatter.date(from: currentMessage.messageTime) else {
                        fatalError("Invalid date format")
                    }
                    let calendar = Calendar.current
                    //let now = Date()
                    var dateString = ""

                    if calendar.isDateInToday(currentDate) {
                        dateString = "today".l10n()
                    } else if calendar.isDateInYesterday(currentDate) {
                        dateString = "yesterday".l10n()
                    } else {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "dd.MM"
                        dateString = formatter.string(from: currentDate)
                    }
                    view.setCell(date: dateString)
                    messageSV.addArrangedSubview(view)
                } else {
                    if currentMessage.sender == user.email {
                        let view = SentMessageView()
                        view.setCell(message: currentMessage)
                        messageSV.addArrangedSubview(view)
                        
                    } else {
                        let view = RecivedMessageView()
                        view.setCell(message: currentMessage)
                        messageSV.addArrangedSubview(view)
                    }
                }
            }
        }
        messageSV.layoutIfNeeded()
        delay(0.1) {
            self.scrollView.scrollToBottom()
        }
    }
}

extension ConversationVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        vm.text = textView.text
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        if newSize.height <= (6 * textView.font!.lineHeight) {
            if newSize.height > 44 {
                textView.isScrollEnabled = false
                messageHeight.constant = newSize.height + 12
                delay(0.1) {
                    self.scrollView.scrollToBottom()
                }
            } else {
                messageHeight.constant = 44
                delay(0.1) {
                    self.scrollView.scrollToBottom()
                }
            }
        } else {
            textView.isScrollEnabled = true
            textView.showsVerticalScrollIndicator = true
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        delay(0.1) {
            self.scrollView.scrollToBottom()
        }
        placeHolderLabel.isHidden = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        placeHolderLabel.isHidden = !textView.text.isEmpty
        delay(0.1) {
            self.scrollView.scrollToBottom()
        }
    }
}
