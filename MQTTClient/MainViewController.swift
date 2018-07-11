//
//  ViewController.swift
//  MQTTClient
//
//  Created by Anton Makarov on 09.07.2018.
//  Copyright © 2018 Anton Makarov. All rights reserved.
//

import UIKit
import CocoaMQTT

class MainViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var chooseTopicButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var subscribeButton: UIButton!
    @IBOutlet weak var qosButton: UIButton!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var disconnectButton: UIButton!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var retainSwitcher: UISwitch!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var currentStateLabel: UILabel!
    @IBOutlet weak var currentTopicLabel: UILabel!
    @IBOutlet weak var countSubscriptions: UILabel!

    var receivedMessages: [(topic: String, message: String)] = []
    var currentTopic: String?
    var isConnected = false
    
    //**************************************
    // MARK: - Initializers / Setup UI
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboard()

        MqttManager.shared.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        messageTextField.setBottomBorder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }

    func setupButtonStyle(button: UIButton, alpha: CGFloat, isEnabled: Bool) {
        button.alpha = alpha
        button.isEnabled = isEnabled
    }
    
    //**************************************
    // MARK: - Actions
    
    // Handling Buttons from header
    @IBAction func headerButtonActions(_ sender: UIButton) {
        
        switch sender.tag {
        case 0:
            if !isConnected {
                receivedMessages.removeAll()
                tableView.reloadData()
                MqttManager.shared.connect(host: MqttSettings.shared.host,
                                           port: Int(MqttSettings.shared.port)!,
                                           username: MqttSettings.shared.username,
                                           password: MqttSettings.shared.password,
                                           cleanSession: MqttSettings.shared.cleanSession)
            }
        case 1:
            if isConnected {
                MqttManager.shared.disconnect()
            }
        case 2:
            print("Press Settings Button")
        default:
            print("default case")
        }
    }
    
    // Selecting the current subscription from the list for work
    @IBAction func chooseTopic(_ sender: Any) {
        let optionMenu = UIAlertController(title: nil, message: "Current subscription", preferredStyle: .actionSheet)
        
        for topic in MqttManager.shared.subscribedTopics {
            let newAction = UIAlertAction(title: topic, style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.currentTopicLabel.text = "Current topic: " + topic
                self.currentTopic = topic
                self.editingMessage(true)
            })
            optionMenu.addAction(newAction)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in })

        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    // Quality of Service (0-2)
    @IBAction func chooseQoS(_ sender: Any) {
        if let numberText = qosButton.titleLabel?.text {
            if numberText == "0" {
                qosButton.setTitle("1", for: .normal)
            } else if numberText == "1" {
                 qosButton.setTitle("2", for: .normal)
            } else if numberText == "2" {
                qosButton.setTitle("0", for: .normal)
            }
            MqttManager.shared.qosNumber = Int(numberText)!
        }
    }
    
    // Handling the input message
    @IBAction func editingMessage(_ sender: Any) {
        if let text = messageTextField.text, !text.isEmpty, isConnected, !MqttManager.shared.subscribedTopics.isEmpty, currentTopic != nil {
            self.setupButtonStyle(button: sendButton, alpha: 1, isEnabled: true)
        } else {
            self.setupButtonStyle(button: sendButton, alpha: 0.5, isEnabled: false)
        }
    }
    
    // Adding a new subscription
    @IBAction func subscribe(_ sender: Any) {

        let alert = UIAlertController(title: "Subscribe", message: "Enter the topic, to which you want to subscribe", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = ""
        }
        
        alert.addAction(UIAlertAction(title: "Subscribe", style: .default, handler: { [weak alert] (_) in
            if let textField = alert?.textFields![0], !(textField.text?.isEmpty)! {
                MqttManager.shared.subscribe(topic: textField.text!)
                self.countSubscriptions.text = "My subsciptions (\(MqttManager.shared.subscribedTopics.count))"
                self.setupButtonStyle(button: self.chooseTopicButton, alpha: 1, isEnabled: true)
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // Send a message to topic / subscription
    @IBAction func publishMessage(_ sender: Any) {
        if let topic = currentTopic {
            MqttManager.shared.publish(message: messageTextField.text!, topic: topic)
        } else {
            print("Topic is not selected")
        }
    }
}


// MARK: - UITableViewDataSource, UITableViewDelegate
extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return receivedMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MessageTableViewCell
        cell.topicLabel.text = "Topic: " + receivedMessages[indexPath.row].topic
        cell.messageLabel.text = receivedMessages[indexPath.row].message
        
        return cell
    }
}

// MARK: - MqttManagerDelegate
extension MainViewController: MqttManagerDelegate {
    func onMqttConnected() {
        isConnected = true
        currentStateLabel.text = "Connected"
        currentStateLabel.textColor = UIColor(hex: 0x4996FA)
        setupButtonStyle(button: subscribeButton, alpha:1, isEnabled: true)
        setupButtonStyle(button: connectButton, alpha: 0.5, isEnabled: false)
        setupButtonStyle(button: disconnectButton, alpha: 1, isEnabled: true)
        editingMessage(true)
    }
    
    func onMqttDisconnected() {
        isConnected = false
        currentStateLabel.text = "Disconnected"
        currentStateLabel.textColor = UIColor(hex: 0xC1001D)
        setupButtonStyle(button: subscribeButton, alpha: 0.5, isEnabled: false)
        setupButtonStyle(button: connectButton, alpha: 1, isEnabled: true)
        setupButtonStyle(button: disconnectButton, alpha: 0.5, isEnabled: false)
        currentTopic = nil
        messageTextField.text = ""
        countSubscriptions.text = "My subsciptions (0)"
        editingMessage(true)
    }
    
    @objc func onMqttMessageReceived(message: String, topic: String) {
        receivedMessages.append((topic: topic, message: message))
        self.tableView.reloadData()
    }
    
    func onMqttError(message: String) { }
}

