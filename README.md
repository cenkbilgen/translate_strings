# translate_strings
A tool for Xcode that automatically translates and updates strings to a target language and updates the Strings Catalog file.

* You will need an API key for DeepL to provide the translation service.
  See https://www.deepl.com/en/pro-api/
* You will also need to have Xcode add the initial Strings Catalog file to your project. 
  See https://developer.apple.com/documentation/xcode/localizing-and-varying-text-with-a-string-catalog

```
USAGE: translate-strings [--verbose] [--file <file>] [--out-file <out-file>] --key <key> [--allow-stdin <allow-stdin>] [--source <source>] --target <target>
OPTIONS:
  -v, --verbose           Verbose output to STDOUT
  -f, --file <file>       Input Strings Catalog file. (default: Localizable.xcstrings)
  -o, --out-file <out-file>
                          Output Strings Catalog file. Overwrites. Use "-" for STDOUT. (default:
                          Localizable.xcstrings)
  -k, --key <key>         API key. Required. If prefixed with "key_id:" the value of the key will be
                          retrieved from the keychain for that ID (macOS only); otherwise, it will be treated as
                          the literal key value.
  -a, --allow-stdin <allow-stdin>
                          Allow STDIN input if prompted for key input. May be needed if using script or no
                          direct tty access. (default: false)
  -s, --source <source>   Override the source language identifier, i.e., "en". (default: from xcstrings file)
  -t, --target <target>   The target language identifier, i.e., "de". Required.
  -h, --help              Show help information.
```

Example to create a Japanese translation of all strings in your app:
```
> translate_strings -k key_id:deeplKey1 -t ja
```

Strings that have not been translated yet, will be processed. Any string with an existing translation or marked "do not translate" will be left alone. Your `Localizable.xcstrings` file will be modified, so commit every time before you run.

### Specifying the API Key
You can provide the key verbatim with `-k this_is_the_actual_key` or have it saved and retrieved from the keychain by key ID with `-k key_id:key1`. If a key with the ID `key1` is not in the keychain, you will be prompted to provide one and subsequently just use the key ID. To view, modify, or delete keys, you can use the macOS _Keychain Access_ app and search for keys with the name `tools.xcode.translate_strings.`

---

# translate
The package includes a second executable target, named **translate**. This just lets you perform one-off translations on the command line that output to STDOUT. Can be used for scripts or Fastlane. Shares the same keychain storage for API keys.

```
USAGE: translate --key <key> [--source <source>] --target <target> <input>
ARGUMENTS:
  <input>                 The phrase to translate
OPTIONS:
  -k, --key <key>         API key. Required. If prefixed with "key_id:" the value of the key will be
                          retrieved from the keychain for that ID (macOS only); otherwise, it will be treated as
                          the literal key value.
  -s, --source <source>   Specify the source language identifier, i.e., "en". Optional.
  -t, --target <target>   The target language identifier, i.e., "de". Required.
  -h, --help              Show help information.
```

---

# Building

1. Run `swift build -c release`. This makes the executable files `translate_strings` and `translate` in the folder `./.build/release`.
2. Copy the executable files anywhere you want, such as a place in your $PATH.
