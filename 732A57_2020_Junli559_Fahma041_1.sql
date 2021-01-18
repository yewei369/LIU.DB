/*Project, Jun Li (junli559) and Fahed Maqbool (Fahma041)*/
## show tables;
## drop table if exists jbemployee,jbstore cascade;

## drop table IF EXISTS ; 
## DROP PROCEDURE IF EXISTS proc_name



/*2)Create your tables and foreign keys in the database using the CREATE TABLE and if necessary the ALTER TABLE queries. 
Once you are done the database should have the same structure as shown in your relational model. 
Also, read up on how attributes can be automatically incremented and implement where appropriate.*/
drop table if exists weekday_fac cascade;
drop table if exists route_price cascade;
drop table if exists profit_fac cascade;
drop table if exists ticket cascade;
drop table if exists reserved cascade;
drop table if exists passenger cascade;
drop table if exists booking cascade;
drop table if exists card cascade;
drop table if exists reserver cascade;
drop table if exists reservation cascade;
drop table if exists contact cascade;
drop table if exists flight cascade;
drop table if exists weekly_schedule cascade;
drop table if exists route cascade;
drop table if exists airport cascade;
drop table if exists customer cascade;


create table airport(code varchar(3) not null,
					 name varchar(30),
                     country varchar(30),
                     constraint pk_airport primary key(code));
create table route(name varchar(30) not null,
				   departure varchar(3),
                   arrival varchar(3),
                   constraint pk_route primary key(name),
                   constraint fk_route_de foreign key (departure) references airport(code),
                   constraint fk_route_arr foreign key (arrival) references airport(code));
create table weekly_schedule(id varchar(10), 
							 route varchar(30), 
                             year int, 
                             day varchar(10), 
                             time TIME,
                             constraint pk_weekly_schedule primary key (id),
                             constraint fk_weekly_schedule foreign key (route) references route(name));
create table flight(number int,
					id varchar(10), 
                    week varchar(10),
                    constraint pk_flight primary key (number),
                    constraint fk_flight foreign key (id) references weekly_schedule(id));
create table reservation(reservation_nr int, 
						 contact varchar(10), 
                         flight_nr int, 
                         passenger_nr int,
                         constraint pk_reservation primary key (reservation_nr),
                         constraint fk_reservation_fli foreign key (flight_nr) references flight(number));
create table reserver(id varchar(10), 
					  reservation_nr int,
                      constraint pk_reserver primary key(id),
                      constraint fk_reserver_reserv foreign key(reservation_nr) references reservation(reservation_nr));                         
create table booking(booking_nr int, 
					 card_nr bigint, 
                     reservation_nr int, 
                     price float,
                     constraint pk_booking primary key(booking_nr));
create table card(card_nr bigint,
				  card_holder varchar(30),
                  constraint pk_card primary key(card_nr));
create table contact(id varchar(10), 
					 phone bigint, 
                     email varchar(30),
                     constraint pk_contact primary key(id));
create table passenger(id varchar(10), 
					   passport_nr int,
                       constraint pk_passenger primary key(id));
create table customer(id varchar(10), 
					  first_name varchar(30), 
                      after_name varchar(30),
                      constraint pk_customer primary key(id));
### Added below in version 1
create table reserved(reservation_nr int, 
                    passenger varchar(10),
                    constraint pk_ticket primary key(reservation_nr,passenger),
                    constraint fk_reserved_reservation foreign key (reservation_nr) references reservation(reservation_nr),
                    constraint fk_reserved_passenger foreign key (passenger) references passenger(id));
### Added above in version 1


create table ticket(ticket_nr int, 
					booking_nr int, 
                    passenger varchar(10),
                    constraint pk_ticket primary key(ticket_nr),
                    constraint fk_ticket_book foreign key (booking_nr) references booking(booking_nr),
                    constraint fk_ticket_passenger foreign key (passenger) references passenger(id));
create table profit_fac(year int, 
						profit_fac double,
                        constraint pk_profitfac primary key(year));                   
create table route_price(year int, 
						 route varchar(30), 
                         route_price double,
                         constraint pk_routeprice primary key(year,route), 
                         constraint fk_routeprice_year foreign key(year) references profit_fac(year)
                         #constraint fk_routeprice_route foreign key(route) references route(name)
                         );
create table weekday_fac(year int, 
						 weekday varchar(10), 
                         weekday_fac double,
                         constraint pk_weekdayfac primary key(year,weekday), 
                         constraint fk_weekdayfac foreign key(year) references profit_fac(year));

