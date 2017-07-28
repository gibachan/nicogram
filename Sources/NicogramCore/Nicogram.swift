import Foundation
import NicoNicoKit

public class Nicogram {
    public init() {}
    
    public func run(_ arguments: [String]) {
        // Parse command line options
        var options: (String, String, String)
        
        do {
            options = try parseArguments(CommandLine.arguments)
        } catch ArgumentError.InvalidEmail {
            print("Invalid email")
            exit(1)
        } catch ArgumentError.InvalidPassword {
            print("Invalid password")
            exit(1)
        } catch ArgumentError.Insufficient {
            print("Insufficient arguments")
            exit(1)
        } catch {
            print("Unexpected error")
            exit(1)
        }
        
        let email = options.0
        let password = options.1
        guard let videoId = extractVideoId(options.2) else {
            print("Invalid URL")
            exit(2)
        }
        
        // Start downloading
        let start = Date()
        
        let progressHandler: (Float) -> Void = { progress in
            print("\u{1B}[1A\u{1B}[KDownloading: \(String(format: "%.2f", progress * 100))%")
        }
        
        download(email: email, password: password, videoId: videoId, progressHandler: progressHandler) { url in
            if let url = url {
                let elapsed = Date().timeIntervalSince(start) as Double
                let formatedElapsed = String(format: "%.3f", elapsed)
                print("Downloaded: \(url.path) Download time: \(formatedElapsed)(s)")
                exit(0)
            } else {
                exit(3)
            }
        }
    }
}
