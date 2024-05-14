--list the name, address and tax number of mechanics who have ever had a salary less than tha
--of all mechanics who have ever worked for the workshop named 'Harmat Kft' Each mechanic
--should appear only once in the result
select distinct m.m_name, m.address, m.tax_number
    from carmechanic.m_mechanic m inner join carmechanic.m_works_for mw
        on m.m_id = mw.mechanic_id
    where mw.salary < all
        (select mw.salary
            from carmechanic.m_works_for  mw inner join carmechanic.m_workshop w
                on mw.workshop_id = w.w_id
                where w_name like 'Harmat%')
    group by m.m_name, m.address, m.tax_number;

select m_name,m.address,tax_number
from carmechanic.m_mechanic m
join carmechanic.m_works_for on m_id = mechanic_id
where salary < all
(select  salary
from carmechanic.m_mechanic
join carmechanic.m_works_for on m_id = mechanic_id
join carmechanic.m_workshop on w_id = workshop_id
where w_name = 'Harmat Kft.')
group by m_name,m.address,tax_number;
    
select sum(salary) from carmechanic.m_works_for mw inner join carmechanic.m_workshop w
on mw.workshop_id = w.w_id
where w.w_name like 'Harmat%'; --580000

--list all data of cars that were either first sold in 2006 or are of opel make
select *
    from carmechanic.m_car c inner join carmechanic.m_car_model cm
        on c.model_id = cm.cm_id
    where extract(year from c.first_sell_date) = 2006
    or cm.make = 'Opel'
    order by c_id asc;

select * 
from carmechanic.m_car
where extract(year from first_sell_date) = 2006
union
select a.*
from carmechanic.m_car a
join carmechanic.m_car_model on cm_id = model_id
where make = 'Opel';

select *
from carmechanic.m_car
where extract(year from first_sell_date) = 2006
or model_id in (select cm_id
                from carmechanic.m_car_model
                where make like '%Opel%')
                order by c_id asc;


--list all the lisence plate number of cars participating in the evaluations with
--the 10 lowest evaluation prices. Also give the evaluation prices along with the lpn
--sort the list desc by evaluation price
select license_plate_number, price   
    from 
        (select c.license_plate_number, ce.price
            from carmechanic.m_car_evaluation ce left outer join carmechanic.m_car c
                on ce.car_id = c.c_id
                order by ce.price asc
                fetch first 10 rows with ties
        )
    order by price desc;

--1.List the identifier of all workshops and the number of repairs in each workshop.
--Workshops with no repaires should also be included. 
--Sort the result descending by the number of repairs.
select workshop_id, count(c_id) as num_of_repairs
    from carmechanic.m_car left join carmechanic.m_repair
        on c_id = car_id
    group by workshop_id
    order by num_of_repairs desc;
    
--list the name of car owners who have never owned an opel car
select o_name
    from carmechanic.m_owner
    where o_id in
        (select owner_id
            from carmechanic.m_owns join carmechanic.m_car
                on car_id = c_id
            join carmechanic.m_car_model
                on model_id = cm_id
            where make not like 'Opel');
    
select o_name
from carmechanic.m_owner
minus
select o_name 
from carmechanic.m_owns
join carmechanic.m_owner on o_id = owner_id
where car_id  in (select c_id
from carmechanic.m_car_model
join carmechanic.m_car on model_id = cm_id
where make = 'Opel');

select distinct o_name
    from carmechanic.m_owner
        where o_id not in
            (select o.owner_id
                from carmechanic.m_owns o join carmechanic.m_car c
                    on o.car_id = c.c_id
                join carmechanic.m_car_model cm
                    on c.model_id = cm.cm_id
                where cm.make like 'Opel%');

--list all data of cars that have never been evaluated
select *
    from carmechanic.m_car c
    where c_id not in
        (select car_id
            from carmechanic.m_car_evaluation
            where evaluation_date is not null);

--3.List the license plate number of cars participating in the evaluations with the 10 lowest evaluation prices. 
--Also give the evaluation prices along with the license plate numbers.
--Sort the list descending by evaluation price.
select license_plate_number, price
    from (select license_plate_number, price
            from carmechanic.m_car c inner join carmechanic.m_car_evaluation ce
            on c.c_id = ce.car_id
            order by price asc
            fetch first 10 rows with ties)
    order by price desc;