alter table reservation add constraint fk_reservation_contact foreign key(contact) references contact(id);
alter table reserver add constraint fk_reserver_id foreign key(id) references customer(id);
alter table booking add constraint fk_booking foreign key (card_nr) references card(card_nr);
alter table contact add constraint fk_contact foreign key(id) references customer(id);
alter table passenger add constraint fk_passenger foreign key(id) references customer(id);

#show tables;

/*3)    */ 
drop procedure if exists addYear;
drop procedure if exists addDay;
drop procedure if exists addDestination;
drop procedure if exists addRoute;
drop procedure if exists addFlight;

## a) Insert a year: Procedure call: addYear(year, factor);
delimiter //
create procedure addYear(in year int, in factor double)
begin
insert into profit_fac values (year, factor);
end;
//
delimiter ;

## b) Insert a day: Procedure call: addDay(year, day, factor);
delimiter //
create procedure addDay(in year int, in day varchar(10), in factor double)
begin
insert into weekday_fac values (year, day, factor);
end;
//
delimiter ;

## c) Insert a destination: Procedure call: addDestination(airport_code, name, country);
delimiter //
create procedure addDestination(in airport_code varchar(3), in name varchar(30), in country varchar(30))
begin
insert into airport values (airport_code, name, country);
end;
//
delimiter ;

## d) Insert a route: Procedure call: addRoute(departure_airport_code, arrival_airport_code, year, routeprice);
delimiter //
create procedure addRoute(in departure_airport_code varchar(3), in arrival_airport_code varchar(3), in year int, in routeprice double)
begin
if not exists (select * from route where name=concat(departure_airport_code,'-',arrival_airport_code)) then
	insert into route values (concat(departure_airport_code,'-',arrival_airport_code), departure_airport_code, arrival_airport_code); 
end if;
insert into route_price values (year, concat(departure_airport_code,'-',arrival_airport_code), routeprice);
end;
//
delimiter ;

## e) Insert a weekly flight: Procedure call: addFlight(departure_airport_code, arrival_airport_code, year, day, departure_time); 
##   Note that this procedure should add information in both weeklyflights and flights (you can assume there are 52 weeks each year).
delimiter //
create procedure addFlight(in departure_airport_code varchar(3), in arrival_airport_code varchar(3), in year int, in day varchar(10), in departure_time TIME)
begin 
	declare ind int default 1;
	declare temp varchar(10) default (select count(*) from weekly_schedule) ;  ## new weekly_schedule
    declare temp1 int;  ## new flight number
	insert into weekly_schedule values (temp, concat(departure_airport_code,'-',arrival_airport_code), year, day, departure_time);

    while ind<53 do  ## begin for loop
		set temp1=(select count(*) from flight);
		insert into flight values (temp1,temp,ind);
		set ind=ind+1;
	end while; ## end for loop
end;
//
delimiter ;

#show tables;
#select * from flight;

/*4)  Write two help-functions that do some of the calculations necessary for the booking procedure:*/ 
drop function if exists calculateFreeSeats;
drop function if exists calculatePrice;

## a) Calculate the number of available seats for a certain flight: Function call: calculateFreeSeats(flightnumber); 
## where the output is the number of free (unpaid) seats (i.e. an integer) on that certain flight.
delimiter //
create function calculateFreeSeats(flightnumber int)
returns int
begin
declare seat int;  ## free seats
declare cou int;   ## count of paid seats

set cou=(select sum(R.passenger_nr) from reservation R,booking B
							  where R.flight_nr=flightnumber and 
									B.reservation_nr=R.reservation_nr and
                                    B.card_nr is not null);


if cou>0 then 
set seat=(40-cou );
else
set seat=40;
end if;

return seat;
end;
//
delimiter ;
## b) Calculate the price of the next seat on a flight: Function call: calculatePrice(flightnumber); 
## where the output is the price (i.e. a double) of the next seat calculated as shown in 1e.
delimiter //
create function calculatePrice(flightnumber int)
returns double
begin
declare routeprice double;
declare weekdayfac double; 
declare profitfac double;
declare yr int; ## year of flight

set yr=(select W.year from weekly_schedule W,flight F where W.id=F.id and F.number=flightnumber);
set routeprice= (select R.route_price
				  from route_price R, flight F, weekly_schedule S
				  where F.number=flightnumber and F.id=S.id and R.route=S.route and R.year=S.year);
set weekdayfac=(select W.weekday_fac
				  from weekday_fac W, flight F, weekly_schedule S
				  where F.number=flightnumber and F.id=S.id and W.weekday=S.day and W.year=S.year);
