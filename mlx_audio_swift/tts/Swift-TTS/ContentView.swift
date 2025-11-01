//
//  ContentView.swift
//  Swift-TTS
//
//  Created by Ben Harraway on 13/04/2025.
//

import SwiftUI
import MLX

struct ContentView: View {
    
    @State private var kokoroTTSModel: KokoroTTSModel? = nil
    @State private var orpheusTTSModel: OrpheusTTSModel? = nil
    
    @State private var sayThis: String = "Hello Everybody"
    @State private var status: String = ""
    
    @State private var chosenProvider: TTSProvider = .kokoro  // Default provider
    @State private var chosenVoice: String = "" // will be set based on provider
    
    var body: some View {
        VStack {
            Image(systemName: "mouth")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("TTS Examples")
                .font(.headline)
                .padding()
            
            if #available(iOS 17.0, *) {
                Picker("Choose a provider", selection: $chosenProvider) {
                    ForEach(TTSProvider.allCases, id: \.self) { provider in
                        Text(provider.displayName)
                    }
                }
                .onChange(of: chosenProvider) { _, newProvider in
                    chosenVoice = newProvider.defaultVoice
                    status = newProvider.statusMessage
                }
                .padding()
                .padding(.bottom, 0)
            } else {
                // Fallback on earlier versions
            }
            
            // Voice picker
            Picker("Choose a voice", selection: $chosenVoice) {
                ForEach(chosenProvider.availableVoices, id: \.self) { voice in
                    Text(voice.capitalized)
                }
            }
            .padding()
            .padding(.top, 0)
            
            TextField("Enter text", text: $sayThis).padding()
            
            Button(action: {
                Task {
                    status = "Generating..."
                    switch chosenProvider {
                    case .kokoro:
                        generateWithKokoro()
                    case .orpheus:
                        await generateWithOrpheus()
                    }
                }
            }, label: {
                Text("Generate")
                    .font(.title2)
                    .padding()
            })
            .buttonStyle(.borderedProminent)
            
            ScrollView {
                Text(status)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .frame(height: 100)
        }
        .padding()
    }
    
    // MARK: - TTS Generation Methods
    
    private func generateWithKokoro() {
        if kokoroTTSModel == nil {
            kokoroTTSModel = KokoroTTSModel()
        }
        
        if chosenProvider.validateVoice(chosenVoice),
           let kokoroVoice = TTSVoice.fromIdentifier(chosenVoice) ?? TTSVoice(rawValue: chosenVoice) {
            kokoroTTSModel!.say(sayThis, kokoroVoice)
            status = "Done"
        } else {
            status = chosenProvider.errorMessage
        }
    }
    
    private func generateWithOrpheus() async {
        if orpheusTTSModel == nil {
            orpheusTTSModel = OrpheusTTSModel()
        }
        
        if chosenProvider.validateVoice(chosenVoice),
           let orpheusVoice = OrpheusVoice(rawValue: chosenVoice) {
            await orpheusTTSModel!.say(sayThis, orpheusVoice)
            status = "Done"
        } else {
            status = chosenProvider.errorMessage
        }
    }
}

#Preview {
    ContentView()
}
