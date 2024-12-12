# translate_strings

A tool for Xcode to automatically add language translations to your Strings Catalog file using DeepL, Anthropic Claude, or OpenAI services.

## Getting Started

To translate all strings in your app to Japanese using default DeepL for translation, call:

```shell
strings_catalog_translate -k [API_KEY] -t ja
```

Ensure that the initial Strings Catalog file is added to your Xcode project. More details can be found [here](https://developer.apple.com/documentation/xcode/localizing-and-varying-text-with-a-string-catalog).

By default the command will read the `Localizable.xcstrings` from the path where it was run and modify it with the translations.

### Usage

```
OVERVIEW: A utility for language translation of Xcode Strings Catalogs. 

USAGE: strings_catalog_translate <subcommand>

OPTIONS:
  --version               Show the version.
  -h, --help              Show help information.

SUBCOMMANDS:
  deepl (default)         Translate Xcode Strings Catalog using DeepL service.
  anthropic               Translate Xcode Strings Catalog using Anthropic service.
  openai                  Translate Xcode Strings Catalog using OpenAI service.
  list_keys               List API keys stored in Keychain.

  See 'strings_catalog_translate help <subcommand>' for detailed help.
```

The subcommands have mostly the same arguments, with a few platform specific variations.

```
% ./.build/release/strings_catalog_translate anthropic -h

OVERVIEW: Translate Xcode Strings Catalog using Anthropic service.

USAGE: strings_catalog_translate anthropic [--verbose] --key <key> [--available_languages] [--input-file <input-file>] [--output-file <output-file>] [--target-language <target-language>] [--model <model>]

OPTIONS:
  -v, --verbose           Verbose output to STDOUT
  -k, --key <key>         --key <key> (Required)
                          The API key used for authentication. You can provide it in one of two ways:
                          1. From Keychain:
                             Use the format `key_id:[YOUR_KEY_ID]` (e.g., `key_id:key1`). The tool will search for the specified `YOUR_KEY_ID` in the keychain.
                             - If the key isn't found, you will be prompted to enter it.
                             - The entered key will be securely saved under the provided `YOUR_KEY_ID` for future use.
                          2. Direct Value:
                             Simply pass the API key as a literal string without any format (e.g., `--key your-api-key`).
  --available_languages   List available translation language codes for service.
  -i, --input-file <input-file>
                          Input Strings Catalog file. (default: Localizable.xcstrings)
  -o, --output-file <output-file>
                          Output Strings Catalog file. Overwrites. Use "-" for STDOUT. (default: Localizable.xcstrings)
  -t, --target-language <target-language>
                          The target language identifier, ie "de". Case-insensitive.
  --model <model>         (default: claude-3-5-haiku-latest)
  --version               Show the version.
  -h, --help              Show help information.

```

**Notes:** 

1.  Only untranslated strings will be processed. Those already translated or marked "do not translate" in the Strings Catalog are skipped.
2.  By default the `Localizable.xcstrings` file will be modified.

### API Keys

- **DeepL:** Get a key from the [DeepL Pro API](https://www.deepl.com/en/pro-api/).
- **Anthropic** Get a key from [Anthropic Dashboard](https://console.anthropic.com/dashboard)
- **OpenAI:** Obtain a key from their [API portal](https://openai.com/api/).

Saved API keys in the keychain can be managed using the macOS Keychain app and searching keys prefixed with `tools.xcode.translate_strings`.

---

## Building

1. Run `swift build -c release` to build the `translate_strings` executable in `./.build/release`.
2. Copy the executable to a location in your `$PATH` for easy access.

## Package Targets

The package has two targets:

1. `strings_catalog_translate` the executable command line tool.
2. `TranslationService` the library the executiable uses for for the translation services. It specifies the protocol and concrete types for DeepL, Anthropic and OpenAI.
