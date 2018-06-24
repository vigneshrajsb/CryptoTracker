//
//  Coin.swift
//  CryptoTracker
//
//  Created by Vigneshraj Sekar Babu on 6/18/18.
//  Copyright © 2018 Vigneshraj Sekar Babu. All rights reserved.
//

import UIKit
import Alamofire

class CoinData {
    //creating a singleton to use for storing the data
    static let shared = CoinData()
    var coins = [Coin]()
    //
    //https://stackoverflow.com/questions/30056526/swift-delegation-when-to-use-weak-pointer-on-delegate#30059243
    //
    weak var delegate : CoinDataDelegate?
    
    //marking it Private so the class cannot be initialized anywhere else in the app
    private init() {
        let array = ["BTC","ETH","LTC", "PPC", "XRP", "XMR", "MAID", "BTS", "DOGE", "VRC", "BCN", "BLOCK", "XEM", "NXT", "BURST",  "XBC"]
        
        for symbol in array {
            let coin = Coin(symbol: symbol)
            coins.append(coin)
        }
    }
    
    func getPrices() {
        
        var listOfSymbols = ""
        for coin in coins {
            listOfSymbols += coin.symbol
            if coin.symbol != coins.last?.symbol {
                listOfSymbols += ","
            }
        }
        
        //DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
        let url = "https://min-api.cryptocompare.com/data/pricemulti?fsyms=\(listOfSymbols)&tsyms=USD"
        Alamofire.request(url).responseJSON { (response) in
            if let json =  response.result.value as? [String:Any] {
                for coin in self.coins {
                    if let price = json[coin.symbol] as? [String:Double] {
                        if let priceForCoin = price["USD"] {
                            coin.price = priceForCoin
                            UserDefaults.standard.set(coin.price, forKey: coin.symbol)
                        }
                    }
                }
            }
            self.delegate?.newPrices?()
        }
        // }
    }
    
    func convertDoubleToCurrencyFormat(double : Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .currency
        if let fancyPrice = formatter.string(from: NSNumber(floatLiteral: double)) {
            return fancyPrice
        } else {
            return "ERROR! converting double to current format"
        }
    }
    
    func getTotalCryptoWorth() -> String {
        var totalWorth : Double = 0
        
        for coin in coins {
            totalWorth += coin.amount * coin.price
        }
        
        return convertDoubleToCurrencyFormat(double: totalWorth)
    }
}

@objc protocol CoinDataDelegate {
    @objc optional func newPrices()
    @objc optional func newHistory()
}

class Coin {
    var symbol : String = ""
    var image = UIImage()
    var price : Double = 0.0
    var historicalPrice = [Double]()
    var amount = 0.0
    
    init(symbol : String) {
        self.symbol = symbol
        
        if let image = UIImage(named: symbol) {
            self.image = image
        }
        
        self.price = UserDefaults.standard.double(forKey: symbol)
        self.amount = UserDefaults.standard.double(forKey: symbol + "amount")
        if let history = UserDefaults.standard.array(forKey: symbol + "history") as? [Double] {
            self.historicalPrice = history
        }
        
    }
    
    func getHistoricalData()  {
        self.historicalPrice = []
        let url = "https://min-api.cryptocompare.com/data/histoday?fsym=\(self.symbol)&tsym=USD&limit=30"
        Alamofire.request(url).responseJSON { (response) in
            if let json = response.result.value as? [String:Any] {
                if let dailyPriceData = json["Data"] as? [[String:Double]] {
                    for day in dailyPriceData {
                        if let priceAtEOD = day["close"] {
                            self.historicalPrice.append(priceAtEOD)
                            UserDefaults.standard.set(self.historicalPrice, forKey: self.symbol + "history" )
                        }
                    }
                }
                CoinData.shared.delegate?.newHistory?()
            } else { fatalError("history JSON error")}
            
        }
    }
    
    
    func getFormattedCurrency() -> String {
        if price == 0.0 {
            return "Loading..."
        }
        return CoinData.shared.convertDoubleToCurrencyFormat(double: price)
    }
    
    func getAmountFormatted() -> String {
        return CoinData.shared.convertDoubleToCurrencyFormat(double: amount * price)
    }
}





