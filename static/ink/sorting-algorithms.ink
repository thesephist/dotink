` sorting algorithm visualizer `

` these ard standard modules found in github.com/thesephist/ink/samples/ `
std := load('std')
bmp := load('bmp').bmp

` importing standard library functions `
log := std.log
sl := std.stringList
clone := std.clone
reverse := std.reverse
slice := std.slice
append := std.append
range := std.range
map := std.map
reduce := std.reduce
each := std.each
writeFile := std.writeFile

` set length of list to sort. All lists
	are assumed to be this length unless otherwise specified `
LENGTH := 500

` hsl to rgb color converter, for rendering the exterior of the set `
hsl := (h, s, l) => (
	` ported from https://stackoverflow.com/questions/2353211/hsl-to-rgb-color-conversion `
	h2rgb := (p, q, t) => (
		` wrap to [0, 1) `
		t := (t < 1 :: {
			true -> t + 1
			false -> t
		})
		t := (t > 1 :: {
			true -> t - 1
			false -> t
		})

		[t < 1/6, t < 1/2, t < 2/3] :: {
			[true, _, _] -> p + (q - p) * 6 * t
			[_, true, _] -> q
			[_, _, true] -> p + (q - p) * (2/3 - t) * 6
			_ -> p
		}
	)

	q := (l < 0.5 :: {
		true -> l * (1 + s)
		false -> l + s - l * s
	})
	p := 2 * l - q

	[
		floor(255 * h2rgb(p, q, h + 1/3))
		floor(255 * h2rgb(p, q, h))
		floor(255 * h2rgb(p, q, h - 1/3))
	]
)

toColor := n => hsl(n, 0.7, 0.63)
toGreyscale := n => (
	shade := floor(n * 255)
	[shade, shade, shade]
)

` utility function to verify whether a list is fully sorted:
	short-circuits out if it's not, checking from beginning `
verify := list => (sub := idx => idx :: {
	LENGTH -> true
	_ -> list.(idx - 1) > list.(idx) :: {
		true -> false
		false -> sub(idx + 1)
	}
})(1)

SelectionSort := list => (
	state := {
		idx: 0
	}

	` return index of min item in list `
	minIdx := lst => (
		min := {
			idx: 0
			val: lst.0
		}
		each(range(0, len(lst), 1), idx => (
			lst.(idx) < min.val :: {
				true -> (
					min.idx := idx
					min.val := lst.(idx)
				)
			}
		))
		min.idx
	)

	sort := () => (
		` find the minimum value in the remaining section of the list `
		idx := state.idx + minIdx(slice(list, state.idx, LENGTH))

		` swap with the end of the sorted list `
		state.idx :: {
			LENGTH -> ()
			_ -> (
				thisMin := list.(idx)
				replaced := list.(state.idx)

				list.(idx) := replaced
				list.(state.idx) := thisMin

				state.idx := state.idx + 1
			)
		}

		` return sorted list `
		list
	)
)

InsertionSort := list => (
	state := {
		idx: 1
	}

	` given a list and a new value, return index at which the new value
		should be inserted in the given list `
	getPos := (lst, next) => (sub := i => next > list.(i) :: {
		false -> i
		true -> i + 1 :: {
			len(lst) -> i + 1
			_ -> sub(i + 1)
		}
	})(0)

	sort := () => (
		next := list.(state.idx)
		nextPos := getPos(slice(list, 0, state.idx), next)

		` construct the new, more sorted list in pieces `
		nextList := slice(list, 0, nextPos)
		nextList.len(nextList) := next
		append(nextList, slice(list, nextPos, state.idx))
		append(nextList, slice(list, state.idx + 1, LENGTH))

		` copy over sorted vesion of list to "list" from "next" `
		each(range(0, LENGTH, 1), i => list.(i) := nextList.(i))
		state.idx := state.idx + 1

		list
	)
)

MergeSort := list => (
	state := {
		prevDivisions: map(list, item => [item])
		nextDivisions: []
		nextMergeIdx: 0
	}

	` merge two ordered lists into a single ordered list `
	mergeLists := (first, second) => (
		result := []
		(sub := (a, b) => [len(a), len(b)] :: {
			[_, 0] -> append(result, a)
			[0, _] -> append(result, b)
			[_, _] -> a.0 < b.0 :: {
				true -> (
					result.len(result) := a.0
					sub(slice(a, 1, len(a)), b)
				)
				false -> (
					result.len(result) := b.0
					sub(a, slice(b, 1, len(b)))
				)
			}
		})(first, second)
	)

	sort := () => (
		first := state.prevDivisions.(state.nextMergeIdx)
		second := state.prevDivisions.(state.nextMergeIdx + 1)
		
		second :: {
			() -> state.nextDivisions.len(state.nextDivisions) := first
			_ -> state.nextDivisions.len(state.nextDivisions) := mergeLists(first, second)
		}

		state.nextMergeIdx := state.nextMergeIdx + 2
		state.nextMergeIdx > len(state.prevDivisions) - 1 :: {
			true -> (
				state.nextMergeIdx := 0
				state.prevDivisions := state.nextDivisions
				state.nextDivisions := []
			)
		}

		` always return the flattened list structure `
		reduce(
			slice(state.prevDivisions, state.nextMergeIdx, len(state.prevDivisions))
			(acc, row) => append(acc, row)
			reduce(state.nextDivisions, (acc, row) => append(acc, row), [])
		)
	)
)