set profitfac=(select P.profit_fac
				  from profit_fac P, flight F, weekly_schedule S
				  where F.number=flightnumber and F.id=S.id and S.year=P.year);
                  
                  
if yr=2010 then 
	return round(routePrice*weekdayfac*(41-calculateFreeSeats(flightnumber))/40*profitfac);
else return round(routePrice*weekdayfac*(41-calculateFreeSeats(flightnumber))/40*profitfac,3);
end if;
end;
//
delimiter ;





/*5) Create a trigger that issues unique unguessable ticket-numbers (of type integer) for each passenger on a reservation 
once it is paid. An appropriate MySQL function to find unguessable numbers is rand().   */ 
drop trigger if exists generate_ticketnumber;

create trigger generate_ticketnumber
before insert on ticket
for each row
set new.ticket_nr=rand();





/*6)  It is now time to write the stored procedures necessary for creating and handling a reservation from the front-end. 
In addition to the input and output detailed below, see the test-files for appropriate error-messages to return in case of unsuccessful payments etc.*/ 
drop procedure if exists addReservation;
drop procedure if exists addPassenger;
drop procedure if exists addContact;
drop procedure if exists addPayment;

/* a) Create a reservation on a specific flight. Procedure call: 
addReservation(departure_airport_code, arrival_airport_code, year, week, day, time, number_of_passengers, output_reservation_nr); 
where the number_of_passengers is the number of passengers the reservation is for (and only used to check that enough unpaid seats are available) and 
output_reservation_nr is an output-variable and should contain the assigned reservation number. */



delimiter //
create procedure addReservation(in departure_airport_code varchar(3), in arrival_airport_code varchar(3), 
								in year int, in week varchar(10), in day varchar(10), in time TIME, 
                                in number_of_passengers int, out output_reservation_nr int)
begin
declare temp0 int default (select count(*) from reservation); ## new reservation number
declare temp1 int;

declare num int; ## free seats
declare fl int;  ## flight number
set fl=(select F.number from flight F, weekly_schedule W
		where F.id=W.id and F.week=week and 
			  W.route=concat(departure_airport_code,'-',arrival_airport_code) and
			  W.year=year and W.day=day and W.time=time);
set num=calculateFreeSeats(fl);


if (select count(*) from weekly_schedule W
					where W.route=concat(departure_airport_code,'-',arrival_airport_code) and
						  W.year=year and W.day=day and W.time=time)>0 then  ## check if route is available
	if num>=number_of_passengers then
		



					select temp0 into output_reservation_nr;
					insert into reservation values (temp0,null,null,number_of_passengers);
					set temp1=(select F.number from route RT, weekly_schedule W, flight F
																		where RT.name=W.route and W.id=F.id and
																			  RT.departure=departure_airport_code and
																			  RT.arrival=arrival_airport_code and
																			  W.year=year and W.day=day and W.time=time and
																			  F.week=week);
					update reservation set flight_nr=temp1;
                    
		
	else select "There are not enough seats available on the chosen flight" as "message";
    end if;

else select "There exist no flight for the given route, date and time" as "message"; 
end if;
end;
//
delimiter ;

/*b) Add a passenger to a reservation: Procedure call to handle: addPassenger(reservation_nr, passport_number, name);*/
delimiter //
create procedure addPassenger(in reservation_nr int, in passport_number int, in name varchar(30))
begin
declare temp3 varchar(10) default (select count(*) from customer); ## new customer_nr

if (select count(*) from reservation R where R.reservation_nr=reservation_nr)>0 then
	if (select count(*) from booking B where B.reservation_nr=reservation_nr)=0 then
							

							#select SUBSTRING_INDEX(name, " ", 1) as firstname;
							#select SUBSTRING_INDEX(name, " ", -1) as lastname;

							insert into customer values (temp3, SUBSTRING_INDEX(name, " ", 1), SUBSTRING_INDEX(name, " ", -1));
							insert into passenger values (temp3, passport_number);
                            insert into reserved values (reservation_nr,temp3);
							
	else select "The booking has already been payed and no futher passengers can be added" as "message";
	end if;
else select "The given reservation number does not exist" as "message";
end if;
end;
//
delimiter ;


## select SUBSTRING_INDEX("HAHA LALA", " ", 1);

## booking(booking_nr, card_nr, reservation_nr, price)
## ticket(ticket_nr, booking_nr, passenger)

