# =========================================================
# CENG311 - Library Management System
# QtSpim
# =========================================================

.data

nl:						.asciiz "\n"
arrow:					.asciiz " -> "
left_arrow:				.asciiz " <- "
empty_wl:				.asciiz "(empty)\n"
msg_full:				.asciiz "Array full!\n"
msg_id:					.asciiz "ID: "
msg_year:				.asciiz "  Year: "
msg_title:				.asciiz "Title: "
msg_status:				.asciiz "Status: "
msg_categories:			.asciiz "Categories: "
msg_nonecats:			.asciiz "(none)\n"
msg_avail:				.asciiz "Available\n"
msg_loan:				.asciiz "On Loan to "
msg_wait:				.asciiz "Waitlist: "
msg_checked_out:		.asciiz "Checked out: "
msg_returned:			.asciiz "Returned: "
msg_noholds:			.asciiz "No holds\n"
msg_already_avail:		.asciiz "Already available: "
msg_already_for:		.asciiz "Already on loan: "
msg_held_by:			.asciiz " - held by "
msg_noholds_for:		.asciiz "No holds for: "
msg_wait_added:			.asciiz "Added to waitlist: "
msg_catalog_header:		.asciiz "===== BOOK CATALOGUE ====="
msg_separator:			.asciiz "---------------------------"
msg_booklist_created:	.asciiz "Book list created (capacity=4, count=0)\n"
msg_added_prefix:		.asciiz "Book added to list: "
comma_space:			.asciiz ", "

t_clean:	.asciiz "Clean Code"
t_os:		.asciiz "Operating Systems"
t_net:		.asciiz "Computer Networks"

c_prog:		.asciiz "programming"
c_best:		.asciiz "best-practices"
c_sys:		.asciiz "systems"
c_edu:		.asciiz "education"
c_net:		.asciiz "networks"

p_Alice:	.asciiz "Alice"
p_Bob:		.asciiz "Bob"
p_Jane:		.asciiz "Jane"
p_Charlie:	.asciiz "Charlie"
p_David:	.asciiz "David"
p_Emma:		.asciiz "Emma"
p_Frank:	.asciiz "Frank"
p_Grace:	.asciiz "Grace"
p_Henry:	.asciiz "Henry"
p_Isla:		.asciiz "Isla"
p_Jack:		.asciiz "Jack"
p_Kate:		.asciiz "Kate"
p_Liam:		.asciiz "Liam"

.text


# --------------------- initBookArray ---------------------
initBookArray:
	#header allocation
	li $v0, 9 #syscall 9: allocate memory
	li $a0, 12 #for 12 bytes(3 words)
	syscall
	move $t0, $v0 #save header address in $t0 for further use

	#backing array allocation
	li $v0, 9 #syscall 9: allocate memory
	li $a0, 16 #for 16 bytes(4 words)
	syscall #now $v0 holds the backing array address

	#initialize header fields
	sw $v0, 0($t0) #store adress of backing in header address + 0 offset
	li $t1, 4 #for assigning backing array's capacity to 4  we assign 4 to $t1
	sw $t1, 4($t0) #store capacity of backing in header address + 4 offset
	sw $zero, 8($t0) #store current number of elements in header address + 8 offset
	
	#printing message
	li $v0, 4 #syscall 4 print string
	la $a0, msg_booklist_created #address of string as argument
	syscall

	#returning
	move $v0, $t0 #restore header address in $v0 for return
	jr   $ra #return to return address

# --------------------- initCategoryArray ---------------------
initCategoryArray:
	#header allocation
	li $v0, 9 #syscall 9: allocate memory
	li $a0, 12 #for 12 bytes(3 words)
	syscall
	move $t0, $v0 #save header address in $t0 for further use

	#backing array allocation
	li $v0, 9 #syscall 9: allocate memory
	li $a0, 16 #for 16 bytes(4 words)
	syscall #now $v0 holds the backing array address

	#initialize header fields
	sw $v0, 0($t0) #store adress of backing in header address + 0 offset
	li $t1, 4 #for assigning backing array's capacity to 4  we assign 4 to $t1
	sw $t1, 4($t0) #store capacity of backing in header address + 4 offset
	sw $zero, 8($t0) #store current number of elements in header address + 8 offset
	
	#returning
	move $v0, $t0 #restore header address in $v0 for return
	jr   $ra

