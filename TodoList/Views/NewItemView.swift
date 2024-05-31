//
//  NewItemView.swift
//  TodoList
//
//  Created by 宮川義之助 on 2024/05/30.
//

import PhotosUI
import SwiftUI

struct NewItemView: View {
    
    // MARK: Stored properties
    
    // The item currently being added
    @State var newItemDescription = ""
    
    // The selection made in the PhotosPicker
    @State var selectionResult: PhotosPickerItem?

    // The actual image loaded from the selection that was made
    @State var newItemImage: TodoItemImage?
    
    // Access the view model through the environment
    @Environment(TodoListViewModel.self) var viewModel
    
    // Binding to control whether this view is visible
    @Binding var showSheet: Bool
    
    // MARK: Computed properties
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Enter a to-do item", text: $newItemDescription)
                    
                    Button("ADD") {
                        // Add the new to-do item
                        viewModel.createToDo(withTitle: newItemDescription)
                        // Clear the input field
                        newItemDescription = ""
                        // Clear the photo picker selection result
                        selectionResult = nil
                        // Clear the loaded photo
                        newItemImage = nil
                    }
                    .font(.caption)
                    .disabled(newItemDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true)
                }

                HStack {
                    
                    PhotosPicker(selection: $selectionResult, matching: .images) {
                        
                        // Has an image been loaded?
                        if let newItemImage = newItemImage {
                            
                            // Yes, show it
                            newItemImage.image
                                .resizable()
                                .scaledToFit()

                        } else {
                            
                            // No, show an icon instead
                            Image(systemName: "photo.badge.plus")
                                .symbolRenderingMode(.multicolor)
                                .font(.system(size: 30))
                                .foregroundStyle(.tint)
                            
                        }
                    }

                }
                .frame(height: 100)
            }
            .padding(20)
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button {
                        showSheet = false
                    } label: {
                        Text("Done")
                            .bold()
                    }
                    
                }
            }
            // This block of code is invoked whenever the selection from the picker changes
            .onChange(of: selectionResult) {
                // When the selection result is not nil...
                if let imageSelection = selectionResult {
                    // ... transfer the data from the selection result into
                    // an actual instance of TodoItemImage
                    loadTransferable(from: imageSelection)
                }
            }

            
            
        }


    }
    
    // MARK: Functions

    // Transfer the data from the PhotosPicker selection result into the stored property that
    // will hold the actual image for the new to-do item
    private func loadTransferable(from imageSelection: PhotosPickerItem) {
        Task {
            do {
                // Attempt to set the stored property that holds the image data
                newItemImage = try await imageSelection.loadTransferable(type: TodoItemImage.self)
            } catch {
                debugPrint(error)
            }
        }
    }
    
}

#Preview {
    NewItemView(showSheet: .constant(true))
}
