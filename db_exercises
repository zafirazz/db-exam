select *
from carmechanic.m_mechanic;
Balla Erik

List the mechanics who are younger than Balla Erik mechanic;
select *
from carmechanic.m_mechanic
where birth_date>(select birth_date from carmechanic.m_mechanic
      where m_name='Balla Erik');
      
hr.employee;
Who is the boss of Kimberly Grant;

select *
from hr.employees
where employee_id=(select manager_id from hr.employees
where first_name='Kimberely' and last_name='Grant');

List all employees (name )and their bosses if they have;
List should be sorted by the name of employees;

select emp.first_name||' '||emp.last_name, 
boss.first_name||' '||boss.last_name
from hr.employees emp left outer join
hr.employees boss
on emp.manager_id=boss.employee_id;

Which car (id, license_plate) was repaired the less times;

select c_id, license_plate_number, count(start_date) nu
from carmechanic.m_car ca left outer join 
carmechanic.m_repair re
on ca.c_id=re.car_id
group by c_id, license_plate_number
order by nu 
fetch first row with ties;

Which car was evaluated the less times?
select c_id, license_plate_number, count(evaluation_date) nu
from carmechanic.m_car ca left outer join 
carmechanic.m_car_evaluation eva
on ca.c_id=eva.car_id
group by c_id, license_plate_number
order by nu 
fetch first row with ties;

Which car (id, license_plate_number) has 
higher first_selling_price than 200% of its average evaluation price.;

select first_sell_price, avg(price), c_id, license_plate_number
from carmechanic.m_car ca join carmechanic.m_car_evaluation ceva
on ca.c_id=ceva.car_id
group by c_id, license_plate_number, first_sell_price
having first_sell_price>2*avg(price);

For each car (? evaluation) (id, license_plate) 
list the last evaluation (price, date);

select c_id, license_plate_number, evaluation_date, price
from carmechanic.m_car_evaluation ceva right outer join
carmechanic.m_car ca
on ca.c_id=ceva.car_id
where (car_id, evaluation_date) in (select car_id, max(evaluation_date)
                                    from carmechanic.m_car_evaluation
                                    group by car_id)
or car_id is null;

List all the cars (license_plate) with their last owner (name);

select c_id, license_plate_number, date_of_buy, o_id, o_name
from carmechanic.m_car ca left outer join 
    (select * from carmechanic.m_owns
     where (car_id, date_of_buy) in (select car_id, max(date_of_buy)
                                     from carmechanic.m_owns
                                     group by car_id)) ns
on ca.c_id=ns.car_id left outer join
carmechanic.m_owner ow
on ns.owner_id=ow.o_id;

Delete cars which color is red, black, or white, and which make is 'Opel';
create table e_car as select * from carmechanic.m_car;

delete--select *
from e_car 
where color in ('red', 'black', 'white')
and model_id in (select cm_id from carmechanic.m_car_model
                where make='Opel');
rollback;                

Delete the repair which was performed in the Kobela Bt. named workshop
on a car which color is ('red', 'black', 'white')
or which first_sell_price is more than 3M;

create table e_repair as select * from carmechanic.m_repair;

delete--select *
from e_repair
where car_id in (select c_id from carmechanic.m_car
                where color in ('red', 'black', 'white')
                or first_sell_price>3000000)
and workshop_id in (select w_id from carmechanic.m_workshop
                    where w_name='Kobela Bt.');
rollback;                    

Delete car_evaluations for the cars which was ever repaired in 'Kobela Bt.'
and where evaluation price is more 3M;

create table e_car_evaluation as select * from carmechanic.m_car_evaluation;     

delete--select *
from e_car_evaluation
where price>3000000
and car_id in (select car_id from carmechanic.m_repair
              where workshop_id in (select w_id from carmechanic.m_workshop
                    where w_name='Kobela Bt.'));
rollback;                    


create table e_works_for as select * from carmechanic.m_works_for;

delete
from e_works_for
where mechanic_id in (select m_id from carmechanic.m_mechanic
where address like 'Debrecen%')
and workshop_id in (select w_id from carmechanic.m_workshop
where w_name = 'Kobela Bt.');

rollback;

create table e_car_evaluations as select * from carmechanic.m_car_evaluation;

delete
from e_car_evaluations cev
where price > 0.8 *  (select first_sell_price 
                from carmechanic.m_car ca
                where cev.car_id = ca.c_id);

rollback;

create table e_repairs as select * from carmechanic.m_repair;

select * 
from e_repairs rep
where repair_cost < 0.1 * (select max(price)
                            from carmechanic.m_car_evaluation ev
                            where rep.car_id = ev.car_id);
                            
rollback;

select * 
from e_repairs
where (car_id ,start_date) in 
            (select car_id, max(start_date)
            from carmechanic.m_repair
            group by car_id);

delete
from e_repairs re
where start_date in 
            (select max(start_date)
            from carmechanic.m_repair r
            where re.car_id = r.car_id);  
rollback;

create table e_car as select * from carmechanic.m_car;

update e_car
set first_sell_price = first_sell_price * 0.1,
color = color || '!'
where model_id in 
        (select cm_id
        from carmechanic.m_car_model
        where make in ('Opel', 'Ford'));
select * from e_car;

rollback;

update e_repair
set repair_cost = repair_cost + 10 * (nvl(end_date, sysdate) - start_date)
where workshop_id in (select w_id from carmechanic.m_workshop
                        where w_name = 'Kobela Bt.');
rollback;

--increase repair cost by 1% of the first)sell)price of the car for the repairs which repaired the cars who has at least one owner from debrecen, and which
--were repaired in the workshop in which the youngest mechanics works.

update e_repair re
set repair_cost = repair_cost + (
            select 0.01 * first_sell_price 
            from carmechanic.m_car c
            where re.car_id = c.c_id)
where car_id in (select car_id from carmechanic.m_owns ow
                where owner_id in
                    (select o_id 
                        from carmechanic.m_owner
                        where address like 'Debrecen%'))
and workshop_id in (select workshop_id from carmechanic.m_works_for
                    where mechanic_id in (select m_id
                                        from carmechanic.m_mechanic
                                        order by birth_date desc null last
                                        fetch first row with ties));
rollback;

--increase repair cost by 10% of the cars last evaluation price for the cars which has less than three owners
--and for workshops whose manager lives in debrecen
update e_repair re
set repair_cost = repair_cost + 0.1 * (select price
                                from carmechanic.m_car_evaluation ev
                                where re.car_id = ev.car_id
                                order by evaluation_date desc nulls last
                                fetch first row with ties)
where car_id in
            (select car_id from carmechanic.m_owns ow
            group by car_id
            having count(owner_id) < 3)
and workshop_id in
            (select w_id from carmechanic.m_workshop
            where manager_id in (select m_id from carmechanic.m_mechanic
                                where address like 'Debrecen%'));
rollback;

--decrease the price of the last evaluation of the cars which has more than 10 repairs and which first sell price
--is more than 5M and which largest repair cost is more than 0.5M by 2% of the first sell price of the car.
update e_evaluation ev
set price = price - 0.02 * (select first_sell_price
                            from carmechanic.m_car
                            where c_id = ev.car_id)
where (car_id, evaluation_date) in (select car_id, max(evaluation_date)
                                        from carmechanic.m_car_evaluation
                                        group by car_id)
and car_id in (select car_id from carmechanic.m_repair
                group by car_id 
                having count(start_date)>10)
and car_id in (select c_id from carmechanic.m_car
                where first_sell_price > 5000000)
and car_id in (select car_id 
                from carmechanic.m_repair
                group by car_id 
                having max(repair_cost)>5000000);
