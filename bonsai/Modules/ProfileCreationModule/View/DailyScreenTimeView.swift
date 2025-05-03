import SwiftUI

struct DailyScreenTimeView: View {
    @ObservedObject var viewModel: ProfileCreationViewModel = ProfileCreationViewModel()

    
    let name: String
    let phoneNumber: String
    
    @State var screenTime: String = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("What is your daily average screen time?")
                    .padding(.top, 130)
                    
                Spacer()
                screenTimeButton(title: "1-2 hours", color: "#81CEB7")
                screenTimeButton(title: "2-4 hours", color: "#31B788")
                screenTimeButton(title: "4-6 hours", color: "#148E63")
                screenTimeButton(title: "7+ hours", color: "#0E7362")

                Spacer()
                
                let forwardButton = Image(systemName: "chevron.right")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.primary)
                    .clipShape(Circle())

                NavigationLink(destination: PastUsageInspireView(screenTime: screenTime)) {
                    forwardButton
                }
                .padding(.leading, 200)
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    
    func screenTimeButton(title: String, color: String) -> some View {
        Button(action: {
            screenTime = title
        }) {
            Text(title)
                .padding(.horizontal, 80)
                .padding(.vertical, 8)
                .background(Color(hex: color))
                .foregroundColor(.white)
                .cornerRadius(20)
                .fontWeight(.bold)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(screenTime == title ? Color.primary : Color.clear, lineWidth: 1)
                )
        }
        .padding(.bottom, 20)
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
