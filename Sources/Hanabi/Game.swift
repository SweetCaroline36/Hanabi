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