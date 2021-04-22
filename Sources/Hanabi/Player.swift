//interface between game and player
protocol Player {
    func updateHand(player: Int, cards: [Card])
    func updatePile(color: Card.Color, currentNumber: Int)
    func updateHand(count: Int)
    func updateInfo(count: Int)
    func updateStrikes(count: Int)
    func receiveInfo(cardIndices: [Int], info: Move.Info)
    func receivePlayerMoves(player: Int, move: Move)
    func gameOver(winType: WinType)
    func makeMove() -> Result<(Move, ReasonHandler), MakeMoveError>
}

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