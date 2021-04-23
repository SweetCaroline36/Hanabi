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
            // Do you mean to remove this from the playable pile now?
            // The indices of your cards may change once you play something
            // We haven't really thought about how that should work...
            // We should probably change the Player protocol to account for this.
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
        // Why are you comparing against the description?
        // The description of a type is probably not part of the stable API.
        // I think you want info == .number(.one) or something similar.
        if info.description == "1" {
            playable.append(contentsOf: cardIndices)
        }
        // Same here
        else if info.description == "5" {
            save.append(contentsOf: cardIndices)
        }
    } // Whitespace?

    func receivePlayerMoves(player: Int, move: Move) {}
    func gameOver(winType: WinType) {}
}
