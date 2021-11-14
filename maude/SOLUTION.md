# Key decisions and high-level design

The solution consists of four modules in the file `atm.maude`.

- `CARD`: Simple module containing the info about a card. A card has a number and the name of the bank it belongs to.
- `BANK`: This module holds info about an account, it's PIN and balance and provides methods to manipulate balance.
- `ATM`: This module holds info about the ATM, it's state: # of banknotes, internal state and the card inserted. 
- `DATABASE` : This module holds info about the banks and provides a method to change a card's balance.

For the purpose of this academic exercise, several constraints were simplified to avoid redundant boilerplate code. 

- A card has a number, which is also the account's number. It is the physical representation of the account and an account can have only one card. 
- The card is validated by 1. having the same number as an account in the bank's database and 2. by the PIN matching. Other validation criteria such as date of validity are disregarded here.
- Account balance is represented as an integer only (no rationals/decimals).
- To withdraw money, the user has to request the bank notes they desire precisely. This is to avoid implementing a change-making algorithm in Maude.
- There are no limits to the PIN, it only has to be a natural number.
- An account's balance cannot go into overdraft.
- The ATM error states are drastically simplified and there is no way to recover an ATM in an error state, other than rejecting the card and trying again.
- Internally, no Maude Lists were used, for the Maude documentation is too cryptic. Instead, a simple "linked-list"-style implementation was used. 

# Testing
Inspect the `test.maude` file and execute it with `<path_to_maude_binary> test.maude`. Several test cases were prepared, illustrating how to insert a card to the ATM, enter PIN, see balance, deposit and withdraw money.
