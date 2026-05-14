import Foundation
import StoreKit

@MainActor
@Observable
class PurchaseManager {
    
    static let shared = PurchaseManager()
    
    // Product ID - you'll need to create this in App Store Connect
    private let premiumProductID = "com.sebastianstrus.datespark.premium"
    
    // Observable properties
    var isPremium: Bool = false
    var isLoading: Bool = false
    var products: [Product] = []
    
    private var updateListenerTask: Task<Void, Never>?
    
    private init() {
        // Start listening for transaction updates in a Task
        Task { @MainActor in
            self.updateListenerTask = self.listenForTransactions()
            await self.loadProducts()
            await self.checkPurchaseStatus()
        }
    }
    
    // MARK: - Product Loading
    
    func loadProducts() async {
        do {
            let products = try await Product.products(for: [premiumProductID])
            self.products = products
        } catch {
            print("Failed to load products: \(error)")
        }
    }
    
    // MARK: - Purchase Status
    
    func checkPurchaseStatus() async {
        // Check if user has purchased premium
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == premiumProductID {
                isPremium = true
                return
            }
        }
        isPremium = false
    }
    
    // MARK: - Purchase Flow
    
    func purchase() async throws {
        guard let product = products.first else {
            throw PurchaseError.productNotFound
        }
        
        isLoading = true
        defer { isLoading = false }
        
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            switch verification {
            case .verified(let transaction):
                // Grant premium access
                isPremium = true
                await transaction.finish()
                
            case .unverified:
                throw PurchaseError.failedVerification
            }
            
        case .userCancelled:
            throw PurchaseError.userCancelled
            
        case .pending:
            throw PurchaseError.pending
            
        @unknown default:
            throw PurchaseError.unknown
        }
    }
    
    // MARK: - Restore Purchases
    
    func restorePurchases() async throws {
        isLoading = true
        defer { isLoading = false }
        
        try await AppStore.sync()
        await checkPurchaseStatus()
    }
    
    // MARK: - Transaction Listener
    
    private func listenForTransactions() -> Task<Void, Never> {
        Task {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await checkPurchaseStatus()
                }
            }
        }
    }
    
    // MARK: - Formatted Price
    
    var formattedPrice: String {
        products.first?.displayPrice ?? "$3.99"
    }
}

// MARK: - Errors

enum PurchaseError: LocalizedError {
    case productNotFound
    case failedVerification
    case userCancelled
    case pending
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "Product not found. Please try again later."
        case .failedVerification:
            return "Purchase verification failed."
        case .userCancelled:
            return "Purchase cancelled."
        case .pending:
            return "Purchase is pending approval."
        case .unknown:
            return "An unknown error occurred."
        }
    }
}
