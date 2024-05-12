--FOR TEST YOU HAVE TO KNOW MIN, COUNT, MAX, SUM
select count(price), min(price), max(price), sum(price), avg(price)
from book_library.books;
select COUNT(*) from BOOK_LIBRARY.books;
select COUNT(1) from BOOK_LIBRARY.book_items;
select 
    (select count(*) from book_library.books)
    * (select count(*) from book_library.book_items)
    from dual;
select count(*) from book_library.books, book_library.book_items;
select * from book_library.books cross join book_library.book_items;
select * from book_library.books, book_library.book_items
    where book_library.books.book_id = book_library.book_items.book_id;
--filtering results
select book_item_id, title, publisher, price, theoretical_value
    from book_library.books, book_library.book_items
    where book_library.books.book_id = book_library.book_items.book_id; 
--request all columns of one of the tables
SELECT book_library.book_items.*, title, publisher, price
    from book_library.books, book_library.book_items
    where book_library.books.book_id = book_library.book_items.book_id;
--the prev example can be written shorter
select book_items.*, title, publisher, price
    from book_library.books, book_library.book_items
    where books.book_id = book_items.book_id;
--it is also possible to use alias
select bi.*, title, publisher, price
    from book_library.books b, book_library.book_items bi
    where b.book_id = bi.book_id;
--join operators
select bi.*, title, publisher, price
    from book_library.books b join book_library.book_items bi
    on b.book_id = bi.book_id
    and title like 'N%';
--print the identifier and theoretical value of the book title And then there
--were none 
select book_item_id, theoretical_value
    from book_library.books natural join book_library.book_items 
    where title = 'And then there were none';
--how much royalty did Stephen King receive for each of his books? The books
--should be represented in the result by their id
select book_id, royalty
    from book_library.authors natural join book_library.writing
    where last_name = 'King' and first_name = 'Stephen';
--same but represent result by title
select title, royalty
    from book_library.authors natural join book_library.writing,
    book_library.books
    where last_name = 'King' and first_name = 'Stephen';
--who wrote book And then there were none
select last_name || ', ' || first_name author
    from book_library.authors natural join book_library.writing
    natural join book_library.books
    where title = 'And then there were none';
--list first and last names of students who currently have some books borrowed
--(return date is unkown) also include the titles of the borrowed books and the id of the copies
select last_name, first_name, title, book_item_id
    from book_library.customers join book_library.borrowing
    on library_card_number = customer_id
    natural join book_library.book_items
    join book_library.books using (book_id)
    where category = 'student' and bring_back_date is null;