# --------------------- putOnCategory ---------------------
# a0 = category_hdr
# a1 = str_ptr
putOnCategory:
	#load capacity and count
	lw $t0, 4($a0) #load capacity
	lw $t1, 8($a0) #load count

	#check fullness
	beq $t0, $t1 full_error #if count == capacity branch to error message

	#if not full store base address of array
	lw $t2, 0($a0) #$t2 = base adress of array

	#calculate the offset for empty slot 
	sll $t3, $t1, 2 #$t3 = 4 * count
	#calculate offset + base adress
	add $t4, $t2, $t3 #$t4 = base adress + offset --> address of empty slot

	#put the st_ptr into empty slot
	sw $a1, 0($t4) #string pointer to empty slot

	#update count of Array
	addi $t1, $t1, 1 #count = count + 1
	sw $t1, 8($a0) #store new count in header

	#return
	jr  $ra

full_error:

	li $v0, 4 #syscall 4 print string
    la $a0, msg_full #error message
    syscall

	#return
    jr $ra

# --------------------- createBook ---------------------
# a0 = id
# a1 = title_ptr
# a2 = year
# a3 = category_hdr
createBook:
	#save id in temp register because $a0 will be used in syscall
	move $t0, $a0 #$t0 = id

	#allocate memory for 24 bytes(for book's 6 fields)
	 li $v0, 9 #syscall 9 memory allocation
	 li $a0, 24 #for 24 bytes
	 syscall #address of the new book is in $v0

	#put fields of new book
	sw $t0, 0($v0) #book's base address + offset 0 = id
	sw $a1, 4($v0) #book's base address + offset 4 = title_ptr
	sw $a2, 8($v0) #book's base address + offset 8 = year
	sw $zero, 12($v0) #book's base address + offset 12 = (status = 0)
	sw $a3, 16($v0) #book's base address + offset 16 = category_hdr
	sw $zero, 20($v0) #book's base address + offset 20 = (waitlist_head = 0)

	#return
	jr   $ra

# --------------------- addBook ---------------------
# a0 = catalog_hdr
# a1 = book*
addBook:
	#check if array is full
	#load capacity and count
	lw $t0, 4($a0) #load capacity
	lw $t1, 8($a0) #load count

	#check fullness
	beq $t0, $t1 full_error #if count == capacity branch to error message

	#store backing array's address at $t2
	lw $t2, 0($a0) 

	#if not full store book pointer into backing array
	sll $t3, $t1, 2 #$t4 = count * 4  
	add $t4, $t2, $t3 #t4 = cataleg_hdr + offset
	sw $a1, 0($t4) #put book pointer to catalog's backing array

	#update count
	addi $t1, $t1, 1 #$t1 += 1
	sw $t1, 8($a0) #update count in array

	#print message 'Book added to list: <Title>'
	li $v0, 4 #syscall 4 print string
	la $a0, msg_added_prefix #print 'Book added to list'
	syscall

	#print books title
	lw $a0, 4($a1) #load book's title address to $a0
	syscall #print bookss title
	la $a0, nl #newline
	syscall #print newline

	#return
	jr  $ra

# --------------------- putOnWaitlistAt ---------------------
# a0 = catalog_hdr
# a1 = index
# a2 = name_ptr
putOnWaitlistAt:
	#find the book
	lw $t0, 0($a0) #$t0 = backing array address
	sll $t1, $a1, 2 #$t1 = offset = index * 4
	
	add $t2, $t1, $t0 #$t2 now holds indexed book's address
	lw $t2, 0($t2) #$t2 now holds indexed book's address

	#create waitlist node
	li $v0 ,9 #syscall 9 memory allocate
	li $a0, 8 #for 8 bytes(2 words)
	syscall
	move $t3, $v0 #store new node's address in $t3

	#initialize node's fields
	sw $a2, 0($t3) #node's address + 0 = name_ptr
	sw $zero, 4($t3) #node's address + 0 = 0(next)

	#retrieve waitlist's head
	lw $t4 20($t2) #$t2 holds waitlist_head of book

	#if the current head is not empty go to end of waitlist
	bne $zero, $t4, find_last_node
	#if the current head is zero append our new node to selected book's waitlist head
	sw $t3, 20($t2) #new node assigned to book's adress + 20(waitlist_head)
	j print_added_to_wl

