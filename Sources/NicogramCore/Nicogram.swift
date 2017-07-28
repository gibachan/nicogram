import Foundation
import NicoNicoKit
import Progress

public class Nicogram {
    public init() {}
    
    public func run(_ arguments: [String]) {
        // Configure ProgressBar
        var bar = ProgressBar(count: 100, configuration: [ProgressPercent(), ProgressBarLine(barLength: 50)])
        bar.next()
        
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
        var progressCounter = 0
        let progressHandler: (Float) -> Void = { progress in
            let counter = Int(progress * 100)
            if counter > progressCounter {
                progressCounter = counter
                bar.next()
            }
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
