//
//  HTMLVisualizer.swift
//  bonsai
//
//  Created by Nicolas Mingorance-Geraldo on 2025-08-04.
//

import SwiftUI
import WebKit

/// A reusable SwiftUI view that loads and displays HTML content from a local file within the app bundle.
///
/// This view wraps a `WKWebView` to render HTML, making it easy to display formatted text
/// for things like privacy policies, terms and conditions, or other legal documents.
///
/// ## Usage
///
/// ```
/// HTMLVisualizer(fileName: "privacy_policy")
/// ```
///
/// - Note: Ensure the HTML file (e.g., "privacy_policy.html") is added to your Xcode project target.
///
struct HTMLVisualizer: UIViewRepresentable {
    
    /// The name of the HTML file (without the .html extension) to be loaded from the main bundle.
    let fileName: String
    
    /// Creates the `WKWebView` and configures it.
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    /// Updates the `WKWebView` with the content of the specified HTML file.
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Attempt to find the file URL in the app's main bundle.
        if let fileURL = Bundle.main.url(forResource: fileName, withExtension: "html") {
            // If the file is found, load its content directly into the web view.
            // `allowingReadAccessTo` is crucial for letting the web view access local resources
            // like CSS or images that might be in the same directory.
            uiView.loadFileURL(fileURL, allowingReadAccessTo: fileURL.deletingLastPathComponent())
        } else {
            // If the file is not found, display an error message.
            let htmlError = """
            <html>
            <body style="font-family: -apple-system, sans-serif; padding: 20px;">
                <h1>Error</h1>
                <p>Could not load the document '\(fileName).html'. Please ensure the file is included in the app bundle.</p>
            </body>
            </html>
            """
            uiView.loadHTMLString(htmlError, baseURL: nil)
        }
    }
}

#Preview {
    // Example preview that attempts to load a "TestPolicy.html" file.
    // For this to work, you must create a file named `TestPolicy.html` and add it to your project.
    HTMLVisualizer(fileName: "TestPolicy")
}
