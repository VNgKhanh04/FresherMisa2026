DROP PROCEDURE IF EXISTS `Proc_Employee_Filter`;
DELIMITER ;;
CREATE PROCEDURE `Proc_Employee_Filter`(
    IN v_DepartmentID  CHAR(36),
    IN v_PositionID    CHAR(36),
    IN v_SalaryFrom    DECIMAL(18, 4),
    IN v_SalaryTo      DECIMAL(18, 4),
    IN v_Gender        INT,
    IN v_HireDateFrom  DATE,
    IN v_HireDateTo    DATE
)
BEGIN
  DECLARE v_where TEXT DEFAULT ' WHERE 1=1 ';
 
  IF v_DepartmentID IS NOT NULL AND v_DepartmentID <> '' THEN
    SET v_where = CONCAT(v_where, ' AND e.DepartmentID = ''', v_DepartmentID, '''');
  END IF;
 
  IF v_PositionID IS NOT NULL AND v_PositionID <> '' THEN
    SET v_where = CONCAT(v_where, ' AND e.PositionID = ''', v_PositionID, '''');
  END IF;
  
  IF v_SalaryFrom IS NOT NULL THEN
    SET v_where = CONCAT(v_where, ' AND e.Salary >= ', v_SalaryFrom);
  END IF;
 
  IF v_SalaryTo IS NOT NULL THEN
    SET v_where = CONCAT(v_where, ' AND e.Salary <= ', v_SalaryTo);
  END IF;

  IF v_Gender IS NOT NULL THEN
    SET v_where = CONCAT(v_where, ' AND e.Gender = ', v_Gender);
  END IF;
 
  IF v_HireDateFrom IS NOT NULL THEN
    SET v_where = CONCAT(v_where, ' AND DATE(e.HireDate) >= ''', v_HireDateFrom, '''');
  END IF;
 
  IF v_HireDateTo IS NOT NULL THEN
    SET v_where = CONCAT(v_where, ' AND DATE(e.HireDate) <= ''', v_HireDateTo, '''');
  END IF;
 
  SET @v_sql = CONCAT(
    'SELECT
       e.EmployeeID,
       e.EmployeeCode,
       e.EmployeeName,
       e.Gender,
       CASE e.Gender
         WHEN 0 THEN ''Nữ''
         WHEN 1 THEN ''Nam''
         WHEN 2 THEN ''Khác''
         ELSE ''Không xác định''
       END AS GenderName,
       e.DateOfBirth,
       e.PhoneNumber,
       e.Email,
       e.Address,
       e.DepartmentID,
       d.DepartmentCode,
       d.DepartmentName,
       e.PositionID,
       p.PositionCode,
       p.PositionName,
       e.Salary,
       e.HireDate,
       e.CreatedDate
     FROM employee e
     LEFT JOIN department d ON e.DepartmentID = d.DepartmentID
     LEFT JOIN position   p ON e.PositionID   = p.PositionID',
    v_where,
    ' ORDER BY e.HireDate DESC, e.CreatedDate DESC'
  );
 
  PREPARE stmt FROM @v_sql;
  EXECUTE stmt;
  DEALLOCATE PREPARE stmt;
 
END
;;
DELIMITER ;