//
//  InAppPurchaseManager.swift
//  scc
//
//  Created by 阿辉 on 2025/1/10.
//

import StoreKit

class InAppPurchaseManager: NSObject {
    
    static let shared = InAppPurchaseManager() // 单例
    
    private var productRequest: SKProductsRequest?
    private var availableProducts: [SKProduct] = []
    private var successCallback: ((String) -> Void)?
    private var failureCallback: ((Error?) -> Void)?
    var productRequestSuccessCallback: (([SKProduct]) -> Void)?
    var productRequestFailureCallback: ((Error?) -> Void)?
    
    private override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    // 初始化内购管理器并请求商品信息

    func initialize(productIdentifiers: [String], success: @escaping ([SKProduct]) -> Void, failure: @escaping (Error?) -> Void) {
        self.productRequestSuccessCallback = success
        self.productRequestFailureCallback = failure
        let productSet = Set(productIdentifiers)
        print(productSet)
        productRequest = SKProductsRequest(productIdentifiers: productSet)
        productRequest?.delegate = self
        productRequest?.start()
    }
    
    // 购买商品
    func purchase(productIdentifier: String, success: @escaping (String) -> Void, failure: @escaping (Error?) -> Void) {
        guard let product = availableProducts.first(where: { $0.productIdentifier == productIdentifier }) else {
            failure(NSError(domain: "Product not found", code: 404, userInfo: nil))
            return
        }
        
        successCallback = success
        failureCallback = failure
        
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    // 恢复购买
    func restorePurchases(success: @escaping ([String]) -> Void, failure: @escaping (Error?) -> Void) {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

// MARK: - SKProductsRequestDelegate
extension InAppPurchaseManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        availableProducts = response.products
        print(response.products)
        if response.invalidProductIdentifiers.count > 0 {
            print("Invalid product identifiers: \(response.invalidProductIdentifiers)")
        }
    }
}

// MARK: - SKPaymentTransactionObserver
extension InAppPurchaseManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                SKPaymentQueue.default().finishTransaction(transaction)
                successCallback?(transaction.payment.productIdentifier)
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
                failureCallback?(transaction.error)
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                break
            }
        }
    }
}