find_last_node:
	#go to next node until there is no next node
	go_next_node:
	lw $t5, 4($t4) #$t4 is current node, #t5 is address of next node
	#if $t5(next node) is zero we have found the end
	beq $zero, $t5, end_found #if so go to end_found
	#if $t5(next node) is not zero assign next node as current node
	move $t4, $t5 #our next nodes becomes our current node
	j go_next_node #jump to go_next_node

	#when end found set new node to end node's "next" field
	end_found:
	sw $t3, 4($t4) #insert new node to end node's "next" field

print_added_to_wl:		
	#print: "Added to waitlist:"
	li $v0, 4 #syscall 4 for print string
	la $a0, msg_wait_added #address of string as argument
	syscall

	#print book's title
	li $v0, 4 #syscall 4 for print string
	lw $a0, 4($t2) #$t2(book's address) + 4 offset = book's title
	syscall

	#print "<-"
	li $v0, 4 #syscall 4 for print string
	la $a0, left_arrow #address of left arrow as argument
	syscall

	#print name 
	li $v0, 4 #syscall 4 for print string
	move $a0, $a2 #name_ptr as argument
	syscall

	#print newline
	li $v0, 4 #syscall 4 for print string
	la $a0, nl #address of newline as argument
	syscall

	#return
	jr   $ra

# --------------------- checkoutBookAt ---------------------
# a0 = catalog_hdr 
# a1 = index
checkoutBookAt:
	#retrieve book from catalog array
	lw $t0, 0($a0) #$t0 holds data_ptr of catalog_hdr
	sll $t1, $a1, 2 #$a1 = 4 * index
	add $t1, $t1, $t0 #$t1 holds address of indexed book's slot
	lw $t1, 0($t1) #$t1 holds address of indexed book
	
	#retrieve status and waitlist of book
	lw $t2, 12($t1) #$t2 = status
	lw $t3, 20($t1) #$t3 = waitlist_head
	
	#check if available and waitlist not empty
	#check if available (status == 0)
	bne $zero, $t2, not_available #if status != 0 branch to not_available
	#check if waitlist not empty (waitlist_head != 0)
	beq $zero, $t3, waitlist_empty #if waitlist empty branch to waitlist_empty
	
	#retrieve the head node's name field
	lw $t4, 0($t3) #$t4 = name_ptr of head node
	
	#set status = borrower name
	sw $t4, 12($t1) #book's status = borrower name
	
	#remove first node of waitlist 
	lw $t3, 4($t3) #$t3 = next node
	sw $t3, 20($t1) #books new waitlist_head = next node in $t3
	
	#jump to print_new_borrow
	j print_new_borrow

#print 'Already on loan: <Title> - held by <Name>'	
not_available:
	#print: 'Already on loan:'
	li $v0, 4 #syscall 4 for print string
	la $a0, msg_already_for #address of string as argument
	syscall
	
	#print book's title
	li $v0, 4 #syscall 4 for print string
	lw $a0, 4($t1) #$t1(book's address) + 4 offset = book's title
	syscall

	#print: '- held by'
	li $v0, 4 #syscall 4 for print string
	la $a0, msg_held_by #address of string as argument
	syscall
	
	#print borrower's name
	li $v0, 4 #syscall 4 for print string
	lw $a0, 12($t1) #$t1(book's address) + 12 offset = borrower's name
	syscall
	
	#print new line
	li $v0, 4
    	la $a0, nl
   	syscall
	
	#jump to return address
	jr $ra

#print 'No holds for: <Title>'
waitlist_empty:
	#print: 'No holds for:'
	li $v0, 4 #syscall 4 for print string
	la $a0, msg_noholds_for #address of string as argument
	syscall
	
	#print book's title
	li $v0, 4 #syscall 4 for print string
	lw $a0, 4($t1) #$t1(book's address) + 4 offset = book's title
	syscall
	
	#print new line
	li $v0, 4
    	la $a0, nl
   	syscall
	
	#jump to return
	jr $ra

