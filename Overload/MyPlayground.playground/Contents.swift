import UIKit

var str = "Hello, playground"

let range = 1...10
let value = 5
let interval = 1
let rowCount = Int(ceil(Double((range.upperBound - range.lowerBound) / interval)))
    

let first = value - range.lowerBound
let second = range.upperBound - range.lowerBound
let percent = Double(first) / Double(second)
let index = Int(percent * Double(rowCount))
print("index:\(index)")
