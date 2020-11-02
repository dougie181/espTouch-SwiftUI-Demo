//
//  ContentView.swift
//  esp32SmartConfigDemo
//
//  Created by Doug Inman on 30/10/20.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ESPTouchManager
    
    var body: some View {
        switch viewModel.state {
        
        case .ready:
            ProvisionDeviceView(viewModel: viewModel)
    
        case .inProgress:
            SearchingForDeviceView(viewModel: viewModel)
            
        case .completed:
            SuccessfullyConfiguredView(viewModel: viewModel)

        case .failed:
            FailedToConfigureView(viewModel: viewModel)
        }
    }

    struct FailedToConfigureView : View {
        var viewModel: ESPTouchManager
        var body: some View {
            VStack {
                CompletedView(success: false)
                Spacer()
                Text("Failed")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                Text("Reason: \(viewModel.message)")
                    .font(.subheadline)
                    .padding()
                    .foregroundColor(.white)
                Button(action: {
                    print("Continue")
                    viewModel.restart()
                }) {
                    Text("Continue")
                        .fontWeight(.semibold)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color(.link))
                        .cornerRadius(10.0)
                        .shadow(radius: 10, y: 5 )
                        .padding()
                }
                Spacer()
            }
            .background(Color(.blue).edgesIgnoringSafeArea(.all))
        }
    }
    
    struct SuccessfullyConfiguredView : View {
        var viewModel: ESPTouchManager
        var body: some View {
            VStack {
                CompletedView(success: true)
                Spacer()
                
                Text("Success")
                    .font(.largeTitle)
                    .padding()
                    .foregroundColor(.white)
                Text("Updated device: \(viewModel.bssid ?? "unknown")")
                    .font(.subheadline)
                    .padding()
                    .foregroundColor(.white)
                Button(action: {
                    print("Continue")
                    viewModel.restart()
                }) {
                    Text("Continue")
                        .fontWeight(.semibold)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color(.link))
                        .cornerRadius(10.0)
                        .shadow(radius: 10, y: 5 )
                        .padding()
                }
                Spacer()
            }
            .background(Color(.blue).edgesIgnoringSafeArea(.all))
        }
    }
    
    
    struct SearchingForDeviceView: View {
        var viewModel: ESPTouchManager
        
        var body: some View {
            VStack {
                AnimatedWiFiSymbol()
                Spacer()
                Text("Searching...")
                    .font(.largeTitle)
                    .padding()
                    .foregroundColor(.white)
                Button(action: {
                    print("cancel search...")
                    viewModel.cancel()
                }) {
                    Text("Cancel")
                        .fontWeight(.semibold)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color(.link))
                        .cornerRadius(10.0)
                        .shadow(radius: 10, y: 5 )
                        .padding()
                }
                Spacer()
            }
            .background(Color(.blue).edgesIgnoringSafeArea(.all))
        }
    }
    
    struct ProvisionDeviceView : View {
        @ObservedObject var viewModel: ESPTouchManager
        @State private var passphrase: String = ""
        
        var body: some View {
            VStack (spacing: 0) {
                VStack(spacing: 0){
                    ZStack {
                        Rectangle()
                            .fill(Color(.blue))
                            .edgesIgnoringSafeArea([.top, .horizontal])
                        WifiSymbol()
                    }
                    .background(Color(.green).edgesIgnoringSafeArea(.all))
                }
                
                /// pass-phrase section - at bottom of view
                VStack (spacing: 0) {
                    Text("Enter the pass-phrase for the following Wi-Fi network:")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .foregroundColor(.black)
                    
                    HStack{
                        Image(systemName: "arrow.counterclockwise")
                            .padding(.leading)
                            .opacity(0)
                        Text("ssid: \(viewModel.ssid ?? "Unknown")")
                            .font(.body)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.black)
                        
                        Button(action: {
                            viewModel.restart()
                        }) {
                            Image(systemName: "arrow.counterclockwise")
                        }
                        .padding(.trailing)
                    }
                    .background(Color(.lightGray))
                    .cornerRadius(10.0)
                    .padding(.horizontal)
                    
                    HStack {
                        if viewModel.ssid != nil {
                            ZStack(alignment: .leading ){
                                if passphrase == "" {
                                    Text("Enter pass-phrase")
                                        .foregroundColor(.gray)
                                        .padding(.leading)
                                }
                                
                                TextField("", text: $passphrase)
                                    .accessibility(label: Text("Wi-Fi pass-phrase"))
                                    .font(.headline)
                                    .padding()
                                    .autocapitalization(.none)
                                    .foregroundColor(.black)
                            }
                           
                            Button(action: {
                                passphrase = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding()
                            }
                        } else {
                            HStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .padding(.leading)
                                Text("Network SSID not found. Please retry.")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                Spacer()
                            }
                        }
                    }
                    .overlay(RoundedRectangle(cornerRadius: 10.0).stroke().foregroundColor(.green))
                    .padding()
                
                    Button(action: {
                        print("submitting...")
                        UIApplication.shared.endEditing()
                        
                        withAnimation(.easeInOut(duration: 2)) {
                            viewModel.performSmartConfig(password: passphrase)
                        }
                    }) {
                        Text("Configure device")
                            .fontWeight(.semibold)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color(.link))
                            .cornerRadius(10.0)
                            .shadow(radius: 10, y: 5 )
                            .padding()
                    }
                    .disabled(passphrase == "" || viewModel.ssid == nil)
                }
                .padding(0)
                .background(Color.white.edgesIgnoringSafeArea(.all))
            }
        }
    }
    
    struct AnimatedWiFiSymbol : View {
        @State private var flag: Bool = true
        
        var body: some View {
            GeometryReader() { geometry in
                
                ZStack {
                    Rectangle()
                        .foregroundColor(Color(.blue))
                    ZStack {
                        Circle()
                            .fill(Color.blue)
                            .opacity(flag ? 0.1 : 0.5)
                            .frame(width: min(geometry.size.width, geometry.size.height) / 2, height: min(geometry.size.width, geometry.size.height) / 2, alignment: .center)
                            .scaleEffect(self.flag ? 0.3 : 1 )
                        Circle()
                            .fill(Color.blue)
                            .opacity(flag ? 0.1 : 0.3)
                            .padding()
                            .scaleEffect(self.flag ? 0.1 : 1 )
                    }
                    .onAppear {
                        withAnimation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true).delay(0.5)) {
                            flag.toggle()
                        }
                    }

                    Group {
                        Circle()
                            .fill(Color(.systemBlue))
                            .frame(width: 100, height: 100, alignment: .center)
                        Image(systemName: "wifi")
                            .scaleEffect(CGSize(width: 3.0, height: 3.0))
                            .frame(width: 75, height: 75, alignment: .center)
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
    
    struct WifiSymbol : View {
        var body: some View {
            ZStack {
                Rectangle()
                    .foregroundColor(Color(.blue))
                Group {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 100, height: 100, alignment: .center)
                    Image(systemName: "wifi")
                        .scaleEffect(CGSize(width: 3.0, height: 3.0))
                        .frame(width: 75, height: 75, alignment: .center)
                        .foregroundColor(.black)
                }
            }
        }
    }

    struct CompletedView : View {
        @State private var flag: Bool = true
        var success: Bool = false
        
        var body: some View {
            ZStack {
                Rectangle()
                    .foregroundColor(Color(.blue))
                
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 100, height: 100, alignment: .center)
                    if success {
                        Image(systemName: "checkmark")
                            .font(Font.title.weight(.semibold))
                            .scaleEffect(self.flag ? 0.01 : 2.0 )
                            .frame(width: 75, height: 75, alignment: .center)
                            .foregroundColor(Color(.blue))
                    } else {
                        Image(systemName: "xmark")
                            .font(Font.title.weight(.semibold))
                            .scaleEffect(self.flag ? 0.01 : 2.0 )
                            .frame(width: 75, height: 75, alignment: .center)
                            .foregroundColor(Color(.blue))
                    }
                }
                .onAppear {
                    withAnimation((Animation.linear(duration: 1).delay(0.3))) {
                        flag.toggle()
                    }
                }
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    @State private var passphrase: String = ""
    
    static var previews: some View {
        ContentView(viewModel: ESPTouchManager(state: .ready))
        ContentView(viewModel: ESPTouchManager(state: .inProgress))
        ContentView(viewModel: ESPTouchManager(state: .completed))
        ContentView(viewModel: ESPTouchManager(state: .failed))
    }
}

extension Path {
    func scaled(toFit rect: CGRect) -> Path {
        let scaleW = rect.width/boundingRect.width
        let scaleH = rect.height/boundingRect.height
        let scaleFactor = min(scaleW, scaleH)
        return applying(CGAffineTransform(scaleX: scaleFactor, y: scaleFactor))
    }
}

struct FlippedUpsideDown: ViewModifier {
   func body(content: Content) -> some View {
    content
        .rotationEffect(.radians(.pi))
        .scaleEffect(x: -1, y: 1, anchor: .center)
   }
}

extension View{
   func flippedUpsideDown() -> some View{
     self.modifier(FlippedUpsideDown())
   }
}

// extension for keyboard to dismiss
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
