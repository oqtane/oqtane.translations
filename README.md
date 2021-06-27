## Overview

Oqtane.Translations is OSS for provding a supported transaltions for [Oqtane Framework](https://github.com/oqtane/oqtane.framework).

## How to create a new translation for Oqtane Framework

There are two ways to start a new translation for Oqtane Framework:

**1. Using Repository**

Simply you can start your new translation from the repository by copying the `English (en)` folder and paste it with the name `{Language} ({Culture})`. For example creating a French translation will lead a `French (fr-FR)` folder to be created.

When your translations are ready you can contribute it with `Oqtane.Translations` by submitting a PR with the added files.

**2. Using Oqtane Resources Extractor Tool**

Another way to start your new translation is to use the `Oqtane Resources Extractor` tool by cloning the [Oqtane.ResxExtractor](https://github.com/hishamco/Oqtane.ResxExtractor) repository, then to run the tool in the root of the Oqtane Framework source.

This way the tool will generate the same resources that's available in `English (en)` folder that you saw earlier, but the main difference you will get a FRESH copy of the resources, because the default resources need to be updated frequently to get the newly added resources in the Oqtane Framework source.

In case you want to generate a culture specific resources instead of clone the English resources and suffix them, you could simple run `oqtane-extractor -c={Culture}` with option.

## How to use the translations in Oqtane Framework

As we know Oqatane Framework is using two runtimes `Server` and `WebAssembly`, to make sure that the newly added translation should work as expected what you need is to copy the translations folder content into `Oqtane.Client` project more specifically into `Resources` folder or the name that is configured in the `AddLocalization()` extension.

Last step you need is to ensure that you include the culture name in the resx file. For example in Frensh translation it should be `{ResourceName}.fr-FR.resx`, this way Oqtane Framework will recognize you added resources

![Instructions](https://github.com/oqtane/oqtane.translations/blob/main/instructions.png?raw=true 'Instructions')
