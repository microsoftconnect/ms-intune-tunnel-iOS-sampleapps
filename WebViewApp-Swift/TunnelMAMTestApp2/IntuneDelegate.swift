//
//  IntuneDelegate.swift
//  TunnelMAMTestApp2
//
//  Created by Todd Bohman on 9/15/22.
//

import Foundation
import MobileAccessApi
import IntuneMAMSwift
import MSAL

class IntuneDelegate : NSObject, IntuneMAMEnrollmentDelegate {
    static var sharedDelegate: IntuneDelegate = IntuneDelegate()
    
    func launchEnrollment() -> Bool {
        IntuneMAMEnrollmentManager.instance().delegate = self
        let enrolledAccount = IntuneMAMEnrollmentManager.instance().enrolledAccount()
        if let enrolledAccount = enrolledAccount {
            NSLog("Microsoft Intune account \"\(enrolledAccount)\" is already enrolled. Skipping enrollment.")
            
            if let vpnConfig = self.getVpnConfig() {
                MobileAccessDelegate.sharedDelegate.setVpnConfiguration(vpnConfig: vpnConfig)
                MobileAccessDelegate.sharedDelegate.configureSDK()
            }
            else {
                NSLog("Failed to get vpn config from Intune")
            }
            
            return false
        }
        else {
            NSLog("No Microsoft Intune account is enrolled. Beginning enrollment.");
            IntuneMAMEnrollmentManager.instance().loginAndEnrollAccount(nil)
            return true
        }
    }
    
    func getVpnConfig() -> Dictionary<String, String>? {
        guard let identity = IntuneMAMEnrollmentManager.instance().enrolledAccount() else {
            NSLog("Failed to get current user")
            return nil
        }
        
        let appConfig = IntuneMAMAppConfigManager.instance().appConfig(forIdentity: identity)
        
        NSLog("Got Intune app config for user '\(identity)': \(String(describing: appConfig.fullData))")
        
        let connectionType = appConfig.stringValue(forKey: "com.microsoft.tunnel.connection_type", defaultValue: "")
        let connectionName = appConfig.stringValue(forKey: "com.microsoft.tunnel.connection_name", defaultValue: "")
        let serverAddress = appConfig.stringValue(forKey: "com.microsoft.tunnel.server_address", defaultValue: "")
        let proxyPacUrl = appConfig.stringValue(forKey: "com.microsoft.tunnel.proxy_pacurl", defaultValue: "")
        let proxyAddress = appConfig.stringValue(forKey: "com.microsoft.tunnel.proxy_address", defaultValue: "")
        let proxyPort = appConfig.numberValue(forKey: "com.microsoft.tunnel.proxy_port", defaultValue: NSNumber.init(value: -1))
        let trustedCertificates = appConfig.stringValue(forKey: "com.microsoft.tunnel.trusted_root_certificates", defaultValue: "")
        
        NSLog("Have connection type: \(connectionType)")
        NSLog("Have connection name: \(connectionName)")
        NSLog("Have server address: \(serverAddress)")
        NSLog("Have proxy pac url: \(proxyPacUrl)")
        NSLog("Have proxy address: \(proxyAddress)")
        NSLog("Have proxy port: \(proxyPort)")
        NSLog("Have trustedCertificates: \(trustedCertificates)")
        
        return [
            String.fromUtf8(kConnectionType): connectionType,
            String.fromUtf8(kConnectionName): connectionName,
            String.fromUtf8(kServerAddress): serverAddress,
            String.fromUtf8(kPacUrl): proxyPacUrl,
            String.fromUtf8(kProxyAddress): proxyAddress,
            String.fromUtf8(kProxyPort): proxyPort.stringValue,
            String.fromUtf8(kTrustedCertificates): trustedCertificates,
            String.fromUtf8("randomValue"): "don't fail"
        ];
    }
    
    private func acquireTokenInteractiveWithCallback(tokenCallback: @escaping TokenRequestCallback, application: MSALPublicClientApplication, resource: String) {
        RunLoop.main.perform {
            guard let vc = IntuneDelegate.getPresentationViewController() else {
                NSLog("No view controller for Intune authentication")
                tokenCallback(nil)
                return
            }
            
            let params = MSALWebviewParameters(authPresentationViewController: vc)
            params.webviewType = .wkWebView
            let interactive = MSALInteractiveTokenParameters(scopes: [resource], webviewParameters: params)
            interactive.promptType = .selectAccount
            
            application.acquireToken(with: interactive) { result, error in
                guard let result = result, error == nil else {
                    NSLog("Failed to get token interactively for gateway auth with error: \(String(describing: error))")
                    tokenCallback(nil)
                    return
                }
                
                tokenCallback(result.accessToken)
                return
            }
        }
   }
    
