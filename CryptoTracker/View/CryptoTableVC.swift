//
//  CryptoTableVC.swift
//  CryptoTracker
//
//  Created by Vigneshraj Sekar Babu on 6/18/18.
//  Copyright © 2018 Vigneshraj Sekar Babu. All rights reserved.
//

import UIKit
import LocalAuthentication


class CryptoTableVC: UITableViewController, CoinDataDelegate {
    var headerHeight : CGFloat = 0.0
    var worthLabelHeight : CGFloat = 0.0
    var totalWorthLabelHeight : CGFloat = 0.0
    
    let worthAmountLabel = UILabel()
    
    fileprivate func initUIDesign() {
        headerHeight = view.safeAreaLayoutGuide.layoutFrame.height / 7
        worthLabelHeight = headerHeight * 0.35
        totalWorthLabelHeight = headerHeight * 0.65
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = []
        initUIDesign()
        CoinData.shared.getPrices()
        
        if LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            updateSecurityUI()
        }
      
    }
    
    func updateSecurityUI() {
        if UserDefaults.standard.bool(forKey: "secure") {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Unsecure App", style: .plain, target: self, action: #selector(securityButtonPressed))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Secure App", style: .plain, target: self, action: #selector(securityButtonPressed))
        }
    }
    
    @objc func securityButtonPressed() {
        if UserDefaults.standard.bool(forKey: "secure") {
            UserDefaults.standard.set(false, forKey: "secure")
        } else {
            UserDefaults.standard.set(true, forKey: "secure")
        }
        updateSecurityUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        CoinData.shared.delegate = self

        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //call func
        return setupHeader()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CoinData.shared.coins.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //code
        let cell = UITableViewCell()
        let coinInfo = CoinData.shared.coins[indexPath.row]
        if coinInfo.amount == 0.0 {
        cell.textLabel?.text = "\(coinInfo.symbol) - \(coinInfo.getFormattedCurrency())"
        } else {
            cell.textLabel?.text = "\(coinInfo.symbol) - \(coinInfo.getFormattedCurrency()) - \(coinInfo.amount)"
        }
        
        cell.imageView?.image = coinInfo.image
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let coinVC = CoinViewController()
        coinVC.coinSelected = CoinData.shared.coins[indexPath.row]
        navigationController?.pushViewController(coinVC, animated: true)
    }
    
    func setupHeader() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.safeAreaLayoutGuide.layoutFrame.width, height: headerHeight))
        headerView.backgroundColor = UIColor.white
        
        let worthLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: worthLabelHeight))
        worthLabel.textAlignment =  .center
        worthLabel.text = "Your Crypto Networth is"
        headerView.addSubview(worthLabel)
        
        worthAmountLabel.frame = CGRect(x: 0, y: 40.0, width: view.frame.size.width, height: totalWorthLabelHeight)
        worthAmountLabel.textAlignment = .center
        worthAmountLabel.font = UIFont.boldSystemFont(ofSize: totalWorthLabelHeight - 10)
        worthAmountLabel.adjustsFontSizeToFitWidth = true
        worthAmountLabel.minimumScaleFactor = 0.5
        
        headerView.addSubview(worthAmountLabel)
        
        worthAmountLabel.text = CoinData.shared.getTotalCryptoWorth()
        
        return headerView
    }
    
    
    func newPrices() {
        
        tableView.reloadData()
    }

    
}
