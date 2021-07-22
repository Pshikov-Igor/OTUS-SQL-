-- =========================================
-- Фильтрованные индексы
-- Filtered index
-- =========================================

use WideWorldImporters

-----------------------------------
-- Фильтрованные  (WHERE)
-----------------------------------

-- UNIQUE

CREATE TABLE #demo(
	Col int null,
	CONSTRAINT UQ_Col UNIQUE(Col)   
)

INSERT INTO #demo VALUES(1)
INSERT INTO #demo VALUES(1)
INSERT INTO #demo VALUES(null)
INSERT INTO #demo VALUES(null)

SELECT * FROM #demo

-- А если хотим, чтобы было несколько NULL, 
-- но остальные значения уникальные?

-- FILTERED INDEX

CREATE TABLE #demo2(
	Col int null
)

CREATE UNIQUE NONCLUSTERED INDEX IX_Col
ON #demo2(Col)
WHERE(Col IS NOT NULL)

INSERT INTO #demo2 VALUES(1)
INSERT INTO #demo2 VALUES(1)
INSERT INTO #demo2 VALUES(null)
INSERT INTO #demo2 VALUES(null)

SELECT * FROM #demo2
