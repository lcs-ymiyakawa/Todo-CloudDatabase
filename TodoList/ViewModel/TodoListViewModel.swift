//
//  TodoListViewModel.swift
//  TodoList
//
//  Created by 宮川義之助 on 2024/04/18.
//

import Foundation
import Storage

@Observable
class TodoListViewModel {
    
    // MARK: Stored properties
    // The list of to-do items
    var todos: [TodoItem]
    
    // Track when to-do items are initially being fetched
    var fetchingTodos: Bool = false
    
    // MARK: Initializer(s)
    init(todos: [TodoItem] = []) {
        self.todos = todos
        Task {
                    try await getTodos()
                }
    }
    
    // MARK: Functions
    
    func getTodos() async throws {
        
        // Indicate that app is in the process of getting to-do items from cloud
        fetchingTodos = true
        
        do {
            let results: [TodoItem] = try await supabase
                .from("todos")
                .select()
                .order("id", ascending: true)
                .execute()
                .value
            
            self.todos = results
            
            // Finished getting to-do items
            fetchingTodos = false
            
        } catch {
            debugPrint(error)
        }
        
    }
    
    func createToDo(withTitle title: String, andImage providedImage: TodoItemImage?) {
        
        // Create a unit of asynchronous work to add the to-do item
        Task {
            // Upload an image.
            // If one was not provided to this function, then this
            // function call will return a nil value.
            let imageURL = try await uploadImage(providedImage)
            // Create the new to-do item instance
            // NOTE: The id will be nil for now
            let todo = TodoItem(
                title: title,
                done: false
                imageURL: imageURL
            )
            
            // Write it to the database
            do {
                
                // Insert the new to-do item, and then immediately select
                // it back out of the database
                let newlyInsertedItem: TodoItem = try await supabase
                    .from("todos")
                    .insert(todo)   // Insert the todo item created locally in memory
                    .select()       // Select the item just inserted
                    .single()       // Ensure just one row is returned
                    .execute()      // Run the query
                    .value          // Automatically decode the JSON into an instance of TodoItem

                // Finally, insert the to-do item instance we just selected back from the
                // database into the array used by the view model
                // NOTE: We do this to obtain the id that is automatically assigned by Supabase
                //       when the to-do item was inserted into the database table
                self.todos.append(newlyInsertedItem)
                
            } catch {
                debugPrint(error)
            }
        }
    }
    
    // We mark the function as "private" meaning it can only be invoked from inside
    // the view model itself (it will not be accessible from the view layer)
    private func uploadImage(_ image: TodoItemImage?) async throws -> String? {
        
        // Only continue past this point if an image was provided.
        // If an image was provided, obtain the raw image data.
        guard let imageData = image?.data else {
            return nil
        }
        
        // Generate a unique file path for the provided image
        let filePath = "\(UUID().uuidString).jpeg"
        
        // Attempt to upload the raw image data to the bucket at Supabase
        try await supabase.storage
            .from("todos_images")
            .upload(
                path: filePath,
                file: imageData,
                options: FileOptions(contentType: "image/jpeg")
            )
        
        return filePath
    }
    
    func downloadTodoItemImage(fromPath path: String) async throws -> TodoItemImage? {
        
        // Attempt to download an image from the provided path
        do {
            let data = try await supabase
                .storage
                .from("todos_images")
                .download(path: path)
            
            return TodoItemImage(rawImageData: data)
            
        } catch {
            debugPrint(error)
        }
        
        // If we landed here, something went wrong, so return nil
        return nil
        
    }
    
    func delete(_ todo: TodoItem) {
            
            // Create a unit of asynchronous work to add the to-do item
            Task {
                
                do {
                    
                    // Run the delete command
                    try await supabase
                        .from("todos")
                        .delete()
                        .eq("id", value: todo.id!)  // Only delete the row whose id
                        .execute()                  // matches that of the to-do being deleted
                    
                    // Update the list of to-do items held in memory to reflect the deletion
                    try await self.getTodos()

                } catch {
                    debugPrint(error)
                }
                
                
            }
                    
        }
    
    func update(todo updatedTodo: TodoItem) {
           
           // Create a unit of asynchronous work to add the to-do item
           Task {
               
               do {
                   
                   // Run the update command
                   try await supabase
                       .from("todos")
                       .update(updatedTodo)
                       .eq("id", value: updatedTodo.id!)   // Only update the row whose id
                       .execute()                          // matches that of the to-do being deleted
                       
               } catch {
                   debugPrint(error)
               }
               
           }
           
       }
    
    func filterTodos(on searchTerm: String) async throws {

	if searchTerm.isEmpty {

		// Get all the to-dos
		Task {
			try await getTodos()
		}

	} else {

		// Get a filtered list of to-dos
		do {
			let results: [TodoItem] = try await supabase
				.from("todos")
				.select()
				.ilike("title", pattern: "%\(searchTerm)%")
				.order("id", ascending: true)
				.execute()
				.value

			self.todos = results

		} catch {
			debugPrint(error)
		}

	}

}
}
