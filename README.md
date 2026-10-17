# Library Management System in MIPS Assembly

A small **library catalogue** written entirely in **MIPS assembly**. It keeps a list of books, each with categories, a loan status and a FIFO waitlist of borrowers, and supports placing holds, checking books out and returning them.

Built as Programming Assignment 2 for the **CENG 311 – Computer Architecture** course. The full assignment description is in [`CENG311_PA2_Library_Assignment.pdf`](CENG311_PA2_Library_Assignment.pdf).

## Features

- **Dynamic arrays**: the book catalogue and each book's category list are heap-allocated arrays (via `sbrk`, syscall 9) with a `{data*, capacity, count}` header. Capacity is 4, and adding to a full array prints `Array full!`.
- **Book records**: each book is a 24-byte heap object.
- **Waitlists as linked lists**: each book holds a singly linked list of `{name*, next*}` nodes. New holds go at the tail and checkouts take from the head (FIFO).
- **Checkout / return logic** with clear console messages:
  - `Added to waitlist: <Title> <- <Name>`
  - `Checked out: <Title> -> <Name>`: the book is lent to the first person on the waitlist.
  - `Already on loan: <Title> - held by <Name>`
  - `No holds for: <Title>`: the waitlist is empty.
  - `Returned: <Title> <- <Name>` / `Already available: <Title>`
- **Catalogue printing**: title, ID, year, status, categories and the current waitlist for every book.
- Follows MIPS calling conventions: `$s` registers and `$ra` are saved on the stack in non-leaf procedures.

## Data Layout

**Book (24 bytes)**

| Offset | Field |
| --- | --- |
| 0 | `id` |
| 4 | `title*` |
| 8 | `year` |
| 12 | `status`: `0` = available, otherwise a pointer to the borrower's name |
| 16 | `categories*` (dynamic array header) |
| 20 | `waitlist_head*` |

**Dynamic array header (12 bytes):** `data*` (+0), `capacity` (+4), `count` (+8)

**Waitlist node (8 bytes):** `name*` (+0), `next*` (+4)

## Procedures

| Procedure | Arguments | Purpose |
| --- | --- | --- |
| `initBookArray` | – | Creates the catalogue (capacity 4) |
| `initCategoryArray` | – | Creates an empty category list |
| `putOnCategory` | `$a0` category header, `$a1` string | Appends a category |
| `createBook` | `$a0` id, `$a1` title, `$a2` year, `$a3` categories | Allocates and initializes a book |
| `addBook` | `$a0` catalogue, `$a1` book | Appends a book to the catalogue |
| `putOnWaitlistAt` | `$a0` catalogue, `$a1` index, `$a2` name | Adds a person to a book's waitlist |
| `checkoutBookAt` | `$a0` catalogue, `$a1` index | Lends the book to the next person on the waitlist |
| `returnBookAt` | `$a0` catalogue, `$a1` index | Marks the book as available |
| `printBookList` / `printBook` | `$a0` catalogue / book | Prints the catalogue |

## Demo Scenario

`main` builds a catalogue of three books:

| ID | Title | Year | Categories |
| --- | --- | --- | --- |
| 123 | Clean Code | 1999 | programming, best-practices, education |
| 55 | Operating Systems | 2014 | systems, education |
| 310 | Computer Networks | 2011 | networks, education |

It then adds several people to the waitlists and runs a series of checkouts and returns, printing the catalogue between steps. The run covers the normal path and the edge cases: already on loan, already available, and no holds.

## Running

1. Install [QtSpim](https://spimsimulator.sourceforge.net/).
2. Load `PA2_310201102.asm` (*File → Reinitialize and Load File*).
3. Click **Run**. The output appears in the console window.

## Project Structure

```
.
├── PA2_310201102.asm                    # Full implementation + demo main
└── CENG311_PA2_Library_Assignment.pdf   # Assignment specification
```