#print 'Added to waitlist: <Title> <- <Name>'
print_new_borrow:
	#print: 'Added to waitlist: '
	li $v0, 4 #syscall 4 for print string
	la $a0, msg_checked_out #address of string as argument
	syscall
	
	#print book's title
	li $v0, 4 #syscall 4 for print string
	lw $a0, 4($t1) #$t1(book's address) + 4 offset = book's title
	syscall
	
	#print "->"
	li $v0, 4 #syscall 4 for print string
	la $a0, arrow #address of right arrow as argument
	syscall

	#print borrower's name
	li $v0, 4 #syscall 4 for print string
	lw $a0, 12($t1) #$t1(book's address) + 12 offset = borrower's name
	syscall
	
	#print new line
	li $v0, 4
    	la $a0, nl
   	syscall
	
	#jump to return
	jr $ra

# --------------------- returnBookAt ---------------------
# a0 = catalog_hdr
# a1 = index
returnBookAt:
	#retrieve book from catalog array
	lw $t0, 0($a0) #$t0 holds data_ptr of catalog_hdr
	sll $t1, $a1, 2 #$a1 = 4 * index
	add $t1, $t1, $t0 #$t1 holds address of indexed book's slot
	lw $t1, 0($t1) #$t1 holds address of indexed book
	
	#retrieve status of book
	lw $t2, 12($t1) #$t2 = status

	#check if available (status == 0)
	beq $zero, $t2, print_alr_avlb #if status == 0 branch to print_alr_avlb
	
	#if not already available mark the book as available
	lw $t2, 12($t1) #retrieve borrower's name to $t2
	sw $zero, 12($t1) #book's status = 0(available) #mark the book as available
	
	#jump to print_returned
	j print_returned
	
#print 'Already available: <Title>'
print_alr_avlb:
	#print: 'Already available: '
	li $v0, 4 #syscall 4 for print string
	la $a0, msg_already_avail #address of string as argument
	syscall
	
	#print book's title
	li $v0, 4 #syscall 4 for print string
	lw $a0, 4($t1) #$t1(book's address) + 4 offset = book's title
	syscall
	
	#print new line
	li $v0, 4
    	la $a0, nl
   	syscall
	
	#jump to return address
	jr $ra

#print 'Returned: <Title> <- <Name>'
print_returned:
	#print: 'Returned: <Title> '
	li $v0, 4 #syscall 4 for print string
	la $a0, msg_returned #address of string as argument
	syscall
	
	#print book's title
	li $v0, 4 #syscall 4 for print string
	lw $a0, 4($t1) #$t1(book's address) + 4 offset = book's title
	syscall
	
	#print "<-"
	li $v0, 4 #syscall 4 for print string
	la $a0, left_arrow #address of left arrow as argument
	syscall

	#print borrower's name
	li $v0, 4 #syscall 4 for print string
	move $a0, $t2 #$t2 = borrower's name
	syscall
	
	#print new line
	li $v0, 4
    	la $a0, nl
   	syscall
	
	#jump to return address
	jr   $ra

# ====================== printBookList (calls printBook) ======================
# a0 = catalog_hdr
printBookList:
	#make room for 16 bytes(4 words) in stack
	addi $sp, $sp, -16
	
	#store $ra, $s0, $s1, $s2 in the stack
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	
	#print '===== BOOK CATALOGUE ====='
    	move $t0, $a0 #temporarily save catalog_hdr on $t0
		
		#print new line
    	li $v0, 4
    	la $a0, nl
    	syscall

    	li $v0, 4 #syscall 4 for print string
    	la $a0, msg_catalog_header #address of string as argument
    	syscall
    	
	#print new line
    	li $v0, 4
    	la $a0, nl
    	syscall
	
	move $a0, $t0 #restore catalog_hdr 
	
	
	#retrieve count and data_ptr
	lw $s1, 0($a0) #retrieve  data_ptr
	lw $s2, 8($a0) #retrieve count
	
	#assign loop counter to 0
	move $s0, $zero #$s0(loop counter) = 0
	
#loop
loop:
	#check loop counter == count if so end loop
	beq $s0, $s2, end_loop
	
	#get address of the count indexed book
	sll $t0, $s0, 2 #$t2 = 4 * count
	add $t0, $t0, $s1 # t2 = data_ptr + (4 * count) #$t2 hold's indexed book's slot
	lw $a0, 0($t0) #$a0 = address of indexed book to pass as an argument
	
	#function call printBook with indexed book passed as argument
	jal printBook
	
	#increment loop counter
	addi $s0, $s0, 1 #$s0 += 1
	
	#jump to loop
	j loop
	
