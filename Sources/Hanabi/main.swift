//Hanabi By Caroline Conner 

// Game: Hey player, make a move
// Player: Okay, play card 100
// Game: No you can't do that, do something else
// Player: Okay, inform player -112a about their Potatoes
// Game: Still no
// Player: Fine, play my second card
// Game: Great, that works

// What I want:
//    makeMove() -> (move: Move, makeMove: ???)

struct ReasonHandler {
    let handle: (IllegalMoveReason) -> Result<(Move, ReasonHandler), MakeMoveError>
    /*func callAsFunction(reason: Reason) throw -> (Move, ReasonHandler) {
        return try self.handle(reason).unwrap()
    }*/
    func callAsFunction(reason: IllegalMoveReason) -> Result<(Move, ReasonHandler), MakeMoveError> {
        return self.handle(reason)
    }
}
/*
extension Result<T, MakeMoveError> {
    func unwrap() throws -> T {
        switch self {
        case .value(let value):
            return value
        case .error(let error):
            throw error
        }
    }
}
*/
enum MakeMoveError: Error {
    case leftGame
    case disconnected
    case other
}

enum IllegalMoveReason {
    case invalidCard
    case invalidPlayer
    case outOfInfo
}

/*
struct Game {
    var player: Player

    func main() {
        var move: Move? = nil

        var (attemptedMove, reasonHandler) = player.makeMove()
        while (move == nil) {
            if let reason = whyIsTheMoveInvalid(attemptedMove) {
                switch reasonHandler(reason: reason) {
                case .success(let pair):
                    (attemptedMove, reasonHandler) = pair
                case .failure(let error):
                    giveUp(), crash(), whatever
                }
            } else {
                move = attemptedMove
            }
        }

        officiallyPlay(move!)
    }
}
*/

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

struct Game {
    //contains game info
    var gameOver = false
    var ranOut = false
    var score = 0

    let numberOfPlayers = 4
    let players: [Player]

    var infoCount = 8
    var maxInfoCount = 8
    var strikeCount = 0
    var maxStrikeCount = 20

    var deck: Deck
    var hands: [[Card]]
    var piles: [Card.Color: Int]

    init(players: [Player]) {
        deck = Deck()

        hands = [[Card]](repeating: [], count: numberOfPlayers)

        for player in 0..<numberOfPlayers {
            for _ in 0..<5 {
                hands[player].append(deck.drawCard()!)
            }
        }

        piles = [:]

        for color in Card.Color.allCases {
            piles[color] = 0
        }

        self.players = players
    }

    func updateEverything() {
        for currentPlayerIndex in players.indices {
            for otherPlayerIndex in players.indices {
                if otherPlayerIndex == currentPlayerIndex { continue }
                players[currentPlayerIndex].updateHand(player: otherPlayerIndex, cards: hands[otherPlayerIndex])
            }

            players[currentPlayerIndex].updateHand(count: hands[currentPlayerIndex].count)

            for (color, number) in piles {
                players[currentPlayerIndex].updatePile(color: color, currentNumber: number)
            }

            players[currentPlayerIndex].updateInfo(count: infoCount)
            players[currentPlayerIndex].updateStrikes(count: strikeCount)
        }
    }
    func tellPlayers(justPlayed: Int, move: Move) {
        for playerIndex in players.indices {
            if playerIndex == justPlayed { continue }
            players[playerIndex].receivePlayerMoves(player: justPlayed, move: move)
        }
    }

