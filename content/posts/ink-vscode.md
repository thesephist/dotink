---
title: "Ink language support in Visual Studio Code"
date: 2020-09-02T02:16:52-04:00
---

Today, I published the first version of **[ink-vscode](https://github.com/thesephist/ink-vscode)**, which adds support for the Ink language to the [Visual Studio Code](https://code.visualstudio.com) editor.

So far, there has only been one kind of editor support for the Ink language, in the form of a [syntax definition for the Vim editor](https://github.com/thesephist/ink/blob/master/utils/ink.vim). This served me (Linus) well, because I almost always write Ink code in Vim. But many developers don't, and Visual Studio Code seemed like the natural next target.

<a href="https://github.com/thesephist/ink-vscode" class="button">See ink-vscode on GitHub &rarr;</a>

![Screenshot of ink-vscode running](/img/ink-vscode.jpg)

At the moment, ink-vscode adds syntax highlighting to Ink programs in Visual Studio Code. I don't anticipate this project to move quickly, because Code isn't my primary editor for Ink projects, but a syntax highlighter is a good start, and I hope to add and accept contributions to keep the extension useful as Ink evolves.

At time of writing, the ink-vscode extension isn't published to the Visual Studio Code Marketplace, which means to use the extension, you'll need to install it from source. You can find instructions to install the extension from source in the [project's GitHub repository](https://github.com/thesephist/ink-vscode#installing-and-developing-locally).

