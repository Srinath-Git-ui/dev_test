CREATE OR REPLACE PROCEDURE sp1
AS

    CURSOR c1 IS
        SELECT id, name, salary
        FROM emp;

    TYPE trec1 IS RECORD (
        vid     emp.id%TYPE,
        vname   emp.name%TYPE,
        vsalary emp.salary%TYPE
    );

    TYPE type1 IS TABLE OF trec1;

    v1 type1;

    verrline NUMBER;
    verrcode VARCHAR2(1000);

BEGIN

    OPEN c1;

    LOOP

        FETCH c1 BULK COLLECT INTO v1 LIMIT 10000;

        EXIT WHEN v1.COUNT = 0;

        FORALL i IN v1.FIRST .. v1.LAST SAVE EXCEPTIONS

            INSERT INTO emp_bkp
            VALUES (
                v1(i).vid,
                v1(i).vname,
                v1(i).vsalary
            );

    END LOOP;

    COMMIT;

    CLOSE c1;

EXCEPTION

    WHEN OTHERS THEN

        FOR i IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP

            verrline := SQL%BULK_EXCEPTIONS(i).ERROR_INDEX;
            verrcode := SQL%BULK_EXCEPTIONS(i).ERROR_CODE;

            INSERT INTO err_log
            VALUES (
                verrline,
                verrcode
            );

        END LOOP;

END;
/
