// https://github.com/apple/swift-package-manager/blob/ad69efd093c6bdfbfa8cac143959f0bb6c43f0c4/Sources/Utility/StringExtensions.swift

extension String {
    /**
     Remove trailing newline characters. By default chomp removes
     all trailing \n (UNIX) or all trailing \r\n (Windows) (it will
     not remove mixed occurrences of both separators.
     */
    public func chomp(separator: String? = nil) -> String {
        func scrub(_ separator: String) -> String {
            var E = endIndex
            while String(self[startIndex ..< E]).hasSuffix(separator) && E > startIndex {
                E = index(before: E)
            }
            return String(self[startIndex ..< E])
        }

        if let separator = separator {
            return scrub(separator)
        } else if hasSuffix("\r\n") {
            return scrub("\r\n")
        } else if hasSuffix("\n") {
            return scrub("\n")
        } else {
            return self
        }
    }

    /**
     Trims whitespace from both ends of a string, if the resulting
     string is empty, returns `nil`.String

     Useful because you can short-circuit off the result and thus
     handle “falsy” strings in an elegant way:

     return userInput.chuzzle() ?? "default value"
     */
    public func chuzzle() -> String? {
        var cc = self

        loop: while true {
            switch cc.first {
            case nil:
                return nil
            case "\n"?, "\r"?, " "?, "\t"?, "\r\n"?:
                cc = String(cc.dropFirst())
            default:
                break loop
            }
        }

        loop: while true {
            switch cc.last {
            case nil:
                return nil
            case "\n"?, "\r"?, " "?, "\t"?, "\r\n"?:
                cc = String(cc.dropLast())
            default:
                break loop
            }
        }

        return String(cc)
    }
}
