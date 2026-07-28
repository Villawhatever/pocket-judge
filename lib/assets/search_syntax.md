### Search Syntax
`n` or `name`: Searches the card\'s name. Punctuation and capitalization are ignored. This is also the default behavior for any unqualified search terms.  
**Examples**: `n:draven` finds all cards with \'Draven\' in the name. `kaisa` finds all cards with \'Kai\'sa\' in the name.
***
`w` or `watcher`: Searches card text for the given term. Punctuation and capitalization are ignored.  
**Examples**: `w:deathknell` finds all cards with \'Deathknell\' in the text.
***
`d` or `domain`: Searches the card's domain. Accepts exactly one of the following values:  
- `fury` or `r`
-  `calm` or `g`
- `mind` or `b`
- `body` or `o`
- `chaos` or `p`
- `order` or `y`  
**Examples**: `d:fury` finds all cards with 'fury' in their domain. `d:y` finds all cards with 'order' in their domain. `d:mistake` would do nothing.
***
`m` or `might`: Finds cards with **exactly** the provided Might.  
**Example**: `m:2` or `might:2` finds all cards with exactly 2 Might, such as Chemtech Enforcer or Gem Jammer.
***
`p` or `power`: Finds cards with **exactly** the amount (not type) of Power.  
**Example**: `p:2` or `power:2` finds all cards that cost exactly 2 of some combination of Power, such as Dazzling Aurora or Falling Star.
***
`e` or `energy`: Finds cards with **exactly** the amount of Energy.  
**Example**: `e:1` or `energy:1` finds all cards that cost exactly 1 Energy, such as Cleave or Against the Odds.
***
`t` or `type`: Finds cards of a given type.
**Example**: `t:Gear` or `type:gear` finds all cards with the Gear type, such as Porobot.
***
`s` or `set`: Finds cards in a given set. This should be the set code (eg `VEN`), not the set name.
***
You can combine any of the above, and they will be `AND`ed together.  
**Examples**: `m:3 draven` will find cards where the name contains 'Draven' AND its Might is exactly 3. `d:body d:chaos` will find all cards that have both Body AND Chaos domains.