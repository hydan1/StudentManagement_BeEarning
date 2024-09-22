//
//  ContentView.swift
//  StudentManagementOnWatch Watch App
//
//  Created by Hydan on 22/9/24.
//

import SwiftUI
import WatchConnectivity

struct ContentView: View {
    @State private var students: [Student] = []
    
    var body: some View {
        List {
            Section(header: Text("Students").font(.headline)) {
                ForEach(students) { student in
                    Text(student.name)
                }
            }
        }
        .onAppear {
            // Set up the connectivity manager
            ConnectivityManager.shared.onReceiveStudents = { receivedStudents in
                DispatchQueue.main.async {
                    self.students = receivedStudents
                }
            }
        }
    }
}


#Preview {
    ContentView()
}
