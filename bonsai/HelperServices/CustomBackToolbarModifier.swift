import SwiftUI

struct CustomBackToolbarModifier: ViewModifier {
    @Environment(\.presentationMode) var presentationMode

    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .onAppear {
                setTransparentNavBar()
                enableSwipeBackGesture()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("return")
                        }
                        .foregroundColor(Color.primary)
                    }
                }
            }
    }
    
    private func setTransparentNavBar() {
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }


    private func enableSwipeBackGesture() {
        
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = scene.windows.first?.rootViewController,
              let nav = findNavController(from: root) else { return }

        nav.interactivePopGestureRecognizer?.isEnabled = true
        nav.interactivePopGestureRecognizer?.delegate = nil
    }

    private func findNavController(from root: UIViewController) -> UINavigationController? {
        if let nav = root as? UINavigationController {
            return nav
        } else if let tab = root as? UITabBarController,
                  let selected = tab.selectedViewController {
            return findNavController(from: selected)
        } else if let presented = root.presentedViewController {
            return findNavController(from: presented)
        } else {
            return root.children.compactMap { findNavController(from: $0) }.first
        }
    }
}

extension View {
    func customBackToolbar() -> some View {
        self.modifier(CustomBackToolbarModifier())
    }
}
