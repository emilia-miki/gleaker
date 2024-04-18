import gleam/order

pub type Suit {
  Hearts
  Diamonds
  Spades
  Clubs
}

pub type Rank {
  Two
  Three
  Four
  Five
  Six
  Seven
  Eight
  Nine
  Ten
  Jack
  Queen
  King
  Ace
}

pub type Card {
  Card(rank: Rank, suit: Suit)
}

pub fn compare(l: Card, r: Card) -> order.Order {
  let #(l, r) = #(l.rank, r.rank)
  case l {
    Ace ->
      case r {
        Ace -> order.Eq
        _ -> order.Gt
      }
    King ->
      case r {
        Ace -> order.Lt
        King -> order.Eq
        _ -> order.Gt
      }
    Queen ->
      case r {
        Ace -> order.Lt
        King -> order.Lt
        Queen -> order.Eq
        _ -> order.Gt
      }
    Jack ->
      case r {
        Ace -> order.Lt
        King -> order.Lt
        Queen -> order.Lt
        Jack -> order.Eq
        _ -> order.Gt
      }
    Ten ->
      case r {
        Ace -> order.Lt
        King -> order.Lt
        Queen -> order.Lt
        Jack -> order.Lt
        Ten -> order.Eq
        _ -> order.Gt
      }
    Nine ->
      case r {
        Ace -> order.Lt
        King -> order.Lt
        Queen -> order.Lt
        Jack -> order.Lt
        Ten -> order.Lt
        Nine -> order.Eq
        _ -> order.Gt
      }
    Eight ->
      case r {
        Ace -> order.Lt
        King -> order.Lt
        Queen -> order.Lt
        Jack -> order.Lt
        Ten -> order.Lt
        Nine -> order.Lt
        Eight -> order.Eq
        _ -> order.Gt
      }
    Seven ->
      case r {
        Ace -> order.Lt
        King -> order.Lt
        Queen -> order.Lt
        Jack -> order.Lt
        Ten -> order.Lt
        Nine -> order.Lt
        Eight -> order.Lt
        Seven -> order.Eq
        _ -> order.Gt
      }
    Six ->
      case r {
        Ace -> order.Lt
        King -> order.Lt
        Queen -> order.Lt
        Jack -> order.Lt
        Ten -> order.Lt
        Nine -> order.Lt
        Eight -> order.Lt
        Seven -> order.Lt
        Six -> order.Eq
        _ -> order.Gt
      }
    Five ->
      case r {
        Ace -> order.Lt
        King -> order.Lt
        Queen -> order.Lt
        Jack -> order.Lt
        Ten -> order.Lt
        Nine -> order.Lt
        Eight -> order.Lt
        Seven -> order.Lt
        Six -> order.Lt
        Five -> order.Eq
        _ -> order.Gt
      }
    Four ->
      case r {
        Ace -> order.Lt
        King -> order.Lt
        Queen -> order.Lt
        Jack -> order.Lt
        Ten -> order.Lt
        Nine -> order.Lt
        Eight -> order.Lt
        Seven -> order.Lt
        Six -> order.Lt
        Five -> order.Lt
        Four -> order.Eq
        _ -> order.Gt
      }
    Three ->
      case r {
        Ace -> order.Lt
        King -> order.Lt
        Queen -> order.Lt
        Jack -> order.Lt
        Ten -> order.Lt
        Nine -> order.Lt
        Eight -> order.Lt
        Seven -> order.Lt
        Six -> order.Lt
        Five -> order.Lt
        Four -> order.Lt
        Three -> order.Eq
        _ -> order.Gt
      }
    Two ->
      case r {
        Ace -> order.Lt
        King -> order.Lt
        Queen -> order.Lt
        Jack -> order.Lt
        Ten -> order.Lt
        Nine -> order.Lt
        Eight -> order.Lt
        Seven -> order.Lt
        Six -> order.Lt
        Five -> order.Lt
        Four -> order.Lt
        Three -> order.Lt
        Two -> order.Eq
      }
  }
}

pub fn are_successive_descending(l: Card, r: Card) -> Bool {
  let #(l, r) = #(l.rank, r.rank)
  case l {
    Ace ->
      case r {
        King -> True
        _ -> False
      }
    Two ->
      case r {
        Ace -> True
        _ -> False
      }
    Three ->
      case r {
        Two -> True
        _ -> False
      }
    Four ->
      case r {
        Three -> True
        _ -> False
      }
    Five ->
      case r {
        Four -> True
        _ -> False
      }
    Six ->
      case r {
        Five -> True
        _ -> False
      }
    Seven ->
      case r {
        Six -> True
        _ -> False
      }
    Eight ->
      case r {
        Seven -> True
        _ -> False
      }
    Nine ->
      case r {
        Eight -> True
        _ -> False
      }
    Ten ->
      case r {
        Nine -> True
        _ -> False
      }
    Jack ->
      case r {
        Ten -> True
        _ -> False
      }
    Queen ->
      case r {
        Jack -> True
        _ -> False
      }
    King ->
      case r {
        Queen -> True
        _ -> False
      }
  }
}

pub fn compare_lists(lcards: List(Card), rcards: List(Card)) -> order.Order {
  case lcards {
    [] -> order.Eq
    [l, ..lrest] -> {
      let assert [r, ..rrest] = rcards
      case compare(l, r) {
        order.Eq -> compare_lists(lrest, rrest)
        ord -> ord
      }
    }
  }
}
