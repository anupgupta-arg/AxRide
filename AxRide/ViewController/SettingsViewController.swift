//
//  SettingsViewController.swift
//  AxRide
//
//  Created by Administrator on 7/17/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit
import MessageUI
import Stripe

class SettingsViewController: UITableViewController {
    
    var paymentHelper: PaymentMethodHelper?

    override func viewDidLoad() {
        super.viewDidLoad()

        // init payment method helper
        paymentHelper = PaymentMethodHelper(self)
        
        // show nav bar
        showNavbar(transparent: false)
        
        // hide empty cells
        self.tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // title
        self.title = "Settings"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // clear title
        self.title = " "
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            // edit profile
            let editProfileVC = SignupProfileViewController(nibName: "SignupProfileViewController", bundle: nil)
            editProfileVC.type = SignupProfileViewController.FROM_PROFILE
            self.navigationController?.pushViewController(editProfileVC, animated: true)
            
        case 1:
            //
            // cards and bank accounts
            //
            // go to payment setup page
            let userCurrent = User.currentUser!
            
            if userCurrent.type == UserType.customer {
                paymentHelper?.showPaymentMethod()
            }
            else if userCurrent.type == UserType.driver {
                let psVC = PaymentStripeViewController(nibName: "PaymentStripeViewController", bundle: nil)
                psVC.fromSetting = true
                self.navigationController?.pushViewController(psVC, animated: true)
            }
            
            break
            
        case 2:
            // rate app
            Utils.rateApp(appId: Config.appId, completion: { (_) in
            })
            
        case 3:
            // send feedback
            if !MFMailComposeViewController.canSendMail() {
                alertOk(title: "Mail", message: "Mail services are not available", cancelButton: "OK", cancelHandler: nil)
                return
            }
            
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            
            // Configure the fields of the interface.
            composeVC.setToRecipients(["blake.murray@driveaxleus.com"])
            composeVC.setSubject("Report a bug")
            composeVC.setMessageBody("", isHTML: false)
            
            // Present the view controller modally.
            self.present(composeVC, animated: true, completion: nil)
            
        case 4:
            // about the app
            let aboutVC = AboutViewController(nibName: "AboutViewController", bundle: nil)
            self.navigationController?.pushViewController(aboutVC, animated: true)
            
        case 5:
            // privacy policy
            let termVC = TermViewController(nibName: "TermViewController", bundle: nil)
            termVC.type = TermViewController.PRIVACY_POLICY
            self.navigationController?.pushViewController(termVC, animated: true)
            
        case 6:
            // terms & conditions
            let termVC = TermViewController(nibName: "TermViewController", bundle: nil)
            termVC.type = TermViewController.TERMS_FROM_SETTING
            self.navigationController?.pushViewController(termVC, animated: true)
            
        case 7:
            // log out
            doSignOut()
            
        default:
            break
        }
    }
    
    private func doSignOut() {
        FirebaseManager.signOut()
        User.currentUser = nil
        
        // go to sign in page
        let signinVC = SigninViewController(nibName: "SigninViewController", bundle: nil)
        self.navigationController?.setViewControllers([signinVC], animated: true)
    }
}

extension SettingsViewController : MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        // Check the result or perform other tasks.
        
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
}

extension SettingsViewController : ARPaymentMethodDelegate {
    func getViewController() -> UIViewController {
        return self
    }
    
    func paymentMethodsViewController(_ paymentMethodsViewController: STPPaymentMethodsViewController, didFailToLoadWithError error: Error) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func paymentMethodsViewControllerDidFinish(_ paymentMethodsViewController: STPPaymentMethodsViewController) {
        // close
        self.navigationController?.popViewController(animated: true)
    }
    
    func paymentMethodsViewControllerDidCancel(_ paymentMethodsViewController: STPPaymentMethodsViewController) {
        // close
        self.navigationController?.popViewController(animated: true)
    }
    
}

