//
//  Utils.swift
//  NSRegularExpression
//
//  Created by wojteklu on 11/12/2016.
//

import Foundation

#if os(Linux)
    typealias NSRegularExpression = RegularExpression
#endif

public extension String {
    
    func matches(for regex: String) -> [NSRange] {
        
        // crash occurs on Linux
        // when RegularExpression has not balanced parantheses
        guard regex.hasBalancedParentheses(left: "(", right: ")"),
            regex.hasBalancedParentheses(left: "[", right: "]") else {
                return []
        }
        
        // or when throws an exception
        var cRegex = regex_t()
        let result = regcomp(&cRegex, regex, REG_EXTENDED)
        if result != 0 {
            return []
        }
        
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let nsString = NSString(string: self)
            return regex.matches(in: self, options: [], range: NSRange(location: 0, length: nsString.length)).map { $0.range }
        } catch _ {
            return []
        }
    }
    
    private func hasBalancedParentheses(left: String, right: String) -> Bool {
        
        let array = self.characters.map { String($0) }
        var leftCount = 0
        var rightCount = 0
        
        for (index, letter) in array.enumerated() {
            
            if letter == left && (index == 0 || (index>0 && array[index-1] != "\\")) {
                leftCount += 1
            }
            
            if letter == right && (index == 0 || (index>0 && array[index-1] != "\\")) {
                rightCount += 1
            }
        }
        
        if leftCount != rightCount {
            return false
        }

        return true
    }
}
