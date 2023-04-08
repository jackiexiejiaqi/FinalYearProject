//
//  FinalYearProjectApp.swift
//  FinalYearProject
//
//  Created by Jiaqi Xie on 08/04/2023.
//

import SwiftUI

@main
struct FinalYearProjectApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
