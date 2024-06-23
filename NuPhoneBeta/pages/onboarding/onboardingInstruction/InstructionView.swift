import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import RiveRuntime

struct InstructionView: View {
    @EnvironmentObject var appState: AppState
    @State var selectedCarrier: String = ""
    @State private var currentStep = 0
    @ObservedObject var agentManager = AgentManager.shared
    @State var instructionsCompleted = false
    @State var clickedForwardCall: Bool = false
    @State var forwardVerifiedResult: Bool?
    @State var isForwardVerifiedLoading: Bool = false
    
    let totalSteps = 4
    
    var body: some View {
        VStack {
            TabView(selection: $currentStep) {
                // Each of these is a separate page
                AlmostDoneStep(currentStep: $currentStep).tag(0)
                    .padding(.horizontal, 30)
                //                StepOneView(selectedCarrier: $selectedCarrier).tag(1)
                //                    .padding(.horizontal, 20)
                CarrierStep(selectedCarrier: $selectedCarrier, currentStep: $currentStep).tag(1)
                    .padding(.horizontal, 30)
                ActivationStep(selectedCarrier: selectedCarrier, currentStep: $currentStep, clickedForwardCall: $clickedForwardCall).tag(2)
                    .padding(.horizontal, 30)
                TestCallForwardingStep(forwardVerifiedResult: $forwardVerifiedResult, isForwardVerifiedLoading: $isForwardVerifiedLoading, displayTestCallForwardingSheet: .constant(false)).tag(3)
                    .padding(.horizontal, 30)
                //                StepThreeView(agentManager: agentManager, instructionsCompleted: $instructionsCompleted).tag(3)
                //                    .padding(.horizontal, 30)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onChange(of: currentStep) { newValue in
                if newValue == 2 && (selectedCarrier == "") {
                    DispatchQueue.main.async {
                        withAnimation {
                            currentStep = 1
                        }
                    }
                }
                else if newValue == 3 && (!clickedForwardCall) {
                    DispatchQueue.main.async {
                        withAnimation {
                            currentStep = 2
                        }
                    }
                }
            }
            //
            if currentStep == 0  {
                GradientButton(title: "Continue", icon: "arrow.right", isLoading: .constant(false), onClick: {
                    withAnimation {
                        currentStep += 1
                    }
                })
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(.horizontal, 30)
                
            }
            
            else if currentStep  == 1 {
                //                GradientButton(title: "Continue", icon: "arrow.right", isLoading: .constant(false), onClick: {
                //                    withAnimation {
                //                        currentStep += 1
                //                    }
                //                })
                //                .foregroundColor(.white)
                //                .cornerRadius(8)
                //                .disableWithOpacity(selectedCarrier == "" || !clickedCall)
                //                .padding(.horizontal, 30)
                Button(action: {
                    withAnimation {
                        currentStep += 1
                    }
                }) {
                    HStack {
                        Text("Continue")
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.black)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                }
                .disableWithOpacity(selectedCarrier == "")
                .buttonStyle()
                .padding(.horizontal, 30)
            }
            else if currentStep  == 2 {
                Button(action: {
                    withAnimation {
                        currentStep += 1
                    }
                }) {
                    HStack {
                        Text("Continue")
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.black)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                }
                .disableWithOpacity(!clickedForwardCall)
                .buttonStyle()
                .padding(.horizontal, 30)
            }
            else if currentStep  == 3 {
                //                GradientButton(title: "Continue", icon: "arrow.right", isLoading: .constant(false), onClick: {
                //                    withAnimation {
                //                        currentStep += 1
                //                    }
                //                })
                //                .foregroundColor(.white)
                //                .cornerRadius(8)
                //                .disableWithOpacity(selectedCarrier == "" || !clickedCall)
                //                .padding(.horizontal, 30)
                Button(action: {
                    withAnimation {
                        //                        currentStep += 1
                        UserDefaults.standard.set(selectedCarrier, forKey: "phoneCarrier")
                        appState.currentView = .agent
                    }
                }) {
                    HStack {
                        Text("Done")
                        Image(systemName: "checkmark")
                    }
                    .foregroundColor(.black)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                }
                .disableWithOpacity(isForwardVerifiedLoading || forwardVerifiedResult == nil || forwardVerifiedResult == false)
                .buttonStyle()
                //                .padding(.horizontal, 30)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.horizontal, 30)
            }
            //            else {
            //                GradientButton(title: "Done", icon: "checkmark", isLoading: .constant(false), onClick: {
            //                    UserDefaults.standard.set(selectedCarrier, forKey: "phoneCarrier")
            //                    appState.currentView = .agent
            //                })
            //                .disableWithOpacity(!instructionsCompleted)
            //                .foregroundColor(.white)
            //                .cornerRadius(8)
            //                .opacity(instructionsCompleted ? 1 : 0.5)
            //                .padding(.horizontal, 30)
            //            }
            
            
            stepperDots
            
        }
    }
    
    @ViewBuilder
    var stepperDots: some View {
        HStack {
            ForEach(0..<totalSteps, id: \.self) { step in
                Circle()
                    .fill(step == currentStep ? Color("AccentColor") : Color.gray)
                    .frame(width: 10, height: 10)
            }
        }
        .padding(.top, 10)
    }
}

struct AlmostDoneStep: View {
    @Binding var currentStep: Int
    var body: some View {
        VStack (alignment: .center, spacing: 0) {
            Spacer()
            VStack (alignment: .center) {
                VStack (alignment: .center){
                    Text("Almost Done!")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                    
                    Text("Set up call forwarding to let your AI Assistant handle missed calls.")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.black.opacity(0.6))
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 20)
                    
                }
            }
            Spacer()
            //            GradientButton(title: "Continue", icon: "arrow.right", isLoading: .constant(false), onClick: {
            //                withAnimation {
            //                    currentStep += 1
            //                }
            //            })
            //            .disableWithOpacity()
        }
    }
}

