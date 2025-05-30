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

class Student {
    let id: Int
    let name: String
    private(set) var grades: [Double]
    
    init(id: Int, name: String, grades: [Double] = []) {
        self.id = id
        self.name = name
        self.grades = grades
    }
    
    func addGrades(_ newGrades: [Double]) {
        grades.append(contentsOf: newGrades)
    }
    
    func averageGrade() -> Double? {
        guard !grades.isEmpty else { return nil }
        return grades.reduce(0, +) / Double(grades.count)
    }
    
    func isPassing(threshold: Double) -> Bool {
        guard let avg = averageGrade() else { return false }
        return avg >= threshold
    }
}

class StudentStore {
    private var students: [Int: Student] = [:]   // keyed by ID
    
    // CRUD helpers
    func add(_ student: Student) -> Bool {
        guard students[student.id] == nil else { return false } // duplicate
        students[student.id] = student
        return true
    }
    
    func all() -> [Student] {
        students.values.sorted { $0.id < $1.id }
    }
    
    func byID(_ id: Int) -> Student? {
        students[id]
    }
}

enum Menu: Int, CaseIterable {
    case add       = 1, viewAll, calcAverage, passFail, exit
    
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
        
        return Int(readLine() ?? "")
            .flatMap(Menu.init(rawValue:))
    }
}

func readInt(prompt: String) -> Int {
    while true {
        print(prompt, terminator: " ")
        if let str = readLine(), let val = Int(str) { return val }
        print("⚠️  Invalid integer. Try again.")
    }
}

func readGrades(prompt: String) -> [Double] {
    while true {
        print(prompt, terminator: " ")
        if let line = readLine() {
            let parts = line.split(separator: " ")
            if let doubles = Optional(parts.compactMap { Double($0) }), doubles.count == parts.count {
                return doubles
            }
        }
        print("⚠️  Enter space-separated numeric grades (e.g., 75 82.5 91).")
    }
}

let store = StudentStore()

while true {
    guard let choice = Menu.prompt() else {
        print("⚠️  Please enter a number between 1 and 5.")
        continue
    }
    
    switch choice {
        
    case .add:
        let id    = readInt(prompt: "Enter student ID:")
        print("Enter student name:", terminator: " ")
        let name  = readLine() ?? "Unknown"
        let grades = readGrades(prompt: "Enter grades separated by spaces:")
        
        let student = Student(id: id, name: name, grades: grades)
        if store.add(student) {
            print("✅ Student added successfully!")
        } else {
            print("⚠️  A student with that ID already exists.")
        }
        
    case .viewAll:
        print("\n--- Student List ---")
        if store.all().isEmpty {
            print("No students in the system.")
        } else {
            for s in store.all() {
                print("ID: \(s.id), Name: \(s.name), Grades: \(s.grades)")
            }
        }
        
    case .calcAverage:
        let id = readInt(prompt: "Enter student ID to calculate average grade:")
        if let s = store.byID(id) {
            if let avg = s.averageGrade() {
                print("Average grade for \(s.name): \(String(format: "%.2f", avg))")
            } else {
                print("\(s.name) has no grades recorded.")
            }
        } else {
            print("⚠️  Student ID \(id) not found.")
        }
        
    case .passFail:
        let threshold = Double(readInt(prompt: "Enter grade threshold:"))
        let passing = store.all().filter { $0.isPassing(threshold: threshold) }
        let failing = store.all().filter { !$0.isPassing(threshold: threshold) }
        
        func printGroup(title: String, group: [Student]) {
            print("\n--- \(title) ---")
            if group.isEmpty {
                print("None.")
            } else {
                for s in group {
                    let avg = s.averageGrade() ?? 0
                    print("ID: \(s.id), Name: \(s.name), Average: \(String(format: "%.2f", avg))")
                }
            }
        }
        printGroup(title: "Passing Students", group: passing)
        printGroup(title: "Failing Students", group: failing)
        
    case .exit:
        print("Exiting the program. Goodbye!")
        exit(EXIT_SUCCESS)
    }
}
