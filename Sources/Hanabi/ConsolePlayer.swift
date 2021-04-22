class ConsolePlayer: Player {

    init() {}

    var otherHands: [Int: [Card]] = [:]
    var otherPlayers: Dictionary<Int, [Card]>.Keys { otherHands.keys }

    func updateHand(player: Int, cards: [Card]) {
        otherHands[player] = cards
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
                    if let attemptedCard = Int(attemptedCard), attemptedCard < handCount && attemptedCard >= 0 {  
                        finalCard = attemptedCard
                    } else {
                        print("Attempted card dont work")
                    }
                }
                finalMove = .play(card: finalCard!)

            } else if move == "2" {
                print("\nWhich card would you like to discard? [0-4]")
                var finalCard: Int? = nil
                while finalCard == nil {
                    let attemptedCard = readLine()!
                    if let attemptedCard = Int(attemptedCard), attemptedCard < handCount && attemptedCard >= 0 {
                        finalCard = attemptedCard
                    } else {
                        print("Attempted card dont work")
                    }
                }
                finalMove = .discard(card: finalCard!)

            } else if move == "3" {
                print("\nWho would you like to inform?")
                var finalPlayerIndex: Int? = nil
                while finalPlayerIndex == nil {
                    let attemptedPlayerIndex = readLine()!
                    if let attemptedPlayerIndex = Int(attemptedPlayerIndex), otherPlayers.contains(attemptedPlayerIndex) {
                        finalPlayerIndex = attemptedPlayerIndex
                    } else {
                        print("That is not an acceptable player index")
                    }
                }
                print("\nWrite the number or color you would like to inform Player \(finalPlayerIndex!) about.\n")
                var finalInformation: Move.Info? = nil
                while finalInformation == nil {
                    let information = readLine()!
                    if let information = decipherInfo(input: information) {
                        finalInformation = information
                    } else {
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

    var handCount: Int!

    func updateHand(count: Int) {
        handCount = count
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