end_loop:
	#restore $ra, $s0, $s1, $s2 from the stack
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)

	#remove 4 words from stack
	addi $sp, $sp, 16

	#print new line
    	li $v0, 4
    	la $a0, nl
    	syscall
	
	jr   $ra


# ====================== printBook (calls printCategories & printWaitlist) ======================
# a0 = book*
printBook:
	#make room for 24 bytes(12 words) in stack
	addi $sp, $sp, -24
	
	#store $ra, $s0, $s1, $s2, $s3, $s4 in the stack
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	
	#put book's pointer to $s0
	move $s0, $a0 #$now $s0 holds book's pointer
	
	#retrieve title, id, year and status of book
	lw $s1, 4($s0) #retrieve title
	lw $s2, 0($s0) #retrieve id
	lw $s3, 8($s0) #retrieve year
	lw $s4, 12($s0) #retrieve status
	
	#print the book’s details (Title, ID, Year, Status)
	#print 'Title: '
	li $v0, 4 #syscall 4 for print string
    	la $a0, msg_title #address of string as argument
    	syscall

	#print book's title
	li $v0, 4 #syscall 4 for print string
	move $a0, $s1 #$s1 = book's title
	syscall
	
	#print new line
    	li $v0, 4
    	la $a0, nl
    	syscall
	
	#print 'ID: '
	li $v0, 4 #syscall 4 for print string
    	la $a0, msg_id #address of string as argument
    	syscall
	
	#print book's ID
	li $v0, 1 #syscall 4 for print integer
	move $a0, $s2 #$s2 = book's ID
	syscall
	
	#print 'Year: '
	li $v0, 4 #syscall 4 for print string
    	la $a0, msg_year #address of string as argument
    	syscall

	#print book's year
	li $v0, 1 #syscall 1 for print year
	move $a0, $s3 #$s3 = book's year
	syscall
	
	#print new line
    	li $v0, 4
    	la $a0, nl
    	syscall

	#print status 
	#if status = 0 print 'Available'
	#if already loaned print 'On Loan to <Name>'
	beq $s4, $zero, print_available #if status = 0 branch to print_available

	j print_on_loan#if status != 0 branch to print_on_loan

print_available:
	#print 'Status: '
	li $v0, 4 #syscall 4 for print string
    	la $a0, msg_status #address of string as argument
    	syscall
	
	#print 'Available'
	li $v0, 4 #syscall 4 for print string
    	la $a0, msg_avail #address of string as argument
    	syscall

	#jump to call_funcs_in_print_book
	j call_funcs_in_print_book

print_on_loan:
	#print 'Status: '
	li $v0, 4 #syscall 4 for print string
    	la $a0, msg_status #address of string as argument
    	syscall
	
	#print 'On Loan to'
	li $v0, 4 #syscall 4 for print string
    	la $a0, msg_loan #address of string as argument
    	syscall

	#print loaner's name
	li $v0, 4 #syscall 4 for print string
	move $a0, $s4 #$s4 = loaner's name
	syscall

	#print new line
    	li $v0, 4
    	la $a0, nl
    	syscall

call_funcs_in_print_book:
	#call printCategories
	lw $a0, 16($s0) #set cat_hdr as argument
	jal printCategories #function call to printCategories
	
	#call printWaitlist
	lw $a0, 20($s0) #set waitlist_head as argument
	jal printWaitlist #function call to printWaitlist

	#print '---------------------------'
	li $v0, 4 #syscall 4 for print string
    	la $a0, msg_separator #address of string as argument
    	syscall
	
	#print new line
    	li $v0, 4
    	la $a0, nl
    	syscall

	#restore stack
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)

	#remove 6 words from stack
	addi $sp, $sp, 24
	
	#jump to return address
	jr $ra


# ====================== printCategories(category_hdr*) ======================
# a0 = category_hdr
printCategories:
	#save $s0 on the stack for further use of $s0
	addi $sp, $sp, -4
	sw $s0, 0($sp)

	#retrieve category array's count
	lw $t0, 8($a0) #$t0 holds count

	#if count == 0 branch to print_empt_cat
	beq $t0, $zero, print_empt_cat 

	#retrieve array's data pointer(0th indexed item)
	lw $t1, 0($a0)
	
	#set loop counter to 0	
	move $s0, $zero
	
	#print 'Categories: '
	li $v0, 4 #syscall 4 for print string
    	la $a0, msg_categories #address of string as argument
    	syscall

