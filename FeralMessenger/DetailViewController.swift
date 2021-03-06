//
//  DetailViewController.swift
//  FeralMessenger
//
//  Created by rightmeow on 5/20/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit
import Parse
import AVFoundation
import CloudKit


class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, KeyboardDockableDelegate {
    
    // MARK: - NavigationController
    
    var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
        view.hidesWhenStopped = true
        return view
    }()
    
    var titleButton: UIButton = {
        let button = UIButton()
        button.tintColor = UIColor.white
        button.setTitle("Messages", for: UIControlState.normal)
        button.frame = CGRect(x: 0, y: 0, width: 35, height: 25)
        return button
    }()
    
    func beginLoadingAnime() {
        DispatchQueue.main.async {
            self.navigationItem.titleView = self.activityIndicator
            self.activityIndicator.startAnimating()
        }
    }
    
    func endLoadingAnime() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.navigationItem.titleView = self.titleButton
        }
    }
    
    var rightBarButton: UIButton = {
        let button = UIButton()
        let buttonWidth: Int = 33
        button.layer.cornerRadius = CGFloat(buttonWidth/2)
        button.clipsToBounds = true
        button.contentMode = UIViewContentMode.scaleAspectFill
        button.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: buttonWidth)
        return button
    }()
    
    private func setupNavigationController() {
        guard let navigationController = navigationController else { return }
        navigationItem.titleView = titleButton
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: rightBarButton)]
        navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.orange]
    }
    
    // MARK: - InputContainerView
    
    var player: AVAudioPlayer?
    
    @IBOutlet weak var heightContraint: NSLayoutConstraint!
    @IBOutlet weak var inputContainerView: InputContainerView!
    
    func sendButton_tapped(_ sender: UIButton) {
        // override this
    }
    
    func playSound() {
        guard let sound = NSDataAsset(name: "sent") else {
            print("sound file not found")
            return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(data: sound.data, fileTypeHint: AVFileTypeWAVE)
            DispatchQueue.main.async {
                guard let player = self.player else { return }
                player.play() // schwoof
            }
        } catch let err {
            print(err.localizedDescription)
        }
    }
    
    func clearMessageTextField() {
        DispatchQueue.main.async {
            self.inputContainerView.inputTextField.text?.removeAll()
        }
    }
    
    private func setupInputContainerView() {
        inputContainerView.sendButton?.addTarget(self, action: #selector(self.sendButton_tapped(_:)), for: UIControlEvents.touchUpInside)
    }
    
    // MARK: - UITableView
    
    @IBOutlet weak var tableView: UITableView!
    
    @objc private func tableViewTapped(recognizer: UIGestureRecognizer) {
        inputContainerView.inputTextField.resignFirstResponder()
    }
    
    // this method is still very buggy
    func scrollToLastCellItem() {
        let numberOfRows = tableView.numberOfRows(inSection: 0)
        let lastIndexPath = IndexPath(row: numberOfRows - 1, section: 0)
        if numberOfRows >= 1 && tableView.visibleCells.count > 1 {
            DispatchQueue.main.async {
                self.tableView.scrollToRow(at: lastIndexPath, at: UITableViewScrollPosition.bottom, animated: true)
            }
        }
    }
    
    func tableViewReload() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func setupTableView() {
        tableView.backgroundColor = UIColor.midNightBlack()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped(recognizer:)))
        tableView.addGestureRecognizer(gesture)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupInputContainerView()
        setupNavigationController()
        setupKeyboardManager()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        keyboardManager?.setupKeyboardDockableNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        keyboardManager?.removeKeyboardNotifications()
        inputContainerView.inputTextField.resignFirstResponder()
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil // add a label to say something like 200 latest messages...
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(84)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let detailCell = tableView.dequeueReusableCell(withIdentifier: DetailCell.id, for: indexPath) as? DetailCell else {
            return UITableViewCell()
        }
        return detailCell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - KeyboardDockableDelegate
    
    var keyboardManager: KeyboardManager?
    
    func setupKeyboardManager() {
        keyboardManager = KeyboardManager()
        keyboardManager?.dockableDelegate = self
    }
    
    func keyboardDidChangeFrame(from notification: Notification, in keyboardRect: CGRect) {
        let keyboardWillShow = (notification.name == NSNotification.Name.UIKeyboardWillShow)
        heightContraint.constant = keyboardWillShow ? (inputContainerView.frame.size.height + keyboardRect.height) : 50
        UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }) { (completed: Bool) in
            if keyboardWillShow {
                self.scrollToLastCellItem()
            }
        }
    }
    
}

















