import Foundation
import IOKit

@main
struct DumpApp {
    static func main() {
        guard let smc = SMCClient() else { return }
        let keys = smc.keys(where: { $0.hasPrefix("T") || $0.hasPrefix("P") || $0.hasPrefix("V") || $0.hasPrefix("I") })
        for key in keys {
            if let val = smc.readValue(key) {
                print("\(key.name): \(val)")
            } else {
                print("\(key.name): null")
            }
        }
    }
}
