import gleam/io
import gleam/list
import gleam/option
import gleam/string
import gleam/int
import gleam/erlang
import poker

fn read_names() -> List(String) {
  io.println("Enter the names of the players separated by commas:")
  case erlang.get_line("") {
    Ok(line) -> {
      let names =
        string.split(line, ",")
        |> list.map(string.trim)
      case list.length(names) {
        0 | 1 -> {
          io.println("At least 2 players are required to play gleaker!")
          read_names()
        }
        num if num < 24 -> names
        _ -> {
          io.println("Too many players, 52 cards are not enough!")
          read_names()
        }
      }
    }
    Error(_) -> {
      io.println("Invalid names!")
      read_names()
    }
  }
}

pub fn show_card(card: poker.Card) -> String {
  case card {
    poker.Card(poker.Ace, poker.Hearts) -> "🂱"
    poker.Card(poker.Two, poker.Hearts) -> "🂲"
    poker.Card(poker.Three, poker.Hearts) -> "🂳"
    poker.Card(poker.Four, poker.Hearts) -> "🂴"
    poker.Card(poker.Five, poker.Hearts) -> "🂵"
    poker.Card(poker.Six, poker.Hearts) -> "🂶"
    poker.Card(poker.Seven, poker.Hearts) -> "🂷"
    poker.Card(poker.Eight, poker.Hearts) -> "🂸"
    poker.Card(poker.Nine, poker.Hearts) -> "🂹"
    poker.Card(poker.Ten, poker.Hearts) -> "🂺"
    poker.Card(poker.Jack, poker.Hearts) -> "🂻"
    poker.Card(poker.Queen, poker.Hearts) -> "🂽"
    poker.Card(poker.King, poker.Hearts) -> "🂾"
    poker.Card(poker.Ace, poker.Diamonds) -> "🃁"
    poker.Card(poker.Two, poker.Diamonds) -> "🃂"
    poker.Card(poker.Three, poker.Diamonds) -> "🃃"
    poker.Card(poker.Four, poker.Diamonds) -> "🃄"
    poker.Card(poker.Five, poker.Diamonds) -> "🃅"
    poker.Card(poker.Six, poker.Diamonds) -> "🃆"
    poker.Card(poker.Seven, poker.Diamonds) -> "🃇"
    poker.Card(poker.Eight, poker.Diamonds) -> "🃈"
    poker.Card(poker.Nine, poker.Diamonds) -> "🃉"
    poker.Card(poker.Ten, poker.Diamonds) -> "🃊"
    poker.Card(poker.Jack, poker.Diamonds) -> "🃋"
    poker.Card(poker.Queen, poker.Diamonds) -> "🃍"
    poker.Card(poker.King, poker.Diamonds) -> "🃎"
    poker.Card(poker.Ace, poker.Spades) -> "🂡"
    poker.Card(poker.Two, poker.Spades) -> "🂢"
    poker.Card(poker.Three, poker.Spades) -> "🂣"
    poker.Card(poker.Four, poker.Spades) -> "🂤"
    poker.Card(poker.Five, poker.Spades) -> "🂥"
    poker.Card(poker.Six, poker.Spades) -> "🂦"
    poker.Card(poker.Seven, poker.Spades) -> "🂧"
    poker.Card(poker.Eight, poker.Spades) -> "🂨"
    poker.Card(poker.Nine, poker.Spades) -> "🂩"
    poker.Card(poker.Ten, poker.Spades) -> "🂪"
    poker.Card(poker.Jack, poker.Spades) -> "🂫"
    poker.Card(poker.Queen, poker.Spades) -> "🂭"
    poker.Card(poker.King, poker.Spades) -> "🂮"
    poker.Card(poker.Ace, poker.Clubs) -> "🃑"
    poker.Card(poker.Two, poker.Clubs) -> "🃒"
    poker.Card(poker.Three, poker.Clubs) -> "🃓"
    poker.Card(poker.Four, poker.Clubs) -> "🃔"
    poker.Card(poker.Five, poker.Clubs) -> "🃕"
    poker.Card(poker.Six, poker.Clubs) -> "🃖"
    poker.Card(poker.Seven, poker.Clubs) -> "🃗"
    poker.Card(poker.Eight, poker.Clubs) -> "🃘"
    poker.Card(poker.Nine, poker.Clubs) -> "🃙"
    poker.Card(poker.Ten, poker.Clubs) -> "🃚"
    poker.Card(poker.Jack, poker.Clubs) -> "🃛"
    poker.Card(poker.Queen, poker.Clubs) -> "🃝"
    poker.Card(poker.King, poker.Clubs) -> "🃞"
  }
}

pub fn show_cards(cards: List(poker.Card)) {
  let mapped = list.map(cards, show_card)
  let interspersed = list.intersperse(mapped, " ")
  string.concat(interspersed)
}

