# What is this?

A set of small command line tools for comparing structural similarities in Slim template code. Hacked it together in an evening, don't expect too much. It's slow. It's suboptimal. And it's better than anything else I found, which was exactly nothing.

## Motivation

Code review. Particularly, code review for pull requests where the creator came down with a nasty case of copypasteitis. Each match found is a potential candidate for refactoring.

# Okay, how do I use it?

```
$ make
$ ./slimmer 5 30 path/to/your/code
```

## Explanation

The first argument `n` is the number of lines a block of code must have to be considered. This is to increase efficiency and reduce the number of false positives - after all, in a Slim template, there will be a lot of lines that are similar, because single lines can consist of simply a HTML tag, and there are only so many of those.

The second argument `m` is the maximum Levenshtein distance between code blocks for them to be considered "similar enough" to be included. This is also to reduce false positives, since if you set this value high enough, _any_ block of code will be "similar" to any _other_ block of code, and that's not helpful. It also increases efficiency, since a cutoff point means we don't need to keep considering lines.

All further arguments are file or folder names. If a folder name is supplied, all files found recursively below that folder will be processed. If a filename is supplied, it's processed like a regular file.

## Technical deets

When processing a file, Slimmer will for each line attempt to find the largest code window (as measured by number of lines) such that its Levenshtein distance to a subsequent non-overlapping code window of the same length is below a given threshold. When increasing the window size would surpass the threshold, the result is displayed to the user. The line pointer then jumps ahead to the next line below the matching code window and resumes its search.

The lines displayed in the output are not necessarily consecutive lines. This is because blank lines are filtered out and not considered. Furthermore, indentation level is not considered when comparing similarity, because two code blocks may well be indented differently due to an if-statement somewhere but still be prime candidates for refactoring.

The whitespace removal is delegated to a shell script because that was the first solution I came up with. It's probably not too inefficient given that the bulk of the rest of the code is written in Ruby, although I kinda do re-implement it partially in Ruby for output formatting reasons. The code for finding the Levenshtein distance is

### Why the Levenshtein distance?

First thing I thought of :) It's possible that some more clever word-edit or token-edit distance would perform much better, but I couldn't be arsed. Levenshtein is technically straightforward and unambiguous.

# DISCLAIMER

This SOFTWARE PRODUCT is provided by THE PROVIDER "as is" and "with all faults." THE PROVIDER makes no representations or warranties of any kind concerning the safety, suitability, lack of viruses, inaccuracies, typographical errors, or other harmful components of this SOFTWARE PRODUCT. There are inherent dangers in the use of any software, and you are solely responsible for determining whether this SOFTWARE PRODUCT is compatible with your equipment and other software installed on your equipment. You are also solely responsible for the protection of your equipment and backup of your data, and THE PROVIDER will not be liable for any damages you may suffer in connection with using, modifying, or distributing this SOFTWARE PRODUCT.

[Source](https://www.javaworld.com/article/2073149/software-disclaimer.html) (non-primary)

Seriously. I'm literally repeatedly pasting arbitrary unknown code in bulk into a command executed by the shell in blind faith, the only barrier between the user and utter annihilation being how well [Shellwords](https://ruby-doc.org/stdlib-2.5.1/libdoc/shellwords/rdoc/Shellwords.html#method-c-escape) does its job escaping bash characters. You've had your warning.
