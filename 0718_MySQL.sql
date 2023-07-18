-- 데이터베이스 사용 설정
use mysql;

-- 테이터베이스에 존재하는 테이블 확인
show tables;

-- 현재 사용중인 유저 확인
SELECT USER(); -- ROOT

-- 현재 사용중인 데이터베이스 확인
SELECT DATABASE(); -- mysql

-- MySQL은 매개변수가 없는 함수는 이름만으로 실행 가능
SELECT DATABASE; -- 완성된 SQL이 아니라 여기서는 오류

-- EMP 테이블에서 ENAME과 SAL, SAL+COMM을 조회
-- NULL과 연산을 하면 결과는 항상 NULL 
-- NULL을 가지는 데이터에 대해서도 연산을 가능하도록 만들기 때문에 중요한 함수
SELECT ENAME, SAL, SAL+IFNULL(COMM, 0) AS 실수령액, COMM
FROM EMP;

-- COMM이 NULL이 아니면 COMM을, COMM이 NULL이고 SAL이 NULL이 아니면
-- SAL을 리턴
SELECT COALESCE (COMM, SAL)
FROM EMP;


-- EMP 테이블의 데이터 갯수를 조회

SELECT COUNT(EMPNO) 
FROM EMP; -- 14 출력

-- EMP 테이블에서 COMM이 NULL이 아닌 데이터 갯수를 조회
-- 실제로는 EMPNO 데이터가 NULL이 아닌 데이터의 갯수를 조회
SELECT COUNT(COMM) 
FROM EMP; -- 4 출력

-- EMP 테이블에서 모든 컬럼이 NULL이 아닌 데이터 갯수를 조회
-- NULL이 있는 경우가 있을 수 있으므로
-- 컬럼 이름이 아니라 * 을 사용하거나 PRIMARY KEY를 활용하는게 좋음
SELECT COUNT(*) AS 'CNT'
FROM EMP; -- 14 출력

-- EMP 테이블에서 SAL 의 평균 구하기
SELECT AVG(SAL)
FROM EMP;

-- EMP 테이블에서 COMM 의 평균 구하기
-- 10개는 NULL이고 4개 데이터만 NULL이 아님
-- 그래서 AVG를 구할 때 NULL을 제외하고 4로 결과를 나눔
SELECT AVG(COMM)
FROM EMP; -- 550

-- EMP 테이블에서 COMM 의 평균 구하기
-- NULL 데이터로 인해 둘의 결과가 다름
SELECT AVG(IFNULL(COMM, 0)) AS 'Average COMM'
FROM EMP; -- 약 157.1

-- EMP 테이블에서 ENAME 과 데이터 갯수를 조회
-- 둘의 데이터 갯수가 다르므로 테이블을 만들 수 없고 에러 발생
SELECT ENAME, COUNT(*) 
FROM EMP;

-- EMP 테이블에서 DEPTNO 별로 SAL 의 평균 조회
-- ENAME 과 같이 데이터의 갯수가 다른 항목을 SELECT 하면 에러 발생
SELECT DEPTNO, AVG(SAL)
FROM EMP
GROUP BY DEPTNO;

-- tCity 테이블에서 region 별 popu 의 합계 조회
SELECT region, SUM(popu) 
FROM tCity
GROUP BY region;

-- 2개 이사의 컬럼으로 그룹화가 가능
-- tStaff 테이블에서 depart, gender 별로 데이터 갯수를 조회
-- 2개 이상의 컬럼을 사용하므로 ORDER BY를 통해 정렬해 주는게 좋음
SELECT 		depart, gender, COUNT(*) 
FROM 		tStaff
GROUP BY 	depart, gender
ORDER BY 	depart;


-- EMP 테이블에서 DEPTNO 가 5번 이상 나오는 경우에
-- DEPTNO 와 SAL의 평균을 조회

