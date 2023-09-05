//
//  ContentView.swift
//  WordScramble
//
//  Created by Julian Miño on 31/08/2023.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var currentScore = 0
    
    var body: some View {
        VStack {
            NavigationView {
                List {
                    Section {
                        TextField("Enter your word", text: $newWord)
                            .textInputAutocapitalization(.never)
                    }
                    
                    Section {
                        ForEach(usedWords, id: \.self) { word in
                            HStack {
                                Image(systemName: "\(word.count).circle")
                                Text(word)
                            }
                        }
                    }
                }
                .navigationTitle(rootWord)
                .onSubmit {
                    addWord()
                }
                .onAppear {
                    startGame()
                }
                .alert(errorTitle, isPresented: $showingError) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(errorMessage)
                }
                .toolbar {
                    Button("Restart game") {
                        startGame()
                    }
                }
            }
            
            Text("Score: \(currentScore)")
                .padding(40)
                .backgroundStyle(.thickMaterial)
                .clipShape(Capsule())
        }
    }
    
    private func startGame() {
        usedWords = []
        currentScore = 0
        guard let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"),
              let startWords = try? String(contentsOf: startWordsURL) else {
            fatalError("Couldn't load file start.text from Bundle.")
        }
        let allWords = startWords.components(separatedBy: "\n")
        rootWord = allWords.randomElement() ?? "silkworm"
    }
    
    private func addWord() {
        let word = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard word.count > 2, word != rootWord else {
            showError(title: "Not a valid word", message: "Your word is either short or the same as \(rootWord.uppercased())")
            return
        }
        
        guard isOriginal(word) else {
            showError(title: "Word used already", message: "Be more original!")
            return
        }
        
        guard isPossible(word) else {
            showError(title: "Word not possible", message: "You can't spell that word from \(rootWord)!")
            return
        }
        
        guard isReal(word) else {
            showError(title: "Word is not real", message: "\(word) is not a real word in english!")
            return
        }
        
        withAnimation {
            usedWords.insert(word, at: 0)
            newWord = ""
            currentScore = (currentScore + 1) * word.count / 2
        }
    }
    
    private func isOriginal(_ word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    private func isPossible(_ word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    private func isReal(_ word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    private func showError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
