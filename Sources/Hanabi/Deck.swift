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
        return storage.popLast()
    }
}