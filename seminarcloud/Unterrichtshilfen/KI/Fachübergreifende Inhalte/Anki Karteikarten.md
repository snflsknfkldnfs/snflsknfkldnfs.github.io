# [Text Files](https://docs.ankiweb.net/importing/text-files.html#text-files)

- [Spreadsheets and UTF-8](https://docs.ankiweb.net/importing/text-files.html#spreadsheets-and-utf-8)
- [HTML](https://docs.ankiweb.net/importing/text-files.html#html)
- [Importing Media](https://docs.ankiweb.net/importing/text-files.html#importing-media)
- [Bulk Media](https://docs.ankiweb.net/importing/text-files.html#bulk-media)
- [Duplicates and Updating](https://docs.ankiweb.net/importing/text-files.html#duplicates-and-updating)
- [File Headers](https://docs.ankiweb.net/importing/text-files.html#file-headers)
    - [Notetype Column](https://docs.ankiweb.net/importing/text-files.html#notetype-column)
    - [Deck Column](https://docs.ankiweb.net/importing/text-files.html#deck-column)
    - [GUID Column](https://docs.ankiweb.net/importing/text-files.html#guid-column)

Any **plain text** file that contains fields separated by commas, semicolons or tabs can be imported into Anki, provided some conditions are met.

- The files must be plain text (myfile.txt). Other formats like myfile.xls, myfile.rtf, myfile.doc must be saved as a plain text file first.
    
- The files must be in UTF-8 format (see below).
    
- Anki determines the number of fields in the file by looking at the first (non-commented) line. If some of the later records in the file contain fewer fields, Anki will treat the missing fields as if they were blank. If some of your records contain extra fields, the extra content will not be imported.
    

Fields in your text file can be mapped to any field in your notes, including the tags field. You can choose which field in the text file corresponds to which field in the note when you import.

When you import a text file, you can choose what deck to put the cards in. Keep in mind that if you have the deck override option set for one or more of your templates, the cards will go to that deck rather than the one you’ve selected.

This is an example of a valid file with three fields:

```
apple;banana;grape
first field;second field;third field
```

There are two ways to include newlines or the field separator in fields.

**Escape the characters by placing the contents of the field in quotation marks**:

```
hello;"this is
a two line answer"
two;this is a one line field
"this includes a ; (semicolon)";another field
```

Because quotes are used to mark where a field begins and ends, if you wish to include them inside your field, you need to replace a single doublequote with two doublequotes to "escape" them from the regular handling, like so:

```
field one;"field two with ""escaped quotes"" inside it"
```

When you use a spreadsheet program like Libreoffice to create the CSV file for you, it will automatically take care of escaping double quotes.

**Use HTML new lines**:

```
hello; this is<br>a two line answer
two; this is a one line one
```

You need to turn on the **Allow HTML in fields** in the import dialog for HTML newlines to work.

Escaped multi-lines will not work correctly if you are using cloze deletions that span multiple lines. In this case, please use HTML newlines instead.

You can also include tags in another field and select it as a tags field in the import dialog:

```
first field;second field;tags
```

This is an example of a valid file where the first line is ignored (#):

```
# this is a comment and is ignored
foo bar;bar baz;baz quux
field1;field2;field3
```

## [Spreadsheets and UTF-8](https://docs.ankiweb.net/importing/text-files.html#spreadsheets-and-utf-8)

If you have non-Latin characters in your file (such as accents, Japanese and so on), Anki expects files to be saved in a 'UTF-8 encoding'. The easiest way to do this is to use the free LibreOffice spreadsheet program instead of Excel to edit your file, as it supports UTF-8 easily, and also exports multi-line content properly, unlike Excel. If you wish to keep using Excel, please see [this doc](https://docs.google.com/document/d/12YE_FS6A9ANLTESJNtPP116ti4nNmCBghyoJBRtno_k/edit?usp=sharing) for more information.

To save your spreadsheet to a file Anki can read with LibreOffice, go to **File > Save As**, and then select CSV for the type of file. After accepting the default options, LibreOffice will save the file and you can then import the saved file into Anki.

## [HTML](https://docs.ankiweb.net/importing/text-files.html#html)

Anki can treat text imported from text files as HTML (the language used for web pages). This means that text with bold, italics and other formatting can be exported to a text file and imported again. If you want to include HTML formatting, you can check the "allow HTML in fields" checkbox when importing. You may wish to turn this off if you’re trying to import cards whose content contains angle brackets or other HTML syntax.

If you wish to use HTML for formatting your file but also wish to include angle brackets or ampersands, you may use the following replacements:

|Character|Replacement|
|---|---|
|<|`&lt;`|
|>|`&gt;`|
|&|`&amp;`|

## [Importing Media](https://docs.ankiweb.net/importing/text-files.html#importing-media)

If you want to include audio and pictures from a text file import, copy the files into the [collection.media folder](https://docs.ankiweb.net/files.html). **Do not put subdirectories in the media folder, or some features will not work.**

After you’ve copied the files, change one of the fields in your text file as follows.

```
<img src="myimage.jpg">
```

or

```
[sound:myaudio.mp3]
```

Alternatively, you can use the [find and replace](https://docs.ankiweb.net/browsing.html) feature in the browse screen to update all the fields at once. If each field contains text like "myaudio", and you wish to make it play a sound, you’d search for (.*) and replace it with "[sound:\1.mp3]", with the 'regular expressions' option enabled.

When importing a text file with these references, you must make sure to enable the "Allow HTML" option.

You might be tempted to do this in a template, like:

```
<img src="{{field name}}">
```

Anki doesn’t support this for two reasons: searching for used media is expensive, as each card has to be rendered, and such functionality isn’t obvious to shared deck users. Please use the find & replace technique instead.

## [Bulk Media](https://docs.ankiweb.net/importing/text-files.html#bulk-media)

Another option for importing large amounts of media at once is to use the [media import add-on](https://ankiweb.net/shared/info/129299120). This add-on will automatically create notes for all files in a folder you select, with the filenames on the front (minus the file extension, so if you have a file named apple.jpg, the front would say 'apple') and the images or audio on the back. If you would like a different arrangement of media and filenames, you can [change the note type](https://docs.ankiweb.net/browsing.html) of the created cards afterwards.

## [Duplicates and Updating](https://docs.ankiweb.net/importing/text-files.html#duplicates-and-updating)

When importing text files, Anki uses the first field to determine if a note is unique. By default, if the file you are importing has a first field that matches one of the existing notes in your collection and that existing note is the same type as the type you’re importing, the existing note’s other fields will be updated based on content of the imported file. A drop-down box in the import screen allows you to change this behaviour, to either ignore duplicates completely, or import them as new notes instead of updating existing ones.

The 'match scope' setting controls how duplicates are identified. When 'note type' is selected, Anki will identify a duplicate if another note with the same note type has the same first field. When set to 'note type and deck', a duplicate will only be flagged if the existing note also happens to be in the deck you are importing into.

If you have updating turned on and older versions of the notes you’re importing are already in your collection, they will be updated in place (in their current decks) rather than being moved to the deck you have set in the import dialog. If notes are updated in place, the existing scheduling information on all their cards will be preserved.

For info on how duplicates are handled in .apkg files, please see the [Deck Packages](https://docs.ankiweb.net/exporting.html#packaged-decks) section.

## [File Headers](https://docs.ankiweb.net/importing/text-files.html#file-headers)

Anki 2.1.54+ supports certain headers that can be included in the text file to make importing more powerful or convenient. They consist of `#key:value` pairs and must be listed in separate lines at the top of the file.

|Key|Allowed Values|Behaviour|
|---|---|---|
|`separator`|`Comma`, `Semicolon`, `Tab`, `Space`, `Pipe`, `Colon`, or the according literal characters|Determines the field separator.|
|`html`|`true`, `false`|Determines whether the file is treated as HTML.|
|`tags`|List of tags, separated by spaces|Adds the listed tags to every imported note.|
|`columns`|List of names, separated by the previously set separator|Determines the number of columns and shows their given names when importing.|
|`notetype`|Note type name or id|Presets the note type, if it exists.|
|`deck`|Deck name or id|Presets the deck, if it exists.|
|`notetype column`|`1`, `2`, `3`, ...|Determines which column contains the note type name or id of each note, see [Notetype Column](https://docs.ankiweb.net/importing/text-files.html#notetype-column).|
|`deck column`|`1`, `2`, `3`, ...|Determines which column contains the deck name or id of each note, see [Deck Column](https://docs.ankiweb.net/importing/text-files.html#deck-column).|
|`tags column`|`1`, `2`, `3`, ...|Determines which column contains the tags of each note.|
|`guid column`|`1`, `2`, `3`, ...|Determines which column contains the GUID of each note, see [GUID Column](https://docs.ankiweb.net/importing/text-files.html#guid-column).|

Some headers have further implications.

### [Notetype Column](https://docs.ankiweb.net/importing/text-files.html#notetype-column)

Usually, all notes from a file will be mapped to a single note type. That changes, if there is a column with note type names or ids.

This allows you to import notes with different note types, and their fields will be mapped implicitly: The first regular column is used for the first field of any note regardless of its note type, the second regular column for the second field, and so on. A _regular column_ here being a column that does not contain special information like decks, tags, note types or GUIDs.

### [Deck Column](https://docs.ankiweb.net/importing/text-files.html#deck-column)

Usually, any new cards created as a result of importing a text file will be placed in a single deck of your choice. If the file contains a deck column, however, new cards of a note will be placed in its specified deck instead. If the deck does not exist, a deck with the given name will be created.

### [GUID Column](https://docs.ankiweb.net/importing/text-files.html#guid-column)

GUID stands for _Globally Unique Identifier_. When you create notes in Anki, Anki assigns each note a unique ID, which can be used for duplicate checking. If you export your notes with the GUID included, you can make changes to the notes, and as long as you do not modify the GUID field, you'll be able to import the notes back in to update the existing notes.

Please note that the GUID is intended to be created by Anki. If you are creating your own IDs, such as `MYNOTE0001`, then it's recommended that you place the IDs in the first field, instead of assigning them to Anki's internal GUID. When importing, Anki is able to use either the first field or the GUID for duplicate checking, so you do not need to make IDs a GUID in order to be able to update your notes.

One other thing to note is that the duplicate option will not work for rows that have a non-empty GUID. If a GUID is provided, and already exists in the collection, a duplicate will not be created.