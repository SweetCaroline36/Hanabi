// I don't think this is important enough to get its own file. It's only used in Game. I think just put this in that file.
// Whitespace?
struct Deck {
    var storage: [Card]

    init() {
        storage = []

        for color in Card.Color.allCases {
            for number in Card.Number.allCases {
                storage += [Card](repeating: Card(color: color, number: number), count: number.frequency)
            }
        }
        storage.shuffle()
    }

    mutating func drawCard() -> Card? {
        storage.popLast()
    }
}
