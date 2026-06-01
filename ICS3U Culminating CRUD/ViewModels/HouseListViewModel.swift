//
//  HouseListViewModel.swift
//  ICS3U Culminating CRUD
//
//  Created by Ethan Edmond Weinbrecht on 2026-06-01.
//

import Foundation

// VIEW MODEL
@Observable
class HouseListViewModel {
    
    // MARK: Stored properties
    // Stored properties must be provided with a value by providing an argument when creating an instance of this class, or, be initialized with a default value
    
    // The list of houses
    // This list can be read from outside the view model, but not mutated (changed) outside the view model
    private(set) var housesList: [House]
    
    // MARK: Computed properties
    // Computed properties calculate or derive a value using stored properties

    // MARK: Initializers
    // Initializers get an instance of a class ready to be used

    // This initializer creates a list of houses based on the provided argument
    // If no argument is provided, the example house list is used instead
    init(housesList: [House] = exampleHouseList) {
        self.housesList = housesList
    }
    
    // MARK: Functions
    // Functions take action using information provided through parameters

}
