//
//  Author: Jashan Kalsi - 991494313
//  Course: INFO10229 Mobile Computing
//  Date: 2025-05-30
//
//
//  main.swift
//  Student Management System - Assignment 1
//

import Foundation

// Student Class
class Student {
    let id: Int
    let name: String
    private(set) var grades: [Double] // List of the student's grades; private(set) so only this class can modify
    
    init(id: Int, name: String, grades: [Double] = []) {
        self.id = id
        self.name = name
        self.grades = grades
    }

// Calculates the average grade. Returns nil if no grades are present.
    func averageGrade() -> Double? {
        guard !grades.isEmpty else { return nil }
        return grades.reduce(0, +) / Double(grades.count)
    }

// Determines if the student is passing based on the given threshold.
// Returns false if no grades are present.
    func isPassing(threshold: Double) -> Bool {
        guard let avg = averageGrade() else { return false }
        return avg >= threshold
    }
}

// StudentStore Class - Manages a collection of `Student` instances, allowing addition and retrieval.
class StudentStore {
    private var students: [Int: Student] = [:] // Keyed by student ID for quick lookup
 
// Adds a new student to the store. Returns false if the ID already exists.
    func add(_ student: Student) -> Bool {
        guard students[student.id] == nil else {
            return false } // Prevent duplicate
        students[student.id] = student
        return true
    }
    
// Returns all students sorted by ID.
    func all() -> [Student] {
        students.values.sorted { $0.id < $1.id }
    }
    
// Retrieves a student by their ID.
    func byID(_ id: Int) -> Student? {
        students[id]
    }
}

// Menu Enum
// Defines the main menu options for the CLI interface.
enum Menu: Int, CaseIterable {
    case add       = 1, viewAll, calcAverage, passFail, exit

// Displays the menu and prompts the user for a choice.
    static func prompt() -> Menu? {
        print("""
        
        ===== Student Management System =====
        1. Add a new student
        2. View all students
        3. Calculate average grade for a student
        4. Display passing or failing students
        5. Exit
        =====================================
        Enter your choice:
        """, terminator: " ")
        
        // Read line, convert to Int, then map to Menu case
        return Int(readLine() ?? "")
            .flatMap(Menu.init(rawValue:))
    }
}

// Reads an integer input from the user with validation.
func readInt(prompt: String) -> Int {
    while true {
        print(prompt, terminator: " ")
        if let str = readLine(), let val = Int(str) { return val }
        print("Invalid integer. Try again.")
    }
}

// Reads a list of double grades from the user with validation.
// Returns: An array of Doubles parsed from the input.
func readGrades(prompt: String) -> [Double] {
    while true {
        print(prompt, terminator: " ")
        if let line = readLine() {
            let parts = line.split(separator: " ")
            let doubles = parts.compactMap { Double($0) }
            // Ensure every token converted successfully
            if doubles.count == parts.count {
                return doubles
            }
        }
        print("Enter space-separated numeric grades (e.g., 52 82.7 99).")
    }
}

// Reads and validates a Double from standard input.
func readDouble(prompt: String) -> Double {
    while true {
        print(prompt, terminator: " ")
        if let str = readLine(), let val = Double(str) { return val }
        print("Invalid number. Try again.")
    }
}

let store = StudentStore()  // Initialize the student storage

while true {
    // Display menu and get user selection
    guard let choice = Menu.prompt() else {
        print("Please enter a number between 1 and 5.")
        continue
    }
    
    switch choice {
      
    // Case 1: Add a new student
    case .add:
        var id: Int
                // Loop until a unique ID is provided or user cancels
                while true {
                    id = readInt(prompt: "Enter student ID (or -1 to cancel):")
                    if id == -1 {
                        print("Cancelled adding student.")
                        break
                    }
                    if store.byID(id) == nil {
                        break // Unique ID found, proceed
                    }
                    print("Error: A student with ID \(id) already exists. Try a different ID.")
                }
                
                // If user cancelled, skip to next menu iteration
                if id == -1 {
                    continue
                }
        // Ensure a non-empty name is provided.
        var name: String
        repeat{
            print("Enter student name:", terminator: " ")
            name = readLine() ?? ""
            if name.isEmpty {
                print("Name cannot be empty. Try again!")
            }
        } while name.isEmpty
        
        // Read grades list from user
        let grades = readGrades(prompt: "Enter grades separated by spaces:")
        
        // Create Student object and attempt to add
        let student = Student(id: id, name: name, grades: grades)
        if store.add(student) {
            print("Student added successfully!")
        } else {
            // Should not occur due to prior uniqueness check, but included for safety
            print("A student with that ID already exists.")
        }
    
    // Case 2: View all students currently in the system
    case .viewAll:
        print("\n--- Student List ---")
        if store.all().isEmpty {
            print("No students in the system.")
        } else {
            for s in store.all() {
                print("ID: \(s.id), Name: \(s.name), Grades: \(s.grades)")
            }
        }
        
// Case 3: Calculate and display a student's average grade
    case .calcAverage:
            var id: Int
            // Loop until a valid ID is provided or user cancels
            while true {
                id = readInt(prompt: "Enter student ID to calculate average grade (or -1 to cancel):")
                if id == -1 {
                    print("Cancelled calculating average grade.")
                    break
                }
                if let s = store.byID(id) {
                    // Compute average if grades exist
                    if let avg = s.averageGrade() {
                        print("Average grade for \(s.name): \(String(format: "%.2f", avg))")
                    } else {
                        print("\(s.name) has no grades recorded.")
                    }
                    break // Valid ID found, exit loop
                }
                print("Student ID \(id) not found. Try a different ID.")
            }
    
// Case 4: Display which students are passing or failing
    case .passFail:
        let threshold = readDouble(prompt: "Enter grade threshold:")
        let passing = store.all().filter { $0.isPassing(threshold: threshold) }
        let failing = store.all().filter { !$0.isPassing(threshold: threshold) }
        
// Helper function to print a group of students with their averages
        func printGroup(title: String, group: [Student]) {
            print("\n--- \(title) ---")
            if group.isEmpty {
                print("None.")
            } else {
                for s in group {
                    let avgStr = s.averageGrade().map { String(format: "%.2f", $0) } ?? "N/A"
                    print("ID: \(s.id), Name: \(s.name), Average: \(avgStr)")
                }
            }
        }
        printGroup(title: "Passing Students", group: passing)
        printGroup(title: "Failing Students", group: failing)
        
    case .exit:
        print("Exiting the management program. Goodbye!")
        exit(EXIT_SUCCESS)
    }
}
