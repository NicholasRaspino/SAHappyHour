//
//  InfoViewController.swift
//  HappyHourInterfaceMVP
//
//  Created by Nicholas Raspino on 9/30/19.
//  Copyright © 2019 Nicholas Raspino. All rights reserved.
//

import UIKit
import MessageUI

class InfoViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    // MARK: - Properties
    
    var text: String?
    
    // MARK: - Interface Builder
    
    @IBOutlet weak var basicInformation: UILabel!
    @IBOutlet weak var lineBreakTwo: UILabel!
    @IBAction func websiteButtonPressed(_ sender: UIButton) {
        goToWebsite()
    }
    @IBOutlet weak var lineBreak: UILabel!
    @IBOutlet weak var privacyPolicy: UILabel!
    @IBOutlet weak var informationWeCollect: UILabel!
    @IBOutlet weak var iCloud: UILabel!
    @IBOutlet weak var informationUsage: UILabel!
    @IBOutlet weak var security: UILabel!
    @IBOutlet weak var thirdPartyLinks: UILabel!
    @IBOutlet weak var californiaPrivacy: UILabel!
    @IBOutlet weak var childrensPrivacy: UILabel!
    @IBOutlet weak var europeanPrivacy: UILabel!
    @IBOutlet weak var internationalTransfers: UILabel!
    @IBOutlet weak var yourConsent: UILabel!
    @IBOutlet weak var contactingUs: UILabel!
    @IBOutlet weak var lineBreakThree: UILabel!
    @IBAction func emailButtonPressed(_ sender: UIButton) {
        openEmail()
    }
    @IBOutlet weak var changesToThisPolicy: UILabel!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Info"
        basicInformation.text = "\nWe try to keep content up to date, but we cannot guarantee the accuracy of restaurant or menu information. Please contact individual restaurants to confirm hours and specials. If you discover content that is out of date, please use our report feature to bring the issue to our attention.\n"
        lineBreak.text = " "
        lineBreakTwo.text = " "
        privacyPolicy.text = "\nThis policy applies to all information collected or submitted on NJR Development LLC’s website and our iPhone app SA Happy Hour.\n"
        informationWeCollect.text = "\nWe request access to track location in order to provide location-based services within the app. Location information is not transmitted or stored outside of the app. If you wish to change our access, you may do so in your device’s settings.\n\nOur server software may store basic technical information, such as your IP address, in temporary memory or logs.\n"
        iCloud.text = "\nOur app stores some of your data in Apple’s iCloud service, such as user submitted issue reports, to help us maintain the app.\n"
        informationUsage.text = "\nWe use the information we collect to operate and improve our website and app.\n\nWe do not share personal information with outside parties. We may share anonymous, aggregate statistics with outside parties, such as how many people use our services.\n\nWe may disclose your information in response to subpoenas, court orders, or other legal requirements; to exercise our legal rights or defend against legal claims; to investigate, prevent, or take action regarding illegal activities, suspected fraud or abuse, violations of our policies; or to protect our rights and property.\n\nIn the future, we may sell to, buy, merge with, or partner with other businesses. In such transactions, user information may be among the transferred assets.\n"
        security.text = "\nWe implement a variety of security measures to help keep your information secure. For instance, all communication with our website requires HTTPS.\n"
        thirdPartyLinks.text = "\nWe displays links and content from third-party websites. These websites have their own independent privacy policies, and we have no responsibility or liability for their content or activities.\n"
        californiaPrivacy.text = "\nWe comply with the California Online Privacy Protection Act. We therefore will not distribute your personal information to outside parties without your consent.\n"
        childrensPrivacy.text = "\nWe never collect or maintain information at our website from those we actually know are under 13, and no part of our website is structured to attract anyone under 13.\n"
        europeanPrivacy.text = "\nBy using our website or app and providing your information, you authorize us to collect, use, and store your information outside of the European Union.\n"
        internationalTransfers.text = "\nInformation may be processed, stored, and used outside of the country in which you are located. Data privacy laws vary across jurisdictions, and different laws may be applicable to your data depending on where it is processed, stored, or used.\n"
        yourConsent.text = "\nBy using our site or app, you consent to our privacy policy.\n"
        contactingUs.text = "\nIf you have questions regarding this privacy policy, you may email us at:\n"
        lineBreakThree.text = " "
        changesToThisPolicy.text = "\nIf we decide to change our privacy policy, we will post those changes on this page. Summary of changes so far:\n\nOctober 15, 2019: First published.\n"
    }
    
    // MARK: - Methods
    
    func goToWebsite() {
        if let url = URL(string: "http://njrdevelopmentllc.com") {
            UIApplication.shared.open(url)
        }
    }
    
    func openEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["info@njrdevelopmentllc.com"])
            present(mail, animated: true)
        }
    }

    // MARK: - MFMailCompose View Controller Delegate

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
