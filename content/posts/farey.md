---
title: "Binary search for rational approximations of irrational numbers"
date: 2020-07-22T19:32:17-04:00
toc: true
math: true
draft: true
---

## Mediants

$$Mediant\left(\frac{a}{b}, \frac{c}{d}\right) := \frac{a + c}{b + d}$$

### Farey sequences

### A proof of the mediant inequality

// restate theorem

$$\frac{a}{b} < \frac{c}{d} \implies \frac{a}{b} < \frac{a + c}{b + d} < \frac{c}{d}$$

## Approximating irrationals with the Farey sequence

// reference the numberphile video

// a nice property of numbers in the farey sequence is that they are all in their most reduced form.

// what is it? how does it work? (comparison to binary search)
// some test runs of example programs.

// TODO: can we make code snippets on dotink so that they are collapsed by default and expand/collapse on user click?

```
` farey addition to approximate numbers `

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