BubbleSort := list => (
	state := {
		idx: 1
	}

	swap := (i, j) => (
		xi := list.(i)
		xj := list.(j)
		list.(i) := xj
		list.(j) := xi
	)

	sortOnce := () => (
		state.idx :: {
			LENGTH -> state.idx := 1
		}

		a := list.(state.idx - 1)
		b := list.(state.idx)

		a > b :: {
			true -> swap(state.idx - 1, state.idx)
			false -> (
				state.idx := state.idx + 1
				sortOnce()
			)
		}
	)

	` BubbleSort is slow.
		to make reasonably square graphs, we sort 15x for each sort() call `
	sort := () => (
		each(range(0, 15, 1), () => verify(list) :: {
			false -> sortOnce()
		})
		list
	)
)

QuickSort := list => (
	state := {
		pivot: ()
		lo: ()
		hi: ()

		` start with a base partition of one partition for the whole list `
		partitions: [[0, LENGTH - 1]]
	}

	state.lo := state.partitions.(0).(0)
	state.hi := state.partitions.(0).(1)
	state.pivot := list.(state.lo)

	swap := (i, j) => (
		xi := list.(i)
		xj := list.(j)
		list.(i) := xj
		list.(j) := xi
	)

	` this quicksort, for illustrative purposes, runs an iterative algorithm with
		a basic queue of partitions to recursively quicksort. This sorts a partition
		and queues two more partitions, if applicable, to be sorted `
	advancePartition := pidx => (
		currentPartition := state.partitions.0
		state.partitions := slice(state.partitions, 1, len(state.partitions))

		state.partitions.len(state.partitions) := [currentPartition.0, pidx]
		state.partitions.len(state.partitions) := [pidx + 1, currentPartition.1]

		(sub := () => (
			state.lo := state.partitions.(0).(0)
			state.hi := state.partitions.(0).(1)

			state.lo < state.hi :: {
				true -> (
					state.pivot := list.(state.lo)
				)
				false -> (
					state.partitions := slice(state.partitions, 1, len(state.partitions))
					sub()
				)
			}
		))()
	)

	sort := () => (
		` this quicksort uses the simple Hoare partition scheme.
			this is a tail-recursive implementation of the Hoare partition `
		(sub := () => (
			state.lo := (sub := lo => list.(lo) < state.pivot :: {
				true -> sub(lo + 1)
				false -> lo
			})(state.lo)
			state.hi := (sub := hi => list.(hi) > state.pivot :: {
				true -> sub(hi - 1)
				false -> hi
			})(state.hi)

			state.lo < state.hi :: {
				true -> (
					swap(state.lo, state.hi)

					state.lo := state.lo + 1
					state.hi := state.hi - 1
				)
				false -> (
					advancePartition(state.hi)
					sub()
				)
			}
		))()

		list
	)
)

SORTS := {
	insertion: InsertionSort
	selection: SelectionSort
	merge: MergeSort
	bubble: BubbleSort
	quick: QuickSort
}

` generate a randomized list to sort `
LIST := map(range(0, LENGTH, 1), rand)

` for each sorting algorithm, generate and save the image `
each(keys(SORTS), k => (
	unsorted := clone(LIST)
	sort := (SORTS.(k))(unsorted)

	` generate rows of pixels representing sorting steps `
	rows := (sub := acc => (
		partial := sort()
		acc.len(acc) := map(partial, toColor)
		verify(partial) :: {
			true -> acc
			false -> sub(acc)
		}
	))([])

	` render from top to bottom, not bottom to top, which is default `
	rows := reverse(rows)

	` transform grid into pixel array `
	pixels := reduce(rows, (acc, row) => append(acc, row), [])

	` generate image file `
	file := bmp(LENGTH, len(pixels) / LENGTH, pixels)
	
	` save file `
	writeFile(k + '.bmp', file, ok => ok :: {
		true -> log('Complete: ' + k)
		() -> log('Error!')
	})
))
