--1 ex: list the id of all workshops and the number of repairs in each workshop. workshops
--with no repairs should also be included. sort desc by number of repairs
select w.w_id, r.repair_cost
    from carmechanic.m_workshop w natural join carmechanic.m_repair r
    order by r.repair_cost desc;

--2 ex: list the name and identifier of workshops where no mechanics from eger have ever worked.
--the address of mechanics from eger starts with 'eger'
select w.w_name, w.w_id
    from carmechanic.m_workshop w right join carmechanic.m_mechanic m
    on m.address not like 'Eger%' --when we are working with strings or chars to see equality use LIKE or NOT LIKE
    where w.w_name is not null;
--checking for ex2
select w.w_name, m.address 
    from carmechanic.m_workshop w right join carmechanic.m_mechanic m
    on m.address not like 'Eger%'
    where w.w_name is not null;

--3 ex: list the license plate number of cars participating in the evaluations with the 10 lowest
--evaluation prices, Also give the evaluation prices along with the lisence plate numbers
--Sort the list in descending by evaluation price.
select c.license_plate_number, e.price
    from carmechanic.m_car c right outer join carmechanic.m_car_evaluation e
    on c.c_id = e.car_id
    order by e.price desc
    fetch first 10 rows only;

--4 ex: list all data of cars that have been evaluated
select *
    from carmechanic.m_car c right join carmechanic.m_car_evaluation e
    on c.c_id = e.car_id
    where evaluation_date is not null;
--solution from last year
select *
    from carmechanic.m_car_evaluation e right outer join carmechanic.m_car c
    on e.car_id = c.c_id
    where c.c_id not in (
        select e.car_id
        from carmechanic.m_car_evaluation
    );

--5 ex: list all data of car with a name longer than 10 characters and unkown address sort by names
select *
    from carmechanic.m_car car left join carmechanic.m_car_model m
    on car.c_id = m.cm_id
    where length(car.cm_name) > 10 and m.details is null
    order by car.cm_name;
--6 ex: list all data of cars that have been owned by someone living in Eger
--and have been repaired in a workshop in eger
--each car should appear only once in the result
select *
    from carmechanic.m_owns own left outer join carmechanic.m_owner owner
    on own.owner_id = owner.o_id right outer join carmechanic.m_car car
    on car.c_id = own.car_id right outer join carmechanic.m_repair repa
    on car.c_id = repa.car_id right outer join carmechanic.m_workshop workshop
    on repa.workshop_id = workshop.w_id
    where workshop.address like 'Eger%'
    and owner.address like 'Eger%';

SELECT car.c_id, m.cm_name, br.brand
FROM carmechanic.m_car car 
RIGHT OUTER JOIN carmechanic.m_car_model m ON car.c_id = m.cm_id
RIGHT OUTER JOIN carmechanic.m_car_make br on br.brand is not null
where car.c_id is not null
ORDER BY car.c_id DESC;

--7 ex: list all data of cars that were either first sold in 2016 or opel make
select *
    from carmechanic.m_car car left join carmechanic.m_car_model model
    on car.model_id = model.cm_id
    where extract(year from first_sell_date) = 2016
    or model.make like 'Opel%';

--8 ex: list the name, address and phone number of all mechanics that sorted asc by their birth date start from yongest
select m_name, address, phone, birth_date
    from carmechanic.m_mechanic
    order by birth_date desc;

--9 ex: list the identifier of cars (together with their repair time in days)
--that were repaired for more than 30 days sort desc by repair cost
select car_id, (end_date - start_date) as days_repair
    from carmechanic.m_repair
    where end_date - start_date > 30
    order by repair_cost;

--10 ex: how many colours are there in our database? Sort the result by num of cars desc
select color, count(*)
    from carmechanic.m_car
    where color is not null
    group by color
    having count(*) >= 1
    order by count(*) desc;
    
--11 ex: list the name of owners who have never had an Opel before
select price from carmechanic.m_car_evaluation;