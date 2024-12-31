import SwiftUI
import FamilyControls
import DeviceActivity
import ManagedSettings

struct SecondPageView: View {
    @StateObject private var model = ScreenTimeSelectAppsModel.shared
    @State private var pickerIsPresented = false
    @State private var monitoringStarted = false
    @State private var enteredPin: String = ""
    @State private var pinError: String? = nil

    let correctPin = "123456" // Replace with your desired PIN

    var body: some View {
        NavigationView {
            ZStack {
                // 1. A transparent background that catches taps
                Color.clear
                    .contentShape(Rectangle())  // Make the entire area tappable
                    .onTapGesture {
                        UIApplication.shared.dismissKeyboard()
                    }
                    .ignoresSafeArea()

                // 2. Your main content
                VStack {
                    Text("Moitoring")
                        .font(.largeTitle)
                        .padding()

                    Button {
                        pickerIsPresented = true
                    } label: {
                        Text("Select Apps to Monitor")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding()
                    .familyActivityPicker(isPresented: $pickerIsPresented, selection: $model.activitySelection)
                    .onChange(of: model.activitySelection) { newValue in
                        model.saveSelection()
                        print("Selection saved: \(newValue)")
                    }

                    Button {
                        startMonitoring()
                    } label: {
                        Text(monitoringStarted ? "Monitoring Started" : "Start Monitoring")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(monitoringStarted ? Color.gray : Color.green)
                            .cornerRadius(10)
                    }
                    .disabled(monitoringStarted)
                    .padding()

                    Button {
                        clearAllRestrictions()
                    } label: {
                        Text("Clear All Restrictions")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    .padding()

                    VStack {
                        SecureField("Enter 6-digit PIN", text: $enteredPin)
                            .keyboardType(.numberPad)
                            .padding()
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 200)

                        Button {
                            UIApplication.shared.dismissKeyboard() // Dismiss keyboard
                            validateAndClearRestrictions()
                        } label: {
                            Text("Submit PIN")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }

                    if let error = pinError {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
        }
    }

    private func startMonitoring() {
        let center = DeviceActivityCenter()

        let timeLimitMinutes = 1
        let selection = model.loadSelection() ?? FamilyActivitySelection()

        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0, second: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59, second: 59),
            repeats: true
        )

        let event = DeviceActivityEvent(
            applications: selection.applicationTokens,
            categories: selection.categoryTokens,
            webDomains: selection.webDomainTokens,
            threshold: DateComponents(minute: timeLimitMinutes)
        )

        let activityName = DeviceActivityName("ScreenTimeActivity")
        let eventName = DeviceActivityEvent.Name("ScreenTimeThreshold")

        do {
            try center.startMonitoring(
                activityName,
                during: schedule,
                events: [eventName: event]
            )
            monitoringStarted = true
            print("Monitoring started.")
        } catch {
            print("Failed to start monitoring: \(error)")
        }
    }

    private func clearAllRestrictions() {
        let store = ManagedSettingsStore()
        store.shield.applicationCategories = nil
        store.shield.applications = nil
        print("All restrictions cleared.")
    }

    private func validateAndClearRestrictions() {
        if enteredPin == correctPin {
            clearAllRestrictions()
            pinError = nil
        } else {
            pinError = "Invalid PIN. Please try again."
        }
    }
}