pub fn show_combination(combination: poker.Combination) -> String {
  case combination {
    poker.HighCard(cards) -> "HighCard(" <> show_cards(cards) <> ")"
    poker.Pair(cards) -> "Pair(" <> show_cards(cards) <> ")"
    poker.TwoPair(cards) -> "TwoPair(" <> show_cards(cards) <> ")"
    poker.ThreeOfAKind(cards) -> "ThreeOfAKind(" <> show_cards(cards) <> ")"
    poker.Straight(cards) -> "Straight(" <> show_cards(cards) <> ")"
    poker.Flush(cards) -> "Flush(" <> show_cards(cards) <> ")"
    poker.FullHouse(cards) -> "FullHouse(" <> show_cards(cards) <> ")"
    poker.FourOfAKind(cards) -> "FourOfAKind(" <> show_cards(cards) <> ")"
    poker.StraightFlush(cards) -> "StraightFlush(" <> show_cards(cards) <> ")"
    poker.RoyalFlush(cards) -> "RoyalFlush(" <> show_cards(cards) <> ")"
  }
}

pub fn show_poker(poker: poker.Poker) -> String {
  "Table "
  <> show_cards(poker.table)
  <> " : Bet "
  <> string.inspect(poker.bet)
  <> " : Bank "
  <> string.inspect(poker.bank)
}

pub fn show_player(player: poker.Player) -> String {
  player.name
  <> ": Hand "
  <> show_cards(player.hand)
  <> " : Bet "
  <> string.inspect(player.bet)
  <> " : Bank "
  <> string.inspect(player.bank)
}

pub fn show_play(play: poker.Play) -> String {
  case play {
    poker.Fold -> "Fold"
    poker.Check -> "Check"
    poker.Call -> "Call"
    poker.Raise(bet) -> "Raise(" <> string.inspect(bet) <> ")"
    poker.AllIn -> "AllIn"
  }
}

fn read_play(
  poker: poker.Poker,
  player: poker.Player,
  valid_plays: List(poker.PlayDesc),
) -> poker.Play {
  io.println(show_poker(poker))
  io.println(show_player(player))
  io.println(
    "In this situation valid plays are: " <> format_play_descs(valid_plays),
  )
  case erlang.get_line("Your play: ") {
    Ok(line) -> {
      let line = string.trim(line)
      let play = case string.split(line, " ") {
        ["Fold"] -> option.Some(poker.Fold)
        ["Check"] -> option.Some(poker.Check)
        ["Call"] -> option.Some(poker.Call)
        ["Raise", num] -> {
          case int.parse(num) {
            Ok(num) -> option.Some(poker.Raise(num))
            Error(_) -> option.None
          }
        }
        ["AllIn"] -> option.Some(poker.AllIn)
        _ -> option.None
      }
      let play = case play {
        option.Some(play) ->
          case poker.validate_play(play, valid_plays) {
            True -> option.Some(play)
            False -> option.None
          }
        option.None -> option.None
      }
      case play {
        option.Some(play) -> play
        option.None -> {
          io.println("Invalid play!")
          read_play(poker, player, valid_plays)
        }
      }
    }
    Error(_) -> {
      io.println("Invalid play!")
      read_play(poker, player, valid_plays)
    }
  }
}

fn format_play_desc(play_desc: poker.PlayDesc) -> String {
  case play_desc {
    poker.FoldDesc -> "Fold"
    poker.CheckDesc -> "Check"
    poker.CallDesc -> "Call"
    poker.RaiseDesc(min_excl, max_excl) ->
      "Raise(more than "
      <> int.to_string(min_excl)
      <> " and less than "
      <> int.to_string(max_excl)
      <> ")"
    poker.AllInDesc -> "AllIn"
  }
}

fn format_play_descs(play_descs: List(poker.PlayDesc)) -> String {
  case play_descs {
    [] -> ""
    [pd] -> format_play_desc(pd)
    [pd1, pd2] -> format_play_desc(pd1) <> " and " <> format_play_desc(pd2)
    [pd1, ..pds] -> format_play_desc(pd1) <> ", " <> format_play_descs(pds)
  }
}

fn print_player_combinations(pcs: List(#(poker.Player, poker.Combination))) {
  case pcs {
    [] -> Nil
    [#(pl, combination), ..rest] -> {
      let comb_str = show_combination(combination)
      io.println(pl.name <> ": " <> comb_str)
      print_player_combinations(rest)
    }
  }
}

fn print_winners(_: poker.Poker, wc: poker.WinCondition, pls: List(String)) {
  let wc_str = case wc {
    poker.EveryoneFolded -> " because everyone folded!"
    poker.LastRoundEnded -> "!"
  }
  let suffix = case list.length(pls) {
    1 -> " has won"
    _ -> " have won"
  }
  let suffix = string.append(suffix, wc_str)
  io.println(format_winner_names(pls) <> suffix)
}

fn format_winner_names(winners: List(String)) -> String {
  case winners {
    [] -> ""
    [winner] -> winner
    [winner1, winner2] -> winner1 <> " and " <> winner2
    [winner1, ..rest] -> winner1 <> ", " <> format_winner_names(rest)
  }
}

pub fn main() {
  io.println("Hello from gleaker!")
  let names = read_names()
  let cbs =
    poker.new_callbacks(
      get_play: read_play,
      show_combinations: print_player_combinations,
      show_winner: print_winners,
    )
    |> poker.set_next_game_start_callback(fn(_) { io.println("Next game!") })
    |> poker.set_next_round_start_callback(fn(_) { io.println("\nNext round!") })
    |> poker.set_game_end_callback(fn(_) { io.println("Game ended!\n") })
  let poker = poker.init_poker(names, cbs)
  poker.game_loop(poker)
}
