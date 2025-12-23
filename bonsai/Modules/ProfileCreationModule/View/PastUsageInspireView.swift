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
    @State private var showText = false
    @State private var navigateToNextView = false
    
    var texts: [AnyView] {
        return [
            AnyView(Text("At your current pace, you're on track to spend").font(.system(size: 30, weight: .medium))),
            AnyView(
                HStack {
                    Text("\(calculateUsage(screenTime: screenTime))")
                        .font(.system(size: 65, weight: .bold))
                        .frame(alignment: .leading)
                    
                    Text("years of your life, staring at your screen")
                        .font(.system(size: 30, weight: .medium))
                        .multilineTextAlignment(.leading)
                }
            ),
            AnyView(Text("But starting today, you choose differently.").font(.system(size: 30, weight: .medium))),
            AnyView(Text("Starting today, you make the commitment to reclaim your time.").font(.system(size: 30, weight: .medium)))
        ]
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                
                VStack(spacing: 20) {
                    if currentStep < texts.count {
                        texts[currentStep]
                            .multilineTextAlignment(.center)
                            .padding()
                            .opacity(showText ? 1 : 0)
                            .animation(.easeInOut(duration: 1), value: showText)
                    }
                    
                    // ✅ Hidden NavigationLink for correct forward animation
                    NavigationLink(
                        destination: ProfileCreation4View(),
                        isActive: $navigateToNextView
                    ) {
                        EmptyView()
                    }
                    .hidden()
                }
                .padding()
                
                Spacer()
                Spacer()
            }
            .navigationBarBackButtonHidden(true)
        }
        .preferredColorScheme(.light)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    showTextSequentially()
                }
        }
    }
    
    func showTextSequentially() {
        let displayDuration = 1.5
        let fadeDuration = 0.5
        let totalStepDuration = displayDuration + fadeDuration + 0.5

        func showNextStep(index: Int) {
            guard index < texts.count else {
                // Transition after the last text
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    navigateToNextView = true
                }
                return
            }

            withAnimation {
                showText = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + displayDuration) {
                withAnimation {
                    showText = false
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + totalStepDuration) {
                currentStep = index + 1
                showNextStep(index: index + 1)
            }
        }

        showNextStep(index: 0)
    }
}

// MARK: - Helper Functions

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

func calculateUsage(screenTime: String) -> Int {
    switch screenTime {
    case "1-2 hours":
        saveHoursPerDay(hours: 1.5)
        return 6
    case "2-4 hours":
        saveHoursPerDay(hours: 3)
        return 12
    case "4-6 hours":
        saveHoursPerDay(hours: 5)
        return 18
    case "7+  hours":
        saveHoursPerDay(hours: 8)
        return 23
    default:
        return 0
    }
}

func saveHoursPerDay(hours: Double) {
    var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: BONSAI_GROUP_NAME)
    }
    sharedDefaults?.set(try! JSONEncoder().encode(hours), forKey: HOURS_PER_DAY_STRING)
}

#Preview {
    PastUsageInspireView(screenTime: "4-6 hours")
}
