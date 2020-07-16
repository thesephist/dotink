---
title: "Annotating the dynamic Web in real time"
date: 2020-07-14T18:01:36-04:00
location: "West Lafayette, IN"
toc: true
---

    Write a dotink post about annotating the web -- the Highlighter class. Two approaches, single interface.

## The highlighting problem

    Frame the problem in human terms

### Highlighting models for the web

    Frame the problem in technical terms
    Outline constraints of the solution, and why it's hard
    Focus on the dynamic nature of the problem that makes it hard.

    Previous art:
    - Hypothes.is
    - Grammarly

### Text rendering and the DOM

    Talk about knowledge needed to understand the rest of this article
    - Node/Element, TextNode, node type
    - ClientRect()

## The hybrid highlighter solution

    Why we have a hybrid solution

### DOM highlighter

    Implementation

### Geometry highlighter

    Implementation

### Piercing the shadow DOM
    
    Why / how shadow DOM complicates things

## Performance considerations

    Ways to make it more efficient

## Future work

    How can we improve?