--3.List the average evaluation price of cars of each model 
--where this average is one of the lowest three. 
--The models should be represented in the result by their identifiers.
select c.model_id
    from carmechanic.m_car c join carmechanic.m_car_evaluation ce
        on c.c_id = ce.car_id
    group by c.model_id
    order by avg(price)
    fetch first 3 rows with ties;

--6. List car models (with brand name and model name) to which at least one car evaluated belongs.
--Each model should appear only once in the result. Sort by brand then by model name
select distinct cm_name, make
    from carmechanic.m_car_model cm join carmechanic.m_car c
        on cm.cm_id = c.model_id
    where c.c_id in
        (select car_id
            from carmechanic.m_car_evaluation)
    order by make, cm_name;
    
select cm_name,make
from carmechanic.m_car_model
left join carmechanic.m_car on model_id = cm_id
left join carmechanic.m_car_evaluation on c_id = car_id
group by cm_id,cm_name,make
having count(car_id) >=1
order by make ,cm_name;
--7. List the license_plate_number of cars having repair with a cost greater than all repair
--cost of Toyota cars. Each license_plate_number should appear only once in the result
select distinct license_plate_number
    from carmechanic.m_car c join carmechanic.m_repair r
        on c.c_id = r.car_id
    where r.repair_cost > all
        (select repair_cost
            from carmechanic.m_repair join carmechanic.m_car
            on car_id = c_id
            join carmechanic.m_car_model
            on model_id = cm_id
            where make like 'Toyoata%');

--8. List the license_plate_number of cars having a repair cost less than any
--repair cost of suzuki car. Each lpn should appear only once
select distinct c.license_plate_number
    from carmechanic.m_car c join carmechanic.m_repair r
    on c.c_id = r.car_id
    where r.repair_cost < any --any
        (select repair_cost 
            from carmechanic.m_car c join carmechanic.m_repair r
            on c.c_id = r.car_id
            join carmechanic.m_car_model cm
            on c.model_id = cm.cm_id
            where cm.make like 'Suzuki%');

--9. List all data of cars that have never been evaluated?
select *
    from carmechanic.m_car
    where c_id not in
        (select car_id
            from carmechanic.m_car_evaluation);

--10. List the name and id of workshop where no mechanics from eger have ever worked
--the address of mechanic from eger starts with 'Eger'
select distinct w_name, w_id
    from carmechanic.m_workshop w left  join carmechanic.m_works_for mw
        on w.w_id = mw.workshop_id
    left join carmechanic.m_mechanic m
        on mw.mechanic_id = m.m_id
    where mw.mechanic_id not in 
        (select m_id
            from carmechanic.m_mechanic
            where address like 'Eger%');
--below solution is correct
select w_name, w_id
    from carmechanic.m_workshop
    where w_id not in
        (select w.w_id
            from carmechanic.m_workshop w join carmechanic.m_works_for mw
            on w.w_id = mw.workshop_id
            join carmechanic.m_mechanic m
            on mw.mechanic_id = m.m_id
            where m.address like 'Eger%');

--11. List all data of cars that have been owned someone living in Eger 
--and have been repaired in a workshop in Eger. Each car should appear only once.
select distinct *
    from carmechanic.m_car 
    where c_id in
        (select car_id
            from carmechanic.m_owns join carmechanic.m_owner
                on owner_id = o_id
                where address like 'Eger%')
    and c_id in
        (select car_id
            from carmechanic.m_repair join carmechanic.m_workshop
                on workshop_id = w_id
                where address like 'Eger%');

--12. list the lpn of cars participating in the evaluations with the evaluations with the
--highest 5 evaluation prices. Also give the evaluations price along with lpn
--sort the list desc by the evaluation price
select license_plate_number, price
    from carmechanic.m_car join carmechanic.m_car_evaluation
    on c_id = car_id
    where c_id in
        (select car_id
            from carmechanic.m_car_evaluation
            order by price desc
            fetch first 5 rows with ties)
    order by price desc
    fetch first 5 rows with ties;
    
select *   
    from
        (select license_plate_number, price
            from carmechanic.m_car join carmechanic.m_car_evaluation
                on c_id = car_id
                order by price desc
                fetch first 5 rows with ties)
order by price desc;

--13. List the total repair cost of cars of each model where this total cost is one of the 
--lowest five.The models should be represented in the result by their identifiers also 
--by their make and model names.
select sum(repair_cost), cm_id, cm_name, make
    from carmechanic.m_car join carmechanic.m_car_model
        on model_id = cm_id
    join carmechanic.m_repair
        on c_id = car_id
    group by cm_id, cm_name, make
    having sum(repair_cost) is not null
    order by sum(repair_cost)
    fetch first 5 rows with ties;
    

