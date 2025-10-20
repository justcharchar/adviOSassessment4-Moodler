//
//  GoalView.swift
//  Moodler
//
//  Created by Owen Herianto on 20/10/2025.
//

import SwiftUI
import UIKit

struct GoalView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("goal") private var storedGoal: String = ""
    @State private var tempGoal: String = ""
    private let characterLimit = 250 

    var body: some View {
        Form {
            Section(header: Text("Your Goal")) {
                TextEditor(text: Binding(
                    get: { tempGoal },
                    set: { newValue in
                        if newValue.count <= characterLimit {
                            tempGoal = newValue
                        }
                    }
                ))
                .frame(minHeight: 150)
                .padding(.vertical, 4)
                
                HStack {
                    Spacer()
                    Text("\(tempGoal.count)/\(characterLimit)")
                        .font(.caption)
                        .foregroundColor(tempGoal.count >= characterLimit ? .red : .secondary)
                }
            }
        }
        .navigationTitle("Your Goal")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    storedGoal = tempGoal
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    dismiss()
                }
                .disabled(tempGoal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .onAppear {
            tempGoal = storedGoal
        }
    }
}
