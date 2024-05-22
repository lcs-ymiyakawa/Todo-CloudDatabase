//
//  Supbase.swift
//  TodoList
//
//  Created by 宮川義之助 on 2024/05/22.
//

import Foundation
import Supabase

let supabase = SupabaseClient(
  supabaseURL: URL(string: "https://ebpwpaydifnjekdmuswx.supabase.co")!,
  supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVicHdwYXlkaWZuamVrZG11c3d4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTM0NjYwNDksImV4cCI6MjAyOTA0MjA0OX0.--ytYWjkg2M1AEhWz6Fi087h69JHfqHYLgmkKDjp508"
)
