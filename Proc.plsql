CREATE OR REPLACE PROCEDURE sp1
AS

    CURSOR c1 IS
        SELECT id, name, salary
        FROM emp;

    TYPE trec1 IS RECORD (
        v_id     emp.id%TYPE,
        v_name   emp.name%TYPE,
        v_salary emp.salary%TYPE
    );

    TYPE type1 IS TABLE OF trec1;

    v1 type1;

    v_errline NUMBER;
    v_errcode VARCHAR2(1000);

BEGIN

    OPEN c1;

    LOOP

        FETCH c1 BULK COLLECT INTO v1 LIMIT 10000;

        EXIT WHEN v1.COUNT = 0;

        FORALL i IN v1.FIRST .. v1.LAST SAVE EXCEPTIONS

            INSERT INTO emp_bkp
            VALUES (
                v1(i).v_id,
                v1(i).v_name,
                v1(i).v_salary
            );

    END LOOP;

    COMMIT;

    CLOSE c1;

EXCEPTION

    WHEN OTHERS THEN

        FOR i IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP

            v_errline := SQL%BULK_EXCEPTIONS(i).ERROR_INDEX;
            v_errcode := SQL%BULK_EXCEPTIONS(i).ERROR_CODE;

            INSERT INTO err_log
            VALUES (
                v_errline,
                v_errcode
            );

        END LOOP;

END;
/
