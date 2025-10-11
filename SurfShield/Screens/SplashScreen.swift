import SwiftUI

struct SplashScreenView: View {
    @State private var isAnimating = false
    @State private var pulseAnimation = false
    
    var body: some View {
        ZStack {
            // Фоновое изображение или градиент
            if let _ = UIImage(named: "LaunchScreenBackground") {
                Image("LaunchScreenBackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            } else {
                // Градиентный фон если нет фонового изображения
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.2),
                        Color.black
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
            // Логотип приложения
            if let _ = UIImage(named: "LaunchIcon") {
                Image("LaunchIcon")
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, 66)
                    .frame(height: 300)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .padding(.top, 204)
//                    .ignoresSafeArea(.container)
            }

        }
    }
}

#Preview {
    SplashScreenView()
}