-- 이 경우에 그룹화 되기 전에 WHERE 절에서 그룹 함수를 사용하므로 에러
SELECT DEPTNO, COUNT(*) 
FROM EMP
WHERE COUNT((DEPTNO) >= 5
GROUP BY DEPTNO;

-- 그룹 함수를 이용한 조건은 HAVING 절에 기재해야 함
SELECT DEPTNO, COUNT(*) 
FROM EMP
GROUP BY DEPTNO
HAVING COUNT(DEPTNO) >= 5;

-- tStaff 테이블에서 depart 별로 평균 salary 가 340이 넘는 부서의
-- depart 와 salary 의 평균을 조회
SELECT 		depart, AVG(salary)
FROM 		tStaff
GROUP BY 	depart
HAVING 		AVG(salary) > 340
ORDER BY 	AVG(salary) DESC;

-- tStaff 테이블에서 depart 가 인사과나 영업부인 데이터의
-- salary의 최댓값을 조회
-- 집계 함수를 사용하지 않기 때문에 WHERE 절에 조건을 작성하는게 좋음
SELECT depart, MAX(salary)
FROM tStaff
GROUP BY depart
HAVING depart = '인사과' OR depart = '영업부';
-- HAVING depart IN ('인사과', '영업부'); -- OR 과 같은 결과

-- WHERE 절을 사용해서 동일한 결과
-- 결과는 같지만 그룹화 하기 전에 필터링을 먼저 처리하므로 이게 더 좋은 방식
SELECT depart, MAX(salary)
FROM tStaff
WHERE depart = '인사과' OR depart = '영업부'
GROUP BY depart;


-- EMP 테이블에서 sal 이 많은 순서대로 일련번호를 부여해서
-- ENAME 과 SAL 을 조회하기
-- MySQL 은 같은 순위의 경우 기본키(PRIMARY KEY) 순서대로 정해짐
SELECT ROW_NUMBER() OVER(ORDER BY SAL DESC) AS NUM, ENAME , SAL 
FROM EMP;

-- EMP 테이블에서 sal 이 많은 순서부터 값이 같은 경우 동일한 순위를 부여해서
-- ENAME 과 SAL 을 조회하기
SELECT DENSE_RANK() OVER(ORDER BY SAL DESC) AS NUM, ENAME , SAL 
FROM EMP;

-- EMP 테이블에서 sal 이 많은 순서부터 값이 같은 경우 동일한 순위를 부여해서
-- ENAME 과 SAL 을 조회하기
-- 동일한 순위가 있으면 다음 순위는 건너뜀
SELECT RANK() OVER(ORDER BY SAL DESC) AS NUM, ENAME , SAL 
FROM EMP;

-- 그룹으로 분할 : 5 그룹
SELECT NTILE(5) OVER(ORDER BY SAL DESC) AS NUM, ENAME , SAL 
FROM EMP;

-- EMP 테이블에서 DEPTNO 별로 sal 이 많은 순서부터 값이 같은 경우 동일한 순위를 부여해서
-- ENAME 과 SAL 을 조회하기
SELECT DEPTNO, DENSE_RANK() OVER(PARTITION BY DEPTNO ORDER BY SAL DESC) AS NUM, ENAME , SAL 
FROM EMP
ORDER BY DEPTNO DESC;

-- EMP 테이블에서 SAL 의 내림차순으로 정렬한 다음
-- 이후 데이터와의 SAL 차이를 알고자 하는 경우
SELECT ENAME, SAL, SAL - (LEAD(SAL, 1) OVER(ORDER BY SAL DESC)) AS "급여 차이"
FROM EMP
ORDER BY SAL DESC;

-- EMP 테이블에서 SAL 의 내림차순으로 정렬한 다음
-- 첫번째 데이터와의 SAL 차이를 알고자 하는 경우
SELECT ENAME, SAL, SAL - (FIRST_VALUE(SAL) OVER(ORDER BY SAL DESC)) AS "급여 차이"
FROM EMP
ORDER BY SAL DESC;

-- EMP 테이블에서 급여의 누적 백분율을 나타내기(누적 순위)
SELECT ENAME, SAL, CUME_DIST() OVER(ORDER BY SAL DESC) * 100 AS "급여 누적 백분율"
FROM EMP
ORDER BY SAL DESC;

-- EMP 테이블에는 JOB과 DEPTNO, SAL 항목이 있음. 
-- 여기에서 JOB 별, DEPTNO 별 SAL의 합계를 구하려고 할 때
-- 기존의 방식
SELECT JOB, DEPTNO, SUM(SAL)
FROM EMP
GROUP BY JOB, DEPTNO;

-- Pivot 을 이용한 방식
SELECT JOB,
	SUM(IF(DEPTNO=10, SAL, 0)) AS '10',
	SUM(IF(DEPTNO=20, SAL, 0)) AS '20',
	SUM(IF(DEPTNO=30, SAL, 0)) AS '30',
	SUM(SAL) AS 'SUM'
FROM EMP
GROUP BY JOB
ORDER BY SUM(SAL) DESC;

-- JSON 출력
SELECT JSON_OBJECT('ename', ENAME, 'sal', SAL) AS 'JSON으로 조회'
from EMP;

-- EMP 테이블에서 DEPTNO를 조회 : 10, 20, 30
SELECT DISTINCT DEPTNO
FROM EMP;

-- DEPT 테이블에서 DEPTNO를 조회 : 10, 20, 30, 40
SELECT DISTINCT DEPTNO
FROM DEPT;

-- EMP, DEPT 테이블의 DEPTNO 의 합집합 : 중복 제거
SELECT DEPTNO
FROM EMP
UNION
SELECT DEPTNO 
FROM DEPT;

-- EMP, DEPT 테이블의 DEPTNO 의 합집합 : 중복 제거
SELECT DEPTNO
FROM EMP
UNION ALL
SELECT DEPTNO 
FROM DEPT;

-- EMP, DEPT 테이블의 DEPTNO 의 교집합 : 10, 20, 30 3개 출력
SELECT DEPTNO
FROM EMP
INTERSECT
SELECT DEPTNO 
FROM DEPT;

-- DEPT 테이블에는 존재하지만 EMP 테이블에는 없는 DEPTNO : 40 1개 출력
SELECT DEPTNO
FROM DEPT
EXCEPT
SELECT DEPTNO 
FROM EMP;

SELECT *
FROM EMP;
desc DEPT;

-- ENAME(EMP 테이블)이 MILLER인 사원의 DNAME(DEPT 테이블)을 조회하려고 하는 경우
-- 2개의 쿼리를 사용하는 방식
SELECT DEPTNO
FROM EMP
WHERE ENAME = 'MILLER';

SELECT DNAME
FROM DEPT
WHERE DEPTNO = 10;

-- Sub Query 를 이용해서 1개의 쿼리만 사용하는 방식
-- 쿼리가 2개이면 무엇을 먼저 처리해야 하는지 알지 못하므로 괄호 안에 Sub 를 넣어줌
-- 괄호 안을 먼저 처리해서 10을 가져오고 그 값을 활요해서 DNAME을 조회하는 방식임
SELECT DNAME
FROM DEPT
WHERE DEPTNO = (SELECT DEPTNO
				FROM EMP
				WHERE ENAME = 'MILLER');

-- EMP 테이블에서 SAL의 평균보다 더 많은 SAL을 받는 직원의 ENAME과 SAL을 조회
SELECT AVG(SAL)
FROM EMP;

SELECT ENAME, SAL 
FROM EMP
WHERE SAL > (SELECT AVG(SAL)
			 FROM EMP)
ORDER BY SAL DESC;

-- EMP 테이블에서 ENAME이 MILLER인 사원과 동일한 직무(JOB)를 가진
-- 사원의 ENAME 과 JOB 을 조회

SELECT ENAME, JOB
FROM EMP
WHERE JOB = (SELECT JOB
			 FROM EMP
			 WHERE ENAME = 'MILLER') AND ENAME != 'MILLER'
ORDER BY ENAME ;

-- EMP 테이블에서 DEPT 테이블의 LOC가 DALLAS인 사원의 ENAME과 SAL을 조회
SELECT ENAME, SAL
FROM EMP
WHERE DEPTNO = (SELECT DEPTNO 
				FROM DEPT
				WHERE LOC = 'DALLAS')
ORDER BY ENAME;


-- EMP 테이블에서 DEPTNO 별 SAL의 최댓값과 동일한 SAL을 갖는 사원의 
-- EMPNO, ENAME, SAL을 조회

-- 서브 쿼리의 결과가 1개보다 많아서 = 연산자로 비교할 수 없기에 에러 발생
SELECT EMPNO, ENAME, SAL 
FROM EMP
WHERE SAL = (SELECT MAX(SAL)
			 FROM EMP
		     GROUP BY DEPTNO);

-- 서브 쿼리의 결과가 2개 이상인 경우 그 값들 중 하나의 값과 일치하면 됨
SELECT EMPNO, ENAME, SAL 
FROM EMP
WHERE SAL IN (SELECT MAX(SAL)
			 FROM EMP
		     GROUP BY DEPTNO);

-- EMP 테이블에서 DEPTNO가 30인 데이터들의 SAL 보다 큰 데이터의 ENAME, SAL을 조회
-- DEPTNO가 30인 데이터는 2개 이상이므로 비교 불가
SELECT ENAME, SAL 
FROM EMP
WHERE SAL > (SELECT SAL
			 FROM EMP
		     WHERE DEPTNO = 30)

-- 여러 SAL 중 모든 값들 보다 크다고 비교하면 됨
SELECT ENAME, SAL, 
FROM EMP
WHERE SAL > ALL(SELECT SAL
			 FROM EMP
		     WHERE DEPTNO = 30)
		     
-- 최대값 보다 크다고 비교하는 것도 동일한 결과
SELECT ENAME, SAL 
FROM EMP
WHERE SAL > (SELECT MAX(SAL)
			 FROM EMP
		     WHERE DEPTNO = 30);

-- 아무 값 중 하나보다 크면 된다면 ANY를 사용하면 됨 
SELECT ENAME, SAL 
FROM EMP
WHERE SAL > ANY(SELECT SAL
			 FROM EMP
		     WHERE DEPTNO = 30)

-- ANY를 사용한 것과 동일
SELECT ENAME, SAL 
FROM EMP
WHERE SAL > (SELECT MIN(SAL)
			 FROM EMP
		     WHERE DEPTNO = 30)

-- EMP 테이블에서 SAL이 2000이 넘는 데이터가 있으면 ENAME, SAL을 조회
-- 2000이 넘는 데이터가 존재하므로 모든 데이터를 조회
-- 2000이 넘는 데이터만 가져오는게 아님
SELECT ENAME, SAL
FROM EMP
WHERE EXISTS (SELECT 1 FROM EMP WHERE SAL > 2000)


-- Cartesian Product
-- FROM 절에 테이블 이름이 2개 이상이고 JOIN 조건이 없는 경우
-- EMP 테이블은 8열 14행, DEPT 테이블은 3열 4행
-- 결과는 11열 56행
SELECT *
FROM EMP, DEPT;

-- EQUI JOIN
-- FROM 절에 2개 이상의 테이블을 기재하고 
-- WHERE 절에서 2개 테이블의 공통된 컬럼의 값이 같다라고 JOIN 조건을 명시한 경우
-- 겹치는 부분만 가져와서 합치기 때문에 열의 갯수는 위와 같지만 행의 갯수는 훨씬 줄어듦
SELECT *
FROM EMP, DEPT
WHERE EMP.DEPTNO = DEPT.DEPTNO;

-- 한 쪽 테이블에만 존재하는 컬럼 이름을 출력할 때는 이름만 사용해도 되지만
-- DEPTNO와 같이 양 쪽에 존재하는 컬럼을 사용할 때는 이름만 사용하면 에러
-- 양 쪽 테이블에 모두 존재하는 컬럼은 앞에 테이블 이름을 명시해야 함
SELECT ENAME, DNAME, LOC, EMP.DEPTNO 
FROM EMP, DEPT
WHERE EMP.DEPTNO = DEPT.DEPTNO;

-- 테이블에 새로운 이름 부여
-- FROM 절에서 이름을 사용하는건 새로운 이름을 붙이는 것으로 기존 이름은 사용할 수 없음
SELECT ENAME, DNAME, LOC, E.DEPTNO 
FROM EMP E, DEPT D
WHERE E.DEPTNO = D.DEPTNO;

-- HASH JOIN
-- DEPT 테이블이 행이 더 적으므로 FROM 절의 순서를 바꿈
-- 결과는 위의 방식과 동일함
-- 처리 속도가 훨씬 빠르기 때문에 데이터가 많을수록 이전 방식과 차이가 커짐
SELECT /*+ ORDERED USE_HASH(e) */
ENAME, DNAME, LOC, E.DEPTNO 
FROM DEPT D, EMP E
WHERE D.DEPTNO = E.DEPTNO;

-- NON EQUI TABLE
-- EMP 테이블에서 SAL은 급여
-- SALGRADE 테이블의 LOSAL, HISAL은 최저, 최대 급여, GRADE는 등급
-- EMP 테이블에서 ENAME과 SAL을 조회하고 SAL에 해당하는 GRADE를 함께 조회
SELECT ENAME, SAL, GRADE
FROM EMP, SALGRADE
WHERE SAL BETWEEN LOSAL AND HISAL;

-- EMP 테이블에서 ENAME과 관리자 ENAME을 조회
-- 종업원의 관리자 사원 번호와 일치하는 관리자의 사원 번호를 찾아서 이름을 조회
-- 이름이 MILLER인 사원의 관리자 이름을 조회하면 됨
SELECT EMPLOYEE.ENAME AS '종업원', MANAGER.ENAME AS '관리자'
FROM EMP EMPLOYEE, EMP MANAGER
WHERE EMPLOYEE.MGR = MANAGER.EMPNO;

-- ANSI CROSS JOIN
-- FROM 중간에 CROSS JOIN 을 추가하면 처리됨
SELECT *
FROM EMP CROSS JOIN DEPT;

-- EMP 테이블과 DEPT 테이블의 INNER JOIN
-- FROM 절의 테이블 이름에 INNER JOIN을 사용하고 WHERE 대신 ON 절을 사용
SELECT *
FROM EMP INNER JOIN DEPT
ON EMP.DEPTNO = DEPT.DEPTNO;

-- 2개의 컬럼 이름이 같으면 USING을 대신 사용할 수 있음
SELECT *
FROM EMP INNER JOIN DEPT
USING(DEPTNO);

-- 2개의 컬럼 이름이 같으면 NATURAL JOIN 사용 가능
-- 동일한 컬럼을 1번만 출력하는게 특징(여기선 행이 10개가 됨)

SELECT *
FROM EMP NATURAL JOIN DEPT;

-- OUTER JOIN
-- DEPT에는 DEPTNO에 40이 추가로 존재함
SELECT DISTINCT DEPTNO
FROM EMP;

SELECT DEPTNO
FROM DEPT;

-- EMP에 존재하는 모든 DEPTNO가 JOIN에 참여함
SELECT *
FROM EMP LEFT OUTER JOIN DEPT
ON EMP.DEPTNO = DEPT.DEPTNO;

-- DEPT에 존재하는 모든 DEPTNO가 JOIN에 참여함
-- DEPT에는 존재하지만 EMP에는 없던 40이 JOIN에 참여함
-- 이 경우 40은 자신의 원래 데이터를 제외하고는 전부 NULL
SELECT *
FROM EMP RIGHT OUTER JOIN DEPT
ON EMP.DEPTNO = DEPT.DEPTNO;

-- MySQL은 FULL OUTER JOIN을 지원하지 않아서 사용하면 에러
-- LEFT, RIGHT OUTER JOIN을 모두 사용하고 UNION을 사용해서 기능을 대체
-- 여기서는 RIGHT OUTER JOIN과 동일한 결과
SELECT *
FROM EMP LEFT OUTER JOIN DEPT
ON EMP.DEPTNO = DEPT.DEPTNO
UNION
SELECT *
FROM EMP RIGHT OUTER JOIN DEPT
ON EMP.DEPTNO = DEPT.DEPTNO;