    mutating func run() {
       updateEverything()

        while !gameOver {
            for playerIndex in players.indices {
                let player = players[playerIndex]
    
                var move: Move? = nil

                var attemptedMove: Move
                var reasonHandler: ReasonHandler
                switch player.makeMove() {
                case .success(let pair):
                    (attemptedMove, reasonHandler) = pair
                case .failure(let error):
                    fatalError("Test crash")
                }

                while move == nil {
                    let reason: IllegalMoveReason?
                    switch attemptedMove {
                    case .discard(let cardIndex):
                        if !hands[playerIndex].indices.contains(cardIndex) {
                            reason = .invalidCard
                        } else {
                            reason = nil
                        }
                    case .play(let cardIndex):
                        if !hands[playerIndex].indices.contains(cardIndex) {
                            reason = .invalidCard
                        } else {
                            reason = nil
                        }
                    case .giveInfo(let otherPlayer, _):
                        if !players.indices.contains(otherPlayer) {
                            reason = .invalidPlayer
                        } 
                        else if infoCount == 0 {
                            reason = .outOfInfo
                        } else {
                            reason = nil
                        }
                    }


                    if let reason = reason {
                        switch reasonHandler(reason: reason) {
                        case .success(let pair):
                            (attemptedMove, reasonHandler) = pair
                        case .failure(let error):
                            fatalError("Test crash")
                        }
                    } else {
                        move = attemptedMove
                    }                    
                }
                switch move! {
                case .giveInfo(let otherPlayer, let info):

                    var indices: [Int] = []
                    
                    for cardIndex in hands[otherPlayer].indices {
                        switch info {
                        case .color(let color): 
                            if hands[otherPlayer][cardIndex].color == color {
                                indices.append(cardIndex)
                            }
                        case .number(let number):
                            if hands[otherPlayer][cardIndex].number == number {
                                indices.append(cardIndex)
                            }
                        }
                    }
                    players[otherPlayer].receiveInfo(cardIndices: indices, info: info)
                    infoCount -= 1

                case .discard(let cardIndex):

                    hands[playerIndex].remove(at: cardIndex)
                    if infoCount < maxInfoCount { infoCount += 1 }
                    
                    if let newCard = deck.drawCard() {
                        hands[playerIndex].append(newCard)
                    } 

                case .play(let cardIndex):

                    let card = hands[playerIndex][cardIndex]

                    if piles[card.color] == card.number.value - 1 {
                        piles[card.color] = card.number.value
                    } else {
                        strikeCount += 1
                    }

                    hands[playerIndex].remove(at: cardIndex)

                    if let newCard = deck.drawCard() {
                        hands[playerIndex].append(newCard)
                    }
                } // end switch

                tellPlayers(justPlayed: playerIndex, move: move!)
                updateEverything()

                outer: for (color, number) in piles {

                    for card in deck.storage {
                        if card.color == color && card.number.value == number + 1 {
                            break outer
                        }
                    }
                    for playerHand in players.indices {
                        for card in hands[playerHand] {
                            if card.color == color && card.number.value == number + 1 {
                                break outer
                            }
                        }
                    }
                    ranOut = true
                } // end outer

                if strikeCount == maxStrikeCount || ranOut {
                    gameOver = true
                    for color in Card.Color.allCases {
                        score += piles[color] ?? 0
                    }
                    let win: WinType
                    if strikeCount == maxStrikeCount {
                        win = .lose(strikes: strikeCount)
                    }
                    else if score == 25 {
                        win = .fullWin(score: score, strikes: strikeCount)
                    }
                    else /* score < 25 */ { 
                        win = .partialWin(score: score, strikes: strikeCount)
                    }
                    for player in players {
                        player.gameOver(winType: win)
                    }
                }
            } // end for
        } // end while
    } // end run
} // end Game

//interface between game and player
protocol Player {
    func updateHand(player: Int, cards: [Card])
    func updatePile(color: Card.Color, currentNumber: Int)
    //func selectMove() -> (Move)//, handler: (InvalidMoveReason) -> Move)
    func updateHand(count: Int)
    func updateInfo(count: Int)
    func updateStrikes(count: Int)
    func receiveInfo(cardIndices: [Int], info: Move.Info)
    func receivePlayerMoves(player: Int, move: Move)
    func gameOver(winType: WinType)
    func makeMove() -> Result<(Move, ReasonHandler), MakeMoveError>
    //func warnPlayer(move: Move, reason: InvalidMoveReason)
}

class ConsolePlayer: Player {

    init() {}

    func updateHand(player: Int, cards: [Card]) {
        print("\nPlayer \(player)'s hand is \(cards)")
    }

    func updatePile(color: Card.Color, currentNumber: Int) {
        print("\(color)'s pile: \(currentNumber)")
    }

    func makeMove() -> Result<(Move, ReasonHandler), MakeMoveError> {
        
        var finalMove: Move? = nil
        while finalMove == nil {
            print("\nWhat would you like to do?\nPlay: 1, Discard: 2, Info: 3")

            let move = readLine()
            if move == "1" {
                print("\nWhich card would you like to play? [0-4]")
                var finalCard: Int? = nil
                while finalCard == nil {
                    let attemptedCard = readLine()!
                    if let attemptedCard = Int(attemptedCard) {
                        finalCard = attemptedCard
                    } else {
                        print("Attempted card dont work")
                    }
                }
                finalMove = .play(finalCard)

            } else if move == "2" {
                print("\nWhich card would you like to discard? [0-4]")
                var finalCard: Int? = nil
                while finalCard == nil {
                    let attemptedCard = readLine()!
                    if let attemptedCard = Int(attemptedCard) {
                        finalCard = attemptedCard
                    } else {
                        print("Attempted card dont work")
                    }
                }
                finalMove = .discard(finalCard)

            } else if move == "3" {
                print("\nWho would you like to inform?")
                let playerIndex = readLine()!
                print("\nWrite the number or color you would like to inform Player \(playerIndex) about.\n")
                let information = readLine()!
                finalMove = .giveInfo(player: Int(playerIndex) ?? 0, info: decipherInfo(input: information))
            } else {
                print("\nNot a valid move.")
            }
        }

        let reasonHandler = ReasonHandler(handle: { (reason: IllegalMoveReason) in 
            print(reason)
            return self.makeMove()
        })

        return .success((finalMove!, reasonHandler))
    }