--14. List the avg evaluation price of cars of each model where this average is one
--of the lowest three, the models should be represented in the result by their identifiers
select avg(price), model_id
    from carmechanic.m_car join carmechanic.m_car_evaluation
        on c_id = car_id
    group by model_id
    order by avg(price) asc
    fetch first 3 rows with ties;
    
--15. List the mechanics with the two highest salaries who are currently working for 
--'Kobela Bt.' (i.e. whom the end of employement is not given) list only the mechanics
--name and salary, sorted desc by salary
select m_name, salary
    from carmechanic.m_mechanic join carmechanic.m_works_for
        on m_id = mechanic_id
    join carmechanic.m_workshop
        on workshop_id = w_id
    where end_of_employment is null
    and w_name = 'Kobela Bt.'
    order by salary desc
    fetch first 2 rows with ties;
    
--16. List the avg price of cars of each model where this avg price is one of the 
--lowest three.The models should be represented in the result by their identifiers also 
--by their make and model names.
select cm_id, cm_name, make, avg(price)
    from carmechanic.m_car join carmechanic.m_car_model
        on model_id = cm_id
    join carmechanic.m_car_evaluation
        on c_id = car_id
    group by cm_id, cm_name, make
    having avg(price) is not null
    order by avg(price) asc
    fetch first 3 rows with ties;

--17. List the license plate number of cars participating in the evaluations 
--with the 10 lowest evaluation price. Also give the evaluation prices along  with 
--the license plate numbers. Sort the list descending by evaluation price.
select *
    from 
        (select license_plate_number, price
            from carmechanic.m_car join carmechanic.m_car_evaluation
                on c_id = car_id
            order by price asc
            fetch first 10 rows with ties)
    order by price desc;

--CREATE TABLE--

--1. Create a table named 'relative' where the relatives of mechanics are stored. 
--the table should include the following columns with names:
--identifier (a string of exactly 10 chars - primary key)
--name (a string of at most 40 chars must not be null)
--date of birth
--mechanic connected to this person (int at most 5 digits with ref m_mechanic)
create table relative (
    identifier char(10 char) constraint pk_relative primary key,
    name varchar2(40 char) not null,
    gender varchar2(10char),
    date_of_birth date,
    mechanic number(5) constraint fk_relative references m_mechanic);

--2. Create table named 'insurance' including the following columns(with arbitrary names)
--insurance number - string 8 chars, primary key
--car id 0 int 5 digits
--owner id - int 5 digits
--owner email address - string 40 chars, not null
--start and end date of insurance date - date
--monthly cost - int 5 digits greater than 10000
--table should reference to the m_car and m_owner tables. Assign a name to each const
create table insurance (
    insurance_number varchar2(8 char) constraint pk_insurance primary key,
    car_id number(5),
    owner_id number(5),
    o_email varchar2(40 char) not null,
    start_date_of_insurance date,
    end_date_of_insurance date,
    monthly_cost number(5) constraint check_cost check(monthly_cost > 10000),
    constraint fk_car foreign key (car_id) references m_car(c_id),
    constraint fk_owner foreign key (owner_id) references m_owner(o_id)
);

--3. Some mechanics took part in a refresher training. Create table named training
--training id - string 10 char
--names - str 20 chars
--description - str 50 chars
--start/end dates of training - date
--cost - int 5
--mechanic id int 5 with ref to m_mechanic table 
--pk consists of taining id and mechanic id
create table training (
    training_id char(10 char),
    t_name varchar2(20 char),
    description varchar2(50 char),
    start_of_training date,
    end_of_training date,
    cost number(5),
    mechanic_id number(5),
    constraint pk_training primary key (training_id, mechanic_id),
    constraint fk_mechanic foreign key (mechanic_id) references m_mechanic(m_id)
);

--4. create a table work plan
--workday - date default sysdate
--mechanic int 5 reference to m mechanic table
--workshop int 5 reference to m workshop 
--pk workday and mechanic id
create table work_plan (
    workday date default sysdate,
    mechanic number(5),
    workshop number(5),
    constraint pk_work_plan primary key (workday, mechanic),
    constraint fk_1 foreign key (workshop) references m_workshop,
    constraint fk_2 foreign key (mechanic) references m_mechanic
);

--5. Add new column to your m_mechanic table. the new column should
--named bonus an int 6 and its value must be at least 2000
alter table m_mechanic
    add bonus number(6) check (bonus >= 2000);

