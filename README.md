# translate_strings

A handy tool for Xcode that automatically adds language translations to your Strings Catalog file. You can choose between DeepL or Google AI services for translations.

## Getting Started

To create a Japanese translation of all strings in your app, run:

```shell
> translate_strings google strings_catalog -k [your api key] -t ja
```

Before you start, make sure Xcode has added the initial Strings Catalog file to your project. You can learn more about this [here](https://developer.apple.com/documentation/xcode/localizing-and-varying-text-with-a-string-catalog).

### Usage

To see help options for using the DeepL service, enter:

```shell
> translate_strings deepl strings_catalog --help
```

#### Command Overview

Translate Xcode Strings Catalog using either:
- `translate_strings deepl strings_catalog`
- `translate_strings google strings_catalog`

The options for both subcommands are the same.

```shell
USAGE: translate_strings deepl strings_catalog [--verbose] --key <key> --target <target> [--file <file>] [--out-file <out-file>]
```

```
OPTIONS:
  -v, --verbose           Verbose output to STDOUT
  -k, --key <key>         API key. Required. 
                          If "key_id:[SOME KEY_ID]" the key with id KEY_ID from the keychain will be used. If
                          not found, you will be prompted to enter the key and it will be stored with that
                          KEY_ID for subsequent calls.
                          Otherwise, it will be treated as the literal API key value.
  -t, --target <target>   The target language identifier, ie "de". Required.
  -f, --file <file>       Input Strings Catalog file. (default: Localizable.xcstrings)
  -o, --out-file <out-file>
                          Output Strings Catalog file. Overwrites. Use "-" for STDOUT. (default:
                          Localizable.xcstrings)
  -h, --help              Show help information.
```

**Note:** Strings that have not been translated yet will be processed. Any string with an existing translation or marked "do not translate" will be skipped. Your `Localizable.xcstrings` file will be modified, so ensure you commit your changes before running the tool.

### API Keys

- **DeepL**: Obtain an API key via [DeepL Pro API](https://www.deepl.com/en/pro-api/).
- **Google using Gemini**: Create a project and an API key as outlined [here](https://ai.google.dev/gemini-api/docs/api-key).
- **Google using Vertex AI**: Vertex is Google's preferred AI platform which does not use API keys for authentication. You can use `gcloud` to generate a temporary API key with your credentials. See [Using Gemini AI Studio with Vertex](https://cloud.google.com/vertex-ai/generative-ai/docs/start/quickstarts/quickstart-multimodal).

You may provide the API key directly with `-k this_is_the_actual_key` or save and retrieve it from the keychain using a key ID like `-k key_id:key1`. If a key ID is not in the keychain, you'll be prompted to provide one for future use. Manage keys with the macOS _Keychain Access_ app by searching for `tools.xcode.translate_strings`.

---

## Building

1. Run `swift build -c release` to create the executable file `translate_strings` in `./.build/release`.
2. Copy this executable to a location in your $PATH for easier access.
```
