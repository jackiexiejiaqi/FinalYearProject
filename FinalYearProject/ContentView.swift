//
//  ContentView.swift
//  FinalYearProject
//
//  Created by Jiaqi Xie on 08/04/2023.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        TabNavigationView()
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
