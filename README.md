# translate_strings

A tool for Xcode to automatically add language translations to your Strings Catalog file using DeepL, Google AI, or OpenAI services.

## Getting Started

To translate all strings in your app to Japanese, use:

```shell
translate_strings deepl strings_catalog -k [your_api_key] -t ja
```

Ensure that the initial Strings Catalog file is added to your Xcode project. More details can be found [here](https://developer.apple.com/documentation/xcode/localizing-and-varying-text-with-a-string-catalog).

By default the command will read the `Localizable.xcstrings` from the path where it was run and modify it with the translations.

### Usage

Command format:

```shell
translate_strings [deepl/google/openai] [command: strings_catalog/text/available_languages] -k [key] -t [target_language_code]
```

Help is specific to any command level, for example:

```shell
translate_strings deepl strings_catalog --help
```

All services share the same subcommands and options with some platform-specific exceptions or requirements.

**OPTIONS:**

- `-v, --verbose`
  Enable verbose output to STDOUT.

- `-k, --key <key>`  
  Required. Use the literal API key or a key stored in the macOS Keychain as `key_id:[SOME_KEY_ID]`.
  If there is no saved key with that "ID" found, you will prompted to enter one and it will be saved to the keychain.
  The saved keys are accessible with the standard `keychain-access` app and namespaced to `tools.xcode.translate_strings.`. 

- `-t, --target <target>`  
  Required. Specify the target language code, e.g., "de".

- `-f, --file <file>`  
  Input Strings Catalog file. Default is `Localizable.xcstrings`.

- `-o, --out-file <out-file>`  
  Output file. Overwrites existing file. Use "-" for STDOUT. Default is `Localizable.xcstrings`.

- `-h, --help`  
  Show help information.

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
