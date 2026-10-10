package main

import "core:fmt"

Node :: struct($T: typeid) {
	data: T,
	npx:  uintptr,
}

Xor_List :: struct($T: typeid) {
	head, tail: ^Node(T),
}

@(private)
addr :: #force_inline proc(n: ^Node($T)) -> uintptr {
	return uintptr(rawptr(n))
}

@(private)
ptr :: #force_inline proc(a: uintptr, $T: typeid) -> ^Node(T) {
	return (^Node(T))(rawptr(a))
}

push_back :: proc(l: ^Xor_List($T), value: T) {
	n := new(Node(T))
	n.data = value
	n.npx = addr(l.tail)

	if l.tail != nil {
		l.tail.npx ~= addr(n)
	} else {
		l.head = n
	}
	l.tail = n
}

push_front :: proc(l: ^Xor_List($T), value: T) {
	n := new(Node(T))
	n.data = value
	n.npx = addr(l.head)

	if l.head != nil {
		l.head.npx ~= addr(n)
	} else {
		l.tail = n
	}
	l.head = n
}

print_all :: proc(l: ^Xor_List($T)) {
	prev: uintptr = 0
	curr := l.head
	for curr != nil {
		fmt.println(curr.data)
		next := curr.npx ~ prev
		prev = addr(curr)
		curr = ptr(next, T)
	}
}

destroy :: proc(l: ^Xor_List($T)) {
	prev: uintptr = 0
	curr := l.head
	for curr != nil {
		next := ptr(curr.npx ~ prev, T)
		prev = addr(curr)
		free(curr)
		curr = next
	}
	l^ = {}
}

main :: proc() {
	fmt.println("introducing xor linked list...")

	l: Xor_List(int)
	defer destroy(&l)
	push_back(&l, 1)
	push_back(&l, 2)
	push_back(&l, 3)
	push_back(&l, 4)
	push_front(&l, 0)
	print_all(&l)
}
