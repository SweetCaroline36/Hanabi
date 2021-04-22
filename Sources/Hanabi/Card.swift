struct Card: CustomStringConvertible {

    enum Color: CaseIterable {
        case blue, red, yellow, green, purple

        var description: String {
            switch self {
            case .blue: return "blue"
            case .red: return "red"
            case .yellow: return "yellow"
            case .green: return "green"
            case .purple: return "purple"
            }
        }
    }

    enum Number: CaseIterable, CustomStringConvertible {
        case one, two, three, four, five

        var description: String { "\(value)" }

        var value: Int {
            switch self {
            case .one: return 1
            case .two: return 2
            case .three: return 3
            case .four: return 4
            case .five: return 5
            }
        }
        var frequency: Int {
            switch self {
            case .one: return 3
            case .two, .three, .four: return 2
            case .five: return 1
            }
        }
    }

    let color: Color

    let number: Number

    var description: String {
        return "\(color) \(number)"
    }
}