    func decipherInfo(input: String) -> Move.Info? {
        if input == "blue" || input == "b" {
            return .color(.blue)
        }
        else if input == "red" || input == "r" {
            return .color(.red)
        }
        else if input == "yellow" || input == "y" {
            return .color(.yellow)
        }
        else if input == "green" || input == "g" {
            return .color(.green)
        }
        else if input == "purple" || input == "p" {
            return .color(.purple)
        }
        else if input == "1" {
            return .number(.one)
        }
        else if input == "2" {
            return .number(.two)
        }
        else if input == "3" {
            return .number(.three)
        }
        else if input == "4" {
            return .number(.four)
        }
        else if input == "5" {
            return .number(.five)
        }
        else {
            //print("Not a valid color or number. Options are: blue/b, red/r, yellow/y, green/g, and purple/p, or 1, 2, 3, 4, 5.")
            return nil
        }
    }

    func updateHand(count: Int) {
        if count == 1 {
            print("\nYou have one card.\n")
        } else {
            print("\nYou have \(count) cards.\n")
        }
    }

    func updateInfo(count: Int) {
        if count == 1 {
            print("\nThere is 1 information token.")
        } else {
            print("\nThere are \(count) information tokens.")
        }
    }

    func updateStrikes(count: Int) {
        if count == 1 {
            print("\nYou collectively have 1 strike.\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
        } else {
            print("\nYou collectively have \(count) strikes.\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
        }
    }

    func receiveInfo(cardIndices: [Int], info: Move.Info) {
        if cardIndices.count == 1 {
            print("\nYou have one \(info.description) card at index \(cardIndices).")
        } else {
            print("\nYou have \(cardIndices.count) \(info.description) cards at indices \(cardIndices)")
        }
    }

    func receivePlayerMoves(player: Int, move: Move) {
        switch move {
        case .play(let card):
            print("\nPlayer \(player) played card \(card).") //a \(card.color) \(card.number).")    
        case .discard(let card):
            print("\nPlayer \(player) discarded card \(card).") //a \(card.color) \(card.number).")
        case .giveInfo(let receivingPlayer, let info):
            switch info {
            case .color(let cardColor):
                print("\nPlayer \(player) told Player \(receivingPlayer) they have \(cardColor.description) cards.")     
            case .number(let cardNumber):
                print("\nPlayer \(player) told Player \(receivingPlayer) how many \(cardNumber.description)s they have.")
            }
        }
    }

    func gameOver(winType: WinType) {
        switch winType {
        case .lose(let strikes):
            print("\(strikes) strikes! You lose. :/")
        case .partialWin(let score, let strikes):
            print("Game Over!\nYou all win, though you could've done better...\nStrikes: \(strikes)          Score: \(score)")
        case .fullWin(let score, let strikes):
            print("Game Over!\nAmazing job, you nailed it! :D\nStrikes: \(strikes)          Score: \(score)")
        }
    }
}

class ComputerPlayer: Player {
    var playable: [Int]
    var save: [Int]
    init() {
        playable = []
        save = []
    }
    func updateHand(player: Int, cards: [Card]) {}
    func updatePile(color: Card.Color, currentNumber: Int) {}
    func makeMove() -> Result<(Move, ReasonHandler), MakeMoveError> {
        let move: Move 
        let reasonHandler = ReasonHandler(handle: { reason in
            fatalError()
        })

        if !playable.isEmpty {
            move = .play(card: playable[0])
        }
        else {
            move = .discard(card: 0)
        }
        return .success((move, reasonHandler))
    }
    func updateHand(count: Int) {}
    func updateInfo(count: Int) {}
    func updateStrikes(count: Int) {}
    func receiveInfo(cardIndices: [Int], info: Move.Info) {
        if info.description == "1" {
            playable.append(contentsOf: cardIndices)
        }
        else if info.description == "5" {
            save.append(contentsOf: cardIndices)
        }
    }

    func receivePlayerMoves(player: Int, move: Move) {}
    func gameOver(winType: WinType) {}
}

enum Move {
    enum Info: CustomStringConvertible {
        case color(Card.Color)
        case number(Card.Number)
        var description: String {
            switch self {
            case .color(let color): return color.description
            case .number(let number): return number.description
            }
        }
    }
    case giveInfo(player: Int, info: Info)
    case discard(card: Int)
    case play(card: Int)
}  
enum WinType {
    case lose(strikes: Int)
    case partialWin(score: Int, strikes: Int)
    case fullWin(score: Int, strikes: Int)
}

var game = Game(players: [ConsolePlayer(), ComputerPlayer(), ComputerPlayer()])
game.run()

//print(game.deck.storage.count)