/*c) Add a contact: Procedure call to handle: addContact(reservation_nr, passport_number, email, phone); 
where the contact already must be added as a passenger to the reservation.*/
delimiter //
create procedure addContact(in reservation_nr int, in passport_number int, in email varchar(30), in phone bigint)
## in this DB design, passport info is not required for contact, thus it's not processed in this step; 
## instead first+last names are needed, but left NULL
## therefore, how to differentiate contact and passengers, in other words, how to decide if contact is also a passenger 
## is not defined/applicable in the scope. To simplyfy this issue, we assume here the contact is a new customer
begin
declare temp0 varchar(10) default (select count(*) from customer);

if (select count(*) from reservation R where R.reservation_nr=reservation_nr)>0 then
	if  (select count(*) from passenger where passport_nr=passport_number)>0  then
				insert into customer values (temp0,null,null);
				insert into contact values(temp0,phone,email);
				update reservation set contact=temp0 where reservation_nr=reservation_nr;
	else select "The person is not a passenger of the reservation" as "message";
    end if;
else select "The given reservation number does not exist" as "message";
end if;
end;
//
delimiter ;

## reservation,2 contact
## passenger<->contact, overlapp
## customer+passenger+contact, check

/*d) Add a payment: Procedure call to handle: addPayment (reservation_nr, cardholder_name, credit_card_number); 
This procedure should, if the reservation has a contact and there are enough unpaid seats on the plane, 
add payment information to the reservation and save the amount to be drawn from the credit card in the database. 
If the conditions above are not fulfilled the appropriate error message should be shown.  */ 
delimiter //
create procedure addPayment (in reservation_nr int, in cardholder_name varchar(30), in credit_card_number bigint)
begin

declare temp0 int; ## new booking number
declare temp1 int; ## flight number
declare temp2 int; ## passenger_nr
declare temp3 varchar(10) default (select count(*) from customer); ## new customer_nr
declare temp4 int default (select count(*) from ticket); ## new ticket number

declare num int; ## free seats
declare fl int;  ## flight number
set fl=(select flight_nr from reservation R where R.reservation_nr=reservation_nr);
set num=calculateFreeSeats(fl);

## insert rows in booking
set temp1=(select R.flight_nr from reservation R where R.reservation_nr=reservation_nr);
set temp2=(select R.passenger_nr from reservation R where R.reservation_nr=reservation_nr);

if (select count(*) from reservation R where R.reservation_nr=reservation_nr)>0 then
	if (select R.contact from reservation R where R.reservation_nr=reservation_nr) is not null then
		if num>=(select count(*) from reserved R where R.reservation_nr=reservation_nr) then
				
				if credit_card_number not in (select card_nr from card) then
					insert into card values (credit_card_number,cardholder_name);
				end if;
				
				set temp0=(select count(*) from booking);
                insert into booking values (temp0,credit_card_number,reservation_nr,calculatePrice(temp1)*temp2);
                
		else select "There are not enough seats available on the flight anymore, deleting reservation" as "message";
			 delete from reserved where reservation_nr=reservation_nr;
             delete from reservation where reservation_nr=reservation_nr;
        end if;
    else select "The reservation has no contact yet" as "message";
    end if;
else select "The given reservation number does not exist" as "message";
end if;
end;
//
delimiter ; 

#select * from reservation;

## card, check
## update booking card_nr, check   



/*7)  Create a view allFlights containing all flights in your database with the following information: 
departure_city_name, destination_city_name, departure_time, departure_day, departure_week, departure_year, nr_of_free_seats, current_price_per_seat. 
See the testcode for an example of how it can look like.   */ 

drop view if exists allFlights;
drop view if exists a;
drop view if exists b;
drop view if exists c;
drop view if exists d;
drop view if exists e;

create view a as (select R.departure as departure, R.arrival as arrival, 
								  W.time as departure_time, W.day as departure_day, 
                                  F.week as departure_week, W.year as departure_year, 
                                  F.number as flight_nr
						   from route R, 
                                weekly_schedule W, 
                                flight F
                           where F.id=W.id and
                                 W.route=R.name and
                                 F.id is not null and
                                 W.id is not null and
                                 R.name is not null);

create view b as (select a.flight_nr,calculateFreeSeats(flight_nr) num from a);
create view c as (select a.flight_nr,calculatePrice(flight_nr) pri from a);
                                 
create view d as (select a.flight_nr,A.name name from airport A right join a on A.code=a.departure);
create view e as (select a.flight_nr,A.name name from airport A right join a on A.code=a.arrival);         

create view allFlights as (select a.flight_nr, d.name departure_city_name, e.name destination_city_name,
								  a.departure_time, a.departure_day,
                                  a.departure_week, a.departure_year, 
								  b.num nr_of_free_seats, c.pri current_price_per_seat
						   from a,b,c,d,e
                           where a.flight_nr=b.flight_nr and
                                 a.flight_nr=c.flight_nr and
                                 a.flight_nr=d.flight_nr and
                                 a.flight_nr=e.flight_nr);



/*8)  Answer the following theoretical questions:
a) How can you protect the credit card information in the database from hackers?
* encrypt data stored in table card;
* all interactions with card should be implemented through stored procedures;
* no stored procedures should be written in dynamic SQL;
* no user should be considered as "safe"

b) Give three advantages of using stored procedures in the database (and thereby execute them on the server) instead of 
writing the same functions in the front-end of the system (in for example java-script on a web-page)?   
* avoid repeating the same coding when the program is adopted by several applications;
* data processed locally improve the communication efficiency, avoiding sending mass data from server to application terminal;
* can be used to check complex constraints

*/ 





/*9)  Open two MySQL sessions. We call one of them A and the other one B. Write START TRANSACTION; in both terminals.
a) In session A, add a new reservation.
b) Is this reservation visible in session B? Why? Why not?
   * this reservation is not visible in session B, since transactions conforms with isolation rule and they are not committed yet; 
     but after COMMIT comand, it will be visible from B.
c) What happens if you try to modify the reservation from A in B? Explain what happens and 
why this happens and how this relates to the concept of isolation of transactions.  
   * for example in session B it works well to add a contact after reservation commited in A, but not before commited, since these 
     transactions run in paralell, which is assured by the isolation rule and 2 transactions 
	 should appear they work in isolation.
*/ 

#START TRANSACTION;
#CALL addReservation("MIT","HOB",2010,1,"Monday","09:00:00",19,@z);
#select sleep(5);
#commit;
#select * from reservation;



/*10)  Is your BryanAir implementation safe when handling multiple concurrent transactions? Let two customers try to simultaneously book more seats than 
what are available on a flight and see what happens. This is tested by executing the testscripts available on the course-page using two different MySQL sessions. 
Note that you should not use explicit transaction control unless this is your solution on 10c.
a) Did overbooking occur when the scripts were executed? If so, why? If not, why not?
   *no, the overbooking does not occur, since there is a checking for free seat numbers in addReservation function where the booking can be made 
    only if the free seats are no less than reserved/booked quantity.


b) Can an overbooking theoretically occur? If an overbooking is possible, in what order must the lines of code in your procedures/functions be executed.
   yes, theoretically it is possible as long as
   * first the checking between free seats and reserved seats in function "addReservation" should be deleted;
   * when "start transaction" is not used, the goal is to make transactions from two sessions serializable. 
     In other words, operations in two schedules should run one after another to assure isolation rule. Here "select sleep(10);" 
	 is used between interacting different tables;
   * and locking/unlocking tables should be implemented in right order, so that two sessions can visit same tables after the other session
     has finished its work. But 2PL protocol should be paid attension to here.

c) Try to make the theoretical case occur in reality by simulating that multiple sessions call the procedure at the same time. 
To specify the order in which the lines of code are executed use the MySQL query SELECT sleep(5); 
which makes the session sleep for 5 seconds. Note that it is not always possible to make the theoretical case occur, if not, motivate why.
   *As explained above in section b), principles have been explored much with inbuilt command in MySQL. Due to current DB design, it is difficult 
    make overbooking happen in this case. According to 2PL one sessions should have finished its shedule when unlocking tables and give control to the other. 
    For example, in this DB
    -addReservation insert rows to reservation(reservation_nr,null,flight,passenger_nr);
    -addPassenger insert rows to booking(booking_nr,null,reservation_nr,price)
                                 ticket(ticket_nr,booking_nr,passenger)
                                 customer(id,first_name,last_name)
                                 with condition that given reservation_nr is included in table reservation but not in booking;
	-addContact insert rows to customer(id,null,null)
							   contact(id,phone,email)
				update relevant rows with reservation.contact;
	-addPayment insert rows to card(number,holder)
				update relevant rows with booking.card_nr
                with condition that free seat is no less than reserved seats
	

d) Modify the testscripts so that overbookings are no longer possible using (some of) the commands 
START TRANSACTION, COMMIT, LOCK TABLES, UNLOCK TABLES, ROLLBACK, SAVEPOINT, and SELECT…FOR UPDATE. 
Motivate why your solution solves the issue, and test that this also is the case using the sleep implemented in 10c. 
Note that it is not ok that one of the sessions ends up in a deadlock scenario. 
Also, try to hold locks on the common resources for as short time as possible to allow multiple sessions to be active at the same time.
* using "START TRANSACTION" in the begining, and "COMMIT" in the end, is already solving the overbooking problem.

  */ 




 
