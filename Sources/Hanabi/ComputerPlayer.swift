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