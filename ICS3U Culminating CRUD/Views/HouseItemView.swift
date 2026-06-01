//
//  HouseItemView.swift
//  ICS3U Culminating CRUD
//
//  Created by Ethan Edmond Weinbrecht on 2026-06-01.
//

import SwiftUI

// CUSTOM SUBVIEW a.k.a. HELPER VIEW
struct HouseItemView: View {
    
    // MARK: Stored properties
    // Stored properties must be provided with a value by providing an argument when creating an instance of this structure, or, be initialized with a default value
    
    // Which house to show information about?
    let providedHouse: House

    // MARK: Computed properties
    // Computed properties calculate or derive a value using stored properties
    
    // The "body" property defines the user interface for this view
    var body: some View {
        VStack(alignment: .leading) {
            Text(providedHouse.name)
                .font(.largeTitle)
            Text(providedHouse.description)
        }
    }
}

#Preview {
    HouseItemView(providedHouse: ryder)
        .padding()
}
