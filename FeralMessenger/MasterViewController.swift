//
//  HomeViewController.swift
//  FeralMessenger
//
//  Created by rightmeow on 5/20/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit
import AVFoundation


class MasterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {

    // MARK: - AddFriendView

    @IBOutlet var addFriendView: AddFriendView!

    func showAddFriendView(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.addFriendView.alpha = 1.0
        }
    }

    func addButton_tapped(_ sender: UIButton) {
        guard let username = addFriendView.userTextField.text, !username.isEmpty else { return }
        clearTextField(textField: addFriendView.userTextField)
        sendInvite(username: username)
    }

    func clearTextField(textField: UITextField) {
        DispatchQueue.main.async {
            textField.text?.removeAll()
        }
    }

    func sendInvite(username: String) {
        // override this to implement
    }

    var player: AVAudioPlayer?

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

    private func setupAddFriendView() {
        addFriendView.alpha = 0
        addFriendView.enableParallaxMotion(magnitude: 15)
    }

    // MARK: - NavigationController

    lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
        view.hidesWhenStopped = true
        return view
    }()
    
    lazy var titleButton: UIButton = {
        let button = UIButton()
        button.tintColor = UIColor.white
        button.setTitle("Chats", for: UIControlState.normal)
        button.frame = CGRect(x: 0, y: 0, width: 35, height: 25)
        return button
    }()

    lazy var rightBarButton: UIButton = {
        let button = UIButton()
        let originalImage = #imageLiteral(resourceName: "Add")
        let tintedImage = originalImage.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        button.setBackgroundImage(tintedImage, for: UIControlState.normal)
        button.contentMode = UIViewContentMode.scaleAspectFill
        button.tintColor = UIColor.orange
        button.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        button.addTarget(self, action: #selector(rightBarButton_tapped(_:)), for: UIControlEvents.touchUpInside)
        return button
    }()

    func rightBarButton_tapped(_ sender: UIButton) {

        // override this to implement
    }
    
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
    
    var timer: Timer?
    
    func scheduleNavigationPrompt(with message: String, duration: TimeInterval) {
        DispatchQueue.main.async {
            self.navigationItem.prompt = message
            self.timer = Timer.scheduledTimer(timeInterval: duration,
                                              target: self,
                                              selector: #selector(self.removePrompt),
                                              userInfo: nil,
                                              repeats: false)
            self.timer?.tolerance = 5
        }
    }
    
    @objc private func removePrompt() {
        if navigationItem.prompt != nil {
            DispatchQueue.main.async {
                self.navigationItem.prompt = nil
            }
        }
    }
    
    private func setupNavigationController() {
        guard let navigationController = navigationController else { return }
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.barTintColor = UIColor.mediumBlueGray
        navigationController.navigationBar.tintColor = UIColor.white
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: rightBarButton)]
    }
    
    // MARK: - TabBarController
    
    private func setupTabBar() {
        guard let tabBar = tabBarController?.tabBar else {
            print("tabBarController cannot be nil")
            return
        }
        tabBar.tintColor = UIColor.candyWhite
        tabBar.barTintColor = UIColor.midNightBlack
        tabBar.isHidden = false
        tabBar.isTranslucent = false
    }
    
    // MARK: - UITableView
    
    @IBOutlet weak var tableView: UITableView!
    
    func tableViewReload() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func setupTableView() {
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.backgroundColor = UIColor.midNightBlack
        tableView.backgroundView?.backgroundColor = UIColor.midNightBlack
    }
    
    // MARK: - UISearchController + UISearchResultsUpdating
    
    let searchController = UISearchController(searchResultsController: nil)

    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.barStyle = UIBarStyle.default
        searchController.searchBar.placeholder = "Search for users"
        searchController.searchBar.barTintColor = UIColor.mediumBlueGray
        let cancelButtonAttributes: [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.candyWhite]
        UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes as [String : AnyObject], for: UIControlState.normal)
        searchController.searchBar.keyboardAppearance = UIKeyboardAppearance.dark
        tableView.tableHeaderView = searchController.searchBar
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        filterContentForSearchText(searchText: searchText)
    }
    
    func filterContentForSearchText(searchText: String) {
        // override this to implement
    }
    
    // MARK: - Lifecycle
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupAddFriendView()
        setupSearchController()
        setupNavigationController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTabBar()
    }
    
    // MARK: - UITableViewDelegate

    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let masterCell = tableView.dequeueReusableCell(withIdentifier: MasterCell.id, for: indexPath) as? MasterCell else {
            return UITableViewCell()
        }
        return masterCell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
}
























