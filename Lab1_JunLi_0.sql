/*Lab 1, Jun Li (junli559)*/
# SOURCE company_schema.sql;
# SOURCE company_data.sql;

/*1) List all employees, i.e. all tuples in the jbemployee relation.*/
select * from jbemployee;
/*
id		name				salary	manager	birthyear	startyear
10		Ross, Stanley		15908	199		1927		1945
11		Ross, Stuart		12067	NULL	1931		1932
13		Edwards, Peter		9000	199		1928		1958
26		Thompson, Bob		13000	199		1930		1970
32		Smythe, Carol		9050	199		1929		1967
33		Hayes, Evelyn		10100	199		1931		1963
35		Evans, Michael		5000	32		1952		1974
37		Raveen, Lemont		11985	26		1950		1974
55		James, Mary			12000	199		1920		1969
98		Williams, Judy		9000	199		1935		1969
129		Thomas, Tom			10000	199		1941		1962
157		Jones, Tim			12000	199		1940		1960
199		Bullock, J.D.		27000	NULL	1920		1920
215		Collins, Joanne		7000	10		1950		1971
430		Brunet, Paul C.		17674	129		1938		1959
843		Schmidt, Herman		11204	26		1936		1956
994		Iwano, Masahiro		15641	129		1944		1970
1110	Smith, Paul			6000	33		1952		1973
1330	Onstad, Richard		8779	13		1952		1971
1523	Zugnoni, Arthur A.	19868	129		1928		1949
1639	Choy, Wanda			11160	55		1947		1970
2398	Wallace, Maggie J.	7880	26		1940		1959
4901	Bailey, Chas M.		8377	32		1956		1975
5119	Bono, Sonny			13621	55		1939		1963
5219	Schwarz, Jason B.	13374	33		1944		1959
*/

/*2) List the name of all departments in alphabetical order. Note: by “name” we mean
the name attribute for all tuples in the jbdept relation.*/
select name from jbdept;
/*
name
Bargain
Candy
Jewelry
Furniture
"Major Appliances"
Linens
Women's
Stationary
Book
Children's
"Junior Miss"
Toys
Men's
Sportswear
Women's
Junior's
Women's
Children's
Giftwrap
*/

/*3) What parts are not in store, i.e. qoh = 0? (qoh = Quantity On Hand)*/
select name from jbparts where qoh=0;
/*
name
"card reader"
"card punch"
"paper tape reader"
"paper tape punch"
*/

/*4) Which employees have a salary between 9000 (included) and 10000 (included)?*/ 
select id,name from jbemployee where salary>=9000 and salary<=10000;
/*
id	name
13	"Edwards, Peter"
32	"Smythe, Carol"
98	"Williams, Judy"
129	"Thomas, Tom"
*/

/*5) What was the age of each employee when they started working (startyear)?*/
select id,name,startyear-birthyear as age from jbemployee;
/*
id		name				age
10		Ross, Stanley		18
11		Ross, Stuart		1
13		Edwards, Peter		30
26		Thompson, Bob		40
32		Smythe, Carol		38
33		Hayes, Evelyn		32
35		Evans, Michael		22
37		Raveen, Lemont		24
55		James, Mary			49
98		Williams, Judy		34
129		Thomas, Tom			21
157		Jones, Tim			20
199		Bullock, J.D.		0
215		Collins, Joanne		21
430		Brunet, Paul C.		21
843		Schmidt, Herman		20
994		Iwano, Masahiro		26
1110	Smith, Paul			21
1330	Onstad, Richard		19
1523	Zugnoni, Arthur A.	21
1639	Choy, Wanda			23
2398	Wallace, Maggie J.	19
4901	Bailey, Chas M.		19
5119	Bono, Sonny			24
5219	Schwarz, Jason B.	15

*/

/*6) Which employees have a last name ending with “son”?*/
select id,name from jbemployee where name like "%son,%";
/*
id	name
26	Thompson, Bob
*/

/*7) Which items (note items, not parts) have been delivered by a supplier called
Fisher-Price? Formulate this query using a subquery in the where-clause.*/
select name from jbitem where supplier in (select id from jbsupplier where name="Fisher-Price");
/*
name
Maze
The 'Feel' Book
Squeeze Ball
*/

/*8) Formulate the same query as above, but without a subquery.*/
select I.name from jbitem I, jbsupplier S where I.supplier=S.id and S.name="Fisher-Price";
/*
name
Maze
The 'Feel' Book
Squeeze Ball
*/

/*9) Show all cities that have suppliers located in them. Formulate this query using a
subquery in the where-clause.*/
select name from jbcity where id in (select city from jbsupplier);
/*
name
Amherst
Boston
New York
White Plains
Hickville
Atlanta
Madison
Paxton
Dallas
Denver
Salt Lake City
Los Angeles
San Diego
San Francisco
Seattle
*/