struct CarrierStep: View {
    @Binding var selectedCarrier: String
    @Binding var currentStep: Int
    //    @Binding var clickedForwardCall: Bool
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        GeometryReader { geometry in
//            ScrollView(.vertical) {
                VStack(alignment: .center, spacing: 20) {
                    //                Text("Activation")
                    //                    .font(.largeTitle)
                    //                    .fontWeight(.heavy)
                    
                    Text("Select Carrier")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .padding(.top, 120)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        //                    Text("1. Select Your Carrier")
                        //                        .font(.headline)
                        Text("The call forwarding method is different for every phone carrier")
                            .subTextStyle()
                        
                        
                        DropDownView(selection: $selectedCarrier, title: "Cell Carrier", prompt: "Select your carrier", options: cellCarriers)
                            .onChange(of: selectedCarrier) { newCarrier in
                                //                        if let carrier = newCarrier {
                                UserDefaults.standard.set(newCarrier, forKey: "phoneCarrier")
                                print("Carrier changed to: \(newCarrier)")
                                //                        }
                            }
                    }
                    
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(.horizontal, 1)
                .frame(width: geometry.size.width)
                .frame(minHeight: geometry.size.height)
//            }
            //            .padding(.top, 80)
        }
        
        //        }
        
        .overlay(
            ZStack {
                Text("Set Up Later")
                    .contentShape(Rectangle())
                    .onTapGesture {
                        appState.currentView = .agent
                    }
                    .foregroundColor(Color("Orange"))
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.leading, 20)
            }
                .frame(height: 70)
                .frame(maxHeight: .infinity, alignment: .top)
        )
    }
}

struct ActivationStep: View {
    @ObservedObject var agentManager = AgentManager.shared
    var selectedCarrier: String
    @Binding var currentStep: Int
    @Binding var clickedForwardCall: Bool
    @EnvironmentObject var appState: AppState
    
    // Use @State for any other local state variables you need for this step
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Text("Forward calls")
                .font(.largeTitle)
                .fontWeight(.heavy)
            //                .frame(maxWidth: .infinity)
            
            VStack(alignment: .leading, spacing: 10) {
                
                let forwardingNumber = callForwardingActivate(for: selectedCarrier, phoneNumber: Constants.agentPhoneNumber)
                
                HStack {
                    Button(action: {
                        UIPasteboard.general.string = forwardingNumber
                    }) {
                        Image(systemName: "doc.on.clipboard")
                            .foregroundColor(Color(.black).opacity(0.4))
                    }
                    .padding(.trailing, 8)
                    Text(forwardingNumber)
                        .foregroundColor(.black.opacity(0.8))
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    
                }
                //                .frame(maxWidth: .infinity)
                
                GradientButton(title: "Call to Activate", icon: "phone", iconPosition: .left, isLoading: .constant(false), onClick: {
                    if let url = URL(string: "tel://\(forwardingNumber)"), UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                    clickedForwardCall = true
                })
                .disableWithOpacity(selectedCarrier == "")
                
                //                OrDivider()
                VStack(alignment: .center, spacing: 20) {
//                Text("Note")
//                    .font(.caption)
//                    .foregroundColor(.white)
//                    .fontWeight(.semibold)
//                    .padding(4)
//                    .background(Color("Orange"))
//                    .cornerRadius(3)
//                    .padding(.top, 20)
                
                //                if let carrier = selectedCarrier {
                let deactivationForwardingNumber = callForwardingDeactivate(for: selectedCarrier)
                Text("\(Text("Note:").bold()) You can revert to your original voicemail at any time by dialing the following number.")
                    .subTextStyle()
                
                    HStack {
                        Button(action: {
                            UIPasteboard.general.string = deactivationForwardingNumber
                        }) {
                            Image(systemName: "doc.on.clipboard")
                                .foregroundColor(Color(.black).opacity(0.4))
                        }
                        .padding(.trailing, 8)
                        Text(deactivationForwardingNumber)
                        //                            .padding(.horizontal, 15)
                        //                            .padding(.vertical, 10)
                            .bold()
                            .foregroundColor(.black.opacity(0.8))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                    }
                }
                .frame(maxWidth: .infinity)
                .padding() // Add some padding inside the HStack
                .background(Color("AccentColor").opacity(0.1)) // Set an orange background with low opacity
                .cornerRadius(12) // Set the corner radius to 12
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color("AccentColor").opacity(0.3), lineWidth: 1))
                .padding(.top, 20)
            }
            //            .padding(.top, 80)
            //            .frame(maxHeight: .infinity)
        }
        .frame(maxHeight: .infinity)
        .overlay(
            ZStack {
                Text("Set Up Later")
                    .contentShape(Rectangle())
                    .onTapGesture {
                        appState.currentView = .agent
                    }
                    .foregroundColor(Color("Orange"))
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.leading, 20)
            }
                .frame(height: 70)
                .frame(maxHeight: .infinity, alignment: .top)
        )
    }
}

struct ProTipTag: View {
    var body: some View {
        Text("PRO TIP")
            .font(.caption)
            .foregroundColor(.white)
            .fontWeight(.semibold)
            .padding(4)
            .background(Color("AccentColor"))
            .cornerRadius(3)
    }
}

struct InstructionView_Previews: PreviewProvider {
    static var previews: some View {
        // Create an instance of your view
        InstructionView()
        // Provide an instance of AppState as an environment object
        //            .environmentObject(MockAppState())
    }
}
