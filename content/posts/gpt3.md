---
title: "Recap: a discussion on NLP, GPT-3, and language models"
date: 2020-07-26T13:13:31-04:00
toc: true
draft: true
---

    open with intuition: long autocomplete / typeahead suggestions

    state of the art used to be LSTM, then LSTM with attention, but tranformers (encoder-decoder with attention) work better now.
        attention is just ability to reference recent other portions of text.
        transformers encode words into vectors while also deciding how to weight each token (attention) in the result 
        https://papers.nips.cc/paper/7181-attention-is-all-you-need.pdf

    few-shot learning

    alternatives to transformers: LSTM, other kinds of models, bidirectional vs. sequential

    "temperature"

    how do you evaluate?
        - GLUE
        - perplexity

    The key to GPT3 is training size, which has been increasing steadily since before GPT2
        sourced from the Internet, a few other sources.
        AI overhang
    

