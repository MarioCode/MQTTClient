//
//  SettingsTableViewController.swift
//  MQTTClient
//
//  Created by Anton Makarov on 11.07.2018.
//  Copyright © 2018 Anton Makarov. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var hostField: UITextField!
    @IBOutlet weak var portField: UITextField!
    @IBOutlet weak var clientIDField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var keppAliveField: UITextField!
    @IBOutlet weak var timeOutField: UITextField!
    
    @IBOutlet weak var cleanSwitch: UISwitch!
    @IBOutlet weak var reconnectSwitch: UISwitch!
    @IBOutlet weak var sslSwitch: UISwitch!
    
    var isChanged = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboard()
        
        title = "Settings"
        navigationController?.navigationBar.isHidden = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveSettings))
        
        hostField.text = MqttSettings.shared.host
        portField.text = MqttSettings.shared.port
        clientIDField.text = MqttSettings.shared.clientID
        keppAliveField.text = MqttSettings.shared.keepAlive
        timeOutField.text = MqttSettings.shared.connectionTimeOut
        passwordField.text = MqttSettings.shared.password
        userNameField.text = MqttSettings.shared.username
        
        cleanSwitch.setOn(MqttSettings.shared.cleanSession, animated: true)
        reconnectSwitch.setOn(MqttSettings.shared.autoReconnect, animated: true)
        sslSwitch.setOn(MqttSettings.shared.ssl, animated: true)
    }
    
    // Replace with generic
    @objc func saveSettings() {
        
        if isChanged {
            let updateAlert = UIAlertController(title: "Update settings", message: "We noticed that you were playing with the settings. Would you like to save them and restart the session?", preferredStyle: UIAlertControllerStyle.alert)
            
            updateAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                
                if let host = self.hostField.text, !host.isEmpty { MqttSettings.shared.host = host }
                if let port = self.portField.text, !port.isEmpty { MqttSettings.shared.port = port }
                if let clientID = self.clientIDField.text, !clientID.isEmpty { MqttSettings.shared.clientID = clientID }
                if let keepAlive = self.keppAliveField.text, !keepAlive.isEmpty { MqttSettings.shared.keepAlive = keepAlive }
                if let timeOut = self.timeOutField.text, !timeOut.isEmpty { MqttSettings.shared.connectionTimeOut = timeOut }
                if let password = self.passwordField.text, !password.isEmpty { MqttSettings.shared.password = password }
                if let userName = self.userNameField.text, !userName.isEmpty { MqttSettings.shared.username = userName }
                
                MqttSettings.shared.cleanSession = self.cleanSwitch.isOn
                MqttSettings.shared.autoReconnect = self.reconnectSwitch.isOn
                MqttSettings.shared.ssl = self.sslSwitch.isOn
                
                MqttManager.shared.disconnect()
                
                self.navigationController?.popViewController(animated: true)
            }))
            
            updateAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            present(updateAlert, animated: true, completion: nil)
        } else {
            let updateAlert = UIAlertController(title: "Hmm, exactly?", message: "It seems to us that you did not even touch the settings", preferredStyle: UIAlertControllerStyle.alert)
            updateAlert.addAction(UIAlertAction(title: "Ah, sure", style: .default, handler: nil))
            present(updateAlert, animated: true, completion: nil)
        }
    }
    
    @IBAction func changeSwitcher(_ sender: UISwitch) {
        isChanged = true
    }
    
    @IBAction func changeTextField(_ sender: UITextField) {
        isChanged = true
    }
}
