import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            // Clean white background
            Color.white
                .ignoresSafeArea()
            
            // Main bear view
            BearView()
        }
    }
}

#Preview {
    ContentView()
}
