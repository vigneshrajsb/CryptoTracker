//
//  CoinViewController.swift
//  CryptoTracker
//
//  Created by Vigneshraj Sekar Babu on 6/21/18.
//  Copyright © 2018 Vigneshraj Sekar Babu. All rights reserved.
//

import UIKit
import SwiftChart


class CoinViewController: UIViewController, CoinDataDelegate {
    var coinSelected : Coin?
    var chart = Chart()
    //design heights
    var chartHeight : CGFloat = 0.0
    var imageSize : CGFloat = 0.0
    var priceLabelSize : CGFloat = 0.0
    var ownedLabelSize : CGFloat = 0.0
    var worthLabelSize : CGFloat = 0.0
    //labels
    let priceLabel = UILabel()
    let ownedLabel = UILabel()
    let worthLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CoinData.shared.delegate = self
        edgesForExtendedLayout = []
        guard let _ = coinSelected else { fatalError("ERROR with selected coin") }
        initializeUI()
        setupChart()
        setupBottomScreen()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editPressed))
        
    }
    
    @objc func editPressed() {
        guard let coin = coinSelected else {
            fatalError("ERROR with selected coin")
        }
        let alert = UIAlertController(title: "Edit", message: "How much \(coin.symbol) do you own?", preferredStyle: .alert)
        var textField = UITextField()
        alert.addTextField { (field) in
            textField = field
            if let coin = self.coinSelected {
            textField.placeholder = "\(coin.amount)"
            } else {
                textField.placeholder = "0.0"
            }
            textField.keyboardType = .decimalPad
        }
        let action = UIAlertAction(title: "Update", style: .default) { (action) in
            //code
            guard let coin = self.coinSelected else { fatalError("ERROR! selected coin missing")}
            if let text = textField.text {
                if let doubleText = Double(text) {
                    coin.amount = doubleText
                    UserDefaults.standard.set(coin.amount, forKey: coin.symbol + "amount")
                }
            }
            self.newPrices()
        }
        alert.addAction(action)
        present(alert, animated: true)
        
    }
    
    
    func newHistory() {
        if let coin = coinSelected {
            let series = ChartSeries(coin.historicalPrice)
            series.area = true
            chart.add(series)
        }
    }
    
    func newPrices() {
        if let coin = coinSelected {
            priceLabel.text = coin.getFormattedCurrency()
            ownedLabel.text = "You own \(coin.amount) \(coin.symbol)"
            worthLabel.text = "\(coin.getAmountFormatted())"
        }
    }
    
    func initializeUI() {
        navigationItem.title = coinSelected?.symbol
        view.backgroundColor = UIColor.white
        chartHeight = view.safeAreaLayoutGuide.layoutFrame.height / 2.4
        imageSize = 100.0
        priceLabelSize = 25.0
        ownedLabelSize = 25.0
        worthLabelSize = 25.0
    }
    
     func setupChart() {
        chart.frame = CGRect(x: 0 , y: 0, width: view.safeAreaLayoutGuide.layoutFrame.width , height: chartHeight)
        //we used $1 for getting the value passed in as the chatt's y label
        chart.yLabelsFormatter = { CoinData.shared.convertDoubleToCurrencyFormat(double: $1)}
        
        chart.xLabels = [30,25,20,15,10,5,0]
        //the formatter is a closure with Int, Double input and  a string output
        //as the chart will format the label data in ascending order, we are working around by subtracting it by 30 to get the labels we need
        chart.xLabelsFormatter = { String(Int(round(30 - $1))) + "d" }
        view.addSubview(chart)
        coinSelected?.getHistoricalData()
    }
    
    func setupBottomScreen() {
        let imageView = UIImageView()
        // imageView.backgroundColor = .blue
        if let symbol = coinSelected?.symbol {
            imageView.image = UIImage(named: symbol)
        }
        imageView.frame = CGRect(x: view.safeAreaLayoutGuide.layoutFrame.width / 2 - imageSize / 2, y: chartHeight + 30 , width: imageSize, height: imageSize)
        view.addSubview(imageView)
        
        priceLabel.frame =  CGRect(x: 0, y: chartHeight + chartHeight/10 + imageSize + imageSize/10, width: view.frame.width, height: priceLabelSize)
        priceLabel.textAlignment = .center
        view.addSubview(priceLabel)
        
        ownedLabel.frame = CGRect(x: 0, y: chartHeight + chartHeight/10 + imageSize + imageSize/10 + priceLabelSize + priceLabelSize / 5, width: view.frame.size.width, height: ownedLabelSize)
        ownedLabel.textAlignment = .center
        ownedLabel.font = UIFont.systemFont(ofSize: 20)
        view.addSubview(ownedLabel)
        
        worthLabel.frame = CGRect(x: 0, y: chartHeight + chartHeight/10 + imageSize + imageSize/10 + priceLabelSize + priceLabelSize/5 + ownedLabelSize + ownedLabelSize/5, width: view.frame.size.width, height: ownedLabelSize)
        worthLabel.textAlignment = .center
        worthLabel.font = UIFont.systemFont(ofSize: 20)
        view.addSubview(worthLabel)
        
        newPrices()
    }
    
    
}
