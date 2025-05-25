//
//  ContentView.swift
//  BetterRest
//
//  Created by Adnan Bakaev  on 24/05/2025.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1

    @State private var alerTitle = ""
    @State private var alertMessage = ""
    @State private var showAlert = false
    
    static var defaultWakeTime : Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }

    var body: some View {
        NavigationStack {
            Form {
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("When do you want to wake up?")
                        .font(.headline)

                    DatePicker(
                        "Please enter a time",
                        selection: $wakeUp,
                        displayedComponents: .hourAndMinute
                    )
                    .labelsHidden()
                }
        
                VStack(alignment: .leading, spacing: 0) {
                    Text("Desired amount of sleep")
                        .font(.headline)

                    Stepper(
                        "\(sleepAmount.formatted()) hours",
                        value: $sleepAmount,
                        in: 4...12,
                        step: 0.25
                    )
                }
               
                VStack(alignment: .leading, spacing: 0) {
                    Text("Daily coffee intake")
                        .font(.headline)

                    Stepper(
                        "\(coffeeAmount) cup(s)",
                        value: $coffeeAmount,
                        in: 1...20
                    )
                }
          
            }
            .navigationTitle("BetterRest ")
            .toolbar {
                Button("Calculate", action: calculateBedTime)
            }
            .alert(alerTitle, isPresented: $showAlert) {
                Button("OK") {}
            } message: {
                Text(alertMessage)
            }
        }

    }

    func calculateBedTime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)

            let components = Calendar.current.dateComponents(
                [.hour, .minute],
                from: wakeUp
            )
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60

            let prediction = try model.prediction(
                wake: Double(hour + minute),
                estimatedSleep: sleepAmount,
                coffee: Double(coffeeAmount)
            )

            let sleepTime = wakeUp - prediction.actualSleep

            alerTitle = "Your ideal bedtime is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)

        } catch {
            alerTitle = "Error"
            alertMessage =
                "Sorry, there was an error calculating your sleep time. Please try again later."
        }

        showAlert = true
    }

}

#Preview {
    ContentView()
}
