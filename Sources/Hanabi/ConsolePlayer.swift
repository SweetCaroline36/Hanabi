class ConsolePlayer: Player {
    init() {}

    // I have decided this should be an unwrapped Optional, but I don't know when it should be initialized
    var otherHands: [Int: [Card]] = [:]
    var otherPlayers: Dictionary<Int, [Card]>.Keys { otherHands.keys }

    // Your habit of printing everything whenever it updates is a bad idea.
    // This means that what the ConsolePlayer displays is decided by the Game.
    // ConsolePlayer should have complete control of what it displays to the user.
    // You know what, I take some of this back. Semi-ignore the parts where I say not to print.
    // You can print there, but I should you should also print out the whole state of the game when makeMove is called.
    func updateHand(player: Int, cards: [Card]) {
        otherHands[player] = cards
        print("\nPlayer \(player)'s hand is \(cards)")
    }

    // Don't print here.
    func updatePile(color: Card.Color, currentNumber: Int) {
        print("\(color)'s pile: \(currentNumber)")
    }

    // It is actually reasonable to print here.
    // This method is way too long. It should be split up.
    func makeMove() -> Result<(Move, ReasonHandler), MakeMoveError> {
        var finalMove: Move?
        while finalMove == nil {
            print("\nWhat would you like to do?\nPlay: 1, Discard: 2, Info: 3")

            let move = readLine()
            // Possibly we should refactor this into a method which takes integers (strings?) and creates moves. Also possibly not.
            // Actually yeah, we should do this.
            // The UI would be better if you could also type "play" or "p" or perhaps others
            if move == "1" {
                print("\nWhich card would you like to play? [0-4]")
                var finalCard: Int?
                while finalCard == nil {
                    // This ! should ideally be removed, perhaps fold it into the following `if let`
                    let attemptedCard = readLine()!
                    if let attemptedCard = Int(attemptedCard), attemptedCard < handCount, attemptedCard >= 0 {
                        finalCard = attemptedCard
                    } else { // Obviously the messaging should be cleaned up
                        print("Attempted card dont work")
                    }
                }
                finalMove = .play(card: finalCard!)

            } else if move == "2" {
                print("\nWhich card would you like to discard? [0-4]")
                var finalCard: Int?
                while finalCard == nil {
                    // !
                    let attemptedCard = readLine()!
                    if let attemptedCard = Int(attemptedCard), attemptedCard < handCount, attemptedCard >= 0 {
                        finalCard = attemptedCard
                    } else { // Fix messaging
                        print("Attempted card dont work")
                    }
                }
                finalMove = .discard(card: finalCard!)

            } else if move == "3" {
                print("\nWho would you like to inform?")
                var finalPlayerIndex: Int?
                while finalPlayerIndex == nil {
                    // !
                    let attemptedPlayerIndex = readLine()!
                    if let attemptedPlayerIndex = Int(attemptedPlayerIndex), otherPlayers.contains(attemptedPlayerIndex) {
                        finalPlayerIndex = attemptedPlayerIndex
                    } else {
                        // Messaging?
                        print("That is not an acceptable player index")
                    }
                }
                print("\nWrite the number or color you would like to inform Player \(finalPlayerIndex!) about.\n")
                var finalInformation: Move.Info?
                while finalInformation == nil {
                    // !
                    let information = readLine()!
                    if let information = decipherInfo(input: information) {
                        finalInformation = information
                    } else {
                        // Messaging
                        print("Not real info")
                    }
                }
                finalMove = .giveInfo(player: finalPlayerIndex!, info: finalInformation!)
            }
        }

        let reasonHandler = ReasonHandler(handle: { (reason: IllegalMoveReason) in
            print(reason)
            return self.makeMove()
        })

        return .success((finalMove!, reasonHandler))
    }

    // This should probably be a static method or an extension to Info or something
    // Also the UI would be better if the user could type B or Blue or BLUE or Blues or maybe 1s or ones
    func decipherInfo(input: String) -> Move.Info? {
        if input == "blue" || input == "b" {
            return .color(.blue)
        } else if input == "red" || input == "r" {
            return .color(.red)
        } else if input == "yellow" || input == "y" {
            return .color(.yellow)
        } else if input == "green" || input == "g" {
            return .color(.green)
        } else if input == "purple" || input == "p" {
            return .color(.purple)
        } else if input == "1" {
            return .number(.one)
        } else if input == "2" {
            return .number(.two)
        } else if input == "3" {
            return .number(.three)
        } else if input == "4" {
            return .number(.four)
        } else if input == "5" {
            return .number(.five)
        } else {
            // Delete this comment after you decide you don't need it anymore.
            // print("Not a valid color or number. Options are: blue/b, red/r, yellow/y, green/g, and purple/p, or 1, 2, 3, 4, 5.")
            return nil
        }
    }

    // Whitespace?
    var handCount: Int!

    // Don't print here
    func updateHand(count: Int) {
        handCount = count
        if count == 1 {
            print("\nYou have one card.\n")
        } else {
            print("\nYou have \(count) cards.\n")
        }
    }

    // Don't print here
    func updateInfo(count: Int) {
        if count == 1 {
            print("\nThere is 1 information token.")
        } else {
            print("\nThere are \(count) information tokens.")
        }
    }

    // Don't print here
    func updateStrikes(count: Int) {
        if count == 1 {
            print("\nYou collectively have 1 strike.\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
        } else {
            print("\nYou collectively have \(count) strikes.\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
        }
    }

    // Don't print here
    func receiveInfo(cardIndices: [Int], info: Move.Info) {
        if cardIndices.count == 1 {
            print("\nYou have one \(info.description) card at index \(cardIndices).")
        } else {
            print("\nYou have \(cardIndices.count) \(info.description) cards at indices \(cardIndices)")
        }
    }

    // Don't print here
    func receivePlayerMoves(player: Int, move: Move) {
        switch move {
        case let .play(card):
            print("\nPlayer \(player) played card \(card).") // a \(card.color) \(card.number).")
        case let .discard(card):
            print("\nPlayer \(player) discarded card \(card).") // a \(card.color) \(card.number).")
        case let .giveInfo(receivingPlayer, info):
            switch info {
            case let .color(cardColor):
                print("\nPlayer \(player) told Player \(receivingPlayer) they have \(cardColor.description) cards.")
            case let .number(cardNumber):
                print("\nPlayer \(player) told Player \(receivingPlayer) how many \(cardNumber.description)s they have.")
            }
        }
    }

    // It's maybe okay to print here.
    func gameOver(winType: WinType) {
        switch winType {
        case let .lose(strikes):
            print("\(strikes) strikes! You lose. :/")
        case let .partialWin(score, strikes):
            print("Game Over!\nYou all win, though you could've done better...\nStrikes: \(strikes)          Score: \(score)")
        case let .fullWin(score, strikes):
            print("Game Over!\nAmazing job, you nailed it! :D\nStrikes: \(strikes)          Score: \(score)")
        }
    }
}
