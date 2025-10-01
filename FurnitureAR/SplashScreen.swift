import SwiftUI

struct SplashScreen: View
{
    @State private var isActive = false
    
    var body: some View
    {
        if isActive
        {
            ContentView() // La vista principal
        } else
            {
               ZStack
                {
                    Color(#colorLiteral(red: 0.9109119773, green: 0.8117216229, blue: 0.7672503591, alpha: 1))
                    .ignoresSafeArea()
                    
                    VStack
                    {
                        Image("SplashScreen") // Tu logo o imagen de bienvenida
                            .resizable()
                            .scaledToFit()
                            .frame(height: 300)
                        
                        Spacer().frame(height: 50)
                        
                        Text("AR Fourniture")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onAppear
                    {
                        // Espera 2.5 segundos antes de mostrar la vista principal
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0)
                        {
                            withAnimation(.easeOut)
                            {
                                isActive = true
                            }
                        }
                    }
                }
            }
    }
}

#Preview {
    SplashScreen()
}