--6. Delete the phone column from m_mechanic
alter table m_mechanic drop column phone;

--7. Delete the table m_owner and m_owns. Take into account the fk ref these tables
--you may use multiple statements to solve this take
drop table m_owner cascade constraints purge; 
--cascade constraints purge statement removes all constraints associated with the table
--that is dropped; it includes primary key, unique constraints, foreign key, check constraints
--it ensures that any constraints defined on the table and those that refs it are also dropped
drop table m_owns cascade constraints purge;

--8. Delete primary key constraint from m_owns table
alter table m_owns
    drop primary key;

--9. Delete tables m_works for and m_mechanic. Take into accout the fk refs these tables
--you may use multip;e statements to solve this task
drop table m_works cascade constraints purge;
drop table m_mechanic cascade constraints purge;

--10. Insert cars from the carmechanic schema into your m_car table that ever had an owner
--with last name 'Jakab ', and whose color either gray or blue 
insert into m_car (c_id, color, first_sell_date, first_sell_price, model_id, license_plate_number)
select *
    from carmechanic.m_car 
    where c_id in 
        (select car_id
            from carmechanic.m_owns join carmechanic.m_owner
            on o_id = owner_id
            where o_name like 'Jakab%')
    and color in ('gray', 'blue');

--11. Insert owners from carmechanic schema,a into your m_owner table who ever had a toyoata car
insert into m_owner
select *
    from carmechanic.m_owner join carmechanic.m_owns
        on o_id = owner_id
    join carmechanic.m_car
        on car_id = c_id
    where model_id in
        (select cm_id
            from carmechanic.m_car_model
            where make like 'Toyota%');

--12. Insert car models with no cars from the 'carmechanic' schema into your m_car_model
insert into m_car_model
select *
    from carmechanic.m_car_model left join carmechanic.m_car
        on cm_id = model_id
    where c_id is null;

--13. Insert car models with the string airbad in their details from the carmechanic
--into your m_car_model table
insert into m_car_model
select *
    from carmechanic.m_car_model
    where details like '%airbag%';
    
--14. Delete repairs of black cars that were finished in 2018
delete from m_repair
where extract(year from end_date) = 2018
and car_id in
    (select c_id
        from carmechanic.m_car
        where color = 'black');

--15. Delete the employment of all mechanics currently working in Kerekes Alex Szervize
--delete rows from the 'm_works_for' table that represent an employment at this workshop
--with unspecified end of employment
delete from m_works_for
    where end_of_employment is null and workshop_id in
        (select w_id
            from carmechanic.m_workshop join carmechanic.m_works_for
                on workshop_id = w_id
                where w_name like 'Kerekes Alex%'
);

--16. Delete car brands with no models in our database
delete from m_car_make
    where brand in
        (select brand from carmechanic.m_car
        minus
        select make from carmechanic.m_car_model);

--17. Increase by 10% the cost of repairs that were finished between jan 1 2018
--and march 31 2019 in workshop named Kobela Bt
update m_repair
set repair_cost = repair_cost * 1.1
where car_id in
    (select car_id
        from carmechanic.m_repair join carmechanic.m_workshop
        on workshop_id = w_id
        where w_name like 'Kobela%'
        and end_date >=date'2018-01-01'
        and end_date <= date'2019-03-31');

--18. Decrease the repair cost of the red and black cars by 10% of the car's first sell price
--if first sell price is null then repiar cost should be unchanged
update m_repair
set repair_cost = repair_cost - (0.1 * (select first_sell_price
from m_car 
where c_id = car_id 
and first_sell_price is not null))
where car_id in (
    select c_id from m_car 
    where color in ('red','black'));
    
--19. The workshop named 'Kerekes Alex Szervize' is closing down.(you may assume that there is 
--only one workshop with this name) due to this all started repairs must be finished.Set the 
--end date of each unfinished repair to current date and set the repair cost to number of 
--days since the start of the repair multiplied by 10% of the first sell price.
update m_repair
set end_date = sysdate,
repair_cost = (sysdate - start_date) * 0.1 * (select first_sell_price
from m_car)
where end_date is null
and workshop_id in
    (select w_id
        from m_workshop 
        where w_name like 'Kerekes%')
and repair_cost is null; --unnecessary


--20. The youngest mechanic moves in to the oldest. Update the address of the youngest
 --mechanic accordingly.(you may assume that there is only one youngest and one oldest 
 --mechanic)
 update m_mechanic
 set address = (select address from m_mechanic where birth_date is not null order by birth_date asc fetch first row only)
