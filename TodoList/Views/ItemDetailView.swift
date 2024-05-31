//
//  ItemDetailView.swift
//  TodoList
//
//  Created by 宮川義之助 on 2024/05/31.
//

import SwiftUI

struct ItemDetailView: View {

    // Holds a reference to the current to-do item
    @Binding var currentItem: TodoItem
    
    // Holds the image for this to-do item
    @State var currentItemImage: TodoItemImage?

    // Access the view model through the environment
    @Environment(TodoListViewModel.self) var viewModel
    
    var body: some View {
        ScrollViewReader { scrollView in
            ScrollView {
                // When an image has been downloaded, show it
                if let currentItemImage = currentItemImage {
                    
                        currentItemImage.image
                            .resizable()
                            .scaledToFill()
                    
                } else {
                    
                    // While waiting for the image to download
                    // show a progress indicator
                    ProgressView()
                }
                
                Label(
                    title: {
                        TextField("", text: $currentItem.title, axis: .vertical)
                            .onSubmit {
                                viewModel.update(todo: currentItem)
                            }
                            .onTapGesture {
                                // If the user chooses to update
                                // this to-do item, and the image
                                // is tall, ensure the scroll
                                // view scrolls down to show
                                // this part of the user
                                // interface
                                withAnimation {
                                    scrollView.scrollTo(1)
                                }
                            }
                    }, icon: {
                        Image(systemName: currentItem.done == true ? "checkmark.circle" : "circle")
                            // Tap to mark as done
                            .onTapGesture {
                                currentItem.done.toggle()
                                viewModel.update(todo: currentItem)
                            }
                            .font(.title2)
                            .foregroundStyle(.tint)
                            
                    }
                )
                .padding()
                
                // Anchor to draw the focus down to this part of the scroll view
                Color.clear
                    .frame(height: 10)
                    .id(1)
                
            }
        }
        // Don't leave space for a navigation title
        .navigationBarTitleDisplayMode(.inline)
        // Load the image for this to-do item, if one exists
        .task {
            if let todoItemImageURL = currentItem.imageURL, todoItemImageURL.isEmpty == false {
                
                do {
                    currentItemImage = try await viewModel.downloadTodoItemImage(fromPath: todoItemImageURL)
                } catch {
                    debugPrint(error)
                }
            }
        }
        // Add a button to allow for deletion of the to-do item
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button("Delete", role: .destructive) {
                    viewModel.delete(currentItem)
                }
                .foregroundStyle(.red)
            }
        }
    }
}

#Preview {
    List {
        ItemDetailView(currentItem: .constant(firstItem))
        ItemDetailView(currentItem: .constant(secondItem))
    }
}
