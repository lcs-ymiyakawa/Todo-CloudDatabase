//
//  ItemView.swift
//  TodoList
//
//  Created by Russell Gordon on 2024-04-08.
//

import SwiftUI

struct ItemView: View {
    
    // Holds a reference to the current to-do item
    @Binding var currentItem: TodoItem

    // Holds the image for this to-do item, if an image exists
    @State var currentItemImage: TodoItemImage?
    
    //Access the view model through environment
    @Environment(TodoListViewModel.self) var viewModel
    
    var body: some View {
        HStack {
            Label(
                title: {
                    TextField("", text: $currentItem.title, axis: .vertical)
                        .onSubmit {
                            viewModel.update(todo: currentItem)
                        }
                }, icon: {
                    Image(systemName: currentItem.done == true ? "checkmark.circle" : "circle")
                        // Tap to mark as done
                        .onTapGesture {
                            currentItem.done.toggle()
                            viewModel.update(todo: currentItem)
                        }
                    
                }
            )
            
            // When an image has been successfully downloaded for this to-do item,
            // (it is not nil), then show a preview of the image (not too big since it is in a list)
            if let currentItemImage = currentItemImage {
                currentItemImage.image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 30, height: 30, alignment: .center)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            }

        }
        // Adds an asynchronous task to perform before this view appears.
        .task {
            // If the image URL for this to-do item is not nil, and if it is not an empty string...
            if let todoItemImageURL = currentItem.imageURL, todoItemImageURL.isEmpty == false {
                
                // ... then attempt to download the image so it can be displayed in this view
                do {
                    currentItemImage = try await viewModel.downloadTodoItemImage(fromPath: todoItemImageURL)
                } catch {
                    debugPrint(error)
                }
                
            }
        }
    }
}

#Preview {
    List {
        ItemView(currentItem: .constant(firstItem))
        ItemView(currentItem: .constant(secondItem))
    }
}
