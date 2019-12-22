# Jsona
A JSON parser for AngelScript in Sven Co-op.

### What is this?
This is a library for other AngelScript plugins in Sven Co-op. In other words, this is NOT a plugin itself, so you don't really install it. It's actually USED by plugins.

### What is this for?
Jsona could parse a JSON string into objects that AngelScript recognizes, and you're able to modify them, then stringify them back into a JSON string.
Sounds simple, right? That is the way it should be, and glad it is. 

### How does this work?
**Jsona** tokenizes a JSON string into a lot of tokens (basically split the string into words) with **JsonaTokenizer**, and parses the tokens to values that they're meant to be, which is stored with **JsonaValue** - since AngelScript is static typed, and you need to know in which type a value is.

### Installation
- Clone or download as zip this repo.
- Create a folder called `Jsona` in `/svencoop/scripts/plugins`.
- Place all files in `/svencoop/scripts/plugins/Jsona`.

### Usage
See [Wiki](https://github.com/Paranoid-AF/Jsona/wiki) For more info.