/*10) What is the name and color of the parts that are heavier than a card reader?
Formulate this query using a subquery in the where-clause. (The SQL query must
not contain the weight as a constant.)*/ 
select name,color from jbparts where weight> (select weight from jbparts where name="card reader");
/*
name			color
disk drive		black
tape drive		black
line printer	yellow
card punch		gray
*/


/*11) Formulate the same query as above, but without a subquery. (The query must not
contain the weight as a constant.)*/
select A.name,A.color from jbparts as A, jbparts as B where A.weight>B.weight and B.name="card reader";
/*
name			color
disk drive		black
tape drive		black
line printer	yellow
card punch		gray
*/

/*12) What is the average weight of black parts?*/
select AVG(weight) from jbparts where color="black";
/*
AVG(weight)
347.2500
*/

/*13) What is the total weight of all parts that each supplier in Massachusetts (“Mass”)
has delivered? Retrieve the name and the total weight for each of these suppliers.
Do not forget to take the quantity of delivered parts into account. Note that one
row should be returned for each supplier.*/
select sum(S.quan*P.weight) sum, SP.name
from jbsupply S, jbparts P, jbsupplier SP, jbcity C
where 	 SP.city=C.id 
     and C.state="Mass"
	 and S.supplier=SP.id
	 and S.part=P.id
group by SP.name;
/*
sum		name
3120	DEC
1135000	Fisher-Price
*/

/*14) Create a new relation (a table), with the same attributes as the table items using
the CREATE TABLE syntax where you define every attribute explicitly (i.e. not
as a copy of another table). Then fill the table with all items that cost less than the
average price for items. Remember to define primary and foreign keys in your
table!*/
drop table if exists jbitem1 cascade; 
create table jbitem1 (id integer,
				name varchar(20),
                dept integer,
                price integer,
                qoh integer,
                supplier integer,
                constraint pk_item1 primary key (id));
alter table jbitem1 add constraint fk_item1_dept foreign key (dept) references jbdept(id);
alter table jbitem1 add constraint fk_item1_suppler foreign key (supplier) references jbsupplier(id);

insert into jbitem1 (select * from jbitem where price< (select avg(price) from jbitem));
/*
id	name			dept	price	qoh		supplier
11	Wash Cloth		1		75		575		213
19	Bellbottoms		43		450		600		33
21	ABC Blocks		1		198		405		125
23	1 lb Box		10		215		100		42
25	2 lb Box, Mix	10		450		75		42
26	Earrings		14		1000	20		199
43	Maze			49		325		200		89
106	Clock Book		49		198		150		125
107	The 'Feel' Book	35		225		225		89
118	Towels, Bath	26		250		1000	213
119	Squeeze Ball	49		250		400		89
120	Twin Sheet		26		800		750		213
165	Jean			65		825		500		33
258	Shirt			58		650		1200	33
*/

/*15) Create a view that contains the items that cost less than the average price for
items.*/
create view item_view as (select * from jbitem where price< (select avg(price) from jbitem));
select * from item_view;
/*
id	name			dept	price	qoh		supplier
11	Wash Cloth		1		75		575		213
19	Bellbottoms		43		450		600		33
21	ABC Blocks		1		198		405		125
23	1 lb Box		10		215		100		42
25	2 lb Box, Mix	10		450		75		42
26	Earrings		14		1000	20		199
43	Maze			49		325		200		89
106	Clock Book		49		198		150		125
107	The 'Feel' Book	35		225		225		89
118	Towels, Bath	26		250		1000	213
119	Squeeze Ball	49		250		400		89
120	Twin Sheet		26		800		750		213
165	Jean			65		825		500		33
258	Shirt			58		650		1200	33
*/


/*16) What is the difference between a table and a view? One is static and the other is
dynamic. Which is which and what do we mean by static respectively dynamic?*/
/*View is a virtual table and built on other table/tables, once data in the original tables
  changes, the data in view will change as well. Therefore, table is static and view is dynamic. */

/*17) Create a view that calculates the total cost of each debit, by considering price and
quantity of each bought item. (To be used for charging customer accounts). The
view should contain the sale identifier (debit) and total cost. Use only the implicit
join notation, i.e. only use a where clause but not the keywords inner join, right
join or left join,*/
drop view if exists sale_view cascade;
create view sale_view as 
select S.debit, sum(I.price*S.quantity) as total_cost from jbsale S, jbitem I 
where S.item=I.id
group by S.debit;
select * from sale_view;
/*
debit	total_cost
100581	2050
100582	1000
100586	13446
100592	650
100593	430
100594	3295
*/

