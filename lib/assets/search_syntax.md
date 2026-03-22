
`n` or `name`: Searches the card\'s name. Punctuation, and capitalization are ignored. This is also the default behavior for any unqualified search terms.

**Examples**: `n:draven` finds all cards with \'draven\' in the name. `kaisa` finds all cards with \'Kai\'sa\' in the name.
***
`d` or `domain`: Searches the card's domain. Accepts exactly one of the following values:

- `fury` or `r`
-  `calm` or `g`
- `mind` or `b`
- `body` or `o`
- `chaos` or `p`
- `order` or `y`

**Examples**: `d:fury` finds all cards with \'fury\' in their domain. `d:y` finds all cards with `order` in their domain. `d:mistake`
***
`m` or `might`: Finds cards with **exactly** the provided Might.

**Example**: `m:2` or `might:2` finds all cards with exactly 2 Might, such as Chemtech Enforcer or Gem Jammer.
***
`p` or `power`: Finds cards with **exactly** the amount (not type) of Power.

**Examples**: `p:2` or `power:2` finds all cards that cost exactly 2 of some combination of Power, such as Dazzling Aurora or Falling Star.
***
`e` or `energy`: Finds cards with **exactly** the amount of Energy.

**Examples**: `e:1` or `energy:1` finds all cards that cost exactly 1 Energy, such as Cleave or Against the Odds. 
