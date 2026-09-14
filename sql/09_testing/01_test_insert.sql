
-- ============================================================
-- CDC INSERT Test
-- ============================================================

INSERT INTO PRACTICE_DB.TRAINING.STREAM_DEMO_EMP
VALUES
(121, 'Naveen', 'Chennai', 485000);

--Verification Query
SELECT *
FROM PRACTICE_DB.TRAINING.STREAM_DEMO_EMP_CDC;