where birth_date = (select max(birth_date) from m_mechanic);
 
--21. Increase the price of car evaluations that took place after 2011 and involved a
--Hyundai or Suzuki car by 20% of the car's first-sell price.
update m_car_evaluation
set price = price + ((select first_sell_price from m_car where c_id = car_id) * 0.2)
where extract(year from evaluation_date) > 2011
and car_id in
    (select c_id 
        from m_car join m_car_model
        on model_id = cm_id
        where make in ('Hyundai', 'Suzuki'));

--22. Create a view that shows the license plate number of the gray car(s) with 
--the highest first_sell price.
create view view1 as
select license_plate_number
from carmechanic.m_car
where color = 'gray'
and first_sell_price = (select max(first_sell_price) from carmechanic.m_car
where color = 'gray');

--23. Create a view that lists the name of car brands and model with no cars.
create view view2 as
select cm_name, make
from carmechanic.m_car_model left join carmechanic.m_car
on cm_id = model_id
group by cm_name, make, cm_id --in group by you should include cm_name, make and id always
having count(c_id) = 0;

--24. Create a view that lists the name and address of workshops in Debrecen, 
--with the  name and address of the workshop's manager if this manager does not
--live in Debrecen. Addresses in Debrecen start with 'Debrecen'.
create view view3 as
select w.w_name, w.address, m.m_name, m.address as mechanic_address
    from carmechanic.m_workshop w join carmechanic.m_mechanic m
        on w.manager_id = m.m_id
    where (w.w_name, w.address) in
        (select w_name, address
            from carmechanic.m_workshop
            where address like 'Debrecen%')
    and (m.m_name, m.address) not in
        (select m_name, address 
            from carmechanic.m_mechanic
            where address like 'Debrecen%');
--25. Create a view that lists the name of workshop managers ,the name of workshop they 
--manage and the name of workshop they ever worked for if these workshops are different 
--from the workshop they manage.
create view view4 as
select m.m_name, m.w_name as manager, a.w_name as mechanic
    from
        (select m_name, w_name, manager_id
            from carmechanic.m_workshop join carmechanic.m_mechanic 
                on m_id = manager_id) m left join
        (select m_name, w_name, m_id
            from carmechanic.m_mechanic join carmechanic.m_works_for
                on m_id = mechanic_id
            join carmechanic.m_workshop
                on w_id = workshop_id
            where m_id in
                (select manager_id from carmechanic.m_workshop)) a on m_id = manager_id
            and a.w_name != m.w_name;

--26. Create a view that shows the name of the workshop where the longest (finished) repair took place
--together with the duration of this repair in days.
create view longest_repair as
select w_name, (end_date - start_date) as total_days
    from carmechanic.m_repair join carmechanic.m_workshop
        on workshop_id = w_id
    where end_date is not null
    and (w_id, (end_date - start_date)) in
        (select workshop_id, (end_date - start_date) as total
            from carmechanic.m_repair
            where end_date is not null 
            order by total desc
            fetch first 1 row with ties);

--27.Create a view that lists the license plate number of all cars together with the
--name of their latest owners. If a car has no owner the string 'no owner'
--should appear next to their license plate number.
create view cars as
select license_plate_number, nvl(o_name, 'no owner')
    from 
        (select license_plate_number, o_name
            from carmechanic.m_car left join carmechanic.m_owns
                on c_id = car_id
            left join carmechanic.m_owner 
                on owner_id = o_id
            group by license_plate_number, o_name)
    order by 1;
--upper one is not correct
create view cars as
select lpn2, nvl(o_name, 'no owner') as owner_name
    from 
        (select car.c_id, car.license_plate_number lpn1, max(own.date_of_buy) as latest_date
            from carmechanic.m_car car left join carmechanic.m_owns own
                on car.c_id = own.car_id
            group by car.c_id, car.license_plate_number) c
    left join
        (select c.license_plate_number lpn2, ow.o_name, o.date_of_buy dtb1
            from carmechanic.m_car c left join carmechanic.m_owns o
                on c.c_id = o.car_id
            left join carmechanic.m_owner ow
                on o.owner_id = ow.o_id) o
    on lpn1 = lpn2
    and latest_date = dtb1
    order by 1; --this seems to be more close to correct, still not sure tho

