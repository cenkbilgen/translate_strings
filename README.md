# translate_strings

A tool for Xcode to automatically add language translations to your Strings Catalog file using DeepL, Google AI, or OpenAI services.

## Getting Started

To translate all strings in your app to Japanese using DeepL for translation, call:

```shell
strings_catalog_translate deepl -k [API_KEY] -t ja
```

Ensure that the initial Strings Catalog file is added to your Xcode project. More details can be found [here](https://developer.apple.com/documentation/xcode/localizing-and-varying-text-with-a-string-catalog).

By default the command will read the `Localizable.xcstrings` from the path where it was run and modify it with the translations.

### Usage

```
OVERVIEW: A utility for language translation of Xcode Strings Catalogs. (DEBUG BUILD)

USAGE: strings_catalog_translate <subcommand>

OPTIONS:
  --version               Show the version.
  -h, --help              Show help information.

SUBCOMMANDS:
  deepl                   Translate Xcode Strings Catalog using DeepL service.
  openai (default)        Translate Xcode Strings Catalog using OpenAI service.
  google                  Translate Xcode Strings Catalog using Google Gemini service.
  list_keys               List API keys stored in Keychain.

  See 'strings_catalog_translate help <subcommand>' for detailed help.
```

The subcommands have mostly the same arguments, with a few platform specific variations.

```
OVERVIEW: Translate Xcode Strings Catalog using OpenAI service.

```
USAGE: strings_catalog_translate openai [--verbose] --key <key> --target-language <target-language> [--input-file <input-file>] [--output-file <output-file>]

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

  -t, --target-language <target-language>
                          The target language identifier, ie "de". Case-insensitive. Required.
  -i, --input-file <input-file>
                          Input Strings Catalog file. (default: Localizable.xcstrings)
  -o, --output-file <output-file>
                          Output Strings Catalog file. Overwrites. Use "-" for STDOUT. (default: Localizable.xcstrings)
  --version               Show the version.
  -h, --help              Show help information.
```

**Note:** Only untranslated strings will be processed. Those already translated or marked "do not translate" in the StringsCatalog are skipped. Ensure you commit changes in `Localizable.xcstrings` before using this tool.

### API Keys

- **DeepL:** Get a key from the [DeepL Pro API](https://www.deepl.com/en/pro-api/).
- **Google (Gemini):** Create an API key as instructed [here](https://ai.google.dev/gemini-api/docs/api-key).
- **Google (Vertex AI):** Google's preferred platform now and does not use API keys; but with `gcloud` you can create a temporary one; see [this guide](https://cloud.google.com/vertex-ai/generative-ai/docs/start/quickstarts/quickstart-multimodal).
- **OpenAI:** Obtain a key from their API portal.

Provide your API key directly with `-k` or manage it using macOS Keychain by searching for `tools.xcode.translate_strings`.

---

## Building

1. Run `swift build -c release` to build the `translate_strings` executable in `./.build/release`.
2. Copy the executable to a location in your `$PATH` for easy access.
