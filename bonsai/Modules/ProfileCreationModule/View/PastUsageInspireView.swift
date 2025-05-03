import SwiftUI
import DeviceActivity
import FamilyControls

struct PastUsageInspireView: View {
    
    @State var screenTime: String
    

    
    let center = AuthorizationCenter.shared
    
    var usageYears: Int {
        return calculateUsage(screenTime: screenTime)
    }
    
    @State private var currentStep = 0
    @State private var showText = true
    @State private var navigateToNextView = false
    
    var texts: [AnyView] {
           return [
               AnyView(Text("At your current pace, you're on track to spend")),
               AnyView(
                   HStack {
                       Text("\(calculateUsage(screenTime: screenTime))")
                           .font(.system(size: 50, weight: .bold))
                           .frame(alignment: .leading)

                       Text("years of your life, staring at your screen")
                               .font(.body)
                               .multilineTextAlignment(.leading)
                   }
               ),
               AnyView(Text("But starting today, you choose differently")),
               AnyView(
                    
                       Text("Starting today, you make the commitment to reclaim your time")
                           
                   
               )
           ]
       }


    
    var body: some View {
        NavigationStack {
            
            Spacer()
            
            VStack(spacing: 20) {
                
                if currentStep < texts.count {
                    texts[currentStep]
                        .multilineTextAlignment(.center)
                        .padding()
                        .opacity(showText ? 1 : 0)
                        .animation(.easeInOut(duration: 1), value: showText)
                            }
            }
            .padding()
            .navigationDestination(isPresented: $navigateToNextView) {
                ProfileCreation4View()
            }
            .navigationBarBackButtonHidden(true)
            
            Spacer()
            Spacer()
            
            
        }
        .preferredColorScheme(.light)
        .onAppear {
            showTextSequentially()
        }
    }
    
    func showTextSequentially() {
        for i in 0..<texts.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i * 4)) { // Wait before showing
                withAnimation {
                    showText = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // Wait before fading out
                    withAnimation {
                        showText = false
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) { // Move to next text after fade-out
                    if i == texts.count - 1 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            navigateToNextView = true // Trigger navigation after the last text fades
                        }
                    } else {
                        currentStep += 1
                    }
                }
            }
        }
    }
}

// Helper function for formatting hobbies
func hobbiesOutput(hobbies: [String]) -> String {
    switch hobbies.count {
    case 1:
        return hobbies[0].lowercased()
    case 2:
        return hobbies.joined(separator: " and ").lowercased()
    default:
        let lastHobby = hobbies.last!
        let otherHobbies = hobbies.dropLast().joined(separator: ", ")
        return otherHobbies.lowercased() + ", and " + lastHobby.lowercased()
    }
}

// Function to calculate usage in years
func calculateUsage(screenTime: String) -> Int {
    switch screenTime {
    case "1-2 hours":
        return 6
    case "2-4 hours":
        return 12
    case "4-6 hours":
        return 18
    case "7+ hours":
        return 23
    default:
        return 0
    }
}

#Preview {
    PastUsageInspireView(screenTime: "4-6 hours")
}