--28. Create a view that for each color, list the license_plate_number and first sell price
--of the cars with that color having the highest first sell price
create view color as --in this case, to include null colors we can use left join but
--it will return a lot of cars, to get only one with null color we can prolly use cases
--but we didn't cover it much and it won't be included in the exam
select car1.color, car1.license_plate_number, car1.first_sell_price
    from carmechanic.m_car car1
    join
        (select color, max(first_sell_price) first_sell_price
            from carmechanic.m_car
        group by color) car2
    on car1.color = car2.color
    and car1.first_sell_price = car2.first_sell_price;
--not my solution but it includes those cars that do not have color but i think 
--in that case there should be only one lpn --> solution is not entirely correct
select distinct a2,c1,b2 from
(select color a2 ,max(first_sell_price) b2
from carmechanic.m_car
group by color ) car
join
(select color a1,license_plate_number c1,first_sell_price b1
from carmechanic.m_car)
on a1 = a2 and b1=b2
or a2 is null and b2 = (select max(first_sell_price) b2
from carmechanic.m_car
where color is null);

--29.Create a view that lists the name of car makes and models with most cars
--in our database
create view makes as
select cm_name, make, count(c_id) as models
    from carmechanic.m_car join carmechanic.m_car_model
        on model_id = cm_id
    group by cm_id, cm_name, make
    having count(c_id) is not null
    order by models desc
    fetch first 1 row with ties;

select cm_name, make
    from 
        (select cm_name, make, count(c_id) car_count
            from carmechanic.m_car join carmechanic.m_car_model
                on model_id = cm_id
            group by cm_id, cm_name, make)
    where car_count in 
        (select max(car_count)
            from
                (select count(c_id) as car_count
                    from carmechanic.m_car join carmechanic.m_car_model
                        on model_id = cm_id
                    group by cm_id, make)
        );

--30. Create a view that shows the year(s) for which the most evaluations of cars
--with this first sell year took place 
create view view5 as
select distinct extract(year from evaluation_date) as year
    from carmechanic.m_car_evaluation
    where extract(year from evaluation_date) in
        (select extract(year from first_sell_date) as year_first_sell
            from carmechanic.m_car
            group by extract(year from first_sell_date)
            having count(*) is not null
            order by count(*) desc
            fetch first 1 row with ties);
            
--on exam read qs carefully cuz this poor fcking wording from panovics makes me wanna kms

--31. Create a view for each workshops shows the car model(s) involved in the most
--repair in that workshop. Both the workshops and the car models should be represented
--by id in the view
--create view view7 as
select r.model_id, workshop_id
    from
        (select workshop_id as w1, max(repair_count) as max_repair_count
            from 
                (select workshop_id, model_id, count(*) as repair_count
                    from carmechanic.m_repair join carmechanic.m_car
                        on car_id = c_id
                    group by workshop_id, model_id) rc
            group by workshop_id) max_count
    join
        (select workshop_id as w2, model_id, count(*) as repair_count
            from carmechanic.m_repair join carmechanic.m_car
                on car_id = c_id
            group by workshop_id, model_id) r
    on w1 = w2
    and max_repair_count = repair_count; 
--i gave up here below is not my solution
--create view view2 as
select distinct a1,model_id from 
(select workshop_id a1,max(cnt) b1
from (select workshop_id,model_id,count(*) cnt
from carmechanic.m_car
join carmechanic.m_repair on c_id = car_id
group by workshop_id,model_id)
group by workshop_id)
join
 (select workshop_id a2,model_id,count(*) b2
from carmechanic.m_car
join carmechanic.m_repair on c_id = car_id
group by workshop_id,model_id)
on a1 = a2 and b1 = b2
or a1 is null and b1= (select max(cnt) 
from (select workshop_id,model_id,count(*) cnt
from carmechanic.m_car
join carmechanic.m_repair on c_id = car_id
group by workshop_id,model_id)
group by workshop_id);
--32. Grant select privilege to the user named 'dzsoni' on your 'm_mechanic' table.
grant select on m_mechanic to dzsoni;

--33. Crant insert and update privileges to the user names 'dzsoni' on your 'm_mechanic' table
grant insert, update on m_mechanic to dzsoni;

--34. Grant all privileges to all users on your 'm_car' table.
grant all privileges to public; --pulbic is all

--35. Revoke the SELECT priviledge from the user named 'dzsoni' on your 'm_mechanic' table.
revoke select on m_mechanic from dzsoni;

--36. Revoke all privileges from all users on your 'm_car' table
revoke all privileges on m_car from public;
