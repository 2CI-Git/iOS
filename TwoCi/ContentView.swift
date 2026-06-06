import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color(red: 0.094, green: 0.137, blue: 0.247)
                .ignoresSafeArea()

            Image("SplashWordmark")
                .resizable()
                .scaledToFit()
                .frame(width: 155, height: 66)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
