import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            AppTheme.navy

            Image("SplashWordmark")
                .resizable()
                .scaledToFit()
                .frame(width: 155, height: 66)
                .accessibilityLabel("2CI")
        }
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
    }
}

struct SplashGateView: View {
    @State private var isShowingSplash = true

    var body: some View {
        ZStack {
            if isShowingSplash {
                SplashView()
                    .transition(.opacity)
            } else {
                ContentView()
                    .transition(.opacity)
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(1.2))

            withAnimation(.easeOut(duration: 0.28)) {
                isShowingSplash = false
            }
        }
    }
}

#Preview {
    SplashView()
}
