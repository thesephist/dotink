---
title: "Binary search for rational approximations of irrational numbers"
date: 2020-07-27T19:32:17-04:00
toc: true
math: true
---

What's a reasonably simple rational approximation of Pi?

We might take a naive approach and simply take a fraction like \\(\frac{314159265}{100000000}\\) and reduce it to get a fractional representation of an arbitrary decimal form of Pi. But this is boring, and requires large denominators to be precise. Can we do any better?

One possible answer is \\(\frac{102573}{32650} = 3.1415926493...\\) which is pretty darn close, accurate to 8 decimal places after rounding, while keeping a much smaller denominator. Want to get more precise? We can take \\(\frac{4272943}{1360120} = 3.14159265358939...\\) which is accurate to 12 decimal places with only 7 significant figures in the fractions.

It turns out there's an interesting, if not entirely practically useful, way to generate these few-significant-figures approximations of irrational and transcendal numbers efficiently, and the process resembles binary search very closely. I want to explore the parallels and dive into the binary search approximation method in this post.

## Mediants

The approximation method I'll outline here recursively computes mediants of fractions. A _mediant_ is an operation defined on two fractions... sort of... as follows.

$$Mediant\left(\frac{a}{b}, \frac{c}{d}\right) := \frac{a + c}{b + d}$$

The mediant operation is technically not a function on two fractions, since reduced and non-reduced forms of fractions will lead to different results. Technically we should define it as a function on two ordered pairs. But I'll simply call this process the mediant _operation_ for simplicity in this post.

There are a few interesting things about a mediant of two fractions. The most interesting property of the mediant is called the _mediant inequality_, and it states that a mediant of two distinct fractions will always be between the two fractions.

$$\frac{a}{b} < \frac{c}{d} \implies \frac{a}{b} < Mediant\left(\frac{a}{b}, \frac{c}{d}\right) < \frac{c}{d}$$

You might already be seeing some clues as to how we can use this to binary-search a range of numbers. But first, let us take an aside into some related ideas in sequences of rational numbers.

### Farey sequences

[Farey sequences](https://en.wikipedia.org/wiki/Farey_sequence) are a countably infinite set of finite sequences of fractions. We form a Farey sequence of order \\(n\\) by enumerating all reduced fractions with denominators less than or equal to \\(n\\) in the range \\([0, 1]\\).

The first 5 Farey sequences are

$$F_{1} = \left\\{
    \frac{0}{1},
    \frac{1}{1}
\right\\}$$

$$F_{2} = \left\\{
    \frac{0}{1},
    \frac{1}{2},
    \frac{1}{1}
\right\\}$$

$$F_{3} = \left\\{
    \frac{0}{1},
    \frac{1}{3},
    \frac{1}{2},
    \frac{2}{3},
    \frac{1}{1}
\right\\}$$

$$F_{4} = \left\\{
    \frac{0}{1},
    \frac{1}{4},
    \frac{1}{3},
    \frac{1}{2},
    \frac{2}{3},
    \frac{3}{4},
    \frac{1}{1}
\right\\}$$

$$F_{5} = \left\\{
    \frac{0}{1},
    \frac{1}{5},
    \frac{1}{4},
    \frac{1}{3},
    \frac{2}{5},
    \frac{1}{2},
    \frac{3}{5},
    \frac{2}{3},
    \frac{3}{4},
    \frac{4}{5},
    \frac{1}{1}
\right\\}$$

Farey sequences have a few notable properties for our task of approximating irrational numbers.

- Any fraction in the Farey sequence appears only once, in its most reduced representation, by definition.
- Farey sequences of increasing order contain fractions that more finely cover the \\([0, 1]\\) interval.

Given these facts, we can simplify our task of finding a small-denominator fractional approximation of a number, to the problem of finding a number in a Farey sequence of sufficiently high order (for a good enough approximation) that is closest to our irrational number.

### Stern-Brocot tree

A closely related structure to the Farey sequence is the [Stern-Brocot tree](https://en.wikipedia.org/wiki/Stern%E2%80%93Brocot_tree), which is a binary tree produced by recursively taking mediants of fractions.

// paper drawing here

The Stern-Brocot tree is another way of enumerating all reduced-form fractions in the unit interval. However, these terms don't appear in the same order as in a Farey sequence -- fractions with denominator \\(n\\) may appear in a tree node of depth less than \\(n\\), as in \\(\frac{2}{5}\\) which appears at depth 4.

However, traversing the Stern-Brocot tree programmatically is easier than computing Farey sequences of increasing order, and fractions in the tree retain the two important properties of fractions that appear in Farey sequences.

- Any fraction in the Stern-Brocot tree appears exactly once, in its most reduced form.
- Fractions at increasing depths of the Stern-Brocot tree more finely cover the unit interval.

## Approximating irrationals with the Stern-Brocot tree

I first found this process of approximating irrational numbers with the Farey sequence and the Stern-Brocot tree from [this Numberphile video](). The process stood out to me, so I thought I'd implement it in an Ink script and write about it, which became this post.

We can approximate any real number in the unit interval by traversing the Stern-Brocot tree, following branches that better approximate the target number at each depth, until either our approximation is good enough, or the denominator is too large.

For example, to approximate the number 0.37, we take the following branches in the tree

$$\frac{0}{1}
    \rightarrow \frac{1}{2}
    \rightarrow \frac{1}{3}
    \rightarrow \frac{2}{5}
    \rightarrow \frac{3}{8}
    \rightarrow \frac{4}{11}$$

We can also extend this method to rationally approximate all reals, by splitting numbers outside of the unit interval to their whole number part and a fractional part, and then computing a rational approximation of the fractional part. From our previous example, we also know that a similar approximation for 1.37 is \\(\frac{11 + 4}{11} = \frac{15}{11}\\).

An Ink program that executes this search is

```
` binary search to approximate numbers `

std := load('std')
log := std.log
f := std.format

Threshold := 0.000000005

` given target & max denominator `
fareyApproximate := (val, max) => (
	whole := floor(val)
	frac := val - whole

	result := (sub := (an, ad, bn, bd) => (
		diff := frac - (an + bn) / (ad + bd)
		absdiff := (diff < 0 :: {
			true -> ~diff
			false -> diff
		})
		absdiff < Threshold | ad + bd > max :: {
			true -> [an + bn, ad + bd]
			false -> diff > 0 :: {
				` frac is greater `
				true -> sub(an + bn, ad + bd, bn, bd)
				` frac is lesser `
				false -> sub(an, ad, an + bn, ad + bd)
			}
		}
	))(0, 1, 1, 1)

	[whole * result.1 + result.0, result.1]
)

main := args => (
	target := number(args.2)
	max := (number(args.3) :: {
		() -> 1000000
		0 -> 1000000
		_ -> number(args.3)
	})

	result := fareyApproximate(target, max)
	log(f('{{ 2 }} approx. = {{ 3 }} = {{ 0 }} / {{ 1 }}'
		[result.0, result.1, target, result.0 / result.1]))
)

main(args())
```

This program takes two arguments. First, the (positive) decimal number to be approximated, and an maximum denominator we are willing to accept, after which the tree traversal would halt. For the 12-digit approximation of Pi with which I opened this post, I ran

```
./farey.ink 3.14159265358979 1000000
```

Which found `4272943 / 1360120` in the tree traversal at depth 323.
