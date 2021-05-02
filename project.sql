SELECT * FROM steam;
SET SERVEROUTPUT ON;
--1function
CREATE OR REPLACE FUNCTION 
single_number_value (
   steam   IN VARCHAR2,
   name   IN VARCHAR2,
   appid    IN NUMBER)
   RETURN NUMBER
IS
   l_return NUMBER;
BEGIN
   EXECUTE IMMEDIATE
         'SELECT '
      || name
      || ' FROM '
      || steam
      || ' WHERE '
      || appid
      INTO l_return;
   RETURN l_return;
END;
--2function 
    CREATE OR REPLACE Function FindGAME
   (name_in IN varchar2)
   RETURN number
IS
   cnumber number;
 
   cursor c1 is
   SELECT name
     FROM steam
     WHERE name = name_in;
 
BEGIN
   open c1;
   fetch c1 into cnumber;
 
   if c1%notfound then
      cnumber := 9999;
   end if;
   close c1;
RETURN cnumber;
 
EXCEPTION	 	 
WHEN OTHERS THEN	 	 
 raise_application_error(-20001,'An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM);
END;

--3function
create or replace function a_func (foo in varchar2)
  return number 
as
  total number;
  -- v_bar varchar2(32);
  v_bar number;    --> should match RETURN datatype
begin
  select foo into v_bar from steam;

  total := v_bar * 1000;

  return v_bar;
end;  

--1procedures
CREATE OR REPLACE PROCEDURE print_info(
    p_id NUMBER 
)
IS
  game_name steam%ROWTYPE;
BEGIN
  -- get contact based on customer id
  SELECT *
  INTO game_name
  FROM steam
  WHERE appid = p_id;

  -- print out pokemon's information
  dbms_output.put_line('Game ' || game_name.name || '.  Date: ' ||
  game_name.RELEASE_DATE);
  

EXCEPTION
   WHEN OTHERS THEN
      dbms_output.put_line( SQLERRM );
END;

EXEC print_info(8000);
--1курсор 
DECLARE
   CURSOR curs
   IS
      SELECT *
        FROM steam
       WHERE appid = 730;
BEGIN
   FOR steam_rec
   IN curs
   LOOP
      DBMS_OUTPUT.put_line (
         steam_rec.name);
   END LOOP;
END;

--2курсор
CREATE OR REPLACE PROCEDURE Test_cursor (Out_Pid OUT VARCHAR2) AS 
cursor  c1 IS
SELECT appid, name  FROM steam
WHERE appid = 30;

c1_rec c1%rowtype;

BEGIN
 OPEN c1;
  LOOP
  FETCH c1 INTO c1_rec;
  EXIT WHEN c1%NOTFOUND;

  Out_Pid := c1_rec.name;
  DBMS_OUTPUT.PUT_LINE('Result from query '||c1_rec.name );
  DBMS_OUTPUT.PUT_LINE('Result from out parameter '||Out_Pid );
 END LOOP;
 END Test_cursor;

--3cursor
DECLARE
    CURSOR curs(r_id INTEGER) IS
    SELECT name, appid
    FROM steam WHERE appid < 200;
    c_name VARCHAR2(50);
    rid INTEGER;
BEGIN
    OPEN curs(1);
    LOOP
    FETCH curs INTO c_name, rid;
    EXIT WHEN curs%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(c_name|| ' ' ||rid);
    END LOOP;
    CLOSE curs;
END;

--4cursor
DECLARE 
    CURSOR game_curs IS 
    SELECT appid, name FROM steam
    ORDER BY appid; 
    v_game_rec game_curs%ROWTYPE; 
    TYPE t_game_data IS TABLE OF game_curs%ROWTYPE 
    INDEX BY BINARY_INTEGER; 
    v_game_data t_game_data; 
BEGIN 
    OPEN game_curs; 
    LOOP 
    FETCH game_curs INTO v_game_rec; 
    EXIT WHEN game_curs%NOTFOUND; v_game_data(v_game_rec.appid) := v_game_rec; 
    END LOOP; 
    CLOSE game_curs; 
    FOR i IN v_game_data.FIRST .. v_game_data.LAST 
    LOOP 
    IF v_game_data.EXISTS(i) 
    THEN DBMS_OUTPUT.PUT_LINE(v_game_data(i).appid || ' ' || v_game_data(i).name); 
    END IF; 
    END LOOP; 
END;

--triggers
CREATE OR REPLACE PROCEDURE makeTable  /*dynamicSql*/
AS
BEGIN
    execute immediate 'CREATE TABLE steam_log
        (
        APPID NUMBER(38,0), 
    NAME VARCHAR2(128 BYTE), 
    RELEASE_DATE DATE, 
    ENGLISH NUMBER(38,0), 
    DEVELOPER VARCHAR2(128 BYTE),
    PUBLISHER VARCHAR2(128 BYTE), 
    PLATFORMS VARCHAR2(26 BYTE), 
    REQUIRED_AGE NUMBER(38,0), 
    CATEGORIES VARCHAR2(1024 BYTE), 
    GENRES VARCHAR2(128 BYTE),
    STEAMSPY_TAGS VARCHAR2(128 BYTE),
    ACHIEVEMENTS NUMBER(38,0),
    POSITIVE_RATINGS NUMBER(38,0),
    NEGATIVE_RATINGS NUMBER(38,0),
    AVERAGE_PLAYTIME NUMBER(38,0),
    MEDIAN_PLAYTIME NUMBER(38,0),
    OWNERS VARCHAR2(26 BYTE),
    PRICE VARCHAR2(26 BYTE)
        )';
        execute immediate '
        INSERT INTO users_log VALUES(1234,|| '''|| 'gg'|| '''||, || '''|| SYSDATE || '''||, 15,|| '''||'fsdf'|| '''||,|| '''||'VFVV'|| '''||,|| '''|| 'DADS'|| '''||, 2,|| '''|| 'SADA'|| '''||, || '''|| 'CSAC'|| '''||, || '''|| 'JHKL'|| '''||, 3, 4, 5, 100, 100, || '''||'hh'|| '''||, || '''||'RGB'|| '''||)';
        commit;
END makeTable;

create or replace TRIGGER trigger_insert
AFTER INSERT
   ON STEAM
   FOR EACH ROW
DECLARE
  v_name varchar2(10);
BEGIN 
   SELECT user INTO v_name
   FROM dual; 
    INSERT INTO steam_log
   (APPID,
            NAME,
            RELEASE_DATE,
           ENGLISH,
            DEVELOPER,
            PUBLISHER,
            PLATFORMS,
            REQUIRED_AGE,
            CATEGORIES,
            GENRES,
            STEAMSPY_TAGS,
           ACHIEVEMENTS,
            POSITIVE_RATINGS,
            NEGATIVE_RATINGS,
            AVERAGE_PLAYTIME,
            MEDIAN_PLAYTIME,
            OWNERS,
            PRICE,
       Action,
       Author)
VALUES
   ( :new.APPID,
           :new.NAME,
           SYSDATE,
           :new.ENGLISH,
            :new.DEVELOPER,
           :new.PUBLISHER,
           :new.PLATFORMS,
           :new.REQUIRED_AGE,
           :new.CATEGORIES,
           :new.GENRES,
           :new.STEAMSPY_TAGS,
          :new.ACHIEVEMENTS,
           :new.POSITIVE_RATINGS,
           :new.NEGATIVE_RATINGS,
           :new.AVERAGE_PLAYTIME,
           :new.MEDIAN_PLAYTIME,
           :new.OWNERS,
           :new.PRICE,
      'Insert',
       user);
END;
/
--End insert trigger


create or replace TRIGGER trigger_update
AFTER UPDATE
   ON steam
   FOR EACH ROW
DECLARE
   steams varchar2(10);
BEGIN
   SELECT user INTO steams
   FROM dual;
   INSERT INTO steam_log
   (APPID,
            NAME,
            RELEASE_DATE,
           ENGLISH,
            DEVELOPER,
            PUBLISHER,
            PLATFORMS,
            REQUIRED_AGE,
            CATEGORIES,
            GENRES,
            STEAMSPY_TAGS,
           ACHIEVEMENTS,
            POSITIVE_RATINGS,
            NEGATIVE_RATINGS,
            AVERAGE_PLAYTIME,
            MEDIAN_PLAYTIME,
            OWNERS,
            PRICE,
       Action,
       Author)
 VALUES
 (:new.APPID,
           :new.NAME,
           SYSDATE,
           :new.ENGLISH,
            :new.DEVELOPER,
           :new.PUBLISHER,
           :new.PLATFORMS,
           :new.REQUIRED_AGE,
           :new.CATEGORIES,
           :new.GENRES,
           :new.STEAMSPY_TAGS,
          :new.ACHIEVEMENTS,
           :new.POSITIVE_RATINGS,
           :new.NEGATIVE_RATINGS,
           :new.AVERAGE_PLAYTIME,
           :new.MEDIAN_PLAYTIME,
           :new.OWNERS,
           :new.PRICE,
      'Update',
       user);
END;
/
--End update trigger


create or replace TRIGGER trigger_delete
AFTER DELETE
  ON steam
  FOR EACH ROW
DECLARE
BEGIN
 INSERT INTO steam_log
      (APPID,
            NAME,
            RELEASE_DATE,
           ENGLISH,
            DEVELOPER,
            PUBLISHER,
            PLATFORMS,
            REQUIRED_AGE,
            CATEGORIES,
            GENRES,
            STEAMSPY_TAGS,
           ACHIEVEMENTS,
            POSITIVE_RATINGS,
            NEGATIVE_RATINGS,
            AVERAGE_PLAYTIME,
            MEDIAN_PLAYTIME,
            OWNERS,
            PRICE,
       Action,
       Author)
 VALUES(
   :old.APPID,
           :old.NAME,
           SYSDATE,
           :old.ENGLISH,
            :old.DEVELOPER,
           :old.PUBLISHER,
           :old.PLATFORMS,
           :old.REQUIRED_AGE,
           :old.CATEGORIES,
           :old.GENRES,
           :old.STEAMSPY_TAGS,
          :old.ACHIEVEMENTS,
           :old.POSITIVE_RATINGS,
           :old.NEGATIVE_RATINGS,
           :old.AVERAGE_PLAYTIME,
           :old.MEDIAN_PLAYTIME,
           :old.OWNERS,
           :old.PRICE,
       'Delete',
       user);
  END;
  /
--End delete trigger

--Test Triggers

--Insert
insert into STEAM values(1234, 'gg', SYSDATE, 15, 'fsdf','VFVV', 'DADS', 2, 'SADA', 'CSAC', 'JHKL', 3, 4, 5, 100, 100, 'hh', 'RGB');
DROP trigger HR.TRIGGER_INSERT;
--Update
update steam
set name = 'nnn'
where appid =  '1234';

--Delete
delete from steam where appid =  1234;

select * from steam_log where appid=1234;

--procedurs
/*/
Create a stored procedure to insert new country into a table
/*/
CREATE OR REPLACE PROCEDURE game_insert
       (
       APPID                              IN steam.APPID%TYPE, 
       NAME                               IN steam.NAME%TYPE, 
       RELEASE_DATE                       IN steam.RELEASE_DATE%TYPE, 
       ENGLISH                            IN steam.ENGLISH%TYPE, 
       DEVELOPER                          IN steam.DEVELOPER%TYPE, 
       PUBLISHER                          IN steam.PUBLISHER%TYPE, 
       PLATFORMS                          IN steam.PLATFORMS%TYPE, 
       REQUIRED_AGE                       IN steam.REQUIRED_AGE%TYPE, 
       CATEGORIES                         IN steam.CATEGORIES%TYPE, 
       GENRES                            IN steam.GENRES%TYPE,
       STEAMSPY_TAGS                        IN steam.STEAMSPY_TAGS%TYPE,
       ACHIEVEMENTS                 IN steam.ACHIEVEMENTS%TYPE,
       POSITIVE_RATINGS                                      IN steam.POSITIVE_RATINGS%TYPE,
       NEGATIVE_RATINGS                                 IN steam.NEGATIVE_RATINGS%TYPE,
       AVERAGE_PLAYTIME                                IN steam.AVERAGE_PLAYTIME%TYPE,
       MEDIAN_PLAYTIME                             IN steam.MEDIAN_PLAYTIME%TYPE,
       OWNERS                                          IN steam.OWNERS%TYPE,
       PRICE                             IN steam.PRICE%TYPE
       )
IS 
BEGIN  

     INSERT INTO steam
          (                    
            APPID,
            NAME,
            RELEASE_DATE,
           ENGLISH,
            DEVELOPER,
            PUBLISHER,
            PLATFORMS,
            REQUIRED_AGE,
            CATEGORIES,
            GENRES,
            STEAMSPY_TAGS,
           ACHIEVEMENTS,
            POSITIVE_RATINGS,
            NEGATIVE_RATINGS,
            AVERAGE_PLAYTIME,
            MEDIAN_PLAYTIME,
            OWNERS,
            PRICE
          ) 
     VALUES 
          ( 
           APPID,
            NAME,
            RELEASE_DATE,
           ENGLISH,
            DEVELOPER,
            PUBLISHER,
            PLATFORMS,
            REQUIRED_AGE,
            CATEGORIES,
            GENRES,
            STEAMSPY_TAGS,
           ACHIEVEMENTS,
            POSITIVE_RATINGS,
            NEGATIVE_RATINGS,
            AVERAGE_PLAYTIME,
            MEDIAN_PLAYTIME,
            OWNERS,
            PRICE
          );

commit;

END; 
--End insert procedure


/*/
Create a stored procedure to delete country into a table
/*/
CREATE OR REPLACE PROCEDURE game_delete(v_id IN steam.appid%TYPE)
IS
BEGIN

  DELETE steam where appid = v_id;
  
  COMMIT;

END;
--End delete procedure

/*/
Create a stored procedure to update country into a table
/*/
CREATE OR REPLACE PROCEDURE game_update(
       v_id IN steam.appid%TYPE,
       v_name IN steam.name%TYPE)
IS
BEGIN

  UPDATE steam SET name = v_name where appid = v_id;
  
  COMMIT;

END;


--package
--1package
CREATE OR REPLACE PACKAGE pack1

IS 
PROCEDURE game_insert;
PROCEDURE game_delete;
PROCEDURE game_update;

END pack1;
/
CREATE OR REPLACE PACKAGE BODY pack1 AS 

/*/
Create a stored procedure to insert new country into a table
/*/
PROCEDURE game_insert
       (
       APPID                              IN steam.APPID%TYPE, 
       NAME                               IN steam.NAME%TYPE, 
       RELEASE_DATE                       IN steam.RELEASE_DATE%TYPE, 
       ENGLISH                            IN steam.ENGLISH%TYPE, 
       DEVELOPER                          IN steam.DEVELOPER%TYPE, 
       PUBLISHER                          IN steam.PUBLISHER%TYPE, 
       PLATFORMS                          IN steam.PLATFORMS%TYPE, 
       REQUIRED_AGE                       IN steam.REQUIRED_AGE%TYPE, 
       CATEGORIES                         IN steam.CATEGORIES%TYPE, 
       GENRES                            IN steam.GENRES%TYPE,
       STEAMSPY_TAGS                        IN steam.STEAMSPY_TAGS%TYPE,
       ACHIEVEMENTS                 IN steam.ACHIEVEMENTS%TYPE,
       POSITIVE_RATINGS                                      IN steam.POSITIVE_RATINGS%TYPE,
       NEGATIVE_RATINGS                                 IN steam.NEGATIVE_RATINGS%TYPE,
       AVERAGE_PLAYTIME                                IN steam.AVERAGE_PLAYTIME%TYPE,
       MEDIAN_PLAYTIME                             IN steam.MEDIAN_PLAYTIME%TYPE,
       OWNERS                                          IN steam.OWNERS%TYPE,
       PRICE                             IN steam.PRICE%TYPE
       )
IS 
BEGIN  

     INSERT INTO steam
          (                    
            APPID,
            NAME,
            RELEASE_DATE,
           ENGLISH,
            DEVELOPER,
            PUBLISHER,
            PLATFORMS,
            REQUIRED_AGE,
            CATEGORIES,
            GENRES,
            STEAMSPY_TAGS,
           ACHIEVEMENTS,
            POSITIVE_RATINGS,
            NEGATIVE_RATINGS,
            AVERAGE_PLAYTIME,
            MEDIAN_PLAYTIME,
            OWNERS,
            PRICE
          ) 
     VALUES 
          ( 
           APPID,
            NAME,
            RELEASE_DATE,
           ENGLISH,
            DEVELOPER,
            PUBLISHER,
            PLATFORMS,
            REQUIRED_AGE,
            CATEGORIES,
            GENRES,
            STEAMSPY_TAGS,
           ACHIEVEMENTS,
            POSITIVE_RATINGS,
            NEGATIVE_RATINGS,
            AVERAGE_PLAYTIME,
            MEDIAN_PLAYTIME,
            OWNERS,
            PRICE
          );

commit;

END; 
--End insert procedure


/*/
Create a stored procedure to delete country into a table
/*/
--2package
PROCEDURE game_delete(v_id IN steam.appid%TYPE)
IS
BEGIN

  DELETE steam where appid = v_id;
  
  COMMIT;

END;
--End delete procedure

/*/
Create a stored procedure to update country into a table
/*/
PROCEDURE game_update(
       v_id IN steam.appid%TYPE,
       v_name IN steam.name%TYPE)
IS
BEGIN

  UPDATE steam SET name = v_name where appid = v_id;
  
  COMMIT;

END;

END pack1;
/


