// interface between game and player
protocol Player {
    func updateHand(player: Int, cards: [Card])
    func updatePile(color: Card.Color, currentNumber: Int)
    // I've decided that I think this API is poorly specified.
    // If we know that index 3 is blue and then a card is removed from our hand,
    //  is the Player responsible for knowing if this card is now at index 2 or is still at index 3?
    // Possibly, our hand should be represented as an opaque ID type that is persistent across playing/discarding/drawing
    func updateHand(count: Int)
    func updateInfo(count: Int)
    func updateStrikes(count: Int)
    func receiveInfo(cardIndices: [Int], info: Move.Info)
    func receivePlayerMoves(player: Int, move: Move)
    func gameOver(winType: WinType)
    func makeMove() -> Result<(Move, ReasonHandler), MakeMoveError>
    // Is a player allowed to be in multiple games at once? Is it allowed to join a game, quit, and then join a different game?
    // I'm not sure this API allows for these things, but maybe it doesn't need to.
    // Perhaps we need to make PlayerDelegates which create instances of Player for each game the User wishes to join.
    // Perhaps we make Player and PlayerDelegate into a single protocol and add that functionality here.
}

// The Player protocol could be dramatically simplified by defining a structure that is the state of the game from the perspective of a player
// struct GameState {
//    var sizeOfHand: Int
//    var othersCards: [Int: [Card]]
//    var info: Int
// }
// and then having Player have a method of type
// func recieveUpdate<T>(key: KeyPath<GameState,T>, value: T)
// This could be called like player.recieveUpdate(key: \.sizeOfHand, value: 4)

// Should probably be renamed to IllegalMoveHandler
struct ReasonHandler {
    let handle: (IllegalMoveReason) -> Result<(Move, ReasonHandler), MakeMoveError>
    /* func callAsFunction(reason: Reason) throw -> (Move, ReasonHandler) {
         return try self.handle(reason).unwrap()
     } */
    func callAsFunction(reason: IllegalMoveReason) -> Result<(Move, ReasonHandler), MakeMoveError> {
        handle(reason)
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
            case let .color(color): return color.description
            case let .number(number): return number.description
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