print_cats_loop:
	
	sll $t2, $s0, 2 #$t2 = 4 * loop counter
	add $t2, $t2, $t1 #now $t2 holds indexed element's address
	
	#retrieve the name of category
	lw $t3, 0($t2)

	#print name of category
	li $v0, 4 #syscall 4 for print string
    	move $a0, $t3 #a0 now holds name
    	syscall
	
	#increment loop counter
	addi $s0, $s0, 1

	#if count = loop counter exit loop
	beq $t0, $s0, exit_loop
	
	#print ', '
	li $v0, 4 #syscall 4 for print string
    	la $a0, comma_space #address of string as argument
    	syscall
	
	#jump to loop
	j print_cats_loop

exit_loop:
	#print new line
    	li $v0, 4
    	la $a0, nl
    	syscall

	#restore stack
    	lw $s0, 0($sp)
    	addi $sp, $sp, 4

	#jump to return address
	jr $ra

print_empt_cat:
	#print 'Categories: (none)'
	#print 'Categories: '
	li $v0, 4 #syscall 4 for print string
    	la $a0, msg_categories #address of string as argument
    	syscall
	
	#print '(none)'
	li $v0, 4 #syscall 4 for print string
    	la $a0, msg_nonecats #address of string as argument
    	syscall

	#restore stack
    	lw $s0, 0($sp)
    	addi $sp, $sp, 4
	
	#jump to return address
	jr   $ra


# ====================== printWaitlist(waitlist_head*) ======================
# a0 = head (node* or 0)
printWaitlist:
	#save head on temp register
	move $t0, $a0

	#print 'Waitlist: '
	li $v0, 4 #syscall 4 for print string
    	la $a0, msg_wait #address of string as argument
    	syscall
	
	#check if waitlist empty
	beq $t0, $zero, print_wl_empty #if so branch to print_wl_empty

print_wl_loop:
	#print the name
	li $v0, 4 #syscall 4 for print string
    	lw $a0, 0($t0) #a0 now holds name
    	syscall
	
	#go to next node
	lw $t0, 4($t0) #$t0 holds now the next node
	
	#check if node is empty(we havereached to end)
	beq $t0, $zero, exit_wl_loop #if we reached the end exit the loop
	
	#print "->"
	li $v0, 4 #syscall 4 for print string
	la $a0, arrow #address of right arrow as argument
	syscall
	
	#jump to loop
	j print_wl_loop

exit_wl_loop:
	#print new line
    	li $v0, 4
    	la $a0, nl
    	syscall

	#jump to return address
	jr   $ra

print_wl_empty:
	#print '(empty)'
	li $v0, 4 #syscall 4 for print string
    	la $a0, empty_wl #address of string as argument
    	syscall
	
	#jump to return address
	jr $ra