    private func getAuthToken(tokenCallback: @escaping TokenRequestCallback) -> Void {
        
        guard let path = Bundle.main.path(forResource: "Info", ofType: "plist") else {
            NSLog("Could not read main bundle path")
            tokenCallback(nil)
            return
        }
        guard let dictionary = NSDictionary(contentsOfFile: path) else {
            NSLog("Could not serialize Info.plist to a dictionary")
            tokenCallback(nil)
            return
        }
        let intuneSettings = dictionary["IntuneMAMSettings"] as! NSDictionary
        
        let resource = "3678c9e9-9681-447a-974d-d19f668fcd88/.default"
        let client = intuneSettings["ADALClientId"] as! String
        let redirectUri = intuneSettings["ADALRedirectUri"] as! String
        let authorityStr = intuneSettings["ADALAuthority"] as! String
        
        guard let authorityUrl = URL(string: authorityStr) else {
            //Handle error
            return
        }
        
        var objectCreationString = "MSALAuthority"
        do {
            
            let authority = try MSALAuthority(url: authorityUrl)
            let configuration = MSALPublicClientApplicationConfig.init(clientId: client, redirectUri: redirectUri, authority: authority)
            objectCreationString = "MSALPublicClientApplication"
            let application = try MSALPublicClientApplication(configuration: configuration)
            let params = MSALParameters()
            application.getCurrentAccount(with: params) { account, previousAccount, error in
                guard let account = account else {
                    NSLog("Failed to find cached token, accquiring new one interactively")
                    tokenCallback(nil)
                    return
                }
                if let error = error {
                    NSLog("Failed to find cached token due to error '\(error)', accquiring new one interactively")
                    tokenCallback(nil)
                    return
                }
                
                let silentParameters = MSALSilentTokenParameters(scopes: [resource], account: account)
                application.acquireTokenSilent(with: silentParameters) { result, error in
                    
                    guard let result = result, error  == nil else {
                        let nsError = error! as NSError
                        if nsError.domain == MSALErrorDomain &&
                            nsError.code == MSALError.interactionRequired.rawValue {
                            NSLog("SSO Token auth requires interactive login")
                            self.acquireTokenInteractiveWithCallback(tokenCallback: tokenCallback, application: application, resource: resource)
                        }
                        else {
                            NSLog("Failed to get token for gateway auth with error: \(String(describing: error))")
                            tokenCallback(nil)
                        }
                        return
                    }
                    
                    tokenCallback(result.accessToken)
                }
            }
        }
        catch {
            NSLog("Failed to create \(objectCreationString): \(error)")
            tokenCallback(nil)
            return
        }
    }
    
    func onTokenRequiredWithCallback(tokenCallback: @escaping TokenRequestCallback, failedToken: String) -> Void {
        DispatchQueue.main.async {
            self.getAuthToken(tokenCallback: tokenCallback)
        }
    }
    
    static func handleMSALResponse(response: URL, sourceApplication: String?) -> Bool {
        return MSALPublicClientApplication.handleMSALResponse(response, sourceApplication: sourceApplication)
    }
    
    private static func getPresentationViewController() -> UIViewController? {
        return topPresentingViewControllerFromWindow(window: UIApplication.shared.keyWindow)
    }
    
    private static func topPresentingViewControllerFromWindow(window: UIWindow?) -> UIViewController? {
        return topPresentingViewControllerFromController(viewController: window?.rootViewController)
    }
    
    private static func topPresentingViewControllerFromController(viewController: UIViewController?) -> UIViewController? {
        var viewController = viewController
        while viewController?.presentedViewController != nil {
            if viewController?.presentedViewController?.isBeingDismissed ?? false {
                return viewController
            }
            viewController = viewController?.presentedViewController
        }
        
        return viewController
    }
    
    func enrollmentRequest(with status: IntuneMAMEnrollmentStatus) {
        if let vpnConfig = self.getVpnConfig() {
            MobileAccessDelegate.sharedDelegate.setVpnConfiguration(vpnConfig: vpnConfig)
            MobileAccessDelegate.sharedDelegate.configureSDK()
        }
        
        // MobileAccessApi::Initialize is called during the singleton construction
        NSLog("\(#function) - status: \(status)")
    }
    
    func policyRequest(with status: IntuneMAMEnrollmentStatus) {
        NSLog("\(#function) - status: \(status)")
    }
    
    func unenrollRequest(with status: IntuneMAMEnrollmentStatus) {
        NSLog("\(#function) - status: \(status)")
    }
}

