//
//  PostComposer.swift
//  SwiftShare
//
//  Created by Dan ILCA on 08/10/2019.
//  Copyright © 2019 Dan Ilca. All rights reserved.
//

import UIKit
import Social
import MessageUI
import RxSwift

public enum PostType: String {
    case facebook
    case twitter
    case linkedin
    case whatsapp
    case mail
}

/// Post / share a message using supported social networking services or mail.
@available(iOSApplicationExtension, unavailable)
open class PostComposer {

    private let urlAllowedCharset: CharacterSet = {
        var charSet = CharacterSet.urlQueryAllowed
        charSet.insert(charactersIn: "#")
        return charSet
    }()

    // swiftlint:disable weak_delegate
    private var mailComposerDelegate: MFMailComposeViewControllerDelegate?
    // swiftlint:enable weak_delegate

    public init() {}

    /// Share a message (text and/or url) using one of the iOS standard or custom services.
    /// Implemented using UIActivityViewController.
    open func selectableShare(text: String?, url: URL? = nil, presenter: UIViewController) -> Single<Bool> {
        return Single<Bool>.create(subscribe: { (event) -> Disposable in
            var items: [Any] = []
            if let text = text {
                items.append(text)
            }
            if let url = url {
                items.append(url)
            }
            let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
            activityVC.completionWithItemsHandler = { (_: UIActivity.ActivityType?, completed: Bool, _: [Any]?, error: Error?) in
                if let error = error {
                    event(.failure(error))
                } else if completed {
                    event(.success(true))
                } else {
                    event(.success(false))
                }
            }
            presenter.present(activityVC, animated: true)
            return Disposables.create()
        })
    }

    /// Post a message (text and/or url) on Facebook, Twitter, LinkedIn or WhatsApp.
    open func share(text: String, url: String? = nil, type: PostType, presenter: UIViewController) -> Single<Bool> {
        return Single<Bool>.create(subscribe: { (event) -> Disposable in
            switch type {
            case .facebook, .twitter:
                self.shareBySocialFramework(text: text, url: url, type: type, presenter: presenter, event: event)
            case .linkedin, .whatsapp:
                self.shareByURLScheme(message: url ?? text, type: type, event: event)
            case .mail:
                event(.failure(AppDataError.configurationError(reason: "Incorrect call, please use shareByMail")))
            }
            return Disposables.create()
        })
    }

    private func shareBySocialFramework(text: String,
                                        url: String? = nil,
                                        type: PostType,
                                        presenter: UIViewController,
                                        event: @escaping ((SingleEvent<Bool>) -> Void)) {
        if let serviceType = self.getSLServiceTypeFor(type) {
            if let composeVC = SLComposeViewController(forServiceType: serviceType) {
                composeVC.setInitialText(text)
                if let urlString = url?.addingPercentEncoding(withAllowedCharacters: urlAllowedCharset),
                   let url = URL(string: urlString) {
                    composeVC.add(url)
                }
                composeVC.completionHandler = { result in
                    switch result {
                    case .done:
                        event(.success(true))
                    case .cancelled:
                        if (type == .facebook), let url = URL(string: "fb://"), !UIApplication.shared.canOpenURL(url) {
                            event(.failure(AppDataError.unsupportedOperation(reason: "Cannot open app for share type: \(type)")))
                        } else if (type == .twitter), let url = URL(string: "twitter://"), !UIApplication.shared.canOpenURL(url) {
                            event(.failure(AppDataError.unsupportedOperation(reason: "Cannot open app for share type: \(type)")))
                        } else {
                            event(.success(false))
                        }
                    @unknown default:
                        event(.failure(AppDataError.unknownError(reason: "Unknown result")))
                    }
                }
                presenter.present(composeVC, animated: true)
            } else {
                event(.failure(AppDataError.unknownError(reason: "Failed to create composer for social networking service type: \(type)")))
            }
        } else {
            event(.failure(AppDataError.unknownError(reason: "No social networking service for type: \(type)")))
        }
    }

    private func getSLServiceTypeFor(_ type: PostType) -> String? {
        switch type {
        case .facebook:
            return "com.apple.social.facebook"
        case .twitter:
            return "com.apple.social.twitter"
        default:
            return nil
        }
    }

    private func shareByURLScheme(message: String, type: PostType, event: @escaping ((SingleEvent<Bool>) -> Void)) {
        if let prefix = self.getShareURLPrefix(type: type) {
            if let encodedMessage = message.addingPercentEncoding(withAllowedCharacters: urlAllowedCharset),
                let shareURL = URL(string: prefix + encodedMessage) {
                if UIApplication.shared.canOpenURL(shareURL) {
                    UIApplication.shared.open(shareURL)
                    event(.success(true))
                } else {
                    event(.failure(AppDataError.unsupportedOperation(reason: "Cannot open app for URL scheme share type: \(type)")))
                }
            } else {
                event(.failure(AppDataError.unknownError(reason: "Failed to create URL for message: \(message)")))
            }
        } else {
            event(.failure(AppDataError.unknownError(reason: "Unsupported URL scheme share type: \(type)")))
        }
    }

    private func getShareURLPrefix(type: PostType) -> String? {
        switch type {
        case .twitter:
            return "twitter://post?message="
        case .linkedin:
            return "https://www.linkedin.com/shareArticle?url="
        case .whatsapp:
            return "whatsapp://send?text="
        default:
            return nil
        }
    }

    /// Post a message using mail.
    open func shareByMail(subject: String, message: String, isHTML: Bool, presenter: UIViewController) -> Single<Bool> {
        return Single<Bool>.create(subscribe: { (event) -> Disposable in
            if MFMailComposeViewController.canSendMail() {
                let mailComposer = MFMailComposeViewController()
                mailComposer.setSubject(subject)
                mailComposer.setMessageBody(message, isHTML: isHTML)
                self.mailComposerDelegate = MailComposerDelegate(event: event)
                mailComposer.mailComposeDelegate = self.mailComposerDelegate
                presenter.present(mailComposer, animated: true)
            } else {
                event(.failure(AppDataError.unsupportedOperation(reason: "Cannot send mail")))
            }
            return Disposables.create()
        })
    }

    private class MailComposerDelegate: NSObject, MFMailComposeViewControllerDelegate {

        private let event: ((SingleEvent<Bool>) -> Void)

        init(event: @escaping ((SingleEvent<Bool>) -> Void)) {
            self.event = event
        }

        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true) {
                switch result {
                case .failed:
                    self.event(.failure(AppDataError.unknownError(reason: "Failed to send email to contact address")))
                case .sent:
                    self.event(.success(true))
                case .cancelled, .saved:
                    self.event(.success(false))
                @unknown default:
                    self.event(.failure(AppDataError.unknownError(reason: "Unknown result")))
                }
            }
        }
    }
}