# ====================== MAIN ======================
main:
	# Create and fill the catalog
	jal  initBookArray
	move $s0, $v0

	jal  initCategoryArray
	move $s1, $v0
	move $a0, $s1
	la   $a1, c_prog
	jal  putOnCategory
	move $a0, $s1
	la   $a1, c_best
	jal  putOnCategory
	move $a0, $s1
	la   $a1, c_edu
	jal  putOnCategory
	li   $a0, 123
	la   $a1, t_clean
	li   $a2, 1999
	move $a3, $s1
	jal  createBook
	move $a0, $s0
	move $a1, $v0
	jal  addBook

	jal  initCategoryArray
	move $s1, $v0
	move $a0, $s1
	la   $a1, c_sys
	jal  putOnCategory
	move $a0, $s1
	la   $a1, c_edu
	jal  putOnCategory
	li   $a0, 55
	la   $a1, t_os
	li   $a2, 2014
	move $a3, $s1
	jal  createBook
	move $a0, $s0
	move $a1, $v0
	jal  addBook

	jal  initCategoryArray
	move $s1, $v0
	move $a0, $s1
	la   $a1, c_net
	jal  putOnCategory
	move $a0, $s1
	la   $a1, c_edu
	jal  putOnCategory
	li   $a0, 310
	la   $a1, t_net
	li   $a2, 2011
	move $a3, $s1
	jal  createBook
	move $a0, $s0
	move $a1, $v0
	jal  addBook

	# Set up waitlists
	move $a0, $s0
	li   $a1, 0
	la   $a2, p_Alice
	jal  putOnWaitlistAt
	move $a0, $s0
	li   $a1, 0
	la   $a2, p_Bob
	jal  putOnWaitlistAt
	move $a0, $s0
	li   $a1, 0
	la   $a2, p_Charlie
	jal  putOnWaitlistAt
	move $a0, $s0
	li   $a1, 0
	la   $a2, p_David
	jal  putOnWaitlistAt
	move $a0, $s0
	li   $a1, 0
	la   $a2, p_Emma
	jal  putOnWaitlistAt

	move $a0, $s0
	li   $a1, 1
	la   $a2, p_Jane
	jal  putOnWaitlistAt
	move $a0, $s0
	li   $a1, 1
	la   $a2, p_Grace
	jal  putOnWaitlistAt
	move $a0, $s0
	li   $a1, 1
	la   $a2, p_Henry
	jal  putOnWaitlistAt

	move $a0, $s0
	li   $a1, 2
	la   $a2, p_Jack
	jal  putOnWaitlistAt
	move $a0, $s0
	li   $a1, 2
	la   $a2, p_Kate
	jal  putOnWaitlistAt
	move $a0, $s0
	li   $a1, 2
	la   $a2, p_Liam
	jal  putOnWaitlistAt
	move $a0, $s0
	li   $a1, 2
	la   $a2, p_Isla
	jal  putOnWaitlistAt
	move $a0, $s0
	li   $a1, 2
	la   $a2, p_Frank
	jal  putOnWaitlistAt

	# Initial full view
	move $a0, $s0
	jal  printBookList

	# Batch A: checkout #0, checkout #1, return #2, then print once
	move $a0, $s0
	li   $a1, 0
	jal  checkoutBookAt
	move $a0, $s0
	li   $a1, 1
	jal  checkoutBookAt
	move $a0, $s0
	li   $a1, 2
	jal  returnBookAt
	move $a0, $s0
	jal  printBookList

	# Batch B: checkout #2, checkout #0, return #1, then print once
	move $a0, $s0
	li   $a1, 2
	jal  checkoutBookAt
	move $a0, $s0
	li   $a1, 0
	jal  checkoutBookAt
	move $a0, $s0
	li   $a1, 1
	jal  returnBookAt
	move $a0, $s0
	jal  printBookList

	# Batch C: return #0, checkout #1, checkout #2, then print once
	move $a0, $s0
	li   $a1, 0
	jal  returnBookAt
	move $a0, $s0
	li   $a1, 1
	jal  checkoutBookAt
	move $a0, $s0
	li   $a1, 2
	jal  checkoutBookAt
	move $a0, $s0
	jal  printBookList

	# Batch D: return #2, checkout #0, checkout #1, return #0, then print once
	move $a0, $s0
	li   $a1, 2
	jal  returnBookAt
	move $a0, $s0
	li   $a1, 0
	jal  checkoutBookAt
	move $a0, $s0
	li   $a1, 1
	jal  checkoutBookAt
	move $a0, $s0
	li   $a1, 0
	jal  returnBookAt
	move $a0, $s0
	jal  printBookList

	# Batch E: checkout #0, return #1, checkout #2, return #2, checkout #1, then print once
	move $a0, $s0
	li   $a1, 0
	jal  checkoutBookAt
	move $a0, $s0
	li   $a1, 1
	jal  returnBookAt
	move $a0, $s0
	li   $a1, 2
	jal  checkoutBookAt
	move $a0, $s0
	li   $a1, 2
	jal  returnBookAt
	move $a0, $s0
	li   $a1, 1
	jal  checkoutBookAt
	move $a0, $s0
	jal  printBookList

	# Batch F: final shuffle — return #0, checkout #0, checkout #2, return #1, checkout #1, then print once
	move $a0, $s0
	li   $a1, 0
	jal  returnBookAt
	move $a0, $s0
	li   $a1, 0
	jal  checkoutBookAt
	move $a0, $s0
	li   $a1, 2
	jal  checkoutBookAt
	move $a0, $s0
	li   $a1, 1
	jal  returnBookAt
	move $a0, $s0
    li   $a1, 1
    jal  checkoutBookAt
	move $a0, $s0
	jal  printBookList

	li   $v0, 10
	syscall