/*18) Do the same as in (17), using only the explicit join notation, i.e. using only left,
right or inner joins but no join condition in a where clause. Motivate why you use
the join you do (left, right or inner), and why this is the correct one (unlike the
others).*/
/* jbdebit(item) and jbitem(id) are those attributes which needs exact matching to extract 
correct total cost, and right join will give NULL values since there are more items in jbitem 
which are missing in jbsale. But inner join and left join both work well in this case since all
items in jbsale are included in jbitem. */
drop view if exists sale_view1 cascade;
create view sale_view1 as 
select S.debit, sum(I.price*S.quantity) as total_cost 
from jbsale S inner join jbitem I on S.item=I.id
group by S.debit;
select * from sale_view1;
/*
debit	total_cost
100581	2050
100582	1000
100586	13446
100592	650
100593	430
100594	3295
*/


/*19) Oh no! An earthquake!
a) Remove all suppliers in Los Angeles from the table jbsupplier. This will not
work right away (you will receive error code 23000) which you will have to
solve by deleting some other related tuples. However, do not delete more
tuples from other tables than necessary and do not change the structure of the
tables, i.e. do not remove foreign keys. Also, remember that you are only
allowed to use “Los Angeles” as a constant in your queries, not “199” or
“900”.
b) Explain what you did and why.*/
delete from jbsale where item in (select I.id from jbitem I,jbsupplier S,jbcity C where C.name="Los Angeles" and S.city=C.id and S.id=I.supplier);
delete from jbitem where supplier in (select S.id from jbsupplier S,jbcity C where C.name="Los Angeles" and S.city=C.id);
delete from jbitem1 where supplier in (select S.id from jbsupplier S,jbcity C where C.name="Los Angeles" and S.city=C.id);
delete from jbsupply where supplier in (select S.id from jbsupplier S,jbcity C where C.name="Los Angeles" and S.city=C.id);
delete from jbsupplier where city in (select id from jbcity where name="Los Angeles");
select * from jbsupplier;
/*Tuples with matched item id in jbsale, supplier id in jbitem, jbitem1, jbsupply, and city id in jbsupplier are deleted, 
since there are foreign keys included in those tuples, which prevents deleting the supplier with id 199. 
After deleting those tuples with foreign keys connected to supplier id and the relevant item id, 
the constraints are no longer valid. */
/*
id	name			city
5	Amdahl			921
15	White Stag		106
20	Wormley			118
33	Levi-Strauss	941
42	Whitman's		802
62	Data General	303
67	Edger			841
89	Fisher-Price	21
122	White Paper		981
125	Playskool		752
213	Cannon			303
241	IBM				100
440	Spooley			609
475	DEC				10
999	A E Neumann		537
*/

/*20) An employee has tried to find out which suppliers that have delivered items that
have been sold. He has created a view and a query that shows the number of items
sold from a supplier.
mysql> CREATE VIEW jbsale_supply(supplier, item, quantity) AS
-> SELECT jbsupplier.name, jbitem.name, jbsale.quantity
-> FROM jbsupplier, jbitem, jbsale
-> WHERE jbsupplier.id = jbitem.supplier
-> AND jbsale.item = jbitem.id;
Query OK, 0 rows affected (0.01 sec)
mysql> SELECT supplier, sum(quantity) AS sum FROM jbsale_supply
-> GROUP BY supplier;
+--------------+---------------+
| supplier | sum(quantity) |
+--------------+---------------+
| Cannon | 6 |
| Levi-Strauss | 1 |
| Playskool | 2 |
| White Stag | 4 |
| Whitman's | 2 |
+--------------+---------------+
5 rows in set (0.00 sec)

The employee would also like include the suppliers which has delivered some
items, although for whom no items have been sold so far. In other words he wants
to list all suppliers, which has supplied any item, as well as the number of these
items that have been sold. Help him! Drop and redefine jbsale_supply to
consider suppliers that have delivered items that have never been sold as well.
Hint: The above definition of jbsale_supply uses an (implicit) inner join that
removes suppliers that have not had any of their delivered items sold.*/
drop view if exists jbsale_supply;
CREATE VIEW jbsale_supply(supplier, item, quantity) AS
SELECT S.name, I.name, SA.quantity
FROM (jbitem I left join jbsupplier S on I.supplier=S.id) left join jbsale SA on I.id=SA.item;

SELECT supplier, sum(quantity) AS sum FROM jbsale_supply GROUP BY supplier;
/*
supplier 		sum
Cannon			6
Fisher-Price	NULL
Levi-Strauss	1
Playskool		2
White Stag		4
Whitman's		2
*/

