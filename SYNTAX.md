Precedent Syntax Guide
----------------------

## Headings, Paragraphs, Quotes, Footnotes, and Rules

Document elements can span multiple lines, but are separated by blank
(empty) lines.

### Headings

```
# A top-level heading
   
## A subheading
    
### A sub-subheading
```

### Paragraphs

The style of a paragraph is determined by the indentation of its first
line:

- 0 Spaces: Flush with the left margin (useful after block quotations)
- 2 Spaces: Indented (most paragraphs should be indented this way)
- 4 Spaces: Flush block quotation paragraphs
- 6 Spaces: Indented block quotation paragraphs
- 8 Spaces: Ragged-left (right-aligned) paragraphs

```
  This first line of this paragraph will be rendered indented. It can 
continue on multiple lines.

    This is a flush blockquote paragraph

      And this is an indented blockquote paragraph.

This paragraph follows the block quotation, and will be rendered without
indentation, i.e. flush with the left margin. This is still part of the
flush paragraph, as no blank line separates it from previous lines.

        This paragraph will be set flush against the right margin, or
ragged left.

  And finally, here is another standard indented paragraph.
```

### Footnotes

Footnote paragraphs are all indented paragraphs. The first paragraph in
a footnote begins with a caret (`^`) and a marker, followed by at least
one space before the text of the paragraph begins. The marker can be an
integer, asterisk (`*`), dagger (`†`), or double dagger (`‡`). That
marker should appear elsewhere within a footnote reference (discussed
below).

For example:

```
  This is a body paragraph.[[12]] It has a footnote reference referring
to a footnote with the marker "12".

^12 This is the first paragraph in footnote twelve.

^ This is another paragraph in the same footnote.
```

Footnote paragraphs need not appear at the end of the document, nor must
they appear immediately after the paragraph containing the corresponding
reference. Footnotes can also appear in any order in the document.

### Horizontal Rules

Rules, written `* * *` can appear in body text or block quotations:

```
  A standard paragraph.

* * *

  Another standard paragraph.

      A blockquote paragraph.

    * * *

    A flush blockquote paragrap.

A flush body paragraph.
```

## Formatting Text

Within a paragraph, the following can be used to format text:

```
This is a paragraph. The final word in this sentence is //emphasized//.
Small capitals can be set with the less-than and greater-than characters
<<like so>>. Citations can be identified with double curly brackes and
contain other formatting. {{//Id.//}} Page breaks@@2@@can be notated
with at-signs. Footnote references appear in double brackets.[[1]]

^1 The text of the footnote.
```

## Metadata

Metadata blocks permit non-content information about a document to be
embedded within it.

Metadata blocks are composed of lines containing:

- a key, composed of alphabet letters and starting with a capital letter
- a colon
- optional spaces
- content of any kind, running to the end of the line

For example:

```
Style: Sebelius v. Auburn Regional Medical Center et al. 
Number: 11–1231
Argued: 2012-12-04
Decided: 2013-01-22
```

Metadata must appear at the top of a document, before any content text.

### Special Metadata Types

Content composed only of digits will be interpreted as an integer
number.

```
Opinions: 3
```

Content of the form `YYYY-MM-DD` will be interpreted as a calendar date.

```
Filed: 2013-01-01
```
