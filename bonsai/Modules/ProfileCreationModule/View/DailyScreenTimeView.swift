import SwiftUI

struct DailyScreenTimeView: View {
    @ObservedObject var viewModel: ProfileCreationViewModel = ProfileCreationViewModel()

    
    let name: String
    let phoneNumber: String
    
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("What is your daily average screen time?")
                    .padding(.top, 130)
                    .font(.system(size: 25))
                    .padding(.bottom, 50)
                
                NavigationLink(destination: PastUsageInspireView(screenTime: "1-2 hours")) {
                    screenTimeButton(title: "1-2 hours", color: "#db6552")
                        .padding(.bottom, 30)
                }
                NavigationLink(destination: PastUsageInspireView(screenTime: "2-4 hours")) {
                    screenTimeButton(title: "2-4 hours", color: "#9d3b6a")
                        .padding(.bottom, 30)
                }
                NavigationLink(destination: PastUsageInspireView(screenTime: "4-6 hours")) {
                    screenTimeButton(title: "4-6 hours", color: "#454380")
                        .padding(.bottom, 30)
                }
                NavigationLink(destination: PastUsageInspireView(screenTime: "7+  hours")) {
                    screenTimeButton(title: "7+  hours", color: "#1e2368")
                        .padding(.bottom, 30)
                }
                .padding(.bottom, 30)
                
                
                Spacer()
            }
            
        }
        .navigationBarBackButtonHidden(true)
    }
    
    
    func screenTimeButton(title: String, color: String) -> some View {
        
        Text(title)
                .padding(.horizontal, 95)
                .padding(.vertical, 14)
                .background(Color(hex: color))
                .foregroundColor(.white)
                .cornerRadius(20)
                .fontWeight(.bold)
    }
}

// Color extension to support hex codes
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let red = Double((rgbValue >> 16) & 0xFF) / 255.0
        let green = Double((rgbValue >> 8) & 0xFF) / 255.0
        let blue = Double(rgbValue & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}

#Preview {
    DailyScreenTimeView(name: "azam", phoneNumber: "azam")
}
