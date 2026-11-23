import SwiftUI

internal struct SplashView: View {
    @EnvironmentObject private var router: ContentRouter

    internal var body: some View {
        VStack {
            Image("LaunchLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.horizontal, UIScreen.main.bounds.width * 0.1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            guard Preferences.standard.configurationFinished else {
                withAnimation {
                    router.route = .configuration
                }

                return
            }

            withAnimation {
                router.route = .main
            }
        }
    }
}

#Preview {
    SplashView()
}
