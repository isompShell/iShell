/* PROCEDURE-删除用户相关关系表*/
/*

  DELIMITER $$
  
   DROP VIEW IF EXISTS authorization_all_user$$
          CREATE VIEW  authorization_all_user AS 

         SELECT  fort_authorization_target_proxy.fort_authorization_id ,fort_user_group_user.fort_user_id,
  fort_user.fort_user_name, fort_user.fort_user_account FROM 
  
  fort_user_group_user,fort_authorization_target_proxy,fort_user 
  WHERE  fort_user_group_user.fort_user_group_id = fort_authorization_target_proxy.fort_target_id 
  AND fort_authorization_target_proxy.fort_target_code ='4' 
  AND fort_user_group_user.fort_user_id = fort_user.fort_user_id

   UNION

       SELECT   fort_authorization_target_proxy.fort_authorization_id  ,fort_user.fort_user_id,
  fort_user.fort_user_name, fort_user.fort_user_account
               FROM fort_authorization_target_proxy,fort_user
             WHERE fort_authorization_target_proxy.fort_target_code = '2'
             AND fort_authorization_target_proxy.fort_target_id  = fort_user.fort_user_id$$
             
  DELIMITER ;
  
  
 */

DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `delFortUserRelation`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `delFortUserRelation`(IN fortUserId TEXT,IN execu VARCHAR(10000))
BEGIN
    IF execu ='delete' THEN
        UPDATE fort_user SET fort_user_state = '2' WHERE fort_user_id = fortUserId;    
        DELETE FROM fort_user_role WHERE fort_user_id = fortUserId;
    END IF;
    
    DELETE FROM fort_user_group_user WHERE fort_user_id = fortUserId;
    DELETE FROM fort_user_protocol_client WHERE fort_user_id = fortUserId;  
    DELETE FROM fort_authorization_target_proxy WHERE fort_target_id = fortUserId;
    DELETE FROM fort_double_approval WHERE fort_user_id = fortUserId;
    DELETE FROM fort_plan_password_target_proxy WHERE fort_target_id = fortUserId;
   
     DELETE FROM fort_rule_command_target_proxy WHERE fort_rule_command_target_proxy.fort_target_id = fortUserId;
        
    DELETE FROM fort_rule_time_resource_target_proxy WHERE fort_rule_time_resource_target_proxy.fort_target_id = fortUserId;    
    
   UPDATE fort_user    SET fort_rule_address_id = NULL,fort_rule_time_id = NULL WHERE fort_user_id = fortUserId ;

    END$$

DELIMITER ;


/* PROCEDURE-获取运维审批人*/
DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `getDownloadApproverByUserId`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `getDownloadApproverByUserId`(IN userId VARCHAR(32))
BEGIN   
     
      DECLARE temp_department_id VARCHAR(50); 
      DECLARE temp_count INT; 
      DECLARE department_name VARCHAR(50); 
      DECLARE temp_parent_name VARCHAR(50); 
      DECLARE done INT DEFAULT 0; 
      DECLARE temp_approver_id TEXT; 
      DECLARE temp_approver_name TEXT;   
      DECLARE temp_approver_account TEXT;   
      
      SELECT  fort_user.fort_department_id INTO temp_department_id FROM fort_user WHERE fort_user.fort_user_id = userId;
    DROP TEMPORARY TABLE IF EXISTS temp_approve;    
    CREATE TEMPORARY TABLE temp_approve(
            approve_id VARCHAR(600)
           ,approve_name VARCHAR(300)
           ,approve_account VARCHAR(300)
       );
       
    /* download_approvers,是一个视图,但在集群中报错,所以不用,转而用sql */
     DROP TEMPORARY TABLE IF EXISTS temp_download_approvers;   
     CREATE TEMPORARY TABLE temp_download_approvers(
                             fort_approver_id VARCHAR(40),
			     fort_approver_name VARCHAR(70),
			     fort_department_id VARCHAR(40),
			     fort_department_name VARCHAR(70)
     );
     INSERT INTO temp_download_approvers(fort_approver_id,fort_approver_name,fort_department_id,fort_department_name)
     SELECT
	    `fu`.`fort_user_id`,
	    `fu`.`fort_user_name`,
	    `fd`.`fort_department_id`,
	    `fd`.`fort_department_name` 
     FROM `fort`.`fort_user` `fu`,
	  `fort`.`fort_department` `fd`
     WHERE `fu`.`fort_department_id` = `fd`.`fort_department_id`
     AND `fu`.`fort_user_id` IN(SELECT
                                      `fur`.`fort_user_id`
                                 FROM `fort`.`fort_user_role` `fur`
                                 WHERE `fur`.`fort_role_id` IN(SELECT
                                                                    `fr`.`fort_role_id`
                                                               FROM `fort`.`fort_role_privilege` `fr`
                                                               WHERE `fr`.`fort_privilege_id` = (SELECT
                                                                                                       `fp`.`fort_privilege_id`
                                                                                                 FROM `fort`.`fort_privilege` `fp`
                                                                                                 WHERE `fp`.`fort_privilege_code` = 'approval_audit_check')));
     /* download_approvers,是一个视图,但在集群中报错,所以不用,转而用sql */
            
    SET temp_parent_name = ''; 
    groupIdLoop: LOOP       
      SET temp_count = (SELECT COUNT(*) FROM temp_download_approvers WHERE temp_download_approvers.fort_department_id = temp_department_id);      
        IF temp_count = 0 THEN
        SET temp_parent_name = ''; 
                    SET temp_approver_id = NULL;
            SET temp_approver_name = NULL;
            SET temp_approver_account = NULL; 
            
            IF (SELECT fort_parent_id FROM fort_department WHERE fort_department_id = temp_department_id) IS NULL THEN  
                SELECT fort_department.fort_department_name INTO temp_parent_name FROM fort_department WHERE fort_department.fort_department_id=temp_department_id;                 
                LEAVE groupIdLoop;
            END IF;
        
            IF (SELECT fort_parent_id FROM fort_department WHERE fort_department_id = temp_department_id) IS NOT NULL  THEN 
                                
                SELECT fort_parent_id INTO temp_department_id FROM fort_department WHERE fort_department.fort_department_id=temp_department_id;
                
                                
            END IF;
            
        END IF; 
        
        IF temp_count>0 THEN
            SET temp_parent_name = ''; 
    
            SELECT GROUP_CONCAT(DISTINCT(CONCAT(temp_download_approvers.fort_approver_id))  SEPARATOR ',' ) ,GROUP_CONCAT(DISTINCT(CONCAT(fort_user.fort_user_name)) SEPARATOR ',' ),GROUP_CONCAT(DISTINCT(CONCAT(fort_user.fort_user_account)) SEPARATOR ',' )
            INTO temp_approver_id ,temp_approver_name ,temp_approver_account
            FROM fort_user , temp_download_approvers 
            WHERE temp_download_approvers.fort_department_id =temp_department_id  
            AND temp_download_approvers.fort_approver_id = fort_user.fort_user_id
            GROUP BY temp_download_approvers.fort_department_id;
                   
                  userLoop: LOOP 
                                 IF (SELECT fort_parent_id FROM fort_department WHERE fort_department_id = temp_department_id) IS NULL  THEN    
                    SELECT fort_department.fort_department_name INTO department_name FROM fort_department WHERE fort_department.fort_department_id=temp_department_id;              
                    LEAVE userLoop;
                END IF;               
                  
                
                                IF (SELECT fort_parent_id FROM fort_department WHERE fort_department_id = temp_department_id) IS NOT NULL  THEN 
                  
                    
                SELECT CONCAT(fort_department.fort_department_name,' -> ',temp_parent_name) INTO temp_parent_name FROM fort_department WHERE fort_department.fort_department_id=temp_department_id; 
                                SELECT fort_parent_id INTO temp_department_id FROM fort_department WHERE fort_department.fort_department_id=temp_department_id;
                                    
                    END IF;               
                 
                END LOOP userLoop;  
                                SET temp_parent_name = CONCAT( department_name,' -> ',temp_parent_name);    
                                SET temp_parent_name = LEFT(temp_parent_name,CHAR_LENGTH(temp_parent_name)-4);  
            LEAVE groupIdLoop;
        END IF; 
    
        
    
    END LOOP groupIdLoop; 
    INSERT INTO temp_approve(approve_id,approve_name,approve_account) VALUES(temp_approver_id,temp_approver_name,temp_approver_account);
      
      SELECT *  FROM temp_approve WHERE approve_id IS NOT NULL;
     DROP TABLE temp_download_approvers;
     DROP TABLE temp_approve;
    END$$

DELIMITER ;


/* VIEW-审计查看审批人*/
DELIMITER $$

USE `fort`$$

DROP VIEW IF EXISTS `download_approvers`$$

CREATE ALGORITHM=UNDEFINED DEFINER=`mysql`@`127.0.0.1` SQL SECURITY DEFINER VIEW `download_approvers` AS (
SELECT
  `fu`.`fort_user_id`         AS `fort_approver_id`,
  `fu`.`fort_user_name`       AS `fort_approver_name`,
  `fd`.`fort_department_id`   AS `fort_department_id`,
  `fd`.`fort_department_name` AS `fort_department_name`
FROM (`fort_user` `fu`
   JOIN `fort_department` `fd`)
WHERE ((`fu`.`fort_department_id` = `fd`.`fort_department_id`)
       AND `fu`.`fort_user_id` IN(SELECT
                                    `fur`.`fort_user_id`
                                  FROM `fort_user_role` `fur`
                                  WHERE `fur`.`fort_role_id` IN(SELECT
                                                                  `fr`.`fort_role_id`
                                                                FROM `fort_role_privilege` `fr`
                                                                WHERE (`fr`.`fort_privilege_id` = (SELECT
                                                                                                     `fp`.`fort_privilege_id`
                                                                                                   FROM `fort_privilege` `fp`
                                                                                                   WHERE (`fp`.`fort_privilege_code` = 'approval_audit_check')))))))$$

DELIMITER ;


/* PROCEDURE-查询是否有部门审批人*/
DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `hasDepartmentApprover`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `hasDepartmentApprover`(IN userId VARCHAR(32),IN accountId VARCHAR(32),OUT departmentApproverCode INTEGER)
BEGIN   
     
      DECLARE temp_auth_id VARCHAR(100);
      DECLARE temp_approver_code VARCHAR(50);
      DECLARE is_approver INT DEFAULT 0 ;
         
      DECLARE done INT DEFAULT 0; 
     
      
 /*  设置游标*/
      DECLARE cur1 CURSOR FOR SELECT a.fort_authorization_id FROM
(
SELECT fort_authorization_target_proxy.fort_authorization_id FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_target_code='8' AND fort_authorization_target_proxy.fort_target_id = accountId
UNION 
SELECT fort_authorization_target_proxy.fort_authorization_id FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_target_code='16' AND fort_authorization_target_proxy.fort_target_id
IN(SELECT fort_account.fort_resource_id FROM fort_account WHERE fort_account.fort_account_id = accountId)
UNION
SELECT DISTINCT
     fort_authorization_target_proxy.fort_authorization_id FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_target_code='32' AND fort_authorization_target_proxy.fort_target_id
     IN(SELECT fort_resource_group_resource.fort_resource_group_id FROM fort_resource_group_resource WHERE fort_resource_group_resource.fort_resource_id IN(
       SELECT fort_account.fort_resource_id FROM fort_account WHERE fort_account.fort_account_id = accountId )  )     
     ) a,
    
     (
    
     SELECT fort_authorization_target_proxy.fort_authorization_id 
     FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_target_code='2' AND fort_authorization_target_proxy.fort_target_id = userId       
      UNION
         SELECT fort_authorization_target_proxy.fort_authorization_id  FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_target_code='4'
          AND fort_authorization_target_proxy.fort_target_id
         IN(SELECT fort_user_group_user.fort_user_group_id FROM fort_user_group_user WHERE fort_user_group_user.fort_user_id = userId)
    
    ) b
    
    WHERE a.fort_authorization_id = b.fort_authorization_id;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1;      
   /* 打开游标 */
    DROP TEMPORARY TABLE IF EXISTS temp_approve;    
    CREATE TEMPORARY TABLE temp_approve(
            approve_id VARCHAR(600)
       );  
      
      OPEN cur1;
    /* 循环开始 */  
    approveLoop: LOOP  
             
        FETCH cur1 INTO temp_auth_id;
        
                SELECT fort_approver_code INTO temp_approver_code FROM fort_authorization WHERE fort_authorization_id = temp_auth_id;
                           
                
                #如果当前用户是审批人则不需要审批
        SELECT COUNT(*) INTO is_approver FROM department_approvers WHERE fort_approver_id = userId; 
        
        IF is_approver>0 THEN 
            LEAVE approveLoop;
        END IF;                
                
                IF temp_approver_code = 1 OR temp_approver_code = 3 OR temp_approver_code = 5  THEN
                     
                        INSERT INTO temp_approve(approve_id) VALUES(temp_approver_code);
                                     
                END IF;
        
        
        
        IF done = 1 THEN  
            LEAVE approveLoop;  
        END IF;     
        
        
        
    END LOOP approveLoop;
    
        
    
    /* 关闭游标 */  
    CLOSE cur1;       
      SELECT COUNT(*) INTO departmentApproverCode FROM temp_approve;
 
      DROP TABLE temp_approve;
    END$$

DELIMITER ;





/* PROCEDURE-查询是否有上级审批 -sso使用*/
DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `hasApprovers`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `hasApprovers`(IN userId VARCHAR(32),OUT approverUser INTEGER)
BEGIN   
     
      DECLARE temp_department_id VARCHAR(100); 
      DECLARE temp_count INT DEFAULT 0; 
      DECLARE isApprover INT DEFAULT 0;
      DECLARE temp_parent_name VARCHAR(50); 
      DECLARE done INT DEFAULT 0; 
      DECLARE department_name VARCHAR(50); 
      DECLARE temp_approver_id VARCHAR(100); 
      DECLARE temp_approver_name VARCHAR(70);   
      DECLARE temp_approver_account VARCHAR(70);   
      
      SELECT  fort_user.fort_department_id INTO temp_department_id FROM fort_user WHERE fort_user.fort_user_id = userId;
    DROP TEMPORARY TABLE IF EXISTS temp_approve;    
    CREATE TEMPORARY TABLE temp_approve(
            approve_id VARCHAR(300)
           ,approve_name VARCHAR(300)
           ,approve_account VARCHAR(300)
       );  
            
    SET temp_parent_name = ''; 
    groupIdLoop: LOOP       
      SET temp_count = (SELECT COUNT(*) FROM department_approvers WHERE department_approvers.fort_department_id = temp_department_id);      
        IF temp_count = 0 THEN
        SET temp_parent_name = ''; 
                    SET temp_approver_id = NULL;
            SET temp_approver_name = NULL;
            SET temp_approver_account = NULL;    
            
            IF (SELECT fort_parent_id FROM fort_department WHERE fort_department_id = temp_department_id) IS NULL THEN  
                SELECT fort_department.fort_department_name INTO temp_parent_name FROM fort_department WHERE fort_department.fort_department_id=temp_department_id;                 
                LEAVE groupIdLoop;
            END IF;
        
            IF (SELECT fort_parent_id FROM fort_department WHERE fort_department_id = temp_department_id) IS NOT NULL THEN  
                                
                SELECT fort_parent_id INTO temp_department_id FROM fort_department WHERE fort_department.fort_department_id=temp_department_id;
                
                                
            END IF;
            
        END IF; 
        
        IF temp_count>0 THEN
            SET temp_parent_name = ''; 
    
            SELECT GROUP_CONCAT(DISTINCT(CONCAT(department_approvers.fort_approver_id))  SEPARATOR ',' ) ,GROUP_CONCAT(DISTINCT(CONCAT(fort_user.fort_user_name)) SEPARATOR ',' ),GROUP_CONCAT(DISTINCT(CONCAT(fort_user.fort_user_account)) SEPARATOR ',' )
            INTO temp_approver_id ,temp_approver_name ,temp_approver_account
            FROM fort_user , department_approvers 
            WHERE department_approvers.fort_department_id =temp_department_id  
            AND department_approvers.fort_approver_id = fort_user.fort_user_id
            GROUP BY department_approvers.fort_department_id;
                   
                  userLoop: LOOP 
                                 IF (SELECT fort_parent_id FROM fort_department WHERE fort_department_id = temp_department_id) IS NULL THEN 
                    SELECT fort_department.fort_department_name INTO department_name FROM fort_department WHERE fort_department.fort_department_id=temp_department_id;              
                    LEAVE userLoop;
                END IF;               
                  
                
                                IF (SELECT fort_parent_id FROM fort_department WHERE fort_department_id = temp_department_id) IS NOT NULL THEN  
                  
                    
                SELECT CONCAT(fort_department.fort_department_name,' -> ',temp_parent_name) INTO temp_parent_name FROM fort_department WHERE fort_department.fort_department_id=temp_department_id; 
                                SELECT fort_parent_id INTO temp_department_id FROM fort_department WHERE fort_department.fort_department_id=temp_department_id;
                                    
                    END IF;               
                 
                END LOOP userLoop;  
                                SET temp_parent_name = CONCAT( department_name,' -> ',temp_parent_name);    
                                SET temp_parent_name = LEFT(temp_parent_name,CHAR_LENGTH(temp_parent_name)-4);  
            LEAVE groupIdLoop;
        END IF; 
    
    END LOOP groupIdLoop; 
    SELECT COUNT(*) INTO isApprover FROM department_approvers WHERE fort_approver_id = userId;
          
          IF(isApprover>0) THEN
              SET temp_approver_id = NULL;
              SET temp_approver_name = NULL;
              SET temp_approver_account = NULL;         
          END IF; 
    
    INSERT INTO temp_approve(approve_id,approve_name,approve_account) VALUES(temp_approver_id,temp_approver_name,temp_approver_account);
      
      SELECT COUNT(*) INTO approverUser  FROM temp_approve WHERE approve_id IS NOT NULL;
     DROP TABLE temp_approve;
    END$$

DELIMITER ;


/* PROCEDURE-查询是否有审批码 -sso使用*/
DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `hasApproverCode`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `hasApproverCode`(IN userId VARCHAR(32),IN accountId VARCHAR(32),OUT approveCode VARCHAR(32) )
BEGIN   
      DECLARE temp_auth_id VARCHAR(50);
   
      DECLARE temp_approver_code VARCHAR(50);
     
        DECLARE temp_count VARCHAR(50);     
      
    DECLARE done INT DEFAULT 0; 
     
      
 /*  设置游标*/
      DECLARE cur1 CURSOR FOR SELECT a.fort_authorization_id FROM
(
SELECT fort_authorization_target_proxy.fort_authorization_id FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_target_code='8' AND fort_authorization_target_proxy.fort_target_id = accountId
UNION 
SELECT fort_authorization_target_proxy.fort_authorization_id FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_target_code='16' AND fort_authorization_target_proxy.fort_target_id
IN(SELECT fort_account.fort_resource_id FROM fort_account WHERE fort_account.fort_account_id = accountId)
UNION
SELECT DISTINCT
     fort_authorization_target_proxy.fort_authorization_id FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_target_code='32' AND fort_authorization_target_proxy.fort_target_id
     IN(SELECT fort_resource_group_resource.fort_resource_group_id FROM fort_resource_group_resource WHERE fort_resource_group_resource.fort_resource_id IN(
       SELECT fort_account.fort_resource_id FROM fort_account WHERE fort_account.fort_account_id = accountId )  )     
     ) a,
    
     (
    
     SELECT fort_authorization_target_proxy.fort_authorization_id 
     FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_target_code='2' AND fort_authorization_target_proxy.fort_target_id = userId       
      UNION
         SELECT fort_authorization_target_proxy.fort_authorization_id  FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_target_code='4'
          AND fort_authorization_target_proxy.fort_target_id
         IN(SELECT fort_user_group_user.fort_user_group_id FROM fort_user_group_user WHERE fort_user_group_user.fort_user_id = userId)
    
    ) b
    
    WHERE a.fort_authorization_id = b.fort_authorization_id;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1;      
   /* 打开游标 */
    DROP TEMPORARY TABLE IF EXISTS temp_code;   
    CREATE TEMPORARY TABLE temp_code(
            approve_code INT(100)
       );  
      
      OPEN cur1;
    /* 循环开始 */  
    approveLoop: LOOP  
             
        FETCH cur1 INTO temp_auth_id;
        
        IF done = 1 THEN  
                LEAVE approveLoop;  
            END IF;
            
        SELECT fort_approver_code INTO temp_approver_code FROM fort_authorization WHERE fort_authorization_id = temp_auth_id;
                
             IF (temp_approver_code IS NOT NULL AND temp_approver_code <> 0 ) THEN
               INSERT INTO temp_code(approve_code) VALUES(temp_approver_code);
            
            END IF;     
  
    END LOOP approveLoop;
        
        
    
    /* 关闭游标 */  
    CLOSE cur1;       
        SELECT COUNT(*) INTO approveCode FROM temp_code;
     
      DROP TABLE temp_code;
    END$$

DELIMITER ;

/* PROCEDURE-查看是否配置上级审批人*/
DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `hasApprover`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `hasApprover`(IN userId VARCHAR(32),IN accountId VARCHAR(32))
BEGIN   
     
      DECLARE temp_auth_id VARCHAR(100);
      DECLARE temp_approver_code VARCHAR(50);
      DECLARE is_approver INT DEFAULT 0 ;
         
      DECLARE done INT DEFAULT 0; 
     
      
 /*  设置游标*/
      DECLARE cur1 CURSOR FOR SELECT a.fort_authorization_id FROM
(
SELECT fort_authorization_target_proxy.fort_authorization_id FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_target_code='8' AND fort_authorization_target_proxy.fort_target_id = accountId
UNION 
SELECT fort_authorization_target_proxy.fort_authorization_id FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_target_code='16' AND fort_authorization_target_proxy.fort_target_id
IN(SELECT fort_account.fort_resource_id FROM fort_account WHERE fort_account.fort_account_id = accountId)
UNION
SELECT DISTINCT
     fort_authorization_target_proxy.fort_authorization_id FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_target_code='32' AND fort_authorization_target_proxy.fort_target_id
     IN(SELECT fort_resource_group_resource.fort_resource_group_id FROM fort_resource_group_resource WHERE fort_resource_group_resource.fort_resource_id IN(
       SELECT fort_account.fort_resource_id FROM fort_account WHERE fort_account.fort_account_id = accountId )  )     
     ) a,
    
     (
    
     SELECT fort_authorization_target_proxy.fort_authorization_id 
     FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_target_code='2' AND fort_authorization_target_proxy.fort_target_id = userId       
      UNION
         SELECT fort_authorization_target_proxy.fort_authorization_id  FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_target_code='4'
          AND fort_authorization_target_proxy.fort_target_id
         IN(SELECT fort_user_group_user.fort_user_group_id FROM fort_user_group_user WHERE fort_user_group_user.fort_user_id = userId)
    
    ) b
    
    WHERE a.fort_authorization_id = b.fort_authorization_id;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1;      
   /* 打开游标 */
    DROP TEMPORARY TABLE IF EXISTS temp_approve;    
    CREATE TEMPORARY TABLE temp_approve(
            approve_id VARCHAR(600)
       );  
      
      OPEN cur1;
    /* 循环开始 */  
    approveLoop: LOOP  
             
        FETCH cur1 INTO temp_auth_id;
        
                SELECT fort_approver_code INTO temp_approver_code FROM fort_authorization WHERE fort_authorization_id = temp_auth_id;
                           
                
                #如果当前用户是审批人则不需要审批
        SELECT COUNT(*) INTO is_approver FROM department_approvers WHERE fort_approver_id = userId; 
        
        IF is_approver>0 THEN 
            LEAVE approveLoop;
        END IF;                
                
                IF temp_approver_code = 1 OR temp_approver_code = 3 OR temp_approver_code = 5  THEN
                     
                        INSERT INTO temp_approve(approve_id) VALUES(temp_approver_code);
                                     
                END IF;
        
        
        
        IF done = 1 THEN  
            LEAVE approveLoop;  
        END IF;     
        
        
        
    END LOOP approveLoop;
    
        
    
    /* 关闭游标 */  
    CLOSE cur1;       
      SELECT COUNT(*) FROM temp_approve;
 
      DROP TABLE temp_approve;
    END$$

DELIMITER ;


/* PROCEDURE-获取上级审批人*/
DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `getApproverByUserId`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `getApproverByUserId`(IN userId VARCHAR(32))
BEGIN   
     
      DECLARE temp_department_id VARCHAR(100); 
      DECLARE temp_count INT; 
      DECLARE department_name VARCHAR(50); 
      DECLARE temp_parent_name VARCHAR(50); 
      DECLARE done INT DEFAULT 0; 
      DECLARE temp_approver_id VARCHAR(100); 
      DECLARE temp_approver_name VARCHAR(70);   
      DECLARE temp_approver_account VARCHAR(70);   
      
      SELECT  fort_user.fort_department_id INTO temp_department_id FROM fort_user WHERE fort_user.fort_user_id = userId;
    DROP TEMPORARY TABLE IF EXISTS temp_approve;    
    CREATE TEMPORARY TABLE temp_approve(
            approve_id VARCHAR(600)
           ,approve_name VARCHAR(300)
           ,approve_account VARCHAR(300)
       );  
            
    SET temp_parent_name = ''; 
    groupIdLoop: LOOP       
      SET temp_count = (SELECT COUNT(*) FROM department_approvers WHERE department_approvers.fort_department_id = temp_department_id);      
        IF temp_count = 0 THEN
        SET temp_parent_name = ''; 
                    SET temp_approver_id = NULL;
            SET temp_approver_name = NULL;
            SET temp_approver_account = NULL; 
            
            IF (SELECT fort_parent_id FROM fort_department WHERE fort_department_id = temp_department_id) IS NULL THEN  
                SELECT fort_department.fort_department_name INTO temp_parent_name FROM fort_department WHERE fort_department.fort_department_id=temp_department_id;                 
                LEAVE groupIdLoop;
            END IF;
        
            IF (SELECT fort_parent_id FROM fort_department WHERE fort_department_id = temp_department_id) IS NOT NULL  THEN 
                                
                SELECT fort_parent_id INTO temp_department_id FROM fort_department WHERE fort_department.fort_department_id=temp_department_id;
                
                                
            END IF;
            
        END IF; 
        
        IF temp_count>0 THEN
            SET temp_parent_name = ''; 
    
            SELECT GROUP_CONCAT(DISTINCT(CONCAT(department_approvers.fort_approver_id))  SEPARATOR ',' ) ,GROUP_CONCAT(DISTINCT(CONCAT(fort_user.fort_user_name)) SEPARATOR ',' ),GROUP_CONCAT(DISTINCT(CONCAT(fort_user.fort_user_account)) SEPARATOR ',' )
            INTO temp_approver_id ,temp_approver_name ,temp_approver_account
            FROM fort_user , department_approvers 
            WHERE department_approvers.fort_department_id =temp_department_id  
            AND department_approvers.fort_approver_id = fort_user.fort_user_id
            GROUP BY department_approvers.fort_department_id;
                   
                  userLoop: LOOP 
                                 IF (SELECT fort_parent_id FROM fort_department WHERE fort_department_id = temp_department_id) IS NULL  THEN    
                    SELECT fort_department.fort_department_name INTO department_name FROM fort_department WHERE fort_department.fort_department_id=temp_department_id;              
                    LEAVE userLoop;
                END IF;               
                  
                
                                IF (SELECT fort_parent_id FROM fort_department WHERE fort_department_id = temp_department_id) IS NOT NULL  THEN 
                  
                    
                SELECT CONCAT(fort_department.fort_department_name,' -> ',temp_parent_name) INTO temp_parent_name FROM fort_department WHERE fort_department.fort_department_id=temp_department_id; 
                                SELECT fort_parent_id INTO temp_department_id FROM fort_department WHERE fort_department.fort_department_id=temp_department_id;
                                    
                    END IF;               
                 
                END LOOP userLoop;  
                                SET temp_parent_name = CONCAT( department_name,' -> ',temp_parent_name);    
                                SET temp_parent_name = LEFT(temp_parent_name,CHAR_LENGTH(temp_parent_name)-4);  
            LEAVE groupIdLoop;
        END IF; 
    
        
    
    END LOOP groupIdLoop; 
    INSERT INTO temp_approve(approve_id,approve_name,approve_account) VALUES(temp_approver_id,temp_approver_name,temp_approver_account);
      
      SELECT *  FROM temp_approve WHERE approve_id IS NOT NULL;
     DROP TABLE temp_approve;
    END$$

DELIMITER ;

 
/* VIEW-部门审批人*/
DELIMITER $$

USE `fort`$$

DROP VIEW IF EXISTS `department_approvers`$$

CREATE ALGORITHM=UNDEFINED DEFINER=`mysql`@`127.0.0.1` SQL SECURITY DEFINER VIEW `department_approvers` AS (
SELECT
  `fu`.`fort_user_id`         AS `fort_approver_id`,
  `fu`.`fort_user_name`       AS `fort_approver_name`,
  `fd`.`fort_department_id`   AS `fort_department_id`,
  `fd`.`fort_department_name` AS `fort_department_name`
FROM (`fort_user` `fu`
   JOIN `fort_department` `fd`)
WHERE ((`fu`.`fort_department_id` = `fd`.`fort_department_id`)
       AND `fu`.`fort_user_id` IN(SELECT
                                    `fur`.`fort_user_id`
                                  FROM `fort_user_role` `fur`
                                  WHERE `fur`.`fort_role_id` IN(SELECT
                                                                  `fr`.`fort_role_id`
                                                                FROM `fort_role_privilege` `fr`
                                                                WHERE (`fr`.`fort_privilege_id` = (SELECT
                                                                                                     `fp`.`fort_privilege_id`
                                                                                                   FROM `fort_privilege` `fp`
                                                                                                   WHERE (`fp`.`fort_privilege_code` = 'approval_operation_access')))))))$$

DELIMITER ;


DELIMITER $$

USE `fort`$$

DROP FUNCTION IF EXISTS `selectDepartmentParentList`$$

CREATE DEFINER=`mysql`@`127.0.0.1` FUNCTION `selectDepartmentParentList`(rootId VARCHAR(24)) RETURNS VARCHAR(10000) CHARSET utf8
BEGIN
    DECLARE sTemp VARCHAR(10000); 
    DECLARE sTempChd VARCHAR(10000);  
    SET sTemp = '';
    SET sTempChd =rootId ;
      WHILE sTempChd IS NOT NULL DO         
         SET sTemp = CONCAT(sTemp,',',sTempChd);
         SELECT GROUP_CONCAT(fort_parent_id) INTO sTempChd FROM fort_department WHERE FIND_IN_SET(fort_department.fort_department_id,sTempChd)>0;  
     END WHILE; 
     SET sTemp = SUBSTRING(sTemp,2);
     RETURN sTemp; 
   END$$

DELIMITER ;

DELIMITER $$

USE `fort`$$

DROP FUNCTION IF EXISTS `selectDepartmentChildList`$$

CREATE DEFINER=`mysql`@`127.0.0.1` FUNCTION `selectDepartmentChildList`(rootId VARCHAR(10000)) RETURNS VARCHAR(10000) CHARSET utf8
BEGIN
    DECLARE sTemp VARCHAR(10000); 
    DECLARE sTempChd VARCHAR(10000);  
    SET sTemp = '';
    SET sTempChd =rootId ;
      WHILE sTempChd IS NOT NULL DO         
         SET sTemp = CONCAT(sTemp,',',sTempChd);
         SELECT GROUP_CONCAT(fort_department_id) INTO sTempChd FROM fort_department WHERE FIND_IN_SET(fort_parent_id,sTempChd)>0;  
     END WHILE; 
     RETURN sTemp; 
   END$$

DELIMITER ;


DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `selectResourceAccountByFortUserId`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `selectResourceAccountByFortUserId`(IN user_id VARCHAR(32))
BEGIN   
      DECLARE done INT DEFAULT -1;  
      DECLARE temp_auth_id VARCHAR(32); 
      DECLARE temp_code INT;   
      DECLARE temp_resource_id VARCHAR(32);  
      DECLARE temp_resource_group VARCHAR(3000);   
      DECLARE temp_resource_group_string VARCHAR(3000); 
      DECLARE temp_sql_string TEXT; 
 
            
    /*  设置游标*/ 
    /*   */
      DECLARE select_auth_for_temp_auth_id CURSOR FOR SELECT DISTINCT fort_authorization.fort_authorization_id,fort_authorization.fort_authorization_code  FROM fort_authorization,temp_sso WHERE  fort_authorization.fort_authorization_id = temp_sso.auth_id;
      DECLARE select_auth_for_temp_sso CURSOR FOR SELECT fort_resource_id,fort_resource_type_id FROM temp_more_sso;
     /*  定义相关的中间组件 */ 
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1;  
      DROP TEMPORARY TABLE IF EXISTS temp_sso;  
      /*  根据用户查询所有的授权id*/
      CREATE TEMPORARY TABLE temp_sso(
           auth_id  VARCHAR(40) 
          ,account_id VARCHAR(40) 
          ,resource_id VARCHAR(40) 
          ,auth_code INT  
       );
       
          /*  查询出 资源对应的资源 详细信息 */
        DROP TEMPORARY TABLE IF EXISTS temp_more_sso;   
        CREATE TEMPORARY TABLE temp_more_sso(  
           fort_resource_name VARCHAR(50) 
          ,fort_resource_ip VARCHAR(50)
          ,fort_account_name VARCHAR(50)
          ,fort_account_password  VARCHAR(2000)
       );
         
        /*  根据用户id,查询授权id，并插入 */  
         INSERT INTO temp_sso(auth_id) SELECT DISTINCT fort_authorization_user.fort_authorization_id FROM fort_authorization_user WHERE fort_authorization_user.fort_user_id = user_id; 
        
        /* 根据用户组id,查询授权id，并插入*/  
         INSERT INTO temp_sso(auth_id) SELECT DISTINCT fort_authorization_user_group.fort_authorization_id FROM fort_authorization_user_group,(SELECT fort_user.fort_user_group_id AS group_id FROM fort_user WHERE fort_user.fort_user_id = user_id ) t_group 
        WHERE FIND_IN_SET (fort_authorization_user_group.fort_user_group_id,t_group.group_id) ; 
     /* 根据授权id 查询对应的查询帐号 */
       
      /* 打开游标 */  
      OPEN select_auth_for_temp_auth_id;
   
    /* 循环开始 */  
      tempAuthLoop: LOOP  
     
        /* 移动游标并赋值 */  
        FETCH select_auth_for_temp_auth_id INTO temp_auth_id,temp_code;  
        IF done = 1 THEN   
          LEAVE tempAuthLoop;  
        END IF;  
        /* do something */
         IF (temp_code&8 = 8 ) THEN
         INSERT INTO temp_sso(account_id,resource_id) SELECT DISTINCT fort_authorization_account.fort_account_id,fort_authorization_account.fort_resource_id FROM fort_authorization_account WHERE fort_authorization_account.fort_authorization_id = temp_auth_id ;
         END IF;  
         IF (temp_code&16 = 16 ) THEN
              INSERT INTO temp_sso(account_id,resource_id) SELECT DISTINCT fort_account.fort_account_id, fort_resource.fort_resource_id FROM fort_account,fort_resource,fort_authorization_resource 
             WHERE fort_authorization_resource.fort_authorization_id = temp_auth_id  AND fort_authorization_resource.fort_resource_id = fort_resource.fort_resource_id 
                     AND fort_resource.fort_resource_id = fort_account.fort_resource_id AND fort_resource.fort_parent_id IS NULL AND fort_account.fort_is_allow_authorized = 1 ;
       
         INSERT INTO temp_sso(account_id,resource_id) SELECT DISTINCT fort_account.fort_account_id, fort_resource.fort_resource_id FROM fort_account,fort_resource,fort_authorization_resource 
                     WHERE fort_authorization_resource.fort_authorization_id = temp_auth_id AND fort_authorization_resource.fort_resource_id = fort_resource.fort_resource_id 
                     AND fort_resource.fort_parent_id = fort_account.fort_resource_id AND fort_resource.fort_parent_id IS NOT NULL AND fort_account.fort_is_allow_authorized = 1;
         END IF; 
         
         IF (temp_code&32 = 32 ) THEN
         
         SELECT GROUP_CONCAT( fort_authorization_resource_group.fort_resource_group_id) INTO temp_resource_group_string FROM fort_authorization_resource_group WHERE fort_authorization_resource_group.fort_authorization_id = temp_auth_id;
        
         INSERT INTO temp_sso(account_id,resource_id) SELECT DISTINCT fort_account.fort_account_id, fort_resource.fort_resource_id FROM fort_account,fort_resource
                    WHERE  fort_resource.fort_resource_id = fort_account.fort_resource_id AND fort_resource.fort_parent_id IS NULL AND fort_resource.fort_resource_state <> 2 AND fort_account.fort_is_allow_authorized = 1
                    AND FIND_IN_SET (fort_resource.fort_resource_group_id,temp_resource_group_string) >0 ;
         INSERT INTO temp_sso(account_id,resource_id)  SELECT DISTINCT fort_account.fort_account_id, fort_resource.fort_resource_id FROM fort_account,fort_resource
                    WHERE  fort_resource.fort_parent_id = fort_account.fort_resource_id AND fort_resource.fort_parent_id IS NOT NULL AND fort_resource.fort_resource_state <> 2 AND fort_account.fort_is_allow_authorized = 1
                    AND FIND_IN_SET (fort_resource.fort_resource_group_id,temp_resource_group_string) >0 ; 
         END IF; 
        END LOOP tempAuthLoop;  
    
   # select  fort_account.fort_account_id,fort_account.fort_account_name,fort_account.fort_is_allow_authorized,fort_resource.fort_resource_name,fort_resource.fort_resource_state from fort_resource ,fort_account,temp_sso where temp_sso.account_id = fort_account.fort_account_id AND fort_account.fort_resource_id = fort_resource.fort_resource_id ;
    
    /* 关闭游标 */  
     CLOSE select_auth_for_temp_auth_id;  
       SET temp_sql_string = CONCAT(
       'insert into temp_more_sso(fort_resource_name,fort_resource_ip,fort_account_name,fort_account_password ) SELECT ',
       'fort_resource.fort_resource_name,fort_resource.fort_resource_ip,',  
           ' fort_account.fort_account_name,',
       ' fort_account.fort_account_password  ',
            ' FROM ', 
       'temp_sso ,',    
       'fort_account ,',
       'fort_resource ',
       ' WHERE  ',
       '  temp_sso.auth_id IS NULL  ',
       ' AND fort_resource.fort_resource_state = 1 ',
       ' AND temp_sso.account_id = fort_account.fort_account_id ',
       ' AND temp_sso.resource_id = fort_resource.fort_resource_id '
       );
     SET @temp_user_sql_string = temp_sql_string;
     PREPARE stmt FROM  @temp_user_sql_string; 
     # select temp_sql_string;
     EXECUTE stmt;      
     DEALLOCATE PREPARE stmt;   
     
     SELECT * FROM temp_more_sso;
    DROP TABLE temp_sso; 
    DROP TABLE temp_more_sso;
    END$$

DELIMITER ;



DELIMITER $$

USE `fort`$$

DROP FUNCTION IF EXISTS `selectResourceTypeChildList`$$

CREATE DEFINER=`mysql`@`127.0.0.1` FUNCTION `selectResourceTypeChildList`(rootId VARCHAR(32)) RETURNS VARCHAR(10000) CHARSET utf8
BEGIN
    DECLARE sTemp VARCHAR(10000); 
    DECLARE sTempChd VARCHAR(10000);  
    SET sTemp = '';
    SET sTempChd =rootId ;
      WHILE sTempChd IS NOT NULL DO         
         SET sTemp = CONCAT(sTemp,',',sTempChd);
         SELECT GROUP_CONCAT(fort_resource_type_id) INTO sTempChd FROM fort_resource_type WHERE FIND_IN_SET(fort_parent_id,sTempChd)>0;  
     END WHILE; 
     SET sTemp = SUBSTRING(sTemp,2);
     RETURN sTemp; 
   END$$

DELIMITER ;


DELIMITER $$

USE `fort`$$

DROP FUNCTION IF EXISTS `selectResourceTypePid`$$

CREATE DEFINER=`mysql`@`127.0.0.1` FUNCTION `selectResourceTypePid`(rootId VARCHAR(24)) RETURNS VARCHAR(10000) CHARSET utf8
BEGIN
    DECLARE sTemp VARCHAR(10000); 
    DECLARE sTempChd VARCHAR(10000);  
    SET sTemp = '';
     
    SET sTempChd =rootId ;
      WHILE sTempChd IS NOT NULL DO         
         SET sTemp = CONCAT(sTempChd);
         SELECT GROUP_CONCAT(fort_parent_id) INTO sTempChd FROM fort_resource_type WHERE FIND_IN_SET(fort_resource_type_id,sTempChd)>0;  
     END WHILE; 
     RETURN sTemp; 
   END$$

DELIMITER ;


DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `getAccountByPasswordPlanId`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `getAccountByPasswordPlanId`(IN `plan_id` VARCHAR(50))
BEGIN 
    DECLARE done INT DEFAULT -1;  
    DECLARE plan_code INT(11); 
    DECLARE resource_id VARCHAR(24);
    DECLARE strategy_password_id VARCHAR(24);
    DECLARE strategy_password_name VARCHAR(32);
    DECLARE period INT(11);
    DECLARE password_length_min INT(11);
    DECLARE password_length_max INT(11);
    DECLARE digital_length INT(11);
    DECLARE lowercase_letter_length INT(11);
    DECLARE capital_letter_length INT(11);
    DECLARE special_characters_length INT(11);
    DECLARE forbidden_character_value VARCHAR(2000);
    DECLARE counts INT(11);
    
    
    DECLARE cur1 CURSOR FOR  SELECT fort_resource_id FROM temp_plan;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1;  
    
    DROP TEMPORARY TABLE IF EXISTS temp_plan;   
    CREATE TEMPORARY TABLE temp_plan(
        fort_account_id  VARCHAR(24) NOT NULL
        ,fort_account_name  VARCHAR(32)
        ,fort_account_password  VARCHAR(256)
        ,fort_resource_id VARCHAR(24)
        ,fort_resource_name VARCHAR(32)
        ,fort_resource_type_id VARCHAR(24)
        ,fort_resource_ip VARCHAR(32)
        ,fort_admin_account VARCHAR(64)
        ,fort_admin_password VARCHAR(256)
        ,fort_connection_protocol VARCHAR(24)
        ,fort_connection_port VARCHAR(8)
        ,fort_connection_timeout VARCHAR(64)
        ,fort_analytical_timeout VARCHAR(64)
        ,fort_up_super_password VARCHAR(64)
        ,fort_base_dn VARCHAR(64)
        ,fort_domain_name VARCHAR(64)
        ,fort_database_name VARCHAR(64)
        ,fort_database_server_name VARCHAR(64)
        ,fort_strategy_password_id VARCHAR(24)
        ,fort_strategy_password_name VARCHAR(32)
        ,fort_period INT(11)
        ,fort_password_length_min INT(11)
        ,fort_password_length_max INT(11)
        ,fort_digital_length INT(11)
        ,fort_lowercase_letter_length INT(11)
        ,fort_capital_letter_length INT(11)
        ,fort_special_characters_length INT(11) 
        ,fort_forbidden_character_value VARCHAR(2000)
    );
        SET plan_code = (SELECT fort_plan_password.fort_plan_code FROM fort_plan_password 
                                        WHERE fort_plan_password.fort_plan_password_id=plan_id);
    IF (plan_code&1 = 1 ) THEN
            INSERT INTO temp_plan(fort_account_id,fort_account_name,fort_account_password,fort_resource_id,fort_resource_name,fort_resource_type_id,
            fort_resource_ip,fort_admin_account,fort_admin_password,fort_connection_protocol,fort_connection_port,fort_connection_timeout,fort_analytical_timeout,
            fort_up_super_password,fort_base_dn,fort_domain_name,fort_database_name,fort_database_server_name)
            SELECT 
                fort_account.fort_account_id,fort_account.fort_account_name,fort_account.fort_account_password,fort_resource.fort_resource_id,
                fort_resource.fort_resource_name,fort_resource.fort_resource_type_id,fort_resource.fort_resource_ip,fort_resource.fort_admin_account,
                fort_resource.fort_admin_password,fort_resource.fort_connection_protocol,fort_resource.fort_connection_port,fort_resource.fort_connection_timeout,
                fort_resource.fort_analytical_timeout,fort_resource.fort_up_super_password,fort_resource.fort_base_dn,fort_resource.fort_domain_name,
                fort_resource.fort_database_name,fort_resource.fort_database_server_name
            FROM  fort_account,fort_resource,fort_plan_password_target_proxy
            WHERE fort_plan_password_target_proxy.fort_target_id = fort_account.fort_account_id
            AND fort_account.fort_resource_id =  fort_resource.fort_resource_id
            AND fort_plan_password_target_proxy.fort_plan_id = plan_id
            AND fort_plan_password_target_proxy.fort_target_code = 1
            AND fort_account.fort_account_password IS NOT NULL
            AND fort_account.fort_account_name !='$user'
	AND fort_account.fort_is_allow_authorized =1;                   
        END IF;  
    IF (plan_code&2 = 2) THEN
            INSERT INTO temp_plan(fort_account_id,fort_account_name,fort_account_password,fort_resource_id,fort_resource_name,fort_resource_type_id,
            fort_resource_ip,fort_admin_account,fort_admin_password,fort_connection_protocol,fort_connection_port,fort_connection_timeout,fort_analytical_timeout,
            fort_up_super_password,fort_base_dn,fort_domain_name,fort_database_name,fort_database_server_name)
            SELECT 
                fort_account.fort_account_id,fort_account.fort_account_name,fort_account.fort_account_password,fort_resource.fort_resource_id,
                fort_resource.fort_resource_name,fort_resource.fort_resource_type_id,fort_resource.fort_resource_ip,fort_resource.fort_admin_account,
                fort_resource.fort_admin_password,fort_resource.fort_connection_protocol,fort_resource.fort_connection_port,fort_resource.fort_connection_timeout,
                fort_resource.fort_analytical_timeout,fort_resource.fort_up_super_password,fort_resource.fort_base_dn,fort_resource.fort_domain_name,
                fort_resource.fort_database_name,fort_resource.fort_database_server_name
            FROM  fort_account,fort_resource,fort_plan_password_target_proxy
            WHERE fort_plan_password_target_proxy.fort_target_id = fort_resource.fort_resource_id
            AND fort_plan_password_target_proxy.fort_plan_id = plan_id
            AND fort_account.fort_resource_id = fort_resource.fort_resource_id
            AND fort_plan_password_target_proxy.fort_target_code = 2
            AND fort_account.fort_account_password IS NOT NULL
            AND fort_account.fort_account_name !='$user'
        AND fort_account.fort_is_allow_authorized =1;           
        END IF;  
    IF (plan_code&4 = 4 ) THEN
            INSERT INTO temp_plan(fort_account_id,fort_account_name,fort_account_password,fort_resource_id,fort_resource_name,fort_resource_type_id,
            fort_resource_ip,fort_admin_account,fort_admin_password,fort_connection_protocol,fort_connection_port,fort_connection_timeout,fort_analytical_timeout,
            fort_up_super_password,fort_base_dn,fort_domain_name,fort_database_name,fort_database_server_name)
            SELECT 
                fort_account.fort_account_id,fort_account.fort_account_name,fort_account.fort_account_password,fort_resource.fort_resource_id,
                fort_resource.fort_resource_name,fort_resource.fort_resource_type_id,fort_resource.fort_resource_ip,fort_resource.fort_admin_account,
                fort_resource.fort_admin_password,fort_resource.fort_connection_protocol,fort_resource.fort_connection_port,fort_resource.fort_connection_timeout,
                fort_resource.fort_analytical_timeout,fort_resource.fort_up_super_password,fort_resource.fort_base_dn,fort_resource.fort_domain_name,
                fort_resource.fort_database_name,fort_resource.fort_database_server_name
            FROM  fort_account,fort_resource,fort_plan_password_target_proxy,fort_resource_group,fort_resource_group_resource
            WHERE fort_resource_group.fort_resource_group_id = fort_plan_password_target_proxy.fort_target_id
            AND fort_plan_password_target_proxy.fort_plan_id = plan_id
            AND fort_account.fort_resource_id = fort_resource.fort_resource_id
            AND fort_resource_group.fort_resource_group_id = fort_resource_group_resource.fort_resource_group_id
            AND fort_resource.fort_resource_id = fort_resource_group_resource.fort_resource_id
            AND fort_plan_password_target_proxy.fort_target_code = 3
            AND fort_account.fort_account_password IS NOT NULL
            AND fort_account.fort_account_name !='$user'
        AND fort_account.fort_is_allow_authorized =1;     
    END IF; 
            
    OPEN cur1;
    
    myLoop:LOOP
        FETCH cur1 INTO resource_id;  
    IF done = 1 THEN   
            LEAVE myLoop;  
    END IF;     
    SELECT  strategy.fort_strategy_password_id,strategy.fort_strategy_password_name,strategy.fort_period,strategy.fort_password_length_min,
        strategy.fort_password_length_max,strategy.fort_digital_length,strategy.fort_lowercase_letter_length,strategy.fort_capital_letter_length,
        strategy.fort_special_characters_length
    INTO    strategy_password_id,strategy_password_name,period,password_length_min,password_length_max,digital_length,lowercase_letter_length,
        capital_letter_length,special_characters_length 
    FROM    fort_strategy_password strategy,fort_resource
    WHERE   strategy.fort_strategy_password_id = fort_resource.fort_strategy_password_id
    AND     fort_resource.fort_resource_id = resource_id;
        
    SELECT GROUP_CONCAT(DISTINCT fort_forbidden_character_value SEPARATOR ';:;') 
    INTO forbidden_character_value
    FROM fort_forbidden_character 
    WHERE fort_strategy_password_id = strategy_password_id;
        
    UPDATE temp_plan SET fort_strategy_password_id = strategy_password_id,fort_strategy_password_name=strategy_password_name,fort_period=period,
        fort_password_length_min=password_length_min,fort_password_length_max=password_length_max,fort_digital_length=digital_length,
        fort_lowercase_letter_length=lowercase_letter_length,fort_capital_letter_length=capital_letter_length,
        fort_special_characters_length=special_characters_length,fort_forbidden_character_value=forbidden_character_value
    WHERE fort_resource_id = resource_id;
    END LOOP myLoop;    
   
    CLOSE cur1;     
  SELECT 
        fort_account_id,fort_account_name,fort_account_password,fort_resource_id,fort_resource_name,fort_resource_type_id,fort_resource_ip,fort_admin_account,
        fort_admin_password,fort_connection_protocol,fort_connection_port,fort_connection_timeout,fort_analytical_timeout,fort_up_super_password,fort_base_dn,
        fort_domain_name,fort_database_name,fort_database_server_name,fort_strategy_password_id,fort_strategy_password_name,fort_period,fort_password_length_min,
        fort_password_length_max,fort_digital_length,fort_lowercase_letter_length,fort_capital_letter_length,fort_special_characters_length,fort_forbidden_character_value
  FROM  temp_plan;
        
  DROP TABLE temp_plan;
END$$

DELIMITER ;

DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `getPlanPasswordAccount`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `getPlanPasswordAccount`(IN `plan_id` VARCHAR(24))
BEGIN 
    DECLARE plan_code INT(11); 
    DECLARE account_id VARCHAR(24);
    DECLARE parent_id VARCHAR(24); 
    DECLARE done INT DEFAULT -1; 
    
    DECLARE cur1 CURSOR FOR  SELECT DISTINCT 
    fort_account_id,fort_parent_id 
    FROM temp_plan;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1; 
    DROP TEMPORARY TABLE IF EXISTS temp_plan;   
    CREATE TEMPORARY TABLE temp_plan(
        fort_account_id  VARCHAR(24) NOT NULL
        ,fort_account_name VARCHAR(32)
        ,fort_account_password VARCHAR(256)
        ,fort_resource_id VARCHAR(24)
        ,fort_resource_name VARCHAR(32)
        ,fort_resource_ip VARCHAR(32) 
        ,fort_resource_type_name VARCHAR(32)  
        ,fort_parent_id VARCHAR(24)  
    );
    SET plan_code = (SELECT fort_plan_password.fort_plan_code 
            FROM fort_plan_password 
            WHERE fort_plan_password.fort_plan_password_id=plan_id);
    IF (plan_code&1 = 1 ) THEN
    INSERT INTO temp_plan
        SELECT  fort_account.fort_account_id,fort_account.fort_account_name,fort_account.fort_account_password,fort_resource.fort_resource_id,
        fort_resource.fort_resource_name,fort_resource.fort_resource_ip,fort_resource_type.fort_resource_type_name,fort_resource_type.fort_parent_id
        FROM  fort_account,fort_resource,fort_plan_password_target_proxy,fort_resource_type
        WHERE fort_plan_password_target_proxy.fort_target_id = fort_account.fort_account_id
        AND fort_account.fort_resource_id =  fort_resource.fort_resource_id
        AND fort_resource.fort_resource_type_id = fort_resource_type.fort_resource_type_id
        AND fort_plan_password_target_proxy.fort_plan_id = plan_id
        AND fort_account.fort_account_password IS NOT NULL
        AND fort_account.fort_account_name != '$user'
        AND fort_plan_password_target_proxy.fort_target_code = 1 
	AND fort_account.fort_is_allow_authorized =1;         
    END IF;  
    IF (plan_code&2 = 2) THEN
        INSERT INTO temp_plan
        SELECT  fort_account.fort_account_id,fort_account.fort_account_name,fort_account.fort_account_password,fort_resource.fort_resource_id,
        fort_resource.fort_resource_name,fort_resource.fort_resource_ip,fort_resource_type.fort_resource_type_name,fort_resource_type.fort_parent_id
        FROM    fort_plan_password_target_proxy,fort_resource,fort_account,fort_resource_type
        WHERE   fort_plan_password_target_proxy.fort_target_id = fort_resource.fort_resource_id
        AND     fort_plan_password_target_proxy.fort_plan_id = plan_id
        AND     fort_resource.fort_resource_type_id = fort_resource_type.fort_resource_type_id
        AND fort_account.fort_resource_id = fort_resource.fort_resource_id
        AND     fort_account.fort_account_password IS NOT NULL
        AND     fort_account.fort_account_name != '$user'
        AND     fort_plan_password_target_proxy.fort_target_code = 2 
	AND fort_account.fort_is_allow_authorized =1;      
    END IF;  
    IF (plan_code&4 = 4 ) THEN
        INSERT INTO temp_plan
        SELECT  fort_account.fort_account_id,fort_account.fort_account_name,fort_account.fort_account_password,fort_resource.fort_resource_id,
        fort_resource.fort_resource_name,fort_resource.fort_resource_ip,fort_resource_type.fort_resource_type_name,fort_resource_type.fort_parent_id
        FROM    fort_resource_group,fort_plan_password_target_proxy,fort_resource,fort_account,fort_resource_type,fort_resource_group_resource
        WHERE   fort_resource_group.fort_resource_group_id = fort_plan_password_target_proxy.fort_target_id
        AND     fort_plan_password_target_proxy.fort_plan_id = plan_id
        AND     fort_resource.fort_resource_type_id = fort_resource_type.fort_resource_type_id
        AND fort_account.fort_resource_id = fort_resource.fort_resource_id
        AND     fort_resource_group.fort_resource_group_id = fort_resource_group_resource.fort_resource_group_id
        AND     fort_resource.fort_resource_id = fort_resource_group_resource.fort_resource_id
        AND     fort_account.fort_account_password IS NOT NULL
        AND     fort_account.fort_account_name != '$user'
        AND     fort_plan_password_target_proxy.fort_target_code = 3 
	AND fort_account.fort_is_allow_authorized =1;   
    END IF;  
        OPEN cur1; 
        myLoop: LOOP    
        FETCH cur1 INTO account_id,parent_id;       
        IF done = 1 THEN   
            LEAVE myLoop; 
        END IF;     
        loo:LOOP            
            IF (parent_id = '1000000000002'||parent_id = '1000000000003'||parent_id = '1000000000004'||parent_id = '1000000000005'||parent_id = '1000000000007') THEN               
                UPDATE temp_plan SET fort_parent_id = parent_id WHERE fort_account_id = account_id;
                LEAVE loo;
            ELSE    
                SELECT fort_parent_id INTO parent_id FROM fort_resource_type WHERE fort_resource_type_id = parent_id;               
             END IF; 
        END LOOP loo;       
    END LOOP myLoop;  
    CLOSE cur1;             
    SELECT DISTINCT fort_account_id,fort_account_name,fort_account_password,fort_resource_id,fort_resource_name,fort_resource_ip,fort_resource_type_name,fort_parent_id
    FROM  temp_plan;
    DROP TABLE temp_plan;
END$$

DELIMITER ;

DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `getPlanPasswordBackupAccount`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `getPlanPasswordBackupAccount`(IN `plan_id` VARCHAR(24))
BEGIN 
    DECLARE plan_code INT(11); 
    DECLARE account_id VARCHAR(24);
    DECLARE parent_id VARCHAR(24); 
    DECLARE done INT DEFAULT -1; 
    
    DECLARE cur1 CURSOR FOR  SELECT DISTINCT 
    fort_account_id,fort_parent_id 
    FROM temp_plan;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1; 
    DROP TEMPORARY TABLE IF EXISTS temp_plan;   
    CREATE TEMPORARY TABLE temp_plan(
        fort_account_id  VARCHAR(24) NOT NULL
        ,fort_account_name VARCHAR(32)
        ,fort_account_password VARCHAR(256)
        ,fort_resource_id VARCHAR(24)
        ,fort_resource_name VARCHAR(32)
        ,fort_resource_ip VARCHAR(32) 
        ,fort_resource_type_name VARCHAR(32)
        ,fort_parent_id VARCHAR(24)
    );
    SET plan_code = (SELECT fort_plan_password_backup.fort_plan_code 
            FROM fort_plan_password_backup
            WHERE fort_plan_password_backup.fort_plan_password_backup_id=plan_id);
    IF (plan_code&1 = 1 ) THEN
    
        INSERT INTO temp_plan       
        SELECT  fort_account.fort_account_id,fort_account.fort_account_name,fort_account.fort_account_password,fort_resource.fort_resource_id,
        fort_resource.fort_resource_name,fort_resource.fort_resource_ip,fort_resource_type.fort_resource_type_name,fort_resource_type.fort_parent_id        
        FROM  fort_account,fort_resource,fort_plan_password_target_proxy,fort_resource_type
        WHERE fort_plan_password_target_proxy.fort_target_id = fort_account.fort_account_id
        AND fort_account.fort_resource_id =  fort_resource.fort_resource_id
        AND fort_resource.fort_resource_type_id = fort_resource_type.fort_resource_type_id
        AND fort_plan_password_target_proxy.fort_plan_id = plan_id
        AND fort_account.fort_account_password IS NOT NULL
        AND fort_account.fort_account_name != '$user'
        AND fort_plan_password_target_proxy.fort_target_code = 1 
	AND fort_account.fort_is_allow_authorized =1;   
            
    END IF;  
    IF (plan_code&2 = 2) THEN
        INSERT INTO temp_plan
        SELECT  fort_account.fort_account_id,fort_account.fort_account_name,fort_account.fort_account_password,fort_resource.fort_resource_id,
        fort_resource.fort_resource_name,fort_resource.fort_resource_ip,fort_resource_type.fort_resource_type_name,fort_resource_type.fort_parent_id
        FROM    fort_plan_password_target_proxy,fort_resource,fort_account,fort_resource_type
        WHERE   fort_plan_password_target_proxy.fort_target_id = fort_resource.fort_resource_id
        AND     fort_plan_password_target_proxy.fort_plan_id = plan_id
        AND     fort_resource.fort_resource_type_id = fort_resource_type.fort_resource_type_id
        AND fort_account.fort_resource_id = fort_resource.fort_resource_id
        AND     fort_account.fort_account_password IS NOT NULL
        AND     fort_account.fort_account_name != '$user'
        AND     fort_plan_password_target_proxy.fort_target_code = 2 
	AND fort_account.fort_is_allow_authorized =1;   
        
    END IF;  
    IF (plan_code&4 = 4 ) THEN
        INSERT INTO temp_plan
        SELECT  fort_account.fort_account_id,fort_account.fort_account_name,fort_account.fort_account_password,fort_resource.fort_resource_id,
        fort_resource.fort_resource_name,fort_resource.fort_resource_ip,fort_resource_type.fort_resource_type_name,fort_resource_type.fort_parent_id
        FROM    fort_resource_group,fort_plan_password_target_proxy,fort_resource,fort_account,fort_resource_type,fort_resource_group_resource
        WHERE   fort_resource_group.fort_resource_group_id = fort_plan_password_target_proxy.fort_target_id
        AND     fort_plan_password_target_proxy.fort_plan_id = plan_id
        AND     fort_resource.fort_resource_type_id = fort_resource_type.fort_resource_type_id
        AND 	fort_account.fort_resource_id = fort_resource.fort_resource_id
        AND     fort_resource_group.fort_resource_group_id = fort_resource_group_resource.fort_resource_group_id
        AND     fort_resource.fort_resource_id = fort_resource_group_resource.fort_resource_id
        AND     fort_account.fort_account_password IS NOT NULL
        AND     fort_account.fort_account_name != '$user'
        AND     fort_plan_password_target_proxy.fort_target_code = 3 
	AND fort_account.fort_is_allow_authorized =1;   
    END IF; 
    OPEN cur1; 
        myLoop: LOOP    
        FETCH cur1 INTO account_id,parent_id;       
        IF done = 1 THEN   
            LEAVE myLoop; 
        END IF;     
        loo:LOOP            
            IF (parent_id = '1000000000002'||parent_id = '1000000000003'||parent_id = '1000000000004'||parent_id = '1000000000005'||parent_id = '1000000000007') THEN               
                UPDATE temp_plan SET fort_parent_id = parent_id WHERE fort_account_id = account_id;
                LEAVE loo;
            ELSE    
                SELECT fort_parent_id INTO parent_id FROM fort_resource_type WHERE fort_resource_type_id = parent_id;
                
             END IF; 
        END LOOP loo;
        
    END LOOP myLoop;  
    CLOSE cur1;             
    SELECT DISTINCT fort_account_id,fort_account_name,fort_account_password,fort_resource_id,fort_resource_name,fort_resource_ip,fort_resource_type_name,fort_parent_id
    FROM  temp_plan;
    DROP TABLE temp_plan;
END$$

DELIMITER ;


DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `getPlanPasswordBackupById`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `getPlanPasswordBackupById`(IN plan_id VARCHAR(50))
BEGIN   
    DECLARE temp_resource MEDIUMTEXT CHARACTER SET utf8mb4;
    DECLARE temp_code VARCHAR(300);
    DECLARE temp_key_admin VARCHAR(200);
    DECLARE temp_department VARCHAR(50);
    
    DROP TEMPORARY TABLE IF EXISTS temp_plan;   
    CREATE TEMPORARY TABLE temp_plan(
        fort_plan_password_backup_id  VARCHAR(24) NOT NULL
        ,fort_plan_password_backup_name VARCHAR(32)
        ,fort_department VARCHAR(50)
        ,fort_run_mode VARCHAR(2)
        ,fort_first_run_time DATETIME
        ,fort_end_run_time DATETIME
        ,fort_run_interval  INT
        ,fort_state VARCHAR(2)
        ,fort_backup_file_name VARCHAR(50)
        ,fort_plan_code INT
        ,fort_password_send_mode VARCHAR(1)
        ,fort_connect_test VARCHAR(1)
        ,fort_password_backup_object VARCHAR(1)
        ,fort_resource MEDIUMTEXT
        ,fort_key_admin VARCHAR(200)
        ,fort_create_by VARCHAR(24)
    ) DEFAULT CHARSET=utf8mb4;
    SET temp_resource='';
    INSERT INTO temp_plan(fort_plan_password_backup_id,fort_plan_password_backup_name,fort_run_mode,fort_first_run_time,fort_end_run_time,
        fort_run_interval,fort_state,fort_backup_file_name,fort_plan_code,fort_password_send_mode,fort_connect_test,fort_password_backup_object,fort_create_by)
    SELECT
    fort_plan_password_backup.fort_plan_password_backup_id,
    fort_plan_password_backup.fort_plan_password_backup_name,
    fort_plan_password_backup.fort_run_mode,
    fort_plan_password_backup.fort_first_run_time,
    fort_plan_password_backup.fort_end_run_time,
    fort_plan_password_backup.fort_run_interval,
    fort_plan_password_backup.fort_state,
    fort_plan_password_backup.fort_backup_file_name,
    fort_plan_password_backup.fort_plan_code,
    fort_plan_password_backup.fort_password_send_mode,
    fort_plan_password_backup.fort_connect_test,
    fort_plan_password_backup.fort_password_backup_object,
    fort_plan_password_backup.fort_create_by
    FROM fort_plan_password_backup
    WHERE fort_plan_password_backup.fort_plan_password_backup_id=plan_id;
    
    SELECT CONCAT(fort_department.fort_department_id,'|',fort_department.fort_department_name) INTO temp_department
    FROM fort_plan_password_backup,fort_department
    WHERE fort_plan_password_backup.fort_department_id = fort_department.fort_department_id
    AND fort_plan_password_backup.fort_plan_password_backup_id = plan_id;
    
    SELECT CONCAT(GROUP_CONCAT(fort_user.fort_user_id),'|',GROUP_CONCAT(fort_user.fort_user_account),'|',GROUP_CONCAT(fort_user.fort_user_name))
    INTO temp_key_admin
    FROM  fort_plan_password_target_proxy,fort_user
    WHERE fort_plan_password_target_proxy.fort_target_id = fort_user.fort_user_id
    AND fort_plan_password_target_proxy.fort_plan_id = plan_id 
    AND fort_plan_password_target_proxy.fort_target_code = 4;   
        
    UPDATE  temp_plan SET fort_key_admin = temp_key_admin,fort_resource = '',fort_department = temp_department 
    WHERE fort_plan_password_backup_id = plan_id ;
    
    SELECT fort_plan_code INTO temp_code FROM temp_plan;
    
    IF (temp_code&1 = 1 ) THEN
        SELECT CONCAT('1:',GROUP_CONCAT(fort_account.fort_account_id),'|',GROUP_CONCAT(fort_account.fort_account_name),'|',
                GROUP_CONCAT(fort_resource.fort_resource_name),'|',GROUP_CONCAT(fort_resource.fort_resource_ip),'|',
                GROUP_CONCAT(fort_resource_type.fort_resource_type_name),'|',
                GROUP_CONCAT(fort_department.fort_department_name),';')
        INTO temp_resource
        FROM  fort_plan_password_target_proxy,fort_resource,fort_account,fort_resource_type,fort_department
        WHERE fort_plan_password_target_proxy.fort_target_id = fort_account.fort_account_id
        AND fort_account.fort_resource_id =  fort_resource.fort_resource_id
        AND fort_plan_password_target_proxy.fort_plan_id = plan_id
        AND fort_resource.fort_resource_type_id = fort_resource_type.fort_resource_type_id
        AND fort_plan_password_target_proxy.fort_target_code = 1
        AND fort_account.fort_account_password IS NOT NULL
        AND fort_account.fort_is_allow_authorized = '1' 
        AND fort_department.fort_department_id = fort_resource.fort_department_id;
                        
        UPDATE  temp_plan SET fort_resource = CONCAT(fort_resource,IFNULL(temp_resource,'')) WHERE fort_plan_password_backup_id = plan_id ;
    END IF;  
        
    IF (temp_code&2 = 2) THEN
            SELECT CONCAT('2:',GROUP_CONCAT(fort_resource.fort_resource_id),'|',GROUP_CONCAT(fort_resource.fort_resource_name),'|',
                GROUP_CONCAT(fort_resource.fort_resource_ip),'|',GROUP_CONCAT(fort_resource_type.fort_resource_type_name),
                '|',GROUP_CONCAT(fort_department.fort_department_name),';')
            INTO temp_resource
            FROM  fort_plan_password_target_proxy,fort_resource,fort_resource_type,fort_department
            WHERE fort_plan_password_target_proxy.fort_target_id = fort_resource.fort_resource_id
            AND fort_plan_password_target_proxy.fort_plan_id = plan_id
            AND fort_resource.fort_resource_type_id = fort_resource_type.fort_resource_type_id
            AND fort_plan_password_target_proxy.fort_target_code = 2 
            AND fort_department.fort_department_id = fort_resource.fort_department_id;
            
            UPDATE temp_plan SET fort_resource =CONCAT(fort_resource,IFNULL(temp_resource,'')) 
            WHERE fort_plan_password_backup_id = plan_id;
        END IF;  
    IF (temp_code&4 = 4 ) THEN
            SELECT CONCAT('4:',GROUP_CONCAT(fort_resource_group.fort_resource_group_id),'|',GROUP_CONCAT(fort_resource_group.fort_resource_group_name),'|',
            GROUP_CONCAT(fort_department.fort_department_name),';')
        INTO temp_resource
            FROM fort_resource_group,fort_plan_password_target_proxy,fort_department
            WHERE fort_resource_group.fort_resource_group_id = fort_plan_password_target_proxy.fort_target_id
            AND  fort_plan_password_target_proxy.fort_plan_id = plan_id
            AND fort_plan_password_target_proxy.fort_target_code = 3
            AND fort_department.fort_department_id = fort_resource_group.fort_department_id;
            
            UPDATE  temp_plan SET fort_resource = CONCAT(fort_resource,IFNULL(temp_resource,'')) 
            WHERE fort_plan_password_backup_id = plan_id;           
    END IF; 
        
  SELECT temp_plan.fort_plan_password_backup_id,temp_plan.fort_plan_password_backup_name, temp_plan.fort_department,temp_plan.fort_run_mode,temp_plan.fort_first_run_time,
    temp_plan.fort_end_run_time,temp_plan.fort_run_interval,temp_plan.fort_state,temp_plan.fort_backup_file_name,fort_password_send_mode,
    fort_connect_test,fort_password_backup_object,temp_plan.fort_resource,temp_plan.fort_key_admin,temp_plan.fort_create_by
  FROM  temp_plan;
  DROP TABLE temp_plan;
END$$

DELIMITER ;


DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `getPlanPasswordById`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `getPlanPasswordById`(IN plan_id VARCHAR(50))
BEGIN   
    DECLARE temp_resource TEXT;
    DECLARE temp_code VARCHAR(300);
    DECLARE temp_key_admin VARCHAR(200);
    DECLARE temp_department VARCHAR(50);
    DROP TEMPORARY TABLE IF EXISTS temp_plan;   
    CREATE TEMPORARY TABLE temp_plan(
        fort_plan_password_id VARCHAR(24),
        fort_plan_password_name VARCHAR(32),
        fort_department VARCHAR(50),
        fort_state VARCHAR(1),
        fort_run_mode VARCHAR(1),
        fort_first_run_time DATETIME,
        fort_end_run_time DATETIME,
        fort_plan_code INT(11),
        fort_run_interval INT(11),
        fort_password_generation_type VARCHAR(1),
        fort_new_password VARCHAR(2000),
        fort_password_send_mode VARCHAR(1),
        fort_connect_test VARCHAR(1),
        fort_key_admin VARCHAR(200),        
        fort_resource TEXT,
        fort_create_by VARCHAR(24)
    );
    SET temp_resource='';
    INSERT INTO temp_plan(fort_plan_password_id,fort_plan_password_name,fort_state,fort_run_mode,fort_first_run_time,fort_end_run_time,
        fort_plan_code,fort_run_interval,fort_password_generation_type,fort_new_password,fort_password_send_mode,fort_connect_test,fort_create_by)
    SELECT
    fort_plan_password.fort_plan_password_id,
    fort_plan_password.fort_plan_password_name,
    fort_plan_password.fort_state,
    fort_plan_password.fort_run_mode,
    fort_plan_password.fort_first_run_time,
    fort_plan_password.fort_end_run_time,
    fort_plan_password.fort_plan_code,
    fort_plan_password.fort_run_interval,
    fort_plan_password.fort_password_generation_type,
    fort_plan_password.fort_new_password,
    fort_plan_password.fort_password_send_mode,
    fort_plan_password.fort_connect_test,
    fort_plan_password.fort_create_by
    FROM fort_plan_password
    WHERE fort_plan_password.fort_plan_password_id=plan_id;
    
    SELECT CONCAT(fort_department.fort_department_id,'|',fort_department.fort_department_name) INTO temp_department
    FROM fort_plan_password,fort_department
    WHERE fort_plan_password.fort_department_id = fort_department.fort_department_id
    AND fort_plan_password.fort_plan_password_id = plan_id;
    
    SELECT CONCAT(GROUP_CONCAT(fort_user.fort_user_id),'|',GROUP_CONCAT(fort_user.fort_user_account),'|',GROUP_CONCAT(fort_user.fort_user_name))
    INTO temp_key_admin
    FROM  fort_plan_password_target_proxy,fort_user
    WHERE fort_plan_password_target_proxy.fort_target_id = fort_user.fort_user_id
    AND fort_plan_password_target_proxy.fort_plan_id = plan_id 
    AND fort_plan_password_target_proxy.fort_target_code = 4;
    
    UPDATE  temp_plan SET fort_key_admin = temp_key_admin,fort_resource = '',fort_department = temp_department 
    WHERE fort_plan_password_id = plan_id ;     
    
    SELECT fort_plan_code INTO temp_code FROM temp_plan;
    IF (temp_code&1 = 1 ) THEN
        SELECT CONCAT('1:',GROUP_CONCAT(fort_account.fort_account_id),'|',GROUP_CONCAT(fort_account.fort_account_name),'|',
            GROUP_CONCAT(fort_resource.fort_resource_name),'|',GROUP_CONCAT(fort_resource.fort_resource_ip),'|',
            GROUP_CONCAT(fort_resource_type.fort_resource_type_name),'|',
            GROUP_CONCAT(fort_department.fort_department_name),';')
        INTO temp_resource
        FROM  fort_plan_password_target_proxy,fort_resource,fort_account,fort_resource_type,fort_department
        WHERE fort_plan_password_target_proxy.fort_target_id = fort_account.fort_account_id
        AND fort_account.fort_resource_id =  fort_resource.fort_resource_id
        AND fort_plan_password_target_proxy.fort_plan_id = plan_id
        AND fort_resource.fort_resource_type_id = fort_resource_type.fort_resource_type_id
        AND fort_plan_password_target_proxy.fort_target_code = 1
        AND fort_account.fort_account_password IS NOT NULL
        AND fort_account.fort_is_allow_authorized = '1' 
        AND fort_department.fort_department_id = fort_resource.fort_department_id;
                
        UPDATE  temp_plan SET fort_resource = CONCAT(fort_resource,IFNULL(temp_resource,'')) WHERE fort_plan_password_id = plan_id ;
    END IF;         
    IF (temp_code&2 = 2) THEN
        SELECT CONCAT('2:',GROUP_CONCAT(fort_resource.fort_resource_id),'|',GROUP_CONCAT(fort_resource.fort_resource_name),'|',
            GROUP_CONCAT(fort_resource.fort_resource_ip),'|',GROUP_CONCAT(fort_resource_type.fort_resource_type_name),
            '|',GROUP_CONCAT(fort_department.fort_department_name),';')
            INTO temp_resource
            FROM  fort_plan_password_target_proxy,fort_resource,fort_resource_type,fort_department
            WHERE fort_plan_password_target_proxy.fort_target_id = fort_resource.fort_resource_id
            AND fort_plan_password_target_proxy.fort_plan_id = plan_id
            AND fort_resource.fort_resource_type_id = fort_resource_type.fort_resource_type_id
            AND fort_plan_password_target_proxy.fort_target_code = 2
            AND fort_department.fort_department_id = fort_resource.fort_department_id;
                
            UPDATE temp_plan SET fort_resource =CONCAT(fort_resource,IFNULL(temp_resource,'')) 
            WHERE fort_plan_password_id = plan_id;
        END IF;  
    IF (temp_code&4 = 4 ) THEN
             SELECT CONCAT('4:',GROUP_CONCAT(fort_resource_group.fort_resource_group_id),'|',GROUP_CONCAT(fort_resource_group.fort_resource_group_name),'|',
            GROUP_CONCAT(fort_department.fort_department_name),';')
            INTO temp_resource
            FROM fort_resource_group,fort_plan_password_target_proxy,fort_department
            WHERE fort_resource_group.fort_resource_group_id = fort_plan_password_target_proxy.fort_target_id
            AND  fort_plan_password_target_proxy.fort_plan_id = plan_id
            AND fort_plan_password_target_proxy.fort_target_code = 3
            AND fort_department.fort_department_id = fort_resource_group.fort_department_id;
            
            UPDATE  temp_plan SET fort_resource = CONCAT(fort_resource,IFNULL(temp_resource,'')) 
            WHERE fort_plan_password_id = plan_id;          
    END IF; 
  SELECT temp_plan.fort_plan_password_id,temp_plan.fort_plan_password_name,temp_plan.fort_department,temp_plan.fort_state,temp_plan.fort_run_mode,
        temp_plan.fort_first_run_time,temp_plan.fort_end_run_time,temp_plan.fort_plan_code,temp_plan.fort_run_interval,temp_plan.fort_password_generation_type,
        temp_plan.fort_new_password,temp_plan.fort_password_send_mode,fort_connect_test,temp_plan.fort_resource,temp_plan.fort_key_admin,
        temp_plan.fort_create_by
  FROM  temp_plan;
  DROP TABLE temp_plan;
END$$

DELIMITER ;



DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `getRuleCommand`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `getRuleCommand`()
BEGIN
    DECLARE done INT DEFAULT -1; 
    
    DECLARE temp_id  VARCHAR(24);
    DECLARE temp_department_id VARCHAR(24);
    DECLARE temp_type  VARCHAR(1);
    DECLARE temp_state VARCHAR(1);
    DECLARE temp_prior_id  VARCHAR(24);
    DECLARE temp_next_id  VARCHAR(24);
    DECLARE temp_level VARCHAR(1);
    DECLARE temp_user VARCHAR(10000) DEFAULT ''; 
    DECLARE temp_resource TEXT;
    DECLARE temp_target_code INT;
    DECLARE temp_target_id VARCHAR(24); 
    DECLARE temp_command_value VARCHAR(2000); 
    DECLARE temp_approval_user VARCHAR(2000);
    
    DECLARE cur1 CURSOR FOR  SELECT DISTINCT 
    fort_rule_command.fort_rule_command_id,
    fort_rule_command.fort_department_id,
    fort_rule_command.fort_rule_command_type,   
    fort_rule_command.fort_rule_command_state,
    fort_rule_command.fort_prior_id,
    fort_rule_command.fort_next_id,
    fort_rule_command.fort_level    
    FROM fort_rule_command;
    
    DECLARE cur2 CURSOR FOR  SELECT DISTINCT 
    fort_target_code,fort_target_id
    FROM temp_authorization;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1;  
    
    DROP TEMPORARY TABLE IF EXISTS temp_strategy;   
    CREATE TEMPORARY TABLE temp_strategy(
         fort_rule_command_id  VARCHAR(24) NOT NULL
        ,fort_department_id VARCHAR(24)
        ,fort_rule_command_type VARCHAR(1)
        ,fort_rule_command_state VARCHAR(1)     
        ,fort_prior_id VARCHAR(24)
        ,fort_next_id VARCHAR(24)
        ,fort_level VARCHAR(1)
        ,fort_user TEXT
        ,fort_resource TEXT
        ,fort_approval_user VARCHAR(10000)
        ,fort_command_value VARCHAR(2000)  
    );
    DROP TEMPORARY TABLE IF EXISTS temp_authorization;
    CREATE TEMPORARY TABLE temp_authorization(      
        fort_target_code INT 
        ,fort_target_id VARCHAR(24)
    );
    SET temp_resource = '';
    SET temp_user = '';
    SET temp_approval_user = '';
    
    OPEN cur1;
    myLoop: LOOP  
        FETCH cur1 INTO temp_id,temp_department_id,temp_type,temp_state,temp_prior_id,temp_next_id,temp_level;     
        IF done = 1 THEN   
            LEAVE myLoop;
        END IF;
        
        INSERT INTO temp_strategy(fort_rule_command_id,fort_department_id,fort_rule_command_type,fort_rule_command_state,fort_level,fort_prior_id,fort_next_id)
        VALUES(temp_id,temp_department_id,temp_type,temp_state,temp_level,temp_prior_id,temp_next_id);
        
        INSERT INTO  temp_authorization
        SELECT fort_target_code,fort_target_id FROM fort_rule_command_target_proxy WHERE fort_rule_command_id = temp_id;
        OPEN cur2;
        typeLoop:LOOP
            FETCH cur2 INTO temp_target_code,temp_target_id;
            IF done = 1 THEN 
                SET done = -1;
                LEAVE typeLoop;
            END IF;
            IF temp_target_code=2 THEN
                IF temp_user='' THEN
                    SELECT CONCAT(CONCAT(fort_user_account,'(',fort_user_name,')')) INTO temp_user  
                    FROM fort_user WHERE fort_user_id = temp_target_id
                    AND fort_user.fort_user_state  <> 2;             
                ELSE 
                    SELECT CONCAT(temp_user,'</br>',CONCAT(fort_user_account,'(',fort_user_name,')')) INTO temp_user  
                    FROM fort_user WHERE fort_user_id = temp_target_id
                    AND fort_user.fort_user_state  <> 2;
                END IF;
            END IF;
            IF temp_target_code=4 THEN 
                IF temp_user='' THEN
                    SELECT fort_user_group_name INTO temp_user FROM fort_user_group WHERE fort_user_group_id = temp_target_id;              
                ELSE                
                    SELECT CONCAT(temp_user,'</br>',fort_user_group_name) INTO temp_user FROM fort_user_group WHERE fort_user_group_id = temp_target_id;
                END IF;
            END IF;             
            IF temp_target_code=8 THEN
                IF temp_resource='' THEN
                    SELECT CONCAT(CONCAT(resource.fort_resource_name,'(',resource.fort_resource_ip,') - ',account.fort_account_name))   
                    INTO temp_resource
                    FROM fort_resource resource,fort_account account
                    WHERE resource.fort_resource_id = account.fort_resource_id
                    AND account.fort_account_id = temp_target_id;
                ELSE
                    SELECT CONCAT(temp_resource,'</br>',CONCAT(resource.fort_resource_name,'(',resource.fort_resource_ip,') - ',account.fort_account_name)) 
                    INTO temp_resource
                    FROM fort_resource resource,fort_account account
                    WHERE resource.fort_resource_id = account.fort_resource_id
                    AND account.fort_account_id = temp_target_id;
                END IF;
            END IF;  
            IF temp_target_code=16 THEN
                IF temp_resource='' THEN
                    SELECT CONCAT(CONCAT(fort_resource_name,'(',fort_resource_ip,')'))  
                    INTO temp_resource
                    FROM fort_resource resource
                    WHERE resource.fort_resource_id = temp_target_id;
                ELSE
                    SELECT CONCAT(temp_resource,'</br>',CONCAT(fort_resource_name,'(',fort_resource_ip,')'))    
                    INTO temp_resource
                    FROM fort_resource resource
                    WHERE resource.fort_resource_id = temp_target_id;
                END IF;
            END IF; 
            IF temp_target_code=32 THEN
                IF temp_resource='' THEN
                    SELECT fort_resource_group_name 
                    INTO temp_resource
                    FROM fort_resource_group 
                    WHERE fort_resource_group_id = temp_target_id;
                ELSE
                    SELECT CONCAT(temp_resource,'</br>',fort_resource_group_name)   
                    INTO temp_resource
                    FROM fort_resource_group 
                    WHERE fort_resource_group_id = temp_target_id;
                END IF;
            END IF; 
            IF temp_target_code=64 THEN
                IF temp_approval_user='' THEN
                    SELECT CONCAT(CONCAT(fort_user_account,'(',fort_user_name,')')) INTO temp_approval_user  
                    FROM fort_user WHERE fort_user_id = temp_target_id
                    AND fort_user.fort_user_state  <> 2;             
                ELSE 
                    SELECT CONCAT(temp_approval_user,'</br>',CONCAT(fort_user_account,'(',fort_user_name,')')) INTO temp_approval_user  
                    FROM fort_user WHERE fort_user_id = temp_target_id
                    AND fort_user.fort_user_state  <> 2;
                END IF;
            END IF;
        END LOOP typeLoop; 
        CLOSE cur2; 
        
        DELETE FROM temp_authorization;
        
        SELECT GROUP_CONCAT(fort_command_value SEPARATOR ';:;') INTO temp_command_value FROM fort_command WHERE fort_rule_command_id=temp_id;
        
        UPDATE temp_strategy SET fort_user=temp_user,fort_resource=temp_resource,fort_command_value=temp_command_value,fort_approval_user=temp_approval_user WHERE fort_rule_command_id=temp_id;
        SET temp_resource = '';
        SET temp_user = '';
        SET temp_approval_user = '';
     END LOOP myLoop;   
  /* 关闭游标 */ 
    CLOSE cur1;
    
    SELECT fort_rule_command_id,fort_department_id,fort_rule_command_type,fort_rule_command_state,fort_level,
        fort_prior_id,fort_next_id,fort_user,fort_resource,fort_command_value,fort_approval_user
    FROM temp_strategy;
      
    DROP TABLE temp_authorization;
    DROP TABLE temp_strategy;
END$$

DELIMITER ;

DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `moveRuleCommand`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `moveRuleCommand`(IN `move_id` VARCHAR(50),IN `down_id` VARCHAR(50))
BEGIN   
    DECLARE downPrior_id VARCHAR(24);
    DECLARE downPrior_priorId VARCHAR(24);
    DECLARE downPrior_nextId VARCHAR(24);
    DECLARE move_priorId VARCHAR(24);
    DECLARE move_nextId VARCHAR(24);
    DECLARE down_priorId VARCHAR(24);
    DECLARE down_nextId VARCHAR(24);
    DECLARE movePrior_id VARCHAR(24);
    DECLARE movePrior_priorId VARCHAR(24);
    DECLARE movePrior_nextId VARCHAR(24);
    DECLARE moveNext_id VARCHAR(24);
    DECLARE moveNext_priorId VARCHAR(24);
    DECLARE moveNext_nextId VARCHAR(24);    
    
    SELECT fort_prior_id,fort_next_id INTO move_priorId,move_nextId FROM fort_rule_command WHERE fort_rule_command_id=move_id;
    
    SELECT fort_rule_command_id,fort_prior_id,fort_next_id INTO movePrior_id,movePrior_priorId,movePrior_nextId 
    FROM fort_rule_command WHERE fort_rule_command_id=move_priorId;
    
    SELECT fort_rule_command_id,fort_prior_id,fort_next_id INTO moveNext_id,moveNext_priorId,moveNext_nextId 
    FROM fort_rule_command WHERE fort_rule_command_id=move_nextId;
    
    SELECT fort_prior_id,fort_next_id INTO down_priorId,down_nextId FROM fort_rule_command WHERE fort_rule_command_id=down_id;  
    
    SELECT fort_rule_command_id,fort_prior_id,fort_next_id INTO downPrior_id,downPrior_priorId,downPrior_nextId 
    FROM fort_rule_command WHERE fort_rule_command_id=down_priorId;
    
    IF (downPrior_id IS NOT NULL) THEN  
        UPDATE fort_rule_command SET fort_prior_id=downPrior_priorId,fort_next_id=move_id  WHERE fort_rule_command_id=downPrior_id;     
    END IF;
    
    SELECT fort_prior_id,fort_next_id INTO down_priorId,down_nextId FROM fort_rule_command WHERE fort_rule_command_id=down_id;  
    SELECT fort_prior_id,fort_next_id INTO downPrior_priorId,downPrior_nextId FROM fort_rule_command WHERE fort_rule_command_id=downPrior_id;
    
    SELECT down_id;
    
    IF (downPrior_id IS NOT NULL) THEN      
        UPDATE fort_rule_command SET fort_prior_id=downPrior_id,fort_next_id=down_id WHERE fort_rule_command_id=move_id;
    ELSE
        UPDATE fort_rule_command SET fort_prior_id=NULL,fort_next_id=down_id WHERE fort_rule_command_id=move_id;
    END IF;
    
    SELECT fort_prior_id,fort_next_id INTO down_priorId,down_nextId FROM fort_rule_command WHERE fort_rule_command_id=down_id;
    
    IF (down_id IS NOT NULL) THEN       
        UPDATE fort_rule_command SET fort_prior_id=move_id,fort_next_id=down_nextId WHERE fort_rule_command_id=down_id;
    END IF;
    
    SELECT fort_prior_id,fort_next_id INTO movePrior_priorId,movePrior_nextId FROM fort_rule_command WHERE fort_rule_command_id=movePrior_id;
    
    IF (movePrior_id IS NOT NULL) THEN
        UPDATE fort_rule_command SET fort_prior_id=movePrior_priorId,fort_next_id=moveNext_id WHERE fort_rule_command_id=movePrior_id;      
    END IF;
    SELECT fort_prior_id,fort_next_id INTO moveNext_priorId,moveNext_nextId FROM fort_rule_command WHERE fort_rule_command_id=moveNext_id;
    IF (moveNext_id IS NOT NULL) THEN
        UPDATE fort_rule_command SET fort_prior_id=movePrior_id,fort_next_id=moveNext_nextId WHERE fort_rule_command_id=moveNext_id;        
    END IF;
    END$$

DELIMITER ;

/*PROCEDURE-修改用户状态-过期 */
DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `updateUserStatus`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `updateUserStatus`()
BEGIN   
      DECLARE temp_end_time VARCHAR(50);
      DECLARE temp_user_id VARCHAR(50);
      DECLARE done INT DEFAULT 0; 
    
      DECLARE cur1 CURSOR FOR SELECT fort_user.fort_end_time,fort_user.fort_user_id FROM fort_user WHERE fort_user.fort_end_time IS NOT NULL;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1;      
    
       
      OPEN cur1;
      
    timeLoop: LOOP  
              
            FETCH cur1 INTO temp_end_time ,temp_user_id; 
               
                IF done = 1 THEN  
                          LEAVE timeLoop;  
                 END IF;   
           
                IF temp_end_time IS NOT NULL && SYSDATE() > temp_end_time THEN    
        
                     UPDATE fort_user SET fort_user_state='0' WHERE fort_user.fort_user_id=temp_user_id AND fort_user.fort_user_state = '1' ;

                END IF;
        
        
      
    END LOOP timeLoop; 
      
    CLOSE cur1;       
      
    END$$

DELIMITER ;


/*EVENT-每隔一分钟检查一次用户、流程状态*/
DELIMITER $$

DROP EVENT IF EXISTS checkStatus$$

CREATE DEFINER=`mysql`@`127.0.0.1` EVENT checkStatus ON SCHEDULE EVERY 1 MINUTE  ON COMPLETION PRESERVE ENABLE DO 

 BEGIN 
 
    CALL updateUserStatus();

    END$$

DELIMITER ;



DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `selectRuleCommandResouceByQuery`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `selectRuleCommandResouceByQuery`(IN fortResourceGroupId VARCHAR(10000),IN fortResourceIp VARCHAR(50),IN fortResourceName VARCHAR(50))
BEGIN   
      DECLARE done INT DEFAULT -1;  
      DECLARE temp_sql_string TEXT; 
      DECLARE temp_window_type_id VARCHAR(10000); 
 
      DROP TEMPORARY TABLE IF EXISTS tempAccountByRuleCommand; 
      
      CREATE TEMPORARY TABLE tempAccountByRuleCommand(
          
            fort_resource_name VARCHAR(100)
           ,fort_resource_id VARCHAR(200)
           ,fort_resource_type_id VARCHAR(200)
           ,fort_resource_type_name VARCHAR(100)
           ,fort_resource_ip VARCHAR(100)
           ,fort_department_name VARCHAR(100)
       )ENGINE=MEMORY;
     
     SET autocommit = 0;
  
   SELECT  GROUP_CONCAT(DISTINCT(selectResourceTypeChildList(fort_resource_type.fort_resource_type_id)) SEPARATOR ",") INTO   temp_window_type_id FROM fort_resource_type 
  WHERE fort_resource_type.`fort_resource_type_id` IN ('1000000000004','1000000000007');
        
    INSERT INTO tempAccountByRuleCommand(fort_resource_id, fort_resource_name,fort_resource_ip,
    
    fort_resource_type_id,fort_resource_type_name,fort_department_name) 
    SELECT 
    
          fort_resource.fort_resource_id,fort_resource.fort_resource_name ,
       
              fort_resource.fort_resource_ip , 
       
             fort_resource_type.fort_resource_type_id,fort_resource_type.fort_resource_type_name ,
              
             fort_department.fort_department_name
       
        FROM fort_resource,fort_resource_type,fort_department 
        
        WHERE 
        
         fort_resource.fort_resource_type_id = fort_resource_type.fort_resource_type_id
       
        AND fort_department.fort_department_id = fort_resource.fort_department_id
        
        AND FIND_IN_SET(fort_resource.fort_resource_type_id ,temp_window_type_id)
       
        AND fort_resource.fort_resource_state !=2 
       
        AND fort_resource.fort_parent_id IS NULL  
     
        AND fort_resource.fort_resource_id IN ( SELECT fort_resource.fort_resource_id FROM fort_resource WHERE FIND_IN_SET(fort_resource.fort_department_id ,fortResourceGroupId));
        
     
      INSERT INTO tempAccountByRuleCommand(fort_resource_id, fort_resource_name,fort_resource_ip,fort_resource_type_id,
      
           fort_resource_type_name,fort_department_name) 
     SELECT 
            fort_resource.fort_resource_id,fort_resource.fort_resource_name ,
       
                fort_resource.fort_resource_ip , fort_resource_type.fort_resource_type_id,
               
                fort_resource_type.fort_resource_type_name ,
                
                fort_department.fort_department_name 
              
        FROM  fort_resource,fort_resource_type,fort_department,fort_resource_group,fort_resource_group_resource
     
        WHERE fort_resource.fort_resource_type_id = fort_resource_type.fort_resource_type_id
        
        AND FIND_IN_SET(fort_resource.fort_resource_type_id ,temp_window_type_id)
       
        AND  fort_department.fort_department_id = fort_resource.fort_department_id
    
        AND fort_resource_group_resource.fort_resource_id = fort_resource.fort_resource_id
        
        AND fort_resource_group_resource.fort_resource_group_id = fort_resource_group.fort_resource_group_id
       
        AND  fort_resource.fort_resource_state !=2 
       
        AND fort_resource.fort_parent_id IS NULL  
     
        AND fort_resource.fort_resource_id IN ( SELECT fort_resource.fort_resource_id FROM fort_resource WHERE 
        
        FIND_IN_SET(fort_resource_group.fort_resource_group_id,fortResourceGroupId));
        
      
        
        INSERT INTO tempAccountByRuleCommand(fort_resource_id,
          
          fort_resource_name,fort_resource_ip,fort_resource_type_id,fort_resource_type_name,fort_department_name) 
    SELECT 
    
          fort_resource.fort_resource_id,fort_resource.fort_resource_name ,
       
              fort_resource.fort_resource_ip , 
       
             fort_resource_type.fort_resource_type_id,fort_resource_type.fort_resource_type_name ,
              
             fort_department.fort_department_name
       
        FROM  fort_resource,fort_resource_type,fort_department 
        
        WHERE
       
            fort_resource.fort_resource_type_id = fort_resource_type.fort_resource_type_id
            
        AND FIND_IN_SET(fort_resource.fort_resource_type_id ,temp_window_type_id)    
       
        AND fort_department.fort_department_id = fort_resource.fort_department_id
       
        AND fort_resource.fort_resource_state !=2 
       
        AND fort_resource.fort_parent_id IS NOT NULL  
     
        AND fort_resource.fort_resource_id IN ( SELECT fort_resource.fort_resource_id FROM fort_resource WHERE FIND_IN_SET(fort_resource.fort_department_id ,fortResourceGroupId));
        
        
      INSERT INTO tempAccountByRuleCommand(fort_resource_id,fort_resource_name,fort_resource_ip,fort_resource_type_id,
      
                fort_resource_type_name,fort_department_name) 
     SELECT 
            fort_resource.fort_resource_id,fort_resource.fort_resource_name ,
       
                fort_resource.fort_resource_ip , fort_resource_type.fort_resource_type_id,
               
                fort_resource_type.fort_resource_type_name , fort_department.fort_department_name 
              
        FROM    fort_resource,fort_resource_type,fort_department,fort_resource_group,fort_resource_group_resource
     
        WHERE 
        
             fort_resource.fort_resource_type_id = fort_resource_type.fort_resource_type_id
       
        AND    fort_department.fort_department_id = fort_resource.fort_department_id
        
        AND FIND_IN_SET(fort_resource.fort_resource_type_id ,temp_window_type_id) 
    
        AND fort_resource_group_resource.fort_resource_id = fort_resource.fort_resource_id
        
        AND fort_resource_group_resource.fort_resource_group_id = fort_resource_group.fort_resource_group_id
       
        AND  fort_resource.fort_resource_state !=2 
       
        AND fort_resource.fort_parent_id IS NOT NULL 
     
        AND fort_resource.fort_resource_id IN ( SELECT fort_resource.fort_resource_id FROM fort_resource WHERE 
        
        FIND_IN_SET(fort_resource_group.fort_resource_group_id,fortResourceGroupId));
        
     SET temp_sql_string = CONCAT(
          "SELECT 
          
           GROUP_CONCAT(DISTINCT(CONCAT(fort_resource_id,':',fort_resource_name,':',fort_department_name )) SEPARATOR '|') AS fort_resource_name, 
           
           fort_resource_ip AS fort_resource_ip, 
           
           GROUP_CONCAT(DISTINCT(CONCAT(fort_resource_type_id,':',fort_resource_type_name)) SEPARATOR '|') AS fort_account_id",
           
       ' FROM ', 
       
       'tempAccountByRuleCommand ',    
       ' WHERE  ',
       'fort_resource_id IS NOT NULL'
       );
       
    IF ( fortResourceName != '' ) THEN 
      SET temp_sql_string = CONCAT(temp_sql_string,' AND fort_resource_name like \'',CONCAT('%',fortResourceName,'%\''));
    END IF;
    IF ( fortResourceIp != '' ) THEN 
       SET temp_sql_string = CONCAT(temp_sql_string,' AND fort_resource_ip like \'',CONCAT('%',fortResourceIp,'%\''));
    END IF;
     SET temp_sql_string = CONCAT(temp_sql_string,' GROUP BY fort_resource_id');
     SET @temp_user_sql_string = temp_sql_string;
     PREPARE stmt FROM  @temp_user_sql_string; 
     EXECUTE stmt;      
     DEALLOCATE PREPARE stmt;   
     DROP TABLE tempAccountByRuleCommand;
    END$$

DELIMITER ;

DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `selectRuleCommandAccountByQuery`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `selectRuleCommandAccountByQuery`(IN fortResourceGroupId VARCHAR(10000),IN fortAccountName VARCHAR(50),IN fortResourceIp VARCHAR(50),IN fortResourceName VARCHAR(50))
BEGIN   
      DECLARE done INT DEFAULT -1;  
      DECLARE temp_sql_string TEXT; 
      DECLARE temp_window_type_id TEXT;    
 
 
      DROP TEMPORARY TABLE IF EXISTS tempAccountByRuleCommand; 
      
      CREATE TEMPORARY TABLE tempAccountByRuleCommand(
            fort_account_id  VARCHAR(200) 
           ,fort_account_name VARCHAR(100)
           ,fort_resource_name VARCHAR(100)
           ,fort_resource_id VARCHAR(200)
           ,fort_resource_type_id VARCHAR(200)
           ,fort_resource_type_name VARCHAR(100)
           ,fort_resource_ip VARCHAR(100)
           ,fort_department_name VARCHAR(100)
       )ENGINE=MEMORY;
     
      SET autocommit = 0;   
     
     SELECT  GROUP_CONCAT(DISTINCT(selectResourceTypeChildList(fort_resource_type.fort_resource_type_id)) SEPARATOR ",") INTO   temp_window_type_id FROM fort_resource_type 
      WHERE fort_resource_type.`fort_resource_type_id` IN ('1000000000004','1000000000007');
       
    INSERT INTO tempAccountByRuleCommand(fort_account_id,fort_account_name,fort_resource_id,
          
          fort_resource_name,fort_resource_ip,fort_resource_type_id,fort_resource_type_name,fort_department_name) 
    SELECT 
              fort_account.fort_account_id,fort_account.fort_account_name, 
    
          fort_resource.fort_resource_id,fort_resource.fort_resource_name ,
       
              fort_resource.fort_resource_ip , 
       
             fort_resource_type.fort_resource_type_id,fort_resource_type.fort_resource_type_name ,
              
             fort_department.fort_department_name
       
        FROM fort_account,fort_resource,fort_resource_type,fort_department 
        
        WHERE fort_account.fort_resource_id = fort_resource.fort_resource_id 
       
    AND FIND_IN_SET(fort_resource.fort_resource_type_id ,temp_window_type_id)
       
        AND fort_resource.fort_resource_type_id = fort_resource_type.fort_resource_type_id
       
        AND fort_department.fort_department_id = fort_resource.fort_department_id
       
        AND fort_resource.fort_resource_state !=2 
       
        AND fort_resource.fort_parent_id IS NULL  AND fort_account.fort_is_allow_authorized  = 1
     
        AND fort_account.fort_resource_id IN ( SELECT fort_resource.fort_resource_id FROM fort_resource WHERE FIND_IN_SET(fort_resource.fort_department_id ,fortResourceGroupId));
        
     
      INSERT INTO tempAccountByRuleCommand(fort_account_id,fort_account_name,fort_resource_id,
          
             fort_resource_name,fort_resource_ip,fort_resource_type_id,fort_resource_type_name,fort_department_name) 
     SELECT fort_account.fort_account_id,fort_account.fort_account_name, 
    
            fort_resource.fort_resource_id,fort_resource.fort_resource_name ,
       
                fort_resource.fort_resource_ip , fort_resource_type.fort_resource_type_id,
               
                fort_resource_type.fort_resource_type_name ,
                
                fort_department.fort_department_name 
              
        FROM    fort_account,fort_resource,fort_resource_type,fort_department,fort_resource_group,fort_resource_group_resource
     
        WHERE fort_account.fort_resource_id = fort_resource.fort_resource_id 
        
         AND FIND_IN_SET(fort_resource.fort_resource_type_id ,temp_window_type_id)
       
        AND    fort_resource.fort_resource_type_id = fort_resource_type.fort_resource_type_id
       
        AND    fort_department.fort_department_id = fort_resource.fort_department_id
    
    AND fort_resource_group_resource.fort_resource_id = fort_account.fort_resource_id
        
        AND fort_resource_group_resource.fort_resource_group_id = fort_resource_group.fort_resource_group_id
       
        AND  fort_resource.fort_resource_state !=2 
       
        AND fort_resource.fort_parent_id IS NULL  AND fort_account.fort_is_allow_authorized  = 1
     
        AND fort_account.fort_resource_id IN ( SELECT fort_resource.fort_resource_id FROM fort_resource WHERE 
        
        FIND_IN_SET(fort_resource_group.fort_resource_group_id,fortResourceGroupId));
        
        
        
        INSERT INTO tempAccountByRuleCommand(fort_account_id,fort_account_name,fort_resource_id,
          
          fort_resource_name,fort_resource_ip,fort_resource_type_id,fort_resource_type_name,fort_department_name) 
    SELECT 
              fort_account.fort_account_id,fort_account.fort_account_name, 
    
          fort_resource.fort_resource_id,fort_resource.fort_resource_name ,
       
              fort_resource.fort_resource_ip , 
       
             fort_resource_type.fort_resource_type_id,fort_resource_type.fort_resource_type_name ,
              
             fort_department.fort_department_name
       
        FROM fort_account,fort_resource,fort_resource_type,fort_department 
        
        WHERE fort_account.fort_resource_id = fort_resource.fort_parent_id 
        
        AND FIND_IN_SET(fort_resource.fort_resource_type_id ,temp_window_type_id)
       
        AND fort_resource.fort_resource_type_id = fort_resource_type.fort_resource_type_id
       
        AND fort_department.fort_department_id = fort_resource.fort_department_id
       
        AND fort_resource.fort_resource_state !=2 
       
        AND fort_resource.fort_parent_id IS NOT NULL  AND fort_account.fort_is_allow_authorized  = 1
     
        AND fort_account.fort_resource_id IN ( SELECT fort_resource.fort_resource_id FROM fort_resource WHERE FIND_IN_SET(fort_resource.fort_department_id ,fortResourceGroupId));
        
        
        
        
      INSERT INTO tempAccountByRuleCommand(fort_account_id,fort_account_name,fort_resource_id,
          
             fort_resource_name,fort_resource_ip,fort_resource_type_id,fort_resource_type_name,fort_department_name) 
     SELECT fort_account.fort_account_id,fort_account.fort_account_name, 
    
            fort_resource.fort_resource_id,fort_resource.fort_resource_name ,
       
                fort_resource.fort_resource_ip , fort_resource_type.fort_resource_type_id,
               
                fort_resource_type.fort_resource_type_name ,
                
                fort_department.fort_department_name 
              
        FROM    fort_account,fort_resource,fort_resource_type,fort_department,fort_resource_group,fort_resource_group_resource
     
        WHERE fort_account.fort_resource_id = fort_resource.fort_parent_id 
        
       AND FIND_IN_SET(fort_resource.fort_resource_type_id ,temp_window_type_id)
       
        AND    fort_resource.fort_resource_type_id = fort_resource_type.fort_resource_type_id
       
        AND    fort_department.fort_department_id = fort_resource.fort_department_id
    
        AND fort_resource_group_resource.fort_resource_id = fort_account.fort_resource_id
        
        AND fort_resource_group_resource.fort_resource_group_id = fort_resource_group.fort_resource_group_id
       
        AND  fort_resource.fort_resource_state !=2 
       
        AND fort_resource.fort_parent_id IS NOT NULL  AND fort_account.fort_is_allow_authorized  = 1
     
        AND fort_account.fort_resource_id IN ( SELECT fort_resource.fort_resource_id FROM fort_resource WHERE 
        
        FIND_IN_SET(fort_resource_group.fort_resource_group_id,fortResourceGroupId));
        
     SET temp_sql_string = CONCAT(
          "SELECT GROUP_CONCAT(DISTINCT(CONCAT(fort_account_id,':',fort_account_name)) SEPARATOR '|') AS fort_account_name, 
          
           GROUP_CONCAT(DISTINCT(CONCAT(fort_resource_id,':',fort_resource_name,':',fort_department_name )) SEPARATOR '|') AS fort_resource_name, 
           
           fort_resource_ip AS fort_resource_ip, 
           
           GROUP_CONCAT(DISTINCT(CONCAT(fort_resource_type_id,':',fort_resource_type_name)) SEPARATOR '|') AS fort_account_id",
           
       ' FROM ', 
       
       'tempAccountByRuleCommand ',    
       ' WHERE  ',
       'fort_resource_id IS NOT NULL'
       );
       
    IF ( fortResourceName != '' ) THEN 
      SET temp_sql_string = CONCAT(temp_sql_string,' AND fort_resource_name like \'',CONCAT('%',fortResourceName,'%\''));
    END IF;
    IF ( fortResourceIp != '' ) THEN 
       SET temp_sql_string = CONCAT(temp_sql_string,' AND fort_resource_ip like \'',CONCAT('%',fortResourceIp,'%\''));
    END IF;
     IF ( fortAccountName != '' ) THEN 
      SET temp_sql_string = CONCAT(temp_sql_string,' AND fort_account_name like \'',CONCAT('%',fortAccountName,'%\''));
    END IF;
     SET temp_sql_string = CONCAT(temp_sql_string,' GROUP BY fort_resource_id');
     SET @temp_user_sql_string = temp_sql_string;
     PREPARE stmt FROM  @temp_user_sql_string; 
     EXECUTE stmt;      
     DEALLOCATE PREPARE stmt;   
     DROP TABLE tempAccountByRuleCommand;
    END$$

DELIMITER ;


DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `selectRuleCommandByUserId`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `selectRuleCommandByUserId`(IN userId VARCHAR(32),IN accountId VARCHAR(32))
BEGIN   
    
     DECLARE rule_while_id VARCHAR(32); 
         DECLARE rule_while_into_id VARCHAR(32);
         DECLARE order_num INT DEFAULT 0 ;

    DROP TEMPORARY TABLE IF EXISTS temp_rule_command_order; 
    CREATE TEMPORARY TABLE temp_rule_command_order(
            rule_command_order_id VARCHAR(30),
            rule_command_order_num INT
       )ENGINE=MEMORY;  
       
       DROP TEMPORARY TABLE IF EXISTS temp_rule_command;    
    CREATE TEMPORARY TABLE temp_rule_command(
            rule_command_id VARCHAR(30),
            rule_command_order INT 
       )ENGINE=MEMORY;  
      
    SET autocommit = 0;
    
     SELECT  fort_rule_command.fort_rule_command_id INTO rule_while_into_id  FROM  fort_rule_command  WHERE fort_rule_command.fort_prior_id IS NULL;
         
          INSERT INTO  temp_rule_command_order(rule_command_order_id,rule_command_order_num)  VALUE (rule_while_into_id,0);

  
     leave_rule_while : WHILE rule_while_into_id IS NOT NULL DO         
               
              
         SET rule_while_id =rule_while_into_id;
         
         SET rule_while_into_id = NULL;
         SELECT fort_rule_command.fort_rule_command_id INTO rule_while_into_id FROM fort_rule_command WHERE fort_rule_command.fort_prior_id = rule_while_id;  

          IF( rule_while_into_id IS  NULL ) THEN
                LEAVE leave_rule_while;
             
             END IF;

         SET order_num =order_num+1;
         
         INSERT INTO  temp_rule_command_order(rule_command_order_id,rule_command_order_num)  VALUE (rule_while_into_id,order_num);

        END WHILE; 
        
    
    INSERT INTO  temp_rule_command(rule_command_id,rule_command_order) 
        SELECT DISTINCT a.fort_rule_command_id,temp_rule_command_order.rule_command_order_num FROM
            (SELECT fort_rule_command_target_proxy.fort_rule_command_id FROM fort_rule_command_target_proxy WHERE fort_rule_command_target_proxy.fort_target_code='8' AND fort_rule_command_target_proxy.fort_target_id = accountId
               
             UNION ALL
             SELECT fort_rule_command_target_proxy.fort_rule_command_id FROM fort_rule_command_target_proxy WHERE fort_rule_command_target_proxy.fort_target_code='16' AND fort_rule_command_target_proxy.fort_target_id
            IN(SELECT fort_account.fort_resource_id FROM fort_account WHERE fort_account.fort_account_id = accountId)
               
               UNION ALL
            SELECT  fort_rule_command_target_proxy.fort_rule_command_id FROM fort_rule_command_target_proxy WHERE fort_rule_command_target_proxy.fort_target_code='32' AND fort_rule_command_target_proxy.fort_target_id
             IN(SELECT fort_resource_group_resource.fort_resource_group_id FROM fort_resource_group_resource WHERE fort_resource_group_resource.fort_resource_id IN(
               SELECT fort_account.fort_resource_id FROM fort_account WHERE fort_account.fort_account_id = accountId )  )     
           ) a,
         (SELECT fort_rule_command_target_proxy.fort_rule_command_id  FROM fort_rule_command_target_proxy WHERE fort_rule_command_target_proxy.fort_target_code='2' AND fort_rule_command_target_proxy.fort_target_id = userId       
       
             UNION ALL
          SELECT fort_rule_command_target_proxy.fort_rule_command_id  FROM fort_rule_command_target_proxy WHERE fort_rule_command_target_proxy.fort_target_code='4'
             AND fort_rule_command_target_proxy.fort_target_id
            IN(SELECT fort_user_group_user.fort_user_group_id FROM fort_user_group_user WHERE fort_user_group_user.fort_user_id = userId)
        ) b,temp_rule_command_order
        
        WHERE a.fort_rule_command_id = b.fort_rule_command_id AND temp_rule_command_order.rule_command_order_id = a.fort_rule_command_id;
    
        
    SELECT temp_rule_command.rule_command_id,fort_rule_command.fort_rule_command_type,fort_command.fort_command_value FROM temp_rule_command,fort_command,fort_rule_command WHERE 
           temp_rule_command.rule_command_id = fort_rule_command.fort_rule_command_id
       AND 
           temp_rule_command.rule_command_id = fort_command.fort_rule_command_id 
       
       AND  
            fort_rule_command.fort_rule_command_state = '1'
           
     ORDER BY temp_rule_command.rule_command_order;
 
      DROP TABLE temp_rule_command;
      DROP TABLE temp_rule_command_order;
   
   SET autocommit = 1;
    
    END$$

DELIMITER ;


 DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `selectAuthorizationById`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `selectAuthorizationById`(IN authorization_id VARCHAR(32))
BEGIN   
      DECLARE done INT DEFAULT -1;  
      DECLARE temp_user TEXT; 
      DECLARE temp_id VARCHAR(32); 
      DECLARE temp_code INT;  
      DECLARE temp_department_id VARCHAR(32); 
      DECLARE temp_department_name VARCHAR(50);    
      DECLARE temp_name VARCHAR(50); 
      DECLARE temp_user_group TEXT;   
      DECLARE temp_resource_group TEXT;   
      DECLARE temp_resource TEXT;
      DECLARE temp_resource_account TEXT; 
       
    
      DECLARE cur1 CURSOR FOR SELECT DISTINCT fort_authorization.fort_authorization_id,fort_authorization.fort_authorization_name,
        
         fort_authorization.fort_authorization_code ,fort_authorization.fort_department_id
             
             FROM fort_authorization WHERE fort_authorization.fort_authorization_id = authorization_id ;
             
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1;  
      DROP TEMPORARY TABLE IF EXISTS tempAuthorization; 
      CREATE TEMPORARY TABLE tempAuthorization(
           auth_id  VARCHAR(24) NOT NULL
           ,auth_code INT
           ,auth_name VARCHAR(50)
           ,auth_department_id VARCHAR(24)
           ,auth_department_name VARCHAR(50)
           ,auth_user TEXT
           ,auth_user_group TEXT
           ,auth_resource_group TEXT
           ,auth_resource TEXT  
           ,auth_resource_account TEXT
       );
       
      SET autocommit = 0;  
    
      OPEN cur1;
      
      myLoop: LOOP  
          
        FETCH cur1 INTO temp_id,temp_name,temp_code,temp_department_id; 
        IF done = 1 THEN   
        LEAVE myLoop;  
        END IF;  
        SELECT fort_department.fort_department_name INTO temp_department_name FROM fort_department WHERE fort_department.fort_department_id = temp_department_id;
          
        INSERT INTO tempAuthorization(auth_id,auth_code,auth_name,auth_department_id,auth_department_name,auth_user,auth_user_group,auth_resource_group)  VALUES (temp_id,temp_code,temp_name,temp_department_id,temp_department_name,NULL,NULL,NULL);     
         IF (temp_code&2 = 2 ) THEN
           SELECT GROUP_CONCAT(DISTINCT(CONCAT(fort_user.fort_user_id,':',fort_user.fort_user_account,':',fort_user.fort_user_name,':',fort_department.fort_department_name)) SEPARATOR '|')   INTO temp_user
           
            FROM fort_authorization_target_proxy,fort_user,fort_department WHERE fort_authorization_target_proxy.fort_target_id = fort_user.fort_user_id 
            
            AND fort_authorization_target_proxy.fort_authorization_id = temp_id  AND fort_department.fort_department_id = fort_user.fort_department_id
            
            AND fort_authorization_target_proxy.fort_target_code = 2 AND fort_user.fort_user_state  <> 2;   
          
            UPDATE  tempAuthorization SET auth_user = temp_user WHERE auth_id = temp_id ;
         
          END IF; 
         IF (temp_code&4 = 4 ) THEN
         
           SELECT GROUP_CONCAT(DISTINCT(CONCAT(fort_user_group.fort_user_group_id,':',fort_user_group.fort_user_group_name ,':',fort_department.fort_department_name)) SEPARATOR  '|') INTO temp_user_group
 
                      FROM fort_authorization_target_proxy,fort_user_group,fort_department 
 
                      WHERE fort_authorization_target_proxy.fort_target_id  = fort_user_group.fort_user_group_id 
 
                      AND fort_authorization_target_proxy.fort_authorization_id = temp_id  AND fort_department.fort_department_id = fort_user_group.fort_department_id
                      
                      AND fort_authorization_target_proxy.fort_target_code = 4;     
 
            UPDATE  tempAuthorization SET auth_user_group = temp_user_group WHERE auth_id = temp_id ;
         END IF; 
         
         IF (temp_code&32 = 32 ) THEN
          
             SELECT GROUP_CONCAT(DISTINCT(CONCAT(fort_resource_group.fort_resource_group_id,':',fort_resource_group.fort_resource_group_name,':',fort_department.fort_department_name)) SEPARATOR  '|')  INTO temp_resource_group
  
             FROM fort_authorization_target_proxy,fort_resource_group,fort_department
    
             WHERE fort_authorization_target_proxy.fort_target_id = fort_resource_group.fort_resource_group_id 
    
             AND fort_authorization_target_proxy.fort_authorization_id = temp_id  AND fort_department.fort_department_id = fort_resource_group.fort_department_id
    
             AND fort_authorization_target_proxy.fort_target_code = 32 ;
        
         UPDATE  tempAuthorization SET auth_resource_group = temp_resource_group WHERE auth_id = temp_id ;
         END IF;  
         
         IF (temp_code&16 = 16 ) THEN
              
             SELECT GROUP_CONCAT(DISTINCT(CONCAT(fort_resource.fort_resource_id,':',fort_resource.fort_resource_name,':',fort_resource.fort_resource_ip,':',
         
                    fort_resource_type.fort_resource_type_name,":",fort_department.fort_department_name)) SEPARATOR '|')  INTO temp_resource
             
              FROM  fort_authorization_target_proxy,fort_resource ,fort_resource_type ,fort_department
              
              WHERE 
                    fort_authorization_target_proxy.fort_target_id =  fort_resource.fort_resource_id
              AND 
                    fort_resource.fort_department_id = fort_department.fort_department_id
              AND 
                    fort_resource.fort_resource_type_id = fort_resource_type.fort_resource_type_id
              AND 
                    fort_authorization_target_proxy.fort_authorization_id = temp_id 
              AND 
                    fort_authorization_target_proxy.fort_target_code = 16 AND fort_resource.fort_resource_state  <> 2 ; 
                  
          UPDATE    tempAuthorization SET auth_resource = temp_resource WHERE auth_id = temp_id ;
         END IF;  
         
    IF (temp_code&8= 8 ) THEN
    
        SELECT GROUP_CONCAT( DISTINCT( CONCAT(fort_resource.fort_resource_id,":",fort_resource.fort_resource_name,":",fort_resource.fort_resource_ip,":",
            
            fort_resource_type.fort_resource_type_id,":",fort_resource_type.fort_resource_type_name,":",fort_account.fort_account_id,":",
            
            fort_account.fort_account_name,":",fort_authorization_target_proxy.fort_is_up_super,":",fort_department.fort_department_name)) SEPARATOR '|')  INTO temp_resource_account
         
               FROM  fort_authorization_target_proxy,fort_resource,fort_account,fort_resource_type  ,fort_department
               WHERE 
                     fort_authorization_target_proxy.fort_target_id = fort_account.fort_account_id 
        AND 
             fort_department.fort_department_id = fort_resource.fort_department_id
                AND 
                     fort_authorization_target_proxy.fort_parent_id =  fort_resource.fort_resource_id
                AND 
                     fort_resource_type.fort_resource_type_id = fort_resource.fort_resource_type_id
                AND 
                     fort_authorization_target_proxy.fort_authorization_id = temp_id 
                AND 
                     fort_authorization_target_proxy.fort_target_code = 8 AND fort_resource.fort_resource_state  <> 2 ;
      UPDATE tempAuthorization SET auth_resource_account = temp_resource_account WHERE auth_id = temp_id ;
        
         END IF;  
            
        END LOOP myLoop;  
      
     CLOSE cur1;    
    
     SELECT tempAuthorization.auth_id,auth_code,tempAuthorization.auth_name, tempAuthorization.auth_department_id,tempAuthorization.auth_department_name,tempAuthorization.auth_user ,tempAuthorization.auth_user_group ,tempAuthorization.auth_resource_group,tempAuthorization.auth_resource,tempAuthorization.auth_resource_account FROM  tempAuthorization;
      
     DROP TABLE tempAuthorization;
     
     SET autocommit = 1;
     
     
    END$$

DELIMITER ;

DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `selectAuthorizationResouceByQuery`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `selectAuthorizationResouceByQuery`(IN fortResourceGroupId TEXT,IN fortResourceIp VARCHAR(50),IN fortResourceName VARCHAR(50))
BEGIN   
      DECLARE done INT DEFAULT -1;  
      DECLARE temp_sql_string TEXT; 
 
      DROP TEMPORARY TABLE IF EXISTS tempAccountByAuth; 
      
      CREATE TEMPORARY TABLE tempAccountByAuth(
          
            fort_resource_name VARCHAR(100)
           ,fort_resource_id VARCHAR(200)
           ,fort_resource_type_id VARCHAR(200)
           ,fort_resource_type_name VARCHAR(100)
           ,fort_resource_ip VARCHAR(100)
           ,fort_department_name VARCHAR(100)
       )ENGINE=MEMORY;
     
      SET autocommit = 0; 
       
    INSERT INTO tempAccountByAuth(fort_resource_id, fort_resource_name,fort_resource_ip,
    
    fort_resource_type_id,fort_resource_type_name,fort_department_name) 
    SELECT 
    
          fort_resource.fort_resource_id,fort_resource.fort_resource_name ,
       
              fort_resource.fort_resource_ip , 
       
             fort_resource_type.fort_resource_type_id,fort_resource_type.fort_resource_type_name ,
              
             fort_department.fort_department_name
       
        FROM fort_resource,fort_resource_type,fort_department 
        
        WHERE 
        
         fort_resource.fort_resource_type_id = fort_resource_type.fort_resource_type_id
       
        AND fort_department.fort_department_id = fort_resource.fort_department_id
       
        AND fort_resource.fort_resource_state !=2 
       
        AND fort_resource.fort_parent_id IS NULL  
     
        AND fort_resource.fort_resource_id IN ( SELECT fort_resource.fort_resource_id FROM fort_resource WHERE FIND_IN_SET(fort_resource.fort_department_id ,fortResourceGroupId));
        
     
      INSERT INTO tempAccountByAuth(fort_resource_id, fort_resource_name,fort_resource_ip,fort_resource_type_id,
      
           fort_resource_type_name,fort_department_name) 
     SELECT 
            fort_resource.fort_resource_id,fort_resource.fort_resource_name ,
       
                fort_resource.fort_resource_ip , fort_resource_type.fort_resource_type_id,
               
                fort_resource_type.fort_resource_type_name ,
                
                fort_department.fort_department_name 
              
        FROM  fort_resource,fort_resource_type,fort_department,fort_resource_group,fort_resource_group_resource
     
        WHERE fort_resource.fort_resource_type_id = fort_resource_type.fort_resource_type_id
       
        AND  fort_department.fort_department_id = fort_resource.fort_department_id
    
    AND fort_resource_group_resource.fort_resource_id = fort_resource.fort_resource_id
        
        AND fort_resource_group_resource.fort_resource_group_id = fort_resource_group.fort_resource_group_id
       
        AND  fort_resource.fort_resource_state !=2 
       
        AND fort_resource.fort_parent_id IS NULL  
     
        AND fort_resource.fort_resource_id IN ( SELECT fort_resource.fort_resource_id FROM fort_resource WHERE 
        
        FIND_IN_SET(fort_resource_group.fort_resource_group_id,fortResourceGroupId));
        
      
        
        INSERT INTO tempAccountByAuth(fort_resource_id,
          
          fort_resource_name,fort_resource_ip,fort_resource_type_id,fort_resource_type_name,fort_department_name) 
    SELECT 
    
          fort_resource.fort_resource_id,fort_resource.fort_resource_name ,
       
              fort_resource.fort_resource_ip , 
       
             fort_resource_type.fort_resource_type_id,fort_resource_type.fort_resource_type_name ,
              
             fort_department.fort_department_name
       
        FROM  fort_resource,fort_resource_type,fort_department 
        
        WHERE
       
            fort_resource.fort_resource_type_id = fort_resource_type.fort_resource_type_id
       
        AND fort_department.fort_department_id = fort_resource.fort_department_id
       
        AND fort_resource.fort_resource_state !=2 
       
        AND fort_resource.fort_parent_id IS NOT NULL  
     
        AND fort_resource.fort_resource_id IN ( SELECT fort_resource.fort_resource_id FROM fort_resource WHERE FIND_IN_SET(fort_resource.fort_department_id ,fortResourceGroupId));
        
        
      INSERT INTO tempAccountByAuth(fort_resource_id,fort_resource_name,fort_resource_ip,fort_resource_type_id,
      
                fort_resource_type_name,fort_department_name) 
     SELECT 
            fort_resource.fort_resource_id,fort_resource.fort_resource_name ,
       
                fort_resource.fort_resource_ip , fort_resource_type.fort_resource_type_id,
               
                fort_resource_type.fort_resource_type_name , fort_department.fort_department_name 
              
        FROM    fort_resource,fort_resource_type,fort_department,fort_resource_group,fort_resource_group_resource
     
        WHERE 
        
             fort_resource.fort_resource_type_id = fort_resource_type.fort_resource_type_id
       
        AND    fort_department.fort_department_id = fort_resource.fort_department_id
    
    AND fort_resource_group_resource.fort_resource_id = fort_resource.fort_resource_id
        
        AND fort_resource_group_resource.fort_resource_group_id = fort_resource_group.fort_resource_group_id
       
        AND  fort_resource.fort_resource_state !=2 
       
        AND fort_resource.fort_parent_id IS NOT NULL 
     
        AND fort_resource.fort_resource_id IN ( SELECT fort_resource.fort_resource_id FROM fort_resource WHERE 
        
        FIND_IN_SET(fort_resource_group.fort_resource_group_id,fortResourceGroupId));
        
     SET temp_sql_string = CONCAT(
          "SELECT 
          
           GROUP_CONCAT(DISTINCT(CONCAT(fort_resource_id,':',fort_resource_name,':',fort_department_name )) SEPARATOR '|') AS fort_resource_name, 
           
           fort_resource_ip AS fort_resource_ip, 
           
           GROUP_CONCAT(DISTINCT(CONCAT(fort_resource_type_id,':',fort_resource_type_name)) SEPARATOR '|') AS fort_account_id",
           
       ' FROM ', 
       
       'tempAccountByAuth ',    
       ' WHERE  ',
       'fort_resource_id IS NOT NULL'
       );
       
    IF ( fortResourceName != '' ) THEN 
      SET temp_sql_string = CONCAT(temp_sql_string,' AND fort_resource_name like \'',CONCAT('%',fortResourceName,'%\''));
    END IF;
    IF ( fortResourceIp != '' ) THEN 
       SET temp_sql_string = CONCAT(temp_sql_string,' AND fort_resource_ip like \'',CONCAT('%',fortResourceIp,'%\''));
    END IF;
     SET temp_sql_string = CONCAT(temp_sql_string,' GROUP BY fort_resource_id');
     SET @temp_user_sql_string = temp_sql_string;
     PREPARE stmt FROM  @temp_user_sql_string; 
     EXECUTE stmt;      
     DEALLOCATE PREPARE stmt;   
     DROP TABLE tempAccountByAuth;
     
     SET autocommit = 1;
     
     
    END$$

DELIMITER ;


DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `selectAuthorizationAccountByQuery`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `selectAuthorizationAccountByQuery`(IN fortResourceGroupId TEXT,IN fortAccountName VARCHAR(50),IN fortResourceIp VARCHAR(50),IN fortResourceName VARCHAR(50))
BEGIN   
      DECLARE done INT DEFAULT -1;  
      DECLARE temp_sql_string TEXT; 
 
      DROP TEMPORARY TABLE IF EXISTS tempAccountByAuth; 
      
      CREATE TEMPORARY TABLE tempAccountByAuth(
            fort_account_id  VARCHAR(200) 
           ,fort_account_name VARCHAR(100)
           ,fort_resource_name VARCHAR(100)
           ,fort_resource_id VARCHAR(200)
           ,fort_resource_type_id VARCHAR(200)
           ,fort_resource_type_name VARCHAR(100)
           ,fort_resource_ip VARCHAR(100)
           ,fort_department_name VARCHAR(100)
       )ENGINE=MEMORY;
     
      
    SET autocommit = 0;
       
    INSERT INTO tempAccountByAuth(fort_account_id,fort_account_name,fort_resource_id,
          
          fort_resource_name,fort_resource_ip,fort_resource_type_id,fort_resource_type_name,fort_department_name) 
    SELECT 
              fort_account.fort_account_id,fort_account.fort_account_name, 
    
          fort_resource.fort_resource_id,fort_resource.fort_resource_name ,
       
              fort_resource.fort_resource_ip , 
       
             fort_resource_type.fort_resource_type_id,fort_resource_type.fort_resource_type_name ,
              
             fort_department.fort_department_name
       
        FROM fort_account,fort_resource,fort_resource_type,fort_department 
        
        WHERE fort_account.fort_resource_id = fort_resource.fort_resource_id 
       
        AND fort_resource.fort_resource_type_id = fort_resource_type.fort_resource_type_id
       
        AND fort_department.fort_department_id = fort_resource.fort_department_id
       
        AND fort_resource.fort_resource_state !=2 
       
           AND fort_account.fort_is_allow_authorized  = 1
     
        AND fort_account.fort_resource_id IN ( SELECT fort_resource.fort_resource_id FROM fort_resource WHERE FIND_IN_SET(fort_resource.fort_department_id ,fortResourceGroupId));
        
     
      INSERT INTO tempAccountByAuth(fort_account_id,fort_account_name,fort_resource_id,
          
             fort_resource_name,fort_resource_ip,fort_resource_type_id,fort_resource_type_name,fort_department_name) 
     SELECT fort_account.fort_account_id,fort_account.fort_account_name, 
    
            fort_resource.fort_resource_id,fort_resource.fort_resource_name ,
       
                fort_resource.fort_resource_ip , fort_resource_type.fort_resource_type_id,
               
                fort_resource_type.fort_resource_type_name ,
                
                fort_department.fort_department_name 
              
        FROM    fort_account,fort_resource,fort_resource_type,fort_department,fort_resource_group,fort_resource_group_resource
     
                WHERE fort_account.fort_resource_id = fort_resource.fort_resource_id 
       
        AND    fort_resource.fort_resource_type_id = fort_resource_type.fort_resource_type_id
       
        AND    fort_department.fort_department_id = fort_resource.fort_department_id
    
    AND fort_resource_group_resource.fort_resource_id = fort_account.fort_resource_id
        
        AND fort_resource_group_resource.fort_resource_group_id = fort_resource_group.fort_resource_group_id
       
        AND  fort_resource.fort_resource_state !=2 
       
          AND fort_account.fort_is_allow_authorized  = 1
     
        AND fort_account.fort_resource_id IN ( SELECT fort_resource.fort_resource_id FROM fort_resource WHERE 
        
        FIND_IN_SET(fort_resource_group.fort_resource_group_id,fortResourceGroupId));
        
        
        
        INSERT INTO tempAccountByAuth(fort_account_id,fort_account_name,fort_resource_id,
          
          fort_resource_name,fort_resource_ip,fort_resource_type_id,fort_resource_type_name,fort_department_name) 
    SELECT 
              fort_account.fort_account_id,fort_account.fort_account_name, 
    
          fort_resource.fort_resource_id,fort_resource.fort_resource_name ,
       
              fort_resource.fort_resource_ip , 
       
             fort_resource_type.fort_resource_type_id,fort_resource_type.fort_resource_type_name ,
              
             fort_department.fort_department_name
       
        FROM fort_account,fort_resource,fort_resource_type,fort_department 
        
        WHERE fort_account.fort_resource_id = fort_resource.fort_parent_id 
       
        AND fort_resource.fort_resource_type_id = fort_resource_type.fort_resource_type_id
       
        AND fort_department.fort_department_id = fort_resource.fort_department_id
       
        AND fort_resource.fort_resource_state !=2 
       
        AND fort_account.fort_is_allow_authorized  = 1
     
        AND fort_account.fort_resource_id IN ( SELECT fort_resource.fort_resource_id FROM fort_resource WHERE FIND_IN_SET(fort_resource.fort_department_id ,fortResourceGroupId));
        
        
        
        
      INSERT INTO tempAccountByAuth(fort_account_id,fort_account_name,fort_resource_id,
          
             fort_resource_name,fort_resource_ip,fort_resource_type_id,fort_resource_type_name,fort_department_name) 
     SELECT fort_account.fort_account_id,fort_account.fort_account_name, 
    
            fort_resource.fort_resource_id,fort_resource.fort_resource_name ,
       
                fort_resource.fort_resource_ip , fort_resource_type.fort_resource_type_id,
               
                fort_resource_type.fort_resource_type_name ,
                
                fort_department.fort_department_name 
              
        FROM    fort_account,fort_resource,fort_resource_type,fort_department,fort_resource_group,fort_resource_group_resource
     
        WHERE fort_account.fort_resource_id = fort_resource.fort_parent_id 
       
        AND    fort_resource.fort_resource_type_id = fort_resource_type.fort_resource_type_id
       
        AND    fort_department.fort_department_id = fort_resource.fort_department_id
    
    AND fort_resource_group_resource.fort_resource_id = fort_account.fort_resource_id
        
        AND fort_resource_group_resource.fort_resource_group_id = fort_resource_group.fort_resource_group_id
       
        AND  fort_resource.fort_resource_state !=2 
       
         AND fort_account.fort_is_allow_authorized  = 1
     
        AND fort_account.fort_resource_id IN ( SELECT fort_resource.fort_resource_id FROM fort_resource WHERE 
        
        FIND_IN_SET(fort_resource_group.fort_resource_group_id,fortResourceGroupId));
        
     SET temp_sql_string = CONCAT(
          "SELECT GROUP_CONCAT(DISTINCT(CONCAT(fort_account_id,':',fort_account_name)) SEPARATOR '|') AS fort_account_name, 
          
           GROUP_CONCAT(DISTINCT(CONCAT(fort_resource_id,':',fort_resource_name,':',fort_department_name )) SEPARATOR '|') AS fort_resource_name, 
           
           fort_resource_ip AS fort_resource_ip, 
           
           GROUP_CONCAT(DISTINCT(CONCAT(fort_resource_type_id,':',fort_resource_type_name)) SEPARATOR '|') AS fort_account_id",
           
       ' FROM ', 
       
       'tempAccountByAuth ',    
       ' WHERE  ',
       'fort_resource_id IS NOT NULL'
       );
       
    IF ( fortResourceName != '' ) THEN 
      SET temp_sql_string = CONCAT(temp_sql_string,' AND fort_resource_name like \'',CONCAT('%',fortResourceName,'%\''));
    END IF;
    IF ( fortResourceIp != '' ) THEN 
       SET temp_sql_string = CONCAT(temp_sql_string,' AND fort_resource_ip like \'',CONCAT('%',fortResourceIp,'%\''));
    END IF;
     IF ( fortAccountName != '' ) THEN 
      SET temp_sql_string = CONCAT(temp_sql_string,' AND fort_account_name like \'',CONCAT('%',fortAccountName,'%\''));
    END IF;
     SET temp_sql_string = CONCAT(temp_sql_string,' GROUP BY fort_resource_id');
     SET @temp_user_sql_string = temp_sql_string;
     PREPARE stmt FROM  @temp_user_sql_string; 
     EXECUTE stmt;      
     DEALLOCATE PREPARE stmt;   
     DROP TABLE tempAccountByAuth;
     
     SET autocommit = 1;
    END$$

DELIMITER ;

DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `selectRuleCommandTargetProxy`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `selectRuleCommandTargetProxy`(IN rule_command_id VARCHAR(32))
BEGIN   
      DECLARE done INT DEFAULT -1;  
      DECLARE temp_user VARCHAR(10000);
      DECLARE temp_id VARCHAR(32); 
      DECLARE temp_code INT;  
      DECLARE temp_name VARCHAR(50); 
      DECLARE temp_user_group TEXT;   
      DECLARE temp_resource_group TEXT;   
      DECLARE temp_resource TEXT;
      DECLARE temp_resource_account TEXT; 
      DECLARE temp_rule_approver TEXT;
       
    
      DECLARE cur1 CURSOR FOR SELECT DISTINCT fort_rule_command.fort_rule_command_id , fort_rule_command.fort_rule_command_authorization_code FROM fort_rule_command WHERE fort_rule_command.fort_rule_command_id = rule_command_id ;
             
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1;  
      DROP TEMPORARY TABLE IF EXISTS temp_rule_command; 
      CREATE TEMPORARY TABLE temp_rule_command(
            rule_id  VARCHAR(24) NOT NULL
           ,rule_code INT
           ,rule_user TEXT
           ,rule_user_group TEXT
           ,rule_resource_group TEXT
           ,rule_resource TEXT  
           ,rule_resource_account TEXT
           ,rule_approver TEXT
       );
       
     
     SET autocommit = 0;
     
      OPEN cur1;
      
      myLoop: LOOP  
          
        FETCH cur1 INTO temp_id,temp_code; 
        IF done = 1 THEN   
        LEAVE myLoop;  
        END IF;  
          
        INSERT INTO temp_rule_command(rule_id,rule_code)  VALUES (temp_id,temp_code);     
         IF (temp_code&2 = 2 ) THEN
           SELECT GROUP_CONCAT(DISTINCT(CONCAT(fort_user.fort_user_id,':',fort_user.fort_user_account,':',fort_user.fort_user_name,':',fort_department.fort_department_name)) SEPARATOR '|')   INTO temp_user
           
            FROM fort_rule_command_target_proxy,fort_user,fort_department WHERE fort_rule_command_target_proxy.fort_target_id = fort_user.fort_user_id 
            
            AND fort_rule_command_target_proxy.fort_rule_command_id = temp_id  AND fort_department.fort_department_id = fort_user.fort_department_id
            
            AND fort_rule_command_target_proxy.fort_target_code = 2 AND fort_user.fort_user_state  <> 2;    
          
            UPDATE  temp_rule_command SET rule_user = temp_user WHERE rule_id = temp_id ;
         
          END IF; 
          
          IF (temp_code&64 = 64 ) THEN
           SELECT GROUP_CONCAT(DISTINCT(CONCAT(fort_user.fort_user_id,':',fort_user.fort_user_account,':',fort_user.fort_user_name,':',fort_department.fort_department_name)) SEPARATOR '|')   INTO temp_rule_approver
           
            FROM fort_rule_command_target_proxy,fort_user,fort_department WHERE fort_rule_command_target_proxy.fort_target_id = fort_user.fort_user_id 
            
            AND fort_rule_command_target_proxy.fort_rule_command_id = temp_id  AND fort_department.fort_department_id = fort_user.fort_department_id
            
            AND fort_rule_command_target_proxy.fort_target_code = 64 AND fort_user.fort_user_state  <> 2;    
          
            UPDATE  temp_rule_command SET rule_approver = temp_rule_approver WHERE rule_id = temp_id ;
         
          END IF;
          
         IF (temp_code&4 = 4 ) THEN
         
           SELECT GROUP_CONCAT(DISTINCT(CONCAT(fort_user_group.fort_user_group_id,':',fort_user_group.fort_user_group_name ,':',fort_department.fort_department_name)) SEPARATOR  '|') INTO temp_user_group
 
                      FROM fort_rule_command_target_proxy,fort_user_group,fort_department 
 
                      WHERE fort_rule_command_target_proxy.fort_target_id  = fort_user_group.fort_user_group_id 
 
                      AND fort_rule_command_target_proxy.fort_rule_command_id = temp_id  AND fort_department.fort_department_id = fort_user_group.fort_department_id
                      
                      AND fort_rule_command_target_proxy.fort_target_code = 4;      
 
            UPDATE  temp_rule_command SET rule_user_group = temp_user_group WHERE rule_id = temp_id ;
         END IF; 
         
         IF (temp_code&32 = 32 ) THEN
          
             SELECT GROUP_CONCAT(DISTINCT(CONCAT(fort_resource_group.fort_resource_group_id,':',fort_resource_group.fort_resource_group_name,':',fort_department.fort_department_name)) SEPARATOR  '|')  INTO temp_resource_group
  
             FROM fort_rule_command_target_proxy,fort_resource_group,fort_department
    
             WHERE fort_rule_command_target_proxy.fort_target_id = fort_resource_group.fort_resource_group_id 
    
             AND fort_rule_command_target_proxy.fort_rule_command_id = temp_id  AND fort_department.fort_department_id = fort_resource_group.fort_department_id
    
             AND fort_rule_command_target_proxy.fort_target_code = 32 ;
        
         UPDATE  temp_rule_command SET rule_resource_group = temp_resource_group WHERE rule_id = temp_id ;
         END IF;  
         
         IF (temp_code&16 = 16 ) THEN
              
             SELECT GROUP_CONCAT(DISTINCT(CONCAT(fort_resource.fort_resource_id,':',fort_resource.fort_resource_name,':',fort_resource.fort_resource_ip,':',
         
                    fort_resource_type.fort_resource_type_name,":",fort_department.fort_department_name)) SEPARATOR '|')  INTO temp_resource
             
              FROM  fort_rule_command_target_proxy,fort_resource ,fort_resource_type ,fort_department
              
              WHERE 
                    fort_rule_command_target_proxy.fort_target_id =  fort_resource.fort_resource_id
              AND 
                    fort_resource.fort_department_id = fort_department.fort_department_id
              AND 
                    fort_resource.fort_resource_type_id = fort_resource_type.fort_resource_type_id
              AND 
                    fort_rule_command_target_proxy.fort_rule_command_id = temp_id 
              AND 
                    fort_rule_command_target_proxy.fort_target_code = 16 AND fort_resource.fort_resource_state  <> 2 ;  
                  
          UPDATE    temp_rule_command SET rule_resource = temp_resource WHERE rule_id = temp_id ;
         END IF;  
         
    IF (temp_code&8= 8 ) THEN
    
        SELECT GROUP_CONCAT( DISTINCT( CONCAT(fort_resource.fort_resource_id,":",fort_resource.fort_resource_name,":",fort_resource.fort_resource_ip,":",
            
            fort_resource_type.fort_resource_type_id,":",fort_resource_type.fort_resource_type_name,":",fort_account.fort_account_id,":",
            
            fort_account.fort_account_name,":",fort_department.fort_department_name)) SEPARATOR '|')  INTO temp_resource_account
         
               FROM  fort_rule_command_target_proxy,fort_resource,fort_account,fort_resource_type  ,fort_department
               WHERE 
                     fort_rule_command_target_proxy.fort_target_id = fort_account.fort_account_id 
        AND 
             fort_department.fort_department_id = fort_resource.fort_department_id
                AND 
                     fort_account.fort_resource_id =  fort_resource.fort_resource_id
                AND 
                     fort_resource_type.fort_resource_type_id = fort_resource.fort_resource_type_id
                AND 
                     fort_rule_command_target_proxy.fort_rule_command_id = temp_id 
                AND 
                     fort_rule_command_target_proxy.fort_target_code = 8 AND fort_resource.fort_resource_state  <> 2 ;
                     
      UPDATE temp_rule_command SET rule_resource_account = temp_resource_account WHERE rule_id = temp_id ;
        
         END IF;  
            
        END LOOP myLoop;  
      
     CLOSE cur1;    
    
     SELECT temp_rule_command.rule_id,temp_rule_command.rule_code,temp_rule_command.rule_user ,temp_rule_command.rule_user_group ,
     temp_rule_command.rule_resource_group,temp_rule_command.rule_resource,temp_rule_command.rule_resource_account ,temp_rule_command.rule_approver
     FROM  temp_rule_command;
      
     DROP TABLE temp_rule_command;
     
     SET autocommit = 1;
     
    END$$

DELIMITER ;


DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `getPlanPasswordBackupList`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `getPlanPasswordBackupList`(IN userId VARCHAR(50),IN orderByClause VARCHAR(50),IN limitStart INT,IN limitEnd INT)
BEGIN   
    DECLARE done INT DEFAULT -1;  
    DECLARE temp_user VARCHAR(50); 
    DECLARE temp_id VARCHAR(24); 
    DECLARE temp_code INT;   
    DECLARE temp_name VARCHAR(32); 
    DECLARE temp_mode VARCHAR(2);   
    DECLARE temp_first DATETIME;
    DECLARE temp_end DATETIME;
    DECLARE temp_interval INT;
    DECLARE temp_state VARCHAR(2);   
    DECLARE temp_file_name VARCHAR(20);
    DECLARE temp_resource TEXT;
    DECLARE temp_department VARCHAR(50);
    DECLARE query_department_id TEXT DEFAULT '';  
       
    
    DECLARE cur1 CURSOR FOR  SELECT DISTINCT 
    fort_plan_password_backup.fort_plan_password_backup_id,
    fort_plan_password_backup.fort_plan_password_backup_name,
    fort_plan_password_backup.fort_run_mode,
    fort_plan_password_backup.fort_first_run_time,
    fort_plan_password_backup.fort_end_run_time,
    fort_plan_password_backup.fort_run_interval,
    fort_plan_password_backup.fort_state,
    fort_plan_password_backup.fort_backup_file_name,
    fort_plan_password_backup.fort_plan_code 
    FROM fort_plan_password_backup 
    WHERE FIND_IN_SET(fort_plan_password_backup.fort_department_id,query_department_id) ;
        
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1;  
    DROP TEMPORARY TABLE IF EXISTS temp_plan;   
    CREATE TEMPORARY TABLE temp_plan(
        fort_plan_password_backup_id  VARCHAR(24) NOT NULL
        ,fort_plan_password_backup_name VARCHAR(32)
        ,fort_department VARCHAR(50)
        ,fort_run_mode VARCHAR(2)
        ,fort_first_run_time DATETIME
        ,fort_end_run_time DATETIME
        ,fort_run_interval  INT
        ,fort_state VARCHAR(2)
        ,fort_backup_file_name VARCHAR(50)
        ,fort_resource TEXT    
    );
       
      SET autocommit = 0;
    
     IF ( userId != '' ) THEN 
     
         SELECT GROUP_CONCAT(DISTINCT(selectDepartmentChildList((SELECT fort_department_id FROM fort_user WHERE fort_user_id =userId ))) SEPARATOR ",")  INTO query_department_id;
           
      END IF;
      
    OPEN cur1;
      
  myLoop: LOOP  
    FETCH cur1 INTO temp_id,temp_name,temp_mode,temp_first,temp_end,temp_interval,temp_state,temp_file_name,temp_code;  
    IF done = 1 THEN   
        LEAVE myLoop;  
    END IF;  
          
        
    SELECT fort_department.fort_department_name INTO temp_department
    FROM fort_plan_password_backup,fort_department
    WHERE fort_plan_password_backup.fort_department_id = fort_department.fort_department_id
    AND fort_plan_password_backup.fort_plan_password_backup_id = temp_id;
    
    INSERT INTO temp_plan(fort_plan_password_backup_id,fort_plan_password_backup_name,fort_department,fort_run_mode,fort_first_run_time,
        fort_end_run_time,fort_run_interval,fort_state,fort_backup_file_name,fort_resource)  
    VALUES (temp_id,temp_name,temp_department,temp_mode,temp_first,temp_end,temp_interval,temp_state,temp_file_name,''); 
      
    IF (temp_code&1 = 1 ) THEN
    SELECT GROUP_CONCAT( DISTINCT( CONCAT(fort_resource.fort_resource_name,"(",fort_resource.fort_resource_ip,") - ",fort_account.fort_account_name,'|'))
    SEPARATOR '') 
    INTO temp_resource
    FROM  fort_plan_password_target_proxy,fort_resource,fort_account
    WHERE fort_plan_password_target_proxy.fort_target_id = fort_account.fort_account_id
    AND fort_account.fort_resource_id =  fort_resource.fort_resource_id
    AND fort_plan_password_target_proxy.fort_plan_id = temp_id
    AND fort_plan_password_target_proxy.fort_target_code = 1
    AND fort_account.fort_account_password IS NOT NULL
    AND fort_account.fort_account_password != ''
    AND fort_account.fort_account_name != '$user';  
    
    UPDATE  temp_plan SET fort_resource = CONCAT(fort_resource,IFNULL(temp_resource,'')) 
    WHERE fort_plan_password_backup_id = temp_id ;
    END IF;  
    IF (temp_code&2 = 2) THEN
    SELECT GROUP_CONCAT(DISTINCT(CONCAT(fort_resource.fort_resource_name,'(',fort_resource.fort_resource_ip,')','|'))SEPARATOR '') INTO temp_resource
    FROM  fort_plan_password_target_proxy,fort_resource
    WHERE fort_plan_password_target_proxy.fort_target_id = fort_resource.fort_resource_id
    AND fort_plan_password_target_proxy.fort_plan_id = temp_id
    AND fort_plan_password_target_proxy.fort_target_code = 2; 
    
    UPDATE temp_plan SET fort_resource = CONCAT(fort_resource,IFNULL(temp_resource,'')) 
    WHERE fort_plan_password_backup_id = temp_id ;  
    END IF;   
    IF (temp_code&4 = 4 ) THEN
    SELECT GROUP_CONCAT(DISTINCT(CONCAT(fort_resource_group.fort_resource_group_name,'|'))SEPARATOR '') INTO temp_resource
    FROM fort_resource_group,fort_plan_password_target_proxy
    WHERE fort_plan_password_target_proxy.fort_target_id = fort_resource_group.fort_resource_group_id
    AND  fort_plan_password_target_proxy.fort_plan_id = temp_id
    AND fort_plan_password_target_proxy.fort_target_code = 3; 
    
    UPDATE  temp_plan SET fort_resource = CONCAT(fort_resource,IFNULL(temp_resource,'')) 
    WHERE fort_plan_password_backup_id = temp_id ;
    END IF;  
                
    END LOOP myLoop;  
    
    CLOSE cur1;  
    IF (orderByClause='fort_plan_password_backup_name desc') THEN
        SELECT temp_plan.fort_plan_password_backup_id,temp_plan.fort_plan_password_backup_name,temp_plan.fort_department,temp_plan.fort_run_mode,
        temp_plan.fort_first_run_time,temp_plan.fort_end_run_time,temp_plan.fort_run_interval,temp_plan.fort_state,temp_plan.fort_backup_file_name,fort_resource
        FROM  temp_plan ORDER BY fort_plan_password_backup_name DESC LIMIT limitStart,limitEnd;
    END IF;
    IF (orderByClause='fort_plan_password_backup_name asc') THEN
        SELECT temp_plan.fort_plan_password_backup_id,temp_plan.fort_plan_password_backup_name,temp_plan.fort_department,temp_plan.fort_run_mode,
        temp_plan.fort_first_run_time,temp_plan.fort_end_run_time,temp_plan.fort_run_interval,temp_plan.fort_state,temp_plan.fort_backup_file_name,fort_resource
        FROM  temp_plan ORDER BY fort_plan_password_backup_name ASC LIMIT limitStart,limitEnd;
    END IF;
    IF (orderByClause='fort_plan_password_backup_id desc')  THEN
        SELECT temp_plan.fort_plan_password_backup_id,temp_plan.fort_plan_password_backup_name,temp_plan.fort_department,temp_plan.fort_run_mode,
        temp_plan.fort_first_run_time,temp_plan.fort_end_run_time,temp_plan.fort_run_interval,temp_plan.fort_state,temp_plan.fort_backup_file_name,fort_resource
        FROM  temp_plan ORDER BY fort_plan_password_backup_id DESC LIMIT limitStart,limitEnd;
    END IF;
    
  DROP TABLE temp_plan;
  SET autocommit = 1;
  
 
END$$

DELIMITER ;

DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `getPlanPasswordList`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `getPlanPasswordList`(IN userId VARCHAR(50),IN `orderByClause` VARCHAR(50) ,IN `limitStart` INT,IN `limitEnd` INT)
BEGIN   
    DECLARE done INT DEFAULT -1;  
    DECLARE temp_user VARCHAR(50); 
    DECLARE temp_id VARCHAR(24); 
    DECLARE temp_code INT;   
    DECLARE temp_name VARCHAR(32); 
    DECLARE temp_mode VARCHAR(2);   
    DECLARE temp_first DATETIME;
    DECLARE temp_end DATETIME;
    DECLARE temp_interval INT;
    DECLARE temp_state VARCHAR(2);  
    DECLARE temp_create VARCHAR(24); 
    DECLARE temp_create_by VARCHAR(70);
    DECLARE temp_resource TEXT;
    DECLARE temp_department VARCHAR(50);
    DECLARE query_department_id TEXT DEFAULT '';
    DECLARE temp_check_id VARCHAR(24);   
       
    
    DECLARE cur1 CURSOR FOR  SELECT DISTINCT 
    fort_plan_password.fort_plan_password_id,
    fort_plan_password.fort_plan_password_name,
    fort_plan_password.fort_run_mode,
    fort_plan_password.fort_first_run_time,
    fort_plan_password.fort_end_run_time,
    fort_plan_password.fort_run_interval,
    fort_plan_password.fort_state,
    fort_plan_password.fort_create_by,
    fort_plan_password.fort_plan_code
    FROM fort_plan_password 
    WHERE FIND_IN_SET(fort_plan_password.fort_department_id,query_department_id) ;
        
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1;  
    DROP TEMPORARY TABLE IF EXISTS temp_plan;   
    CREATE TEMPORARY TABLE temp_plan(
        fort_plan_password_id  VARCHAR(24) NOT NULL
        ,fort_plan_password_name VARCHAR(32)
        ,fort_department VARCHAR(50)
        ,fort_run_mode VARCHAR(2)
        ,fort_first_run_time DATETIME
        ,fort_end_run_time DATETIME
        ,fort_run_interval  INT
        ,fort_state VARCHAR(2)
        ,fort_create_by VARCHAR(70)
        ,fort_resource TEXT    
    );
       
    SET autocommit = 0;
    
     IF ( userId != '' ) THEN 
     
         SELECT GROUP_CONCAT(DISTINCT(selectDepartmentChildList((SELECT fort_department_id FROM fort_user WHERE fort_user_id =userId ))) SEPARATOR ",")  INTO query_department_id;
           
      END IF;
     
   
    OPEN cur1;
      
  myLoop: LOOP  
          
    FETCH cur1 INTO temp_id,temp_name,temp_mode,temp_first,temp_end,temp_interval,temp_state,temp_create,temp_code;  
    IF temp_id IS NULL THEN
     LEAVE myLoop;
    END IF;
    IF  temp_check_id = temp_id THEN   
         LEAVE myLoop;
    ELSE
         SET temp_check_id = temp_id; 
    END IF;  
    SELECT fort_department.fort_department_name INTO temp_department
    FROM fort_plan_password,fort_department
    WHERE fort_plan_password.fort_department_id = fort_department.fort_department_id
    AND fort_plan_password.fort_plan_password_id = temp_id;
      
        
    SELECT fort_user_name INTO temp_create_by FROM fort_user WHERE fort_user_id = temp_create;
        
    INSERT INTO temp_plan(fort_plan_password_id,fort_plan_password_name,fort_department,fort_run_mode,fort_first_run_time,
        fort_end_run_time,fort_run_interval,fort_state,fort_create_by,fort_resource)  
    VALUES (temp_id,temp_name,temp_department,temp_mode,temp_first,temp_end,temp_interval,temp_state,temp_create_by,''); 
  
    IF (temp_code&1 = 1 ) THEN
    
    SELECT GROUP_CONCAT( DISTINCT( CONCAT(fort_resource.fort_resource_name,"(",fort_resource.fort_resource_ip,") - ",fort_account.fort_account_name,'|')) SEPARATOR '') 
    INTO temp_resource
    FROM  fort_plan_password_target_proxy,fort_resource,fort_account
    WHERE fort_plan_password_target_proxy.fort_target_id = fort_account.fort_account_id
    AND fort_account.fort_resource_id =  fort_resource.fort_resource_id
    AND fort_plan_password_target_proxy.fort_plan_id = temp_id
    AND fort_plan_password_target_proxy.fort_target_code = 1
    AND fort_account.fort_account_password IS NOT NULL
    AND fort_account.fort_is_allow_authorized = '1';
            
    UPDATE  temp_plan SET fort_resource = CONCAT(fort_resource,IFNULL(temp_resource,'')) WHERE fort_plan_password_id = temp_id ;
    END IF;  
    IF (temp_code&2 = 2) THEN
   
    SELECT GROUP_CONCAT(DISTINCT(CONCAT(fort_resource.fort_resource_name,'(',fort_resource.fort_resource_ip,')','|'))SEPARATOR '') INTO temp_resource
    FROM  fort_plan_password_target_proxy,fort_resource
    WHERE fort_plan_password_target_proxy.fort_target_id = fort_resource.fort_resource_id
    AND fort_plan_password_target_proxy.fort_plan_id = temp_id
    AND fort_plan_password_target_proxy.fort_target_code = 2; 
    
       
    UPDATE temp_plan SET fort_resource =CONCAT(fort_resource,IFNULL(temp_resource,'')) WHERE fort_plan_password_id = temp_id ;
    END IF;  
    
      IF (temp_code&4 = 4 ) THEN
        SELECT GROUP_CONCAT(DISTINCT(CONCAT(fort_resource_group.fort_resource_group_name,'|'))SEPARATOR '') INTO temp_resource
        FROM fort_resource_group,fort_plan_password_target_proxy
        WHERE fort_plan_password_target_proxy.fort_target_id = fort_resource_group.fort_resource_group_id
        AND  fort_plan_password_target_proxy.fort_plan_id = temp_id
        AND fort_plan_password_target_proxy.fort_target_code = 3; 
            
        
        UPDATE  temp_plan SET fort_resource = CONCAT(fort_resource,IFNULL(temp_resource,'') ) WHERE fort_plan_password_id = temp_id ;
    END IF;  
                
    END LOOP myLoop;  
    
    CLOSE cur1;  
    
    IF (orderByClause='fort_plan_password_name desc') THEN
        SELECT temp_plan.fort_plan_password_id,temp_plan.fort_plan_password_name,temp_plan.fort_department,temp_plan.fort_run_mode,temp_plan.fort_first_run_time,
        temp_plan.fort_end_run_time,temp_plan.fort_run_interval,temp_plan.fort_state,temp_plan.fort_create_by,
        fort_resource
        FROM  temp_plan ORDER BY fort_plan_password_name DESC LIMIT limitStart,limitEnd;
    END IF;
    IF (orderByClause='fort_plan_password_name asc') THEN
        SELECT temp_plan.fort_plan_password_id,temp_plan.fort_plan_password_name,temp_plan.fort_department,temp_plan.fort_run_mode,temp_plan.fort_first_run_time,
        temp_plan.fort_end_run_time,temp_plan.fort_run_interval,temp_plan.fort_state,temp_plan.fort_create_by,
        fort_resource
        FROM  temp_plan ORDER BY fort_plan_password_name ASC LIMIT limitStart,limitEnd;
    END IF;
    IF (orderByClause='fort_plan_password_id desc') THEN
        SELECT temp_plan.fort_plan_password_id,temp_plan.fort_plan_password_name,temp_plan.fort_department,temp_plan.fort_run_mode,temp_plan.fort_first_run_time,
        temp_plan.fort_end_run_time,temp_plan.fort_run_interval,temp_plan.fort_state,temp_plan.fort_create_by,
        fort_resource
        FROM  temp_plan ORDER BY fort_plan_password_id DESC LIMIT limitStart,limitEnd;
    END IF;
  DROP TABLE temp_plan;
  
   SET autocommit = 1;
   
      
END$$

DELIMITER ;



DELIMITER $$


DROP PROCEDURE IF EXISTS selectAuthNameForUserId$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE selectAuthNameForUserId(IN user_id VARCHAR(32))
BEGIN   
   
      DROP TEMPORARY TABLE IF EXISTS temp_auth_name;    
      CREATE TEMPORARY TABLE temp_auth_name (
           auth_id  VARCHAR(33) 
          ,account_id VARCHAR(33) 
          ,auth_name VARCHAR(33) 
       )ENGINE=MEMORY;  
       
         SET autocommit = 0;   
        /*  根据用户id,查询授权id，并插入 */  
         INSERT INTO temp_auth_name (auth_id) SELECT DISTINCT fort_authorization_target_proxy.fort_authorization_id FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_target_id = user_id AND fort_authorization_target_proxy.fort_target_code = 2 ; 
        
        /* 根据用户组id,查询授权id，并插入*/  
         INSERT INTO temp_auth_name (auth_id)  SELECT DISTINCT fort_authorization_target_proxy.fort_authorization_id FROM fort_authorization_target_proxy,(SELECT fort_user_group_user.fort_user_group_id AS group_id FROM fort_user_group_user WHERE fort_user_group_user.fort_user_id = user_id ) t_group 
        WHERE  fort_authorization_target_proxy.fort_target_code = 4 AND FIND_IN_SET (fort_authorization_target_proxy.fort_target_id,t_group.group_id)  ; 
         
      SELECT  DISTINCT fort_authorization.fort_authorization_id AS auth_id ,fort_authorization.fort_authorization_name  AS auth_name FROM fort_authorization,temp_auth_name  WHERE fort_authorization.fort_authorization_id = temp_auth_name .auth_id;
   
     DROP TABLE temp_auth_name ; 
     SET autocommit = 1;   
    END$$

DELIMITER ;




DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `selectProcessTaskChildList`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `selectProcessTaskChildList`(IN rootId VARCHAR(200))
BEGIN 
    DECLARE sTemp VARCHAR(10000); 
    DECLARE sTempChd VARCHAR(10000);  
    SET sTemp = '';
    SET sTempChd =rootId ;
      WHILE sTempChd IS NOT NULL DO         
         SET sTemp = CONCAT(sTemp,',',sTempChd);
         SELECT GROUP_CONCAT(fort_process_task_id) INTO sTempChd FROM fort_process_task WHERE FIND_IN_SET(fort_parent_id,sTempChd)>0; 
     END WHILE; 
     SET sTemp = SUBSTRING(sTemp,2);
    SELECT sTemp ;  
    END$$

DELIMITER ;



DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `selectClientByresourceIdAndResouceTypeId`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `selectClientByresourceIdAndResouceTypeId`(IN fort_resource_id VARCHAR(100),IN fort_resource_type_id VARCHAR(100))
BEGIN   
     
     DECLARE temp_protocol_client TEXT;
     DECLARE temp_operations_protocol TEXT;
     
     
       IF (FIND_IN_SET('1000000000001',selectResourceTypePid(fort_resource_type_id ))) THEN
                 
              SELECT DISTINCT GROUP_CONCAT( DISTINCT(CONCAT(fort_protocol_client.fort_client_tool_id,":",fort_client_tool.fort_client_tool_name)) ORDER BY fort_protocol_client.fort_client_tool_id ASC  SEPARATOR '|') ,
              GROUP_CONCAT(DISTINCT(CONCAT("protoco",":",fort_operations_protocol.fort_operations_protocol_id,":",fort_operations_protocol.fort_operations_protocol_name)) ORDER BY fort_operations_protocol.fort_operations_protocol_id ASC SEPARATOR '|') INTO temp_protocol_client,temp_operations_protocol
          
          FROM fort_resource_operations_protocol ,fort_operations_protocol ,fort_protocol_client ,fort_client_tool 
         
          WHERE  fort_resource_operations_protocol.fort_operations_protocol_id = fort_operations_protocol.fort_operations_protocol_id 
          
          AND fort_operations_protocol.fort_operations_protocol_id = fort_protocol_client.fort_operations_protocol_id 
          
          AND fort_protocol_client.fort_client_tool_id = fort_client_tool.fort_client_tool_id 
          
          AND fort_resource_operations_protocol.fort_resource_id = fort_resource_id;   
         
         UPDATE  temp_protocol_client_table SET fort_protocol_client = temp_protocol_client,fort_operations_protocol = temp_operations_protocol  WHERE id = '100001' ;  
         END IF;  
         
         IF (FIND_IN_SET('1000000000002',selectResourceTypePid(fort_resource_type_id ))|| FIND_IN_SET('1000000000003',selectResourceTypePid(fort_resource_type_id )) ) THEN
          
           SELECT DISTINCT GROUP_CONCAT( DISTINCT(CONCAT(fort_protocol_client.fort_client_tool_id,":",fort_client_tool.fort_client_tool_name)) ORDER BY fort_protocol_client.fort_client_tool_id ASC  SEPARATOR '|') ,
  
                     GROUP_CONCAT( DISTINCT(CONCAT( "application",":",fort_application_release_server.fort_application_release_server_id,":",fort_application_release_server.fort_application_release_server_name)) ORDER BY fort_operations_protocol.fort_operations_protocol_id ASC SEPARATOR '|') INTO temp_protocol_client,temp_operations_protocol
           
               FROM   fort_resource ,fort_resource_operations_protocol,fort_operations_protocol , fort_protocol_client ,fort_client_tool ,fort_resource_application , fort_application_release_server 
              
               WHERE    fort_resource_application.fort_resource_id = fort_resource.fort_resource_id 
               AND fort_resource_application.fort_application_release_server_id = fort_application_release_server.fort_application_release_server_id 
               AND  fort_resource.fort_resource_id = fort_resource_operations_protocol.fort_resource_id
               AND fort_resource_operations_protocol.fort_operations_protocol_id = fort_protocol_client.fort_operations_protocol_id  
           AND fort_protocol_client.fort_client_tool_id = fort_client_tool.fort_client_tool_id   
           AND  fort_resource.fort_resource_id = fort_resource_id ;
           
               UPDATE  temp_protocol_client_table SET fort_protocol_client = temp_protocol_client,fort_operations_protocol = temp_operations_protocol  WHERE id = '100001' ;    
    
     END IF; 
 
    END$$

DELIMITER ;


DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `hasProcessId`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `hasProcessId`(IN userId VARCHAR(32),IN accountId VARCHAR(32),OUT processId VARCHAR(32))
BEGIN   
      DECLARE temp_auth_id VARCHAR(50);
      DECLARE temp_process_id VARCHAR(50);
      DECLARE temp_superior_state VARCHAR(50);
      DECLARE temp_user_sum INT;
      DECLARE temp_second_user_id VARCHAR(50);
      DECLARE temp_approver_name VARCHAR(50);
      DECLARE temp_approver_password VARCHAR(50);      
      DECLARE done INT DEFAULT 0; 
     
      
 /*  设置游标*/
      DECLARE cur1 CURSOR FOR SELECT a.fort_authorization_id FROM
(
SELECT fort_authorization_target_proxy.fort_authorization_id FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_target_code='8' AND fort_authorization_target_proxy.fort_target_id = accountId
UNION 
SELECT fort_authorization_target_proxy.fort_authorization_id FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_target_code='16' AND fort_authorization_target_proxy.fort_target_id
IN(SELECT fort_account.fort_resource_id FROM fort_account WHERE fort_account.fort_account_id = accountId)
UNION
SELECT DISTINCT
     fort_authorization_target_proxy.fort_authorization_id FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_target_code='32' AND fort_authorization_target_proxy.fort_target_id
     IN(SELECT fort_resource_group_resource.fort_resource_group_id FROM fort_resource_group_resource WHERE fort_resource_group_resource.fort_resource_id IN(
       SELECT fort_account.fort_resource_id FROM fort_account WHERE fort_account.fort_account_id = accountId )  )     
     ) a,
    
     (
    
     SELECT fort_authorization_target_proxy.fort_authorization_id 
     FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_target_code='2' AND fort_authorization_target_proxy.fort_target_id = userId       
      UNION
         SELECT fort_authorization_target_proxy.fort_authorization_id  FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_target_code='4'
          AND fort_authorization_target_proxy.fort_target_id
         IN(SELECT fort_user_group_user.fort_user_group_id FROM fort_user_group_user WHERE fort_user_group_user.fort_user_id = userId)
    
    ) b
    
    WHERE a.fort_authorization_id = b.fort_authorization_id;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1;      
   /* 打开游标 */
    DROP TEMPORARY TABLE IF EXISTS temp_process;    
    CREATE TEMPORARY TABLE temp_process(
            process_id VARCHAR(600)
       )ENGINE=MEMORY;  
      
      OPEN cur1;
    /* 循环开始 */  
    approveLoop: LOOP  
              SET done = 0;
              
           FETCH cur1 INTO temp_auth_id;
                
          IF done = 1 THEN  
            LEAVE approveLoop;  
           END IF;
           
                SELECT fort_superior_process_id INTO temp_process_id FROM fort_authorization WHERE fort_authorization_id = temp_auth_id;
             
                SELECT fort_state INTO temp_superior_state FROM fort_process WHERE fort_process_id = temp_process_id;
                
                IF temp_superior_state = 1 THEN
                   INSERT INTO temp_process(process_id) VALUES(temp_process_id);
                   
               END IF;
       
    END LOOP approveLoop;
    
        
    
    /* 关闭游标 */  
    CLOSE cur1;   
    
     
    SELECT DISTINCT(process_id) INTO processId FROM  temp_process LIMIT 1;
     DROP TABLE temp_process;
    END$$

DELIMITER ;




DELIMITER $$

USE `fort`$$

DROP VIEW IF EXISTS `department_approvers`$$

CREATE ALGORITHM=UNDEFINED DEFINER=`mysql`@`127.0.0.1` SQL SECURITY DEFINER VIEW `fort`.`department_approvers` AS (
SELECT
  `fu`.`fort_user_id`       AS `fort_approver_id`,
  `fu`.`fort_user_name`     AS `fort_approver_name`,
  `fu`.`fort_user_account`  AS `fort_approver_account`,
  `fd`.`fort_department_id` AS `fort_department_id`,
  `fd`.`fort_full_name`     AS `fort_department_name`
FROM (`fort`.`fort_user` `fu`
   JOIN `fort`.`fort_department` `fd`)
WHERE ((`fu`.`fort_department_id` = `fd`.`fort_department_id`)
       AND `fu`.`fort_user_id` IN(SELECT
                                    `fur`.`fort_user_id`
                                  FROM `fort`.`fort_user_role` `fur`
                                  WHERE `fur`.`fort_role_id` IN(SELECT
                                                                  `fr`.`fort_role_id`
                                                                FROM `fort`.`fort_role_privilege` `fr`
                                                                WHERE (`fr`.`fort_privilege_id` = (SELECT
                                                                                                     `fp`.`fort_privilege_id`
                                                                                                   FROM `fort`.`fort_privilege` `fp`
                                                                                                   WHERE (`fp`.`fort_privilege_code` = 'approval_operation_access')))))))$$

DELIMITER ;



/* PROCEDURE-获取流程ID*/
DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `getProcessId`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `getProcessId`(IN userId VARCHAR(32),IN accountId VARCHAR(32))
BEGIN   
      DECLARE temp_auth_id VARCHAR(50);
      DECLARE temp_process_id VARCHAR(50);
      DECLARE temp_superior_state VARCHAR(50);
      DECLARE temp_user_sum INT;
      DECLARE temp_second_user_id VARCHAR(50);
      DECLARE temp_approver_name VARCHAR(50);
      DECLARE temp_approver_password VARCHAR(50);      
      DECLARE done INT DEFAULT 0; 
     
      
 
      DECLARE cur1 CURSOR FOR SELECT a.fort_authorization_id FROM
(
SELECT fort_authorization_target_proxy.fort_authorization_id FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_target_code='8' AND fort_authorization_target_proxy.fort_target_id = accountId
UNION 
SELECT fort_authorization_target_proxy.fort_authorization_id FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_target_code='16' AND fort_authorization_target_proxy.fort_target_id
IN(SELECT fort_account.fort_resource_id FROM fort_account WHERE fort_account.fort_account_id = accountId)
UNION
SELECT DISTINCT
     fort_authorization_target_proxy.fort_authorization_id FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_target_code='32' AND fort_authorization_target_proxy.fort_target_id
     IN(SELECT fort_resource_group_resource.fort_resource_group_id FROM fort_resource_group_resource WHERE fort_resource_group_resource.fort_resource_id IN(
       SELECT fort_account.fort_resource_id FROM fort_account WHERE fort_account.fort_account_id = accountId )  )     
     ) a,
    
     (
    
     SELECT fort_authorization_target_proxy.fort_authorization_id 
     FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_target_code='2' AND fort_authorization_target_proxy.fort_target_id = userId       
      UNION
         SELECT fort_authorization_target_proxy.fort_authorization_id  FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_target_code='4'
          AND fort_authorization_target_proxy.fort_target_id
         IN(SELECT fort_user_group_user.fort_user_group_id FROM fort_user_group_user WHERE fort_user_group_user.fort_user_id = userId)
    
    ) b
    
    WHERE a.fort_authorization_id = b.fort_authorization_id;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1;      
   
    DROP TEMPORARY TABLE IF EXISTS temp_process;    
    CREATE TEMPORARY TABLE temp_process(
            process_id VARCHAR(600)
       );  
      
      OPEN cur1;
      
    approveLoop: LOOP  
             SET done = 0;
        FETCH cur1 INTO temp_auth_id;
          IF done = 1 THEN  
            LEAVE approveLoop;  
           END IF;
                SELECT fort_superior_process_id INTO temp_process_id FROM fort_authorization WHERE fort_authorization_id = temp_auth_id;
             
                SELECT fort_state INTO temp_superior_state FROM fort_process WHERE fort_process_id = temp_process_id;
              
                IF temp_superior_state = 1 THEN
                   INSERT INTO temp_process(process_id) VALUES(temp_process_id);
                   
               END IF;
       
                
    END LOOP approveLoop;
    
        
    
      
    CLOSE cur1;   
    
    
     SELECT DISTINCT * FROM  temp_process WHERE process_id IS NOT NULL;
      DROP TABLE temp_process;
    END$$

DELIMITER ;


DELIMITER $$



DROP PROCEDURE IF EXISTS checkUpSuper$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE checkUpSuper(IN userId VARCHAR(32),IN accountId VARCHAR(32))
BEGIN  
    
    DROP TEMPORARY TABLE IF EXISTS temp_up_super;    
    CREATE TEMPORARY TABLE temp_up_super(
            authorization_id VARCHAR(50)
       ); 

      INSERT INTO temp_up_super(authorization_id)  SELECT a.fort_authorization_id FROM
 (
SELECT fort_authorization_target_proxy.fort_authorization_id FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_target_code='8' AND fort_authorization_target_proxy.fort_target_id = accountId
UNION 
SELECT fort_authorization_target_proxy.fort_authorization_id FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_target_code='16' AND fort_authorization_target_proxy.fort_target_id
IN(SELECT fort_account.fort_resource_id FROM fort_account WHERE fort_account.fort_account_id = accountId)
UNION
SELECT DISTINCT
     fort_authorization_target_proxy.fort_authorization_id FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_target_code='32' AND fort_authorization_target_proxy.fort_target_id
     IN(SELECT fort_resource_group_resource.fort_resource_group_id FROM fort_resource_group_resource WHERE fort_resource_group_resource.fort_resource_id IN(
       SELECT fort_account.fort_resource_id FROM fort_account WHERE fort_account.fort_account_id = accountId )  )     
     ) a,
    
     (
    
     SELECT fort_authorization_target_proxy.fort_authorization_id 
     FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_target_code='2' AND fort_authorization_target_proxy.fort_target_id = userId       
      UNION
         SELECT fort_authorization_target_proxy.fort_authorization_id  FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_target_code='4'
          AND fort_authorization_target_proxy.fort_target_id
         IN(SELECT fort_user_group_user.fort_user_group_id FROM fort_user_group_user WHERE fort_user_group_user.fort_user_id = userId)
    
    ) b
    
    WHERE a.fort_authorization_id = b.fort_authorization_id;
    
    
 
  
      
        SELECT COUNT(DISTINCT fort_authorization_target_proxy.fort_authorization_target_proxy_id)  FROM fort_authorization_target_proxy,temp_up_super 
               WHERE fort_authorization_target_proxy.fort_authorization_id = temp_up_super.authorization_id  
               AND  fort_authorization_target_proxy.fort_target_id = accountId
               AND fort_authorization_target_proxy.fort_target_code = 8
               AND fort_authorization_target_proxy.fort_is_up_super = '1';
             
      
    
        
  
  
     DROP TABLE temp_up_super;
    END$$

DELIMITER ;



DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `selectSuperiorApproval`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `selectSuperiorApproval`(IN userId VARCHAR(50),IN accountId VARCHAR(50),IN process_id VARCHAR(50),IN web_session VARCHAR(100),IN applyResourceId VARCHAR(100),OUT superior_approval_state VARCHAR(32) )
BEGIN   
     
      DECLARE temp_common_superior_approval_id VARCHAR(50);
      
      DECLARE temp_quick_superior_approval_id VARCHAR(50);
      
      DECLARE temp_common_superior_approval_state VARCHAR(10);
      
      SELECT fort_superior_approval_application.fort_superior_approval_application_id ,fort_process_instance.fort_state 
           INTO temp_common_superior_approval_id,temp_common_superior_approval_state
           FROM  fort_superior_approval_application , fort_process_instance 
       WHERE fort_superior_approval_application.fort_process_instance_id = fort_process_instance.fort_process_instance_id
           AND fort_superior_approval_application.fort_start_time < SYSDATE() AND fort_superior_approval_application.fort_end_time > SYSDATE()
        AND fort_superior_approval_application.fort_account_id = accountId
           AND fort_superior_approval_application.fort_applicant_id = userId  AND fort_superior_approval_application.fort_process_id = process_id
           AND fort_superior_approval_application.fort_resource_id = applyResourceId
           ORDER BY fort_superior_approval_application.fort_apply_create_time DESC LIMIT 1;
    
         
           
    IF (temp_common_superior_approval_id  IS NOT NULL && temp_common_superior_approval_state = 2 )  THEN 
        
             SET  superior_approval_state = '0' ;
     
     END IF;  
      
      IF ( temp_common_superior_approval_id  IS  NULL ||  temp_common_superior_approval_state != 2 )  THEN 
        
          SELECT fort_superior_approval_application.fort_superior_approval_application_id INTO temp_quick_superior_approval_id FROM fort_superior_approval_application 
                WHERE fort_superior_approval_application.fort_process_id = process_id
                     AND fort_superior_approval_application.fort_account_id = accountId
                     AND fort_superior_approval_application.fort_applicant_id = userId
                     AND  fort_superior_approval_application.fort_web_session = web_session
                     AND fort_superior_approval_application.fort_resource_id = applyResourceId;
     
     END IF;  
     
    IF (temp_quick_superior_approval_id  IS NOT NULL  )  THEN 
        
            SET  superior_approval_state = '1' ;
     
     END IF;  
     
     IF (temp_quick_superior_approval_id  IS  NULL &&   ( temp_common_superior_approval_id  IS  NULL || temp_common_superior_approval_state != 2 )  )  THEN 
        
           SET  superior_approval_state = '2' ;
     
     END IF;  
      
  
    END$$

DELIMITER ;




DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `selectApproverStatus`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `selectApproverStatus`(IN fort_user_id VARCHAR(100),IN fort_account_id VARCHAR(100),IN fort_web_session VARCHAR(100),OUT approverStatus INTEGER)
BEGIN 

     SELECT fort_process_instance.fort_state INTO approverStatus FROM  fort_process_instance ,fort_double_approval_application
     WHERE fort_double_approval_application.fort_account_id = fort_account_id 
     AND fort_double_approval_application.fort_applicant_id = fort_user_id  
     AND fort_double_approval_application.fort_web_session = fort_web_session
     AND fort_double_approval_application.fort_session IS NULL 
    AND fort_double_approval_application.fort_process_instance_id = fort_process_instance.fort_process_instance_id 
    ORDER BY fort_process_instance.fort_end_time DESC,fort_apply_create_time DESC LIMIT 1 ;
   
    END$$

DELIMITER ;



DELIMITER $$

USE `fort`$$

DROP VIEW IF EXISTS `authorization_all_user`$$

CREATE ALGORITHM=UNDEFINED DEFINER=`mysql`@`127.0.0.1` SQL SECURITY DEFINER VIEW `authorization_all_user` AS 
SELECT
  `fort_authorization_target_proxy`.`fort_authorization_id` AS `fort_authorization_id`,
  `fort_user_group_user`.`fort_user_id`                     AS `fort_user_id`,
  `fort_user`.`fort_user_name`                              AS `fort_user_name`,
  `fort_user`.`fort_user_account`                           AS `fort_user_account`
FROM ((`fort_user_group_user`
    JOIN `fort_authorization_target_proxy`)
   JOIN `fort_user`)
WHERE ((`fort_user_group_user`.`fort_user_group_id` = `fort_authorization_target_proxy`.`fort_target_id`)
       AND (`fort_authorization_target_proxy`.`fort_target_code` = '4')
       AND (`fort_user_group_user`.`fort_user_id` = `fort_user`.`fort_user_id`))UNION SELECT
                                                                                        `fort_authorization_target_proxy`.`fort_authorization_id`  AS `fort_authorization_id`,
                                                                                        `fort_user`.`fort_user_id`                                 AS `fort_user_id`,
                                                                                        `fort_user`.`fort_user_name`                               AS `fort_user_name`,
                                                                                        `fort_user`.`fort_user_account`                            AS `fort_user_account`
                                                                                      FROM (`fort_authorization_target_proxy`
                                                                                         JOIN `fort_user`)
                                                                                      WHERE ((`fort_authorization_target_proxy`.`fort_target_code` = '2')
                                                                                             AND (`fort_authorization_target_proxy`.`fort_target_id` = `fort_user`.`fort_user_id`))$$




DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `checkDoubleApproveByResourceGroupAdd`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `checkDoubleApproveByResourceGroupAdd`(IN temp_resouce_group_id VARCHAR(100),IN temp_resource_ids TEXT)
BEGIN   
      DECLARE done INT DEFAULT -1;  
      DECLARE temp_auth_id VARCHAR(32); 
      DECLARE temp_auth_check_id VARCHAR(32); 
      DECLARE temp_code INT;  
      DECLARE temp_auth_check_code INT;   
      DECLARE temp_authorization_resource TEXT;
      DECLARE temp_user_group_vali_auth_num INT;       
      
      DECLARE select_auth_for_all CURSOR FOR SELECT fort_authorization.fort_authorization_id,fort_authorization.fort_authorization_code 
             FROM fort_authorization,temp_auth_id 
              WHERE  fort_authorization.fort_double_is_open = '1' 
              AND fort_authorization.fort_authorization_id <> temp_auth_id.auth_id;
      
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1;  
      
      SET autocommit = 0;
     
      DROP TEMPORARY TABLE IF EXISTS temp_account_sso;  
      CREATE TEMPORARY TABLE temp_account_sso(
           auth_id  VARCHAR(32) 
          ,account_id VARCHAR(32) 
          ,resource_id VARCHAR(32)   
       )ENGINE=MEMORY;
      
       DROP TEMPORARY TABLE IF EXISTS temp_account_auth;  
       CREATE TEMPORARY TABLE temp_account_auth(
           account_id VARCHAR(32) 
          ,resource_id VARCHAR(32)   
       )ENGINE=MEMORY;
      DROP TEMPORARY TABLE IF EXISTS temp_auth_id;  
      CREATE TEMPORARY TABLE temp_auth_id(
           auth_id  VARCHAR(32) 
       )ENGINE=MEMORY;
       
      DROP TEMPORARY TABLE IF EXISTS temp_approve;  
      CREATE TEMPORARY TABLE temp_approve(
           fort_user_id  VARCHAR(32)
           ,fort_user_name  VARCHAR(100) 
           ,fort_resource_name  VARCHAR(100) 
           ,fort_authorization_name VARCHAR(100)
       )ENGINE=MEMORY;
       
       DROP TEMPORARY TABLE IF EXISTS temp_resourceIds;  
       CREATE TEMPORARY TABLE temp_resourceIds(
         resource_id VARCHAR(32)   
       )ENGINE=MEMORY;
       
      INSERT INTO temp_auth_id SELECT fort_authorization_target_proxy.fort_authorization_id FROM fort_authorization_target_proxy 
             WHERE  fort_authorization_target_proxy.fort_target_id = temp_resouce_group_id;
       
       # 用户id字符串处理    
     SET @temp_authorization_resource = CONCAT(CONCAT("insert into temp_resourceIds values('",REPLACE(temp_resource_ids,',',"'),('")),"')"); 
     PREPARE stmt FROM  @temp_authorization_resource; 
     EXECUTE stmt;      
     DEALLOCATE PREPARE stmt;       
    #字符串id字符串处理结束 
      
      INSERT INTO temp_account_auth(account_id,resource_id)    
           SELECT  fort_account.fort_account_id, fort_resource.fort_resource_id 
            FROM 
                  fort_account,fort_resource,temp_resourceIds
            WHERE 
                  temp_resourceIds.resource_id = fort_resource.fort_resource_id 
                    AND fort_resource.fort_resource_id = fort_account.fort_resource_id 
                    AND fort_resource.fort_parent_id IS NULL AND fort_account.fort_is_allow_authorized = 1 ;
       
         INSERT INTO temp_account_auth(account_id,resource_id) 
            SELECT fort_account.fort_account_id, fort_resource.fort_resource_id 
              FROM 
                    fort_account,fort_resource,temp_resourceIds 
              WHERE 
                   temp_resourceIds.resource_id = fort_resource.fort_resource_id 
             AND  fort_resource.fort_parent_id = fort_account.fort_resource_id 
             AND  fort_resource.fort_parent_id IS NOT NULL AND fort_account.fort_is_allow_authorized = 1 ;
      /** 查询授权 非关联资源组  */
        
      OPEN select_auth_for_all;
   
      
      tempSuperoirApproveAllAuthLoop: LOOP  
     
        SET done = 0; 
        FETCH select_auth_for_all INTO temp_auth_id,temp_code;  
       
        IF done = 1 THEN    
           LEAVE tempSuperoirApproveAllAuthLoop;  
        END IF;  
         IF (temp_code&8 = 8 ) THEN
         
         INSERT INTO temp_account_sso(auth_id,account_id,resource_id) 
              SELECT fort_authorization_target_proxy.fort_authorization_id,fort_authorization_target_proxy.fort_target_id,fort_authorization_target_proxy.fort_parent_id
                    FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_id 
                    AND fort_authorization_target_proxy.fort_target_code = 8 ;
         END IF;  
         
         IF (temp_code&16 = 16 ) THEN
              INSERT INTO temp_account_sso(auth_id,account_id,resource_id)    
                    SELECT  fort_authorization_target_proxy.fort_authorization_id,fort_account.fort_account_id, fort_resource.fort_resource_id FROM fort_account,fort_resource,fort_authorization_target_proxy 
            WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_id 
                AND fort_authorization_target_proxy.fort_target_code = 16
            AND fort_authorization_target_proxy.fort_target_id = fort_resource.fort_resource_id 
                    AND fort_resource.fort_resource_id = fort_account.fort_resource_id 
                    AND fort_resource.fort_parent_id IS NULL AND fort_account.fort_is_allow_authorized = 1 ;
       
         INSERT INTO temp_account_sso(auth_id,account_id,resource_id) 
             SELECT fort_authorization_target_proxy.fort_authorization_id,fort_account.fort_account_id, fort_resource.fort_resource_id FROM fort_account,fort_resource,fort_authorization_target_proxy 
             WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_id  
             AND fort_authorization_target_proxy.fort_target_code = 16
             AND fort_authorization_target_proxy.fort_target_id = fort_resource.fort_resource_id 
                     AND fort_resource.fort_parent_id = fort_account.fort_resource_id 
                     AND fort_resource.fort_parent_id IS NOT NULL AND fort_account.fort_is_allow_authorized = 1 ;
                     
         END IF; 
         
    
         
         IF (temp_code&32 = 32 ) THEN
          
         INSERT INTO temp_account_sso(auth_id,account_id,resource_id) 
                SELECT fort_authorization_target_proxy.fort_authorization_id,fort_account.fort_account_id, fort_resource.fort_resource_id 
                FROM fort_account,fort_resource,fort_resource_group_resource,fort_authorization_target_proxy
                    WHERE  fort_resource.fort_resource_id = fort_account.fort_resource_id
                    AND fort_resource_group_resource.fort_resource_id = fort_resource.fort_resource_id
                    AND fort_resource.fort_parent_id IS NULL AND fort_resource.fort_resource_state <> 2 
                    AND fort_account.fort_is_allow_authorized = 1
                    AND fort_authorization_target_proxy.fort_authorization_id = temp_auth_id 
                    AND fort_authorization_target_proxy.fort_target_code =  32 
                    AND fort_resource_group_resource.fort_resource_group_id = fort_authorization_target_proxy.fort_target_id;
                    
         INSERT INTO temp_account_sso(auth_id,account_id,resource_id) 
                SELECT fort_authorization_target_proxy.fort_authorization_id,fort_account.fort_account_id, fort_resource.fort_resource_id 
                FROM fort_account,fort_resource,fort_resource_group_resource,fort_authorization_target_proxy
                    WHERE  fort_resource.fort_parent_id = fort_account.fort_resource_id
                    AND fort_resource_group_resource.fort_resource_id = fort_resource.fort_resource_id
                    AND fort_resource.fort_parent_id IS NOT NULL AND fort_resource.fort_resource_state <> 2 
                    AND fort_account.fort_is_allow_authorized = 1
                    AND fort_authorization_target_proxy.fort_authorization_id = temp_auth_id 
                    AND fort_authorization_target_proxy.fort_target_code =  32
                    AND fort_resource_group_resource.fort_resource_group_id = fort_authorization_target_proxy.fort_target_id;
                    
         END IF;  
          
        END LOOP tempSuperoirApproveAllAuthLoop;  
    
     CLOSE select_auth_for_all;  
      
      
     INSERT INTO temp_approve(fort_user_id,fort_user_name,fort_resource_name,fort_authorization_name)   
         SELECT DISTINCT fort_double_approval.fort_user_id ,fort_user.fort_user_name,
         fort_resource.fort_resource_name,fort_authorization.fort_authorization_name  
         FROM temp_account_auth,fort_user,fort_account,fort_resource ,fort_double_approval,temp_auth_id,fort_authorization
         WHERE 
              fort_double_approval.fort_is_candidate = '1'  
         AND temp_auth_id.auth_id = fort_double_approval.fort_authorization_id     
         AND fort_double_approval.fort_user_id = fort_user.fort_user_id
         AND temp_account_auth.account_id = fort_account.fort_account_id 
         AND fort_resource.fort_resource_id = fort_account.fort_resource_id
         AND fort_authorization.fort_authorization_id = fort_double_approval.fort_authorization_id
     GROUP BY fort_double_approval.fort_user_id,temp_account_auth.account_id 
     HAVING COUNT(DISTINCT fort_double_approval.fort_authorization_id )>1;  
     
       SELECT COUNT(*) INTO temp_user_group_vali_auth_num  FROM temp_approve;
       
   IF (temp_user_group_vali_auth_num = 0) THEN
     INSERT INTO temp_approve(fort_user_id,fort_user_name,fort_resource_name,fort_authorization_name)
        SELECT DISTINCT fort_double_approval.fort_user_id ,fort_user.fort_user_name,
         fort_resource.fort_resource_name,fort_authorization.fort_authorization_name 
         FROM temp_account_sso,fort_user,fort_account,fort_resource,fort_double_approval,fort_authorization,( 
         SELECT DISTINCT temp_account_auth.account_id,temp_account_auth.resource_id,fort_double_approval.fort_authorization_id,fort_double_approval.fort_user_id
         FROM temp_account_auth,temp_auth_id,fort_double_approval WHERE 
         fort_double_approval.fort_authorization_id = temp_auth_id.auth_id 
         AND fort_double_approval.fort_is_candidate = '1' 
         )t
       WHERE  fort_double_approval.fort_authorization_id  = temp_account_sso.auth_id 
     AND fort_double_approval.fort_authorization_id <> t.fort_authorization_id
         AND temp_account_sso.account_id = t.account_id
         AND temp_account_sso.resource_id = t.resource_id 
         AND fort_double_approval.fort_user_id = t.fort_user_id
         AND fort_double_approval.fort_user_id = fort_user.fort_user_id
         AND temp_account_sso.account_id = fort_account.fort_account_id 
         AND fort_resource.fort_resource_id = fort_account.fort_resource_id
         AND fort_authorization.fort_authorization_id = fort_double_approval.fort_authorization_id;
         
   END IF; 
   
     SELECT * FROM temp_approve;
   
    DROP TABLE temp_account_sso; 
    DROP TABLE temp_account_auth; 
      
    DROP TABLE temp_auth_id;
    
    DROP TABLE temp_approve;
 
    DROP TABLE temp_resourceIds;
      
    SET autocommit = 1;
    
    END$$

DELIMITER ;



DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `checkSuperiorProcessByResourceGroupAdd`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `checkSuperiorProcessByResourceGroupAdd`(IN temp_resouce_group_id VARCHAR(100),IN temp_resource_ids TEXT)
BEGIN   
      DECLARE done INT DEFAULT -1;  
      DECLARE temp_auth_id VARCHAR(32); 
      DECLARE temp_auth_check_id VARCHAR(32); 
      DECLARE temp_code INT;  
      DECLARE temp_auth_check_code INT;   
      DECLARE temp_authorization_resource TEXT;
      DECLARE temp_user_group_vali_auth_num INT;       
      
      DECLARE select_auth_for_all CURSOR FOR SELECT fort_authorization.fort_authorization_id,fort_authorization.fort_authorization_code 
             FROM fort_authorization,fort_process,temp_auth_id 
              WHERE fort_authorization.fort_superior_process_id = fort_process.fort_process_id AND fort_process.fort_state = '1' 
              AND fort_authorization.fort_authorization_id <> temp_auth_id.auth_id;
    
      DECLARE select_auth_for_auth_id CURSOR FOR SELECT DISTINCT fort_authorization.fort_authorization_id,
              fort_authorization.fort_authorization_code  FROM fort_authorization ,temp_auth_id,fort_process
          WHERE  fort_authorization.fort_superior_process_id = fort_process.fort_process_id 
              AND fort_process.fort_state = '1' 
              AND  fort_authorization.fort_authorization_id = temp_auth_id.auth_id;
      
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1;  
      
      SET autocommit = 0;
     
      DROP TEMPORARY TABLE IF EXISTS temp_account_sso;  
      CREATE TEMPORARY TABLE temp_account_sso(
           auth_id  VARCHAR(32) 
          ,account_id VARCHAR(32) 
          ,resource_id VARCHAR(32)   
       )ENGINE=MEMORY;
      
      DROP TEMPORARY TABLE IF EXISTS temp_user_sso;  
      
      CREATE TEMPORARY TABLE temp_user_sso(
           auth_id  VARCHAR(32) 
          ,user_id VARCHAR(32) 
       )ENGINE=MEMORY;
       
       DROP TEMPORARY TABLE IF EXISTS temp_account_auth;  
       CREATE TEMPORARY TABLE temp_account_auth(
           account_id VARCHAR(32) 
          ,resource_id VARCHAR(32)   
       )ENGINE=MEMORY;
      
      DROP TEMPORARY TABLE IF EXISTS temp_user_auth;  
      CREATE TEMPORARY TABLE temp_user_auth(  
          auth_id  VARCHAR(32) 
         ,user_id VARCHAR(32) 
       )ENGINE=MEMORY;
      
      DROP TEMPORARY TABLE IF EXISTS temp_auth_id;  
      CREATE TEMPORARY TABLE temp_auth_id(
           auth_id  VARCHAR(32) 
       )ENGINE=MEMORY;
       
      DROP TEMPORARY TABLE IF EXISTS temp_approve;  
      CREATE TEMPORARY TABLE temp_approve(
           fort_user_id  VARCHAR(32)
           ,fort_user_name  VARCHAR(100) 
           ,fort_resource_name  VARCHAR(100) 
           ,fort_authorization_name VARCHAR(100)
       )ENGINE=MEMORY;
       
       DROP TEMPORARY TABLE IF EXISTS temp_resourceIds;  
       CREATE TEMPORARY TABLE temp_resourceIds(
         resource_id VARCHAR(32)   
       )ENGINE=MEMORY;
       
      INSERT INTO temp_auth_id SELECT fort_authorization_target_proxy.fort_authorization_id FROM fort_authorization_target_proxy 
             WHERE  fort_authorization_target_proxy.fort_target_id = temp_resouce_group_id;
       
       # 用户id字符串处理    
     SET @temp_authorization_resource = CONCAT(CONCAT("insert into temp_resourceIds values('",REPLACE(temp_resource_ids,',',"'),('")),"')"); 
     PREPARE stmt FROM  @temp_authorization_resource; 
     EXECUTE stmt;      
     DEALLOCATE PREPARE stmt;       
    #字符串id字符串处理结束 
      
      INSERT INTO temp_account_auth(account_id,resource_id)    
           SELECT  fort_account.fort_account_id, fort_resource.fort_resource_id 
            FROM 
                  fort_account,fort_resource,temp_resourceIds
            WHERE 
                  temp_resourceIds.resource_id = fort_resource.fort_resource_id 
                    AND fort_resource.fort_resource_id = fort_account.fort_resource_id 
                    AND fort_resource.fort_parent_id IS NULL AND fort_account.fort_is_allow_authorized = 1 ;
       
         INSERT INTO temp_account_auth(account_id,resource_id) 
            SELECT fort_account.fort_account_id, fort_resource.fort_resource_id 
              FROM 
                    fort_account,fort_resource,temp_resourceIds 
              WHERE 
                   temp_resourceIds.resource_id = fort_resource.fort_resource_id 
             AND  fort_resource.fort_parent_id = fort_account.fort_resource_id 
             AND  fort_resource.fort_parent_id IS NOT NULL AND fort_account.fort_is_allow_authorized = 1 ;
          
             
    OPEN select_auth_for_auth_id;
   
     
      tempApproveOneAuthLoop: LOOP  
        
        SET done = 0; 
        FETCH select_auth_for_auth_id INTO temp_auth_check_id,temp_auth_check_code;  
        IF done = 1 THEN   
        LEAVE tempApproveOneAuthLoop;  
        END IF;  
       
      IF (temp_auth_check_code&2 = 2 ) THEN
      
     INSERT INTO temp_user_auth(auth_id,user_id) 
               SELECT DISTINCT fort_authorization_target_proxy.fort_authorization_id  ,fort_authorization_target_proxy.fort_target_id
               FROM fort_authorization_target_proxy
               WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_check_id
               AND fort_authorization_target_proxy.fort_target_code = 2; 
     
       END IF;  
       
      IF (temp_auth_check_code&4 = 4 ) THEN 
         INSERT INTO temp_user_auth(auth_id,user_id)    
                SELECT  DISTINCT t.fort_authorization_id,fort_user_group_user.fort_user_id FROM 
         fort_user_group_user,( SELECT fort_authorization_target_proxy.fort_target_id,fort_authorization_target_proxy.fort_authorization_id FROM fort_authorization_target_proxy  
         WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_check_id AND  fort_authorization_target_proxy.fort_target_code ='4') t
        WHERE fort_user_group_user.fort_user_group_id IN ( t.fort_target_id) ; 
      
        END IF;    
         
        END LOOP tempApproveOneAuthLoop;  
    
     CLOSE select_auth_for_auth_id;         
    
    
       
      /** 查询授权 非关联用户组  */
        
      OPEN select_auth_for_all;
   
      
      tempSuperoirApproveAllAuthLoop: LOOP  
     
        SET done = 0; 
        FETCH select_auth_for_all INTO temp_auth_id,temp_code;  
       
        IF done = 1 THEN    
           LEAVE tempSuperoirApproveAllAuthLoop;  
        END IF;  
    
      IF (temp_code&2 = 2 ) THEN
    
     INSERT INTO temp_user_sso(auth_id,user_id) 
               SELECT DISTINCT fort_authorization_target_proxy.fort_authorization_id  ,fort_authorization_target_proxy.fort_target_id
               FROM fort_authorization_target_proxy
               WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_id
               AND fort_authorization_target_proxy.fort_target_code = 2; 
     
       END IF;  
       
      IF (temp_code&4 = 4 ) THEN 
         INSERT INTO temp_user_sso(auth_id,user_id)    
                SELECT  DISTINCT t.fort_authorization_id,fort_user_group_user.fort_user_id FROM 
         fort_user_group_user,( SELECT fort_authorization_target_proxy.fort_target_id,fort_authorization_target_proxy.fort_authorization_id FROM fort_authorization_target_proxy  
         WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_id AND  fort_authorization_target_proxy.fort_target_code ='4') t
        WHERE fort_user_group_user.fort_user_group_id IN ( t.fort_target_id) ; 
      
        END IF;    
         IF (temp_code&8 = 8 ) THEN
         
         INSERT INTO temp_account_sso(auth_id,account_id,resource_id) 
              SELECT fort_authorization_target_proxy.fort_authorization_id,fort_authorization_target_proxy.fort_target_id,fort_authorization_target_proxy.fort_parent_id
                    FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_id 
                    AND fort_authorization_target_proxy.fort_target_code = 8 ;
         END IF;  
         
         IF (temp_code&16 = 16 ) THEN
              INSERT INTO temp_account_sso(auth_id,account_id,resource_id)    
                    SELECT  fort_authorization_target_proxy.fort_authorization_id,fort_account.fort_account_id, fort_resource.fort_resource_id FROM fort_account,fort_resource,fort_authorization_target_proxy 
            WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_id 
                AND fort_authorization_target_proxy.fort_target_code = 16
            AND fort_authorization_target_proxy.fort_target_id = fort_resource.fort_resource_id 
                    AND fort_resource.fort_resource_id = fort_account.fort_resource_id 
                    AND fort_resource.fort_parent_id IS NULL AND fort_account.fort_is_allow_authorized = 1 ;
       
         INSERT INTO temp_account_sso(auth_id,account_id,resource_id) 
             SELECT fort_authorization_target_proxy.fort_authorization_id,fort_account.fort_account_id, fort_resource.fort_resource_id FROM fort_account,fort_resource,fort_authorization_target_proxy 
             WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_id  
             AND fort_authorization_target_proxy.fort_target_code = 16
             AND fort_authorization_target_proxy.fort_target_id = fort_resource.fort_resource_id 
                     AND fort_resource.fort_parent_id = fort_account.fort_resource_id 
                     AND fort_resource.fort_parent_id IS NOT NULL AND fort_account.fort_is_allow_authorized = 1 ;
                     
         END IF; 
         
    
         
         IF (temp_code&32 = 32 ) THEN
          
         INSERT INTO temp_account_sso(auth_id,account_id,resource_id) 
                SELECT fort_authorization_target_proxy.fort_authorization_id,fort_account.fort_account_id, fort_resource.fort_resource_id 
                FROM fort_account,fort_resource,fort_resource_group_resource,fort_authorization_target_proxy
                    WHERE  fort_resource.fort_resource_id = fort_account.fort_resource_id
                    AND fort_resource_group_resource.fort_resource_id = fort_resource.fort_resource_id
                    AND fort_resource.fort_parent_id IS NULL AND fort_resource.fort_resource_state <> 2 
                    AND fort_account.fort_is_allow_authorized = 1
                    AND fort_authorization_target_proxy.fort_authorization_id = temp_auth_id 
                    AND fort_authorization_target_proxy.fort_target_code =  32 
                    AND fort_resource_group_resource.fort_resource_group_id = fort_authorization_target_proxy.fort_target_id;
                    
         INSERT INTO temp_account_sso(auth_id,account_id,resource_id) 
                SELECT fort_authorization_target_proxy.fort_authorization_id,fort_account.fort_account_id, fort_resource.fort_resource_id 
                FROM fort_account,fort_resource,fort_resource_group_resource,fort_authorization_target_proxy
                    WHERE  fort_resource.fort_parent_id = fort_account.fort_resource_id
                    AND fort_resource_group_resource.fort_resource_id = fort_resource.fort_resource_id
                    AND fort_resource.fort_parent_id IS NOT NULL AND fort_resource.fort_resource_state <> 2 
                    AND fort_account.fort_is_allow_authorized = 1
                    AND fort_authorization_target_proxy.fort_authorization_id = temp_auth_id 
                    AND fort_authorization_target_proxy.fort_target_code =  32
                    AND fort_resource_group_resource.fort_resource_group_id = fort_authorization_target_proxy.fort_target_id;
                    
         END IF;  
          
        END LOOP tempSuperoirApproveAllAuthLoop;  
    
     CLOSE select_auth_for_all;  
    
     INSERT INTO temp_approve(fort_user_id,fort_user_name,fort_resource_name,fort_authorization_name)   
         SELECT DISTINCT temp_user_auth.user_id ,fort_user.fort_user_name,
         fort_resource.fort_resource_name,fort_authorization.fort_authorization_name   
         FROM temp_account_auth,temp_user_auth,fort_user,fort_account,fort_resource,fort_authorization
         WHERE 
             temp_user_auth.user_id = fort_user.fort_user_id
         AND temp_account_auth.account_id = fort_account.fort_account_id 
         AND fort_resource.fort_resource_id = fort_account.fort_resource_id
         AND fort_authorization.fort_authorization_id = temp_user_auth.auth_id
     GROUP BY temp_user_auth.user_id,temp_account_auth.account_id 
     HAVING COUNT(DISTINCT temp_user_auth.auth_id )>1;
        
       SELECT COUNT(*) INTO temp_user_group_vali_auth_num  FROM temp_approve;
       
   IF (temp_user_group_vali_auth_num = 0) THEN
   
     INSERT INTO temp_approve(fort_user_id,fort_user_name,fort_resource_name,fort_authorization_name)
        SELECT DISTINCT temp_user_sso.user_id ,fort_user.fort_user_name,
         fort_resource.fort_resource_name,fort_authorization.fort_authorization_name    
         FROM temp_account_sso,temp_user_sso ,temp_account_auth,temp_user_auth,fort_user,fort_account,fort_resource,fort_authorization
       WHERE  temp_user_sso.auth_id  = temp_account_sso.auth_id 
         AND temp_account_sso.account_id = temp_account_auth.account_id
         AND temp_account_sso.resource_id = temp_account_auth.resource_id 
         AND temp_user_sso.user_id = temp_user_auth.user_id
         AND temp_user_sso.user_id = fort_user.fort_user_id
         AND temp_account_sso.account_id = fort_account.fort_account_id 
         AND fort_resource.fort_resource_id = fort_account.fort_resource_id 
         AND fort_authorization.fort_authorization_id = temp_user_sso.auth_id;
   
   END IF; 
   
     SELECT * FROM temp_approve;
   
    DROP TABLE temp_account_sso; 
    
    DROP TABLE temp_user_sso;
    
    DROP TABLE temp_account_auth; 
      
    DROP TABLE temp_user_auth;
     
    DROP TABLE temp_auth_id;
    
    DROP TABLE temp_approve;
 
    DROP TABLE temp_resourceIds;
      
    SET autocommit = 1;
    
    END$$

DELIMITER ;


DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `checkSuperiorProcessByUserGroupAdd`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `checkSuperiorProcessByUserGroupAdd`(IN temp_user_group_id VARCHAR(100),IN temp_user_ids TEXT)
BEGIN   
      DECLARE done INT DEFAULT -1;  
      DECLARE temp_auth_id VARCHAR(32); 
      DECLARE temp_auth_check_id VARCHAR(32); 
      DECLARE temp_code INT;  
      DECLARE temp_auth_check_code INT;   
      DECLARE temp_authorization_user TEXT;
      DECLARE temp_user_group_vali_auth_num INT;       
      
      DECLARE select_auth_for_all CURSOR FOR SELECT fort_authorization.fort_authorization_id,fort_authorization.fort_authorization_code 
             FROM fort_authorization,fort_process,temp_auth 
              WHERE fort_authorization.fort_superior_process_id = fort_process.fort_process_id AND fort_process.fort_state = '1' 
              AND fort_authorization.fort_authorization_id <> temp_auth.auth_id;
    
       DECLARE select_auth_for_auth_id CURSOR FOR SELECT DISTINCT fort_authorization.fort_authorization_id,
              fort_authorization.fort_authorization_code  FROM fort_authorization ,temp_auth,fort_process
          WHERE  fort_authorization.fort_superior_process_id = fort_process.fort_process_id 
              AND fort_process.fort_state = '1'  
              AND fort_authorization.fort_authorization_id = temp_auth.auth_id;
      
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1;  
      
      SET autocommit = 0;
     
      DROP TEMPORARY TABLE IF EXISTS temp_account_sso;  
      CREATE TEMPORARY TABLE temp_account_sso(
           auth_id  VARCHAR(32) 
          ,account_id VARCHAR(32) 
          ,resource_id VARCHAR(32)   
       )ENGINE=MEMORY;
      
      DROP TEMPORARY TABLE IF EXISTS temp_user_sso;  
      
      CREATE TEMPORARY TABLE temp_user_sso(
           auth_id  VARCHAR(32) 
          ,user_id VARCHAR(32) 
       )ENGINE=MEMORY;
       
       DROP TEMPORARY TABLE IF EXISTS temp_account_auth;  
       CREATE TEMPORARY TABLE temp_account_auth(
           auth_id  VARCHAR(32) 
          ,account_id VARCHAR(32) 
          ,resource_id VARCHAR(32)   
       )ENGINE=MEMORY;
      
      DROP TEMPORARY TABLE IF EXISTS temp_user_auth;  
      CREATE TEMPORARY TABLE temp_user_auth(  
         user_id VARCHAR(32) 
       )ENGINE=MEMORY;
      
      DROP TEMPORARY TABLE IF EXISTS temp_auth;  
      CREATE TEMPORARY TABLE temp_auth(
           auth_id  VARCHAR(32) 
       )ENGINE=MEMORY;
       
      DROP TEMPORARY TABLE IF EXISTS temp_approve;  
      CREATE TEMPORARY TABLE temp_approve(
            fort_user_id  VARCHAR(32)
           ,fort_user_name  VARCHAR(100) 
           ,fort_resource_name  VARCHAR(100)
           ,fort_authorization_name VARCHAR(100)
       )ENGINE=MEMORY;
      
      INSERT INTO temp_auth SELECT fort_authorization_target_proxy.fort_authorization_id FROM fort_authorization_target_proxy 
             WHERE  fort_authorization_target_proxy.fort_target_id = temp_user_group_id;
       
       
     SET @temp_authorization_user = CONCAT(CONCAT("insert into temp_user_auth values('",REPLACE(temp_user_ids,',',"'),('")),"')"); 
     PREPARE stmt FROM  @temp_authorization_user; 
     EXECUTE stmt;      
     DEALLOCATE PREPARE stmt;       
    
       
       
    OPEN select_auth_for_auth_id;
   
      
      tempApproveOneAuthLoop: LOOP  
        
        SET done = 0; 
        FETCH select_auth_for_auth_id INTO temp_auth_check_id,temp_auth_check_code;  
        IF done = 1 THEN   
        LEAVE tempApproveOneAuthLoop;  
        END IF;  
  
     IF (temp_auth_check_code&8 = 8 ) THEN
         
         INSERT INTO temp_account_auth(auth_id,account_id,resource_id) 
              SELECT DISTINCT fort_authorization_target_proxy.fort_authorization_id,fort_authorization_target_proxy.fort_target_id,fort_authorization_target_proxy.fort_parent_id
                    FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_check_id 
                    AND fort_authorization_target_proxy.fort_target_code = 8 ;
         END IF;  
       
    IF (temp_auth_check_code&16 = 16 ) THEN
             
              INSERT INTO temp_account_auth(auth_id,account_id,resource_id)    
                    SELECT DISTINCT fort_authorization_target_proxy.fort_authorization_id,fort_account.fort_account_id, fort_resource.fort_resource_id FROM fort_account,fort_resource,fort_authorization_target_proxy 
            WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_check_id 
                AND fort_authorization_target_proxy.fort_target_code = 16
            AND fort_authorization_target_proxy.fort_target_id = fort_resource.fort_resource_id 
                    AND fort_resource.fort_resource_id = fort_account.fort_resource_id 
                    AND fort_resource.fort_parent_id IS NULL AND fort_account.fort_is_allow_authorized = 1 ;
       
         INSERT INTO temp_account_auth(auth_id,account_id,resource_id) 
             SELECT DISTINCT fort_authorization_target_proxy.fort_authorization_id,fort_account.fort_account_id, fort_resource.fort_resource_id FROM fort_account,fort_resource,fort_authorization_target_proxy 
             WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_check_id  
             AND fort_authorization_target_proxy.fort_target_code = 16
             AND fort_authorization_target_proxy.fort_target_id = fort_resource.fort_resource_id 
                     AND fort_resource.fort_parent_id = fort_account.fort_resource_id 
                     AND fort_resource.fort_parent_id IS NOT NULL AND fort_account.fort_is_allow_authorized = 1 ;
                     
         END IF; 
         
     IF (temp_auth_check_code&32 = 32 ) THEN
         
         
       INSERT INTO temp_account_sso(auth_id,account_id,resource_id) 
                SELECT fort_authorization_target_proxy.fort_authorization_id,fort_account.fort_account_id, fort_resource.fort_resource_id 
                FROM fort_account,fort_resource,fort_resource_group_resource,fort_authorization_target_proxy
                    WHERE  fort_resource.fort_resource_id = fort_account.fort_resource_id
                    AND fort_resource_group_resource.fort_resource_id = fort_resource.fort_resource_id
                    AND fort_resource.fort_parent_id IS NULL AND fort_resource.fort_resource_state <> 2 
                    AND fort_account.fort_is_allow_authorized = 1
                    AND fort_authorization_target_proxy.fort_authorization_id = temp_auth_check_id 
                    AND fort_authorization_target_proxy.fort_target_code =  32 
                    AND fort_resource_group_resource.fort_resource_group_id = fort_authorization_target_proxy.fort_target_id;
                    
         INSERT INTO temp_account_sso(auth_id,account_id,resource_id) 
                SELECT fort_authorization_target_proxy.fort_authorization_id,fort_account.fort_account_id, fort_resource.fort_resource_id 
                FROM fort_account,fort_resource,fort_resource_group_resource,fort_authorization_target_proxy
                    WHERE  fort_resource.fort_parent_id = fort_account.fort_resource_id
                    AND fort_resource_group_resource.fort_resource_id = fort_resource.fort_resource_id
                    AND fort_resource.fort_parent_id IS NOT NULL AND fort_resource.fort_resource_state <> 2 
                    AND fort_account.fort_is_allow_authorized = 1
                    AND fort_authorization_target_proxy.fort_authorization_id = temp_auth_check_id 
                    AND fort_authorization_target_proxy.fort_target_code =  32
                    AND fort_resource_group_resource.fort_resource_group_id = fort_authorization_target_proxy.fort_target_id;
                    
         END IF;  
         
        END LOOP tempApproveOneAuthLoop;  
    
     CLOSE select_auth_for_auth_id;         
    
        
      
        
      OPEN select_auth_for_all;
   
      
      tempSuperoirApproveAllAuthLoop: LOOP  
     
        SET done = 0; 
        FETCH select_auth_for_all INTO temp_auth_id,temp_code;  
       
        IF done = 1 THEN    
           LEAVE tempSuperoirApproveAllAuthLoop;  
        END IF;  
    
      IF (temp_code&2 = 2 ) THEN
    
     INSERT INTO temp_user_sso(auth_id,user_id) 
               SELECT DISTINCT fort_authorization_target_proxy.fort_authorization_id  ,fort_authorization_target_proxy.fort_target_id
               FROM fort_authorization_target_proxy
               WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_id
               AND fort_authorization_target_proxy.fort_target_code = 2; 
     
       END IF;  
       
      IF (temp_code&4 = 4 ) THEN 
         INSERT INTO temp_user_sso(auth_id,user_id)    
                SELECT  DISTINCT t.fort_authorization_id,fort_user_group_user.fort_user_id FROM 
         fort_user_group_user,( SELECT fort_authorization_target_proxy.fort_target_id,fort_authorization_target_proxy.fort_authorization_id FROM fort_authorization_target_proxy  
         WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_id AND  fort_authorization_target_proxy.fort_target_code ='4') t
        WHERE fort_user_group_user.fort_user_group_id IN ( t.fort_target_id) ; 
      
        END IF;    
         IF (temp_code&8 = 8 ) THEN
         
         INSERT INTO temp_account_sso(auth_id,account_id,resource_id) 
              SELECT fort_authorization_target_proxy.fort_authorization_id,fort_authorization_target_proxy.fort_target_id,fort_authorization_target_proxy.fort_parent_id
                    FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_id 
                    AND fort_authorization_target_proxy.fort_target_code = 8 ;
         END IF;  
         
         IF (temp_code&16 = 16 ) THEN
              INSERT INTO temp_account_sso(auth_id,account_id,resource_id)    
                    SELECT  fort_authorization_target_proxy.fort_authorization_id,fort_account.fort_account_id, fort_resource.fort_resource_id FROM fort_account,fort_resource,fort_authorization_target_proxy 
            WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_id 
                AND fort_authorization_target_proxy.fort_target_code = 16
            AND fort_authorization_target_proxy.fort_target_id = fort_resource.fort_resource_id 
                    AND fort_resource.fort_resource_id = fort_account.fort_resource_id 
                    AND fort_resource.fort_parent_id IS NULL AND fort_account.fort_is_allow_authorized = 1 ;
       
         INSERT INTO temp_account_sso(auth_id,account_id,resource_id) 
             SELECT fort_authorization_target_proxy.fort_authorization_id,fort_account.fort_account_id, fort_resource.fort_resource_id FROM fort_account,fort_resource,fort_authorization_target_proxy 
             WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_id  
             AND fort_authorization_target_proxy.fort_target_code = 16
             AND fort_authorization_target_proxy.fort_target_id = fort_resource.fort_resource_id 
                     AND fort_resource.fort_parent_id = fort_account.fort_resource_id 
                     AND fort_resource.fort_parent_id IS NOT NULL AND fort_account.fort_is_allow_authorized = 1 ;
                     
         END IF; 
         
    
         
         IF (temp_code&32 = 32 ) THEN
          
         INSERT INTO temp_account_sso(auth_id,account_id,resource_id) 
                SELECT fort_authorization_target_proxy.fort_authorization_id,fort_account.fort_account_id, fort_resource.fort_resource_id 
                FROM fort_account,fort_resource,fort_resource_group_resource,fort_authorization_target_proxy
                    WHERE  fort_resource.fort_resource_id = fort_account.fort_resource_id
                    AND fort_resource_group_resource.fort_resource_id = fort_resource.fort_resource_id
                    AND fort_resource.fort_parent_id IS NULL AND fort_resource.fort_resource_state <> 2 
                    AND fort_account.fort_is_allow_authorized = 1
                    AND fort_authorization_target_proxy.fort_authorization_id = temp_auth_id 
                    AND fort_authorization_target_proxy.fort_target_code =  32 
                    AND fort_resource_group_resource.fort_resource_group_id = fort_authorization_target_proxy.fort_target_id;
                    
         INSERT INTO temp_account_sso(auth_id,account_id,resource_id) 
                SELECT fort_authorization_target_proxy.fort_authorization_id,fort_account.fort_account_id, fort_resource.fort_resource_id 
                FROM fort_account,fort_resource,fort_resource_group_resource,fort_authorization_target_proxy
                    WHERE  fort_resource.fort_parent_id = fort_account.fort_resource_id
                    AND fort_resource_group_resource.fort_resource_id = fort_resource.fort_resource_id
                    AND fort_resource.fort_parent_id IS NOT NULL AND fort_resource.fort_resource_state <> 2 
                    AND fort_account.fort_is_allow_authorized = 1
                    AND fort_authorization_target_proxy.fort_authorization_id = temp_auth_id 
                    AND fort_authorization_target_proxy.fort_target_code =  32
                    AND fort_resource_group_resource.fort_resource_group_id = fort_authorization_target_proxy.fort_target_id;
                    
         END IF;  
          
        END LOOP tempSuperoirApproveAllAuthLoop;  
    
     CLOSE select_auth_for_all;  
      
     INSERT INTO temp_approve(fort_user_id,fort_user_name,fort_resource_name,fort_authorization_name)   
         SELECT DISTINCT temp_user_auth.user_id ,fort_user.fort_user_name,
         fort_resource.fort_resource_name,fort_authorization.fort_authorization_name  
         FROM temp_account_auth,temp_user_auth,fort_user,fort_account,fort_resource,fort_authorization 
         WHERE 
             temp_user_auth.user_id = fort_user.fort_user_id
         AND temp_account_auth.account_id = fort_account.fort_account_id 
         AND fort_resource.fort_resource_id = fort_account.fort_resource_id
         AND fort_authorization.fort_authorization_id = temp_account_auth.auth_id
     GROUP BY temp_user_auth.user_id,temp_account_auth.account_id 
     HAVING COUNT(DISTINCT temp_account_auth.auth_id )>1;   
     
  
         
     SELECT COUNT(*) INTO temp_user_group_vali_auth_num  FROM temp_approve;
 
    
   IF (temp_user_group_vali_auth_num = 0) THEN
  
     INSERT INTO temp_approve(fort_user_id,fort_user_name,fort_resource_name,fort_authorization_name)
        SELECT DISTINCT temp_user_sso.user_id ,fort_user.fort_user_name,
         fort_resource.fort_resource_name ,fort_authorization.fort_authorization_name   
         FROM temp_account_sso,temp_user_sso ,temp_account_auth,temp_user_auth,fort_user,fort_account,fort_resource,fort_authorization
       WHERE  temp_user_sso.auth_id  = temp_account_sso.auth_id 
         AND temp_account_sso.account_id = temp_account_auth.account_id
         AND temp_account_sso.resource_id = temp_account_auth.resource_id 
         AND temp_user_sso.user_id = temp_user_auth.user_id
         AND temp_user_sso.user_id = fort_user.fort_user_id
         AND temp_account_sso.account_id = fort_account.fort_account_id 
         AND fort_resource.fort_resource_id = fort_account.fort_resource_id 
         AND fort_authorization.fort_authorization_id = temp_user_sso.auth_id;
         
   END IF; 
   
    SELECT * FROM temp_approve;
  
    DROP TABLE temp_account_sso; 
    
    DROP TABLE temp_user_sso;
    
    DROP TABLE temp_account_auth; 
     
    DROP TABLE temp_user_auth;
    
    DROP TABLE temp_auth;
    
    DROP TABLE temp_approve;
    
    SET autocommit = 1;
    
    END$$

DELIMITER ;


DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `getDoubleApprover`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `getDoubleApprover`(IN userId VARCHAR(32),IN accountId VARCHAR(32))
BEGIN   
      DECLARE temp_auth_id VARCHAR(100);
      DECLARE approver_auth_id VARCHAR(50);
      DECLARE temp_user_id VARCHAR(100);
      DECLARE temp_is_candidate VARCHAR(50);     
      DECLARE temp_user_sum INT;
      DECLARE temp_second_user_id VARCHAR(100);
      DECLARE temp_approver_name VARCHAR(50);
      DECLARE temp_approver_password VARCHAR(50);      
      DECLARE done INT DEFAULT 0; 
     
      
 
      DECLARE cur1 CURSOR FOR SELECT a.fort_authorization_id FROM
(
SELECT fort_authorization_target_proxy.fort_authorization_id FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_target_code='8' AND fort_authorization_target_proxy.fort_target_id = accountId
UNION 
SELECT fort_authorization_target_proxy.fort_authorization_id FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_target_code='16' AND fort_authorization_target_proxy.fort_target_id
IN(SELECT fort_account.fort_resource_id FROM fort_account WHERE fort_account.fort_account_id = accountId)
UNION
SELECT DISTINCT
     fort_authorization_target_proxy.fort_authorization_id FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_target_code='32' AND fort_authorization_target_proxy.fort_target_id
     IN(SELECT fort_resource_group_resource.fort_resource_group_id FROM fort_resource_group_resource WHERE fort_resource_group_resource.fort_resource_id IN(
       SELECT fort_account.fort_resource_id FROM fort_account WHERE fort_account.fort_account_id = accountId )  )     
     ) a,
    
     (
    
     SELECT fort_authorization_target_proxy.fort_authorization_id 
     FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_target_code='2' AND fort_authorization_target_proxy.fort_target_id = userId       
      UNION
         SELECT fort_authorization_target_proxy.fort_authorization_id  FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_target_code='4'
          AND fort_authorization_target_proxy.fort_target_id
         IN(SELECT fort_user_group_user.fort_user_group_id FROM fort_user_group_user WHERE fort_user_group_user.fort_user_id = userId)
    
    ) b
    
    WHERE a.fort_authorization_id = b.fort_authorization_id;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1;      
   
    DROP TEMPORARY TABLE IF EXISTS temp_approve;    
    CREATE TEMPORARY TABLE temp_approve(
            approve_id VARCHAR(600),
            approve_name VARCHAR(300),
            authorization_id VARCHAR(32)
       );  
      
      OPEN cur1;
      
    approveLoop: LOOP  
             
        SET  done = 0; 
        FETCH cur1 INTO temp_auth_id;
        
      IF done = 1 THEN  
            LEAVE approveLoop;  
        END IF;
        
         SELECT fort_double_approval.fort_authorization_id INTO approver_auth_id FROM fort_double_approval , fort_authorization  WHERE  
        fort_authorization.fort_authorization_id   = fort_double_approval.fort_authorization_id 
        AND fort_double_approval.fort_authorization_id = temp_auth_id AND fort_user_id = userId AND fort_is_candidate = '1' 
        AND fort_authorization.fort_double_is_open = '1';
            

                   INSERT INTO temp_approve(approve_id,approve_name,authorization_id) 
                   SELECT fort_user.fort_user_id,fort_user.fort_user_name,approver_auth_id FROM fort_user WHERE fort_user.fort_user_id IN
                   
                   (SELECT fort_double_approval.fort_user_id FROM fort_double_approval WHERE fort_authorization_id = approver_auth_id 
                        AND fort_double_approval.fort_user_id != userId AND fort_double_approval.fort_is_approver = 1);  
       
        
        
  
    END LOOP approveLoop;
    
        
    
      
    CLOSE cur1;    
      SELECT DISTINCT * FROM temp_approve;
      DROP TABLE temp_approve;
    END$$

DELIMITER ;


DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `checkDoubleApproveAuthUpdate`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `checkDoubleApproveAuthUpdate`(IN temp_user_ids TEXT,IN temp_user_group_ids TEXT,IN temp_account_ids TEXT,
IN temp_resource_ids TEXT,IN temp_resource_group_ids TEXT,IN temp_authorization_id VARCHAR(200))
BEGIN   
      DECLARE done INT DEFAULT -1;  
      DECLARE temp_auth_id VARCHAR(32); 
      DECLARE temp_code INT;   
      DECLARE temp_double_state VARCHAR(5); 
 
      DECLARE temp_sql_string TEXT; 
  
      DECLARE temp_sql_target_ids TEXT; 
      
      DECLARE select_auth_for_all CURSOR FOR SELECT fort_authorization.fort_authorization_id,
              fort_authorization.fort_authorization_code  FROM fort_authorization 
               WHERE  fort_authorization.fort_authorization_id <> temp_authorization_id 
               AND fort_authorization.fort_double_is_open = '1' ;
      
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1;  
     
     
      DROP TEMPORARY TABLE IF EXISTS temp_account_sso;  
      CREATE TEMPORARY TABLE temp_account_sso(
           auth_id  VARCHAR(32) 
          ,account_id VARCHAR(32) 
          ,resource_id VARCHAR(32)   
       )ENGINE=MEMORY;
       
       DROP TEMPORARY TABLE IF EXISTS temp_account_auth;  
       CREATE TEMPORARY TABLE temp_account_auth(
           auth_id  VARCHAR(32) 
          ,account_id VARCHAR(32) 
          ,resource_id VARCHAR(32)   
       )ENGINE=MEMORY;
       
      
      DROP TEMPORARY TABLE IF EXISTS temp_targets;  
       CREATE TEMPORARY TABLE temp_targets(
         target_id VARCHAR(32)   
       )ENGINE=MEMORY;      
       
      SET autocommit = 0;
         
    
     IF (temp_account_ids != '' && temp_account_ids IS NOT NULL ) THEN    
         SET @temp_sql_target_ids = CONCAT(CONCAT("insert into temp_targets values('",REPLACE(temp_account_ids,',',"'),('")),"')"); 
         PREPARE stmt FROM  @temp_sql_target_ids; 
         EXECUTE stmt;      
        
         INSERT INTO temp_account_auth(auth_id,account_id,resource_id) 
           SELECT temp_authorization_id,fort_account.fort_account_id, fort_resource.fort_resource_id FROM fort_account,fort_resource,temp_targets 
           WHERE temp_targets.target_id = fort_account.fort_account_id 
           AND fort_resource.fort_resource_id = fort_account.fort_resource_id ;
        
        TRUNCATE TABLE temp_targets;
      END IF; 
    
     
    
     IF (temp_resource_ids != '' && temp_resource_ids IS NOT NULL ) THEN   
         SET @temp_sql_target_ids = CONCAT(CONCAT("insert into temp_targets values('",REPLACE(temp_resource_ids,',',"'),('")),"')"); 
         PREPARE stmt FROM  @temp_sql_target_ids; 
         EXECUTE stmt;      
        
         INSERT INTO temp_account_auth(auth_id,account_id,resource_id)    
                SELECT  temp_authorization_id,fort_account.fort_account_id, fort_resource.fort_resource_id 
                FROM fort_account,fort_resource,temp_targets 
             WHERE 
                   temp_targets.target_id = fort_resource.fort_resource_id 
                AND fort_resource.fort_resource_id = fort_account.fort_resource_id 
                AND fort_resource.fort_parent_id IS NULL AND fort_account.fort_is_allow_authorized = 1 ;
           
         INSERT INTO temp_account_auth(auth_id,account_id,resource_id) 
             SELECT temp_authorization_id,fort_account.fort_account_id, fort_resource.fort_resource_id FROM fort_account,fort_resource,temp_targets 
             WHERE
                   temp_targets.target_id = fort_resource.fort_resource_id 
                 AND fort_resource.fort_parent_id = fort_account.fort_resource_id 
                 AND fort_resource.fort_parent_id IS NOT NULL AND fort_account.fort_is_allow_authorized = 1 ;
        
        TRUNCATE TABLE temp_targets;
     END IF; 
    
    
    IF (temp_resource_group_ids != '' && temp_resource_group_ids IS NOT NULL ) THEN  
         SET @temp_sql_target_ids = CONCAT(CONCAT("insert into temp_targets values('",REPLACE(temp_resource_group_ids,',',"'),('")),"')"); 
         PREPARE stmt FROM  @temp_sql_target_ids; 
         EXECUTE stmt;      
        
         INSERT INTO temp_account_auth(auth_id,account_id,resource_id) 
            SELECT temp_authorization_id,fort_account.fort_account_id, fort_resource.fort_resource_id 
            FROM fort_account,fort_resource,fort_resource_group_resource,temp_targets
                WHERE  fort_resource.fort_resource_id = fort_account.fort_resource_id
                AND fort_resource_group_resource.fort_resource_id = fort_resource.fort_resource_id
                AND fort_resource.fort_parent_id IS NULL AND fort_resource.fort_resource_state <> 2 
                AND fort_account.fort_is_allow_authorized = 1
                AND fort_resource_group_resource.fort_resource_group_id = temp_targets.target_id ;
                
         INSERT INTO temp_account_auth(auth_id,account_id,resource_id) 
            SELECT temp_authorization_id,fort_account.fort_account_id, fort_resource.fort_resource_id 
            FROM fort_account,fort_resource,fort_resource_group_resource,temp_targets
                WHERE  fort_resource.fort_parent_id = fort_account.fort_resource_id
                AND fort_resource_group_resource.fort_resource_id = fort_resource.fort_resource_id
                AND fort_resource.fort_parent_id IS NOT NULL AND fort_resource.fort_resource_state <> 2 
                AND fort_account.fort_is_allow_authorized = 1
                AND fort_resource_group_resource.fort_resource_group_id = temp_targets.target_id;
        TRUNCATE TABLE temp_targets;
     
       END IF; 
       
     
     DEALLOCATE PREPARE stmt;   
       
     OPEN select_auth_for_all;
      tempDoubleApproveAllAuthLoop: LOOP  
     
          SET done = 0;
        FETCH select_auth_for_all INTO temp_auth_id,temp_code;  
        
        IF done = 1 THEN   
           LEAVE tempDoubleApproveAllAuthLoop;  
        END IF;  
         IF (temp_code&8 = 8 ) THEN
         
         INSERT INTO temp_account_sso(auth_id,account_id,resource_id) 
              SELECT fort_authorization_target_proxy.fort_authorization_id,fort_authorization_target_proxy.fort_target_id,fort_authorization_target_proxy.fort_parent_id
                    FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_id 
                    AND fort_authorization_target_proxy.fort_target_code = 8 ;
         END IF;  
         
         IF (temp_code&16 = 16 ) THEN
              INSERT INTO temp_account_sso(auth_id,account_id,resource_id)    
                    SELECT  fort_authorization_target_proxy.fort_authorization_id,fort_account.fort_account_id, fort_resource.fort_resource_id FROM fort_account,fort_resource,fort_authorization_target_proxy 
            WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_id 
                AND fort_authorization_target_proxy.fort_target_code = 16
            AND fort_authorization_target_proxy.fort_target_id = fort_resource.fort_resource_id 
                    AND fort_resource.fort_resource_id = fort_account.fort_resource_id 
                    AND fort_resource.fort_parent_id IS NULL AND fort_account.fort_is_allow_authorized = 1 ;
       
         INSERT INTO temp_account_sso(auth_id,account_id,resource_id) 
             SELECT fort_authorization_target_proxy.fort_authorization_id,fort_account.fort_account_id, fort_resource.fort_resource_id FROM fort_account,fort_resource,fort_authorization_target_proxy 
             WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_id  
             AND fort_authorization_target_proxy.fort_target_code = 16
             AND fort_authorization_target_proxy.fort_target_id = fort_resource.fort_resource_id 
                     AND fort_resource.fort_parent_id = fort_account.fort_resource_id 
                     AND fort_resource.fort_parent_id IS NOT NULL AND fort_account.fort_is_allow_authorized = 1 ;
                     
         END IF; 
         
    
         
         IF (temp_code&32 = 32 ) THEN
          
         INSERT INTO temp_account_sso(auth_id,account_id,resource_id) 
                SELECT fort_authorization_target_proxy.fort_authorization_id,fort_account.fort_account_id, fort_resource.fort_resource_id 
                FROM fort_account,fort_resource,fort_resource_group_resource,fort_authorization_target_proxy
                    WHERE  fort_resource.fort_resource_id = fort_account.fort_resource_id
                    AND fort_resource_group_resource.fort_resource_id = fort_resource.fort_resource_id
                    AND fort_resource.fort_parent_id IS NULL AND fort_resource.fort_resource_state <> 2 
                    AND fort_account.fort_is_allow_authorized = 1
                    AND fort_authorization_target_proxy.fort_authorization_id = temp_auth_id 
                    AND fort_authorization_target_proxy.fort_target_code =  32 
                    AND fort_resource_group_resource.fort_resource_group_id = fort_authorization_target_proxy.fort_target_id;
                    
         INSERT INTO temp_account_sso(auth_id,account_id,resource_id) 
                SELECT fort_authorization_target_proxy.fort_authorization_id,fort_account.fort_account_id, fort_resource.fort_resource_id 
                FROM fort_account,fort_resource,fort_resource_group_resource,fort_authorization_target_proxy
                    WHERE  fort_resource.fort_parent_id = fort_account.fort_resource_id
                    AND fort_resource_group_resource.fort_resource_id = fort_resource.fort_resource_id
                    AND fort_resource.fort_parent_id IS NOT NULL AND fort_resource.fort_resource_state <> 2 
                    AND fort_account.fort_is_allow_authorized = 1
                    AND fort_authorization_target_proxy.fort_authorization_id = temp_auth_id 
                    AND fort_authorization_target_proxy.fort_target_code =  32
                    AND fort_resource_group_resource.fort_resource_group_id = fort_authorization_target_proxy.fort_target_id;
                    
         END IF;  
          
        END LOOP tempDoubleApproveAllAuthLoop;  
    
     CLOSE select_auth_for_all;  
     
   SELECT fort_authorization.fort_double_is_open INTO temp_double_state FROM fort_authorization WHERE  fort_authorization.fort_authorization_id = temp_authorization_id;
    
    IF (temp_double_state = '1') THEN
         SELECT DISTINCT fort_double_approval.fort_user_id ,fort_user.fort_user_name,
         fort_resource.fort_resource_name,fort_authorization.fort_authorization_name 
         FROM temp_account_sso,fort_user,fort_account,fort_resource,fort_double_approval,fort_authorization,( 
         SELECT DISTINCT temp_account_auth.account_id,temp_account_auth.resource_id,fort_double_approval.fort_authorization_id,fort_double_approval.fort_user_id
         FROM temp_account_auth,fort_double_approval WHERE 
         fort_double_approval.fort_authorization_id = temp_account_auth.auth_id 
         AND fort_double_approval.fort_is_candidate = '1' 
         )t
           WHERE  fort_double_approval.fort_authorization_id  = temp_account_sso.auth_id 
         AND fort_double_approval.fort_authorization_id <> t.fort_authorization_id
         AND temp_account_sso.account_id = t.account_id
         AND temp_account_sso.resource_id = t.resource_id 
         AND fort_double_approval.fort_user_id = t.fort_user_id
         AND fort_double_approval.fort_user_id = fort_user.fort_user_id
         AND temp_account_sso.account_id = fort_account.fort_account_id 
         AND fort_resource.fort_resource_id = fort_account.fort_resource_id
         AND fort_double_approval.fort_is_candidate = '1'
         AND fort_authorization.fort_authorization_id = fort_double_approval.fort_authorization_id;  
    END IF;  
  
     
    DROP TABLE temp_account_sso; 
    
    
    DROP TABLE temp_account_auth; 
    DROP TABLE temp_targets; 
     
 
    SET autocommit = 1;
    
    END$$

DELIMITER ;



DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `checkSuperiorProcessAuthUpdate`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `checkSuperiorProcessAuthUpdate`(IN temp_user_ids TEXT,IN temp_user_group_ids TEXT,IN temp_account_ids TEXT,
IN temp_resource_ids TEXT,IN temp_resource_group_ids TEXT,IN temp_authorization_id VARCHAR(100))
BEGIN   
      DECLARE done INT DEFAULT -1;  
      DECLARE temp_auth_id VARCHAR(32); 
      DECLARE temp_code INT;   
      DECLARE temp_process_state VARCHAR(5); 
      DECLARE temp_sql_string TEXT; 
  
      DECLARE temp_sql_target_ids TEXT; 
      DECLARE select_auth_for_all CURSOR FOR SELECT fort_authorization.fort_authorization_id,
              fort_authorization.fort_authorization_code  FROM fort_authorization,fort_process
               WHERE   fort_authorization.fort_superior_process_id = fort_process.fort_process_id 
               AND fort_process.fort_state = '1'  
               AND fort_authorization.fort_authorization_id <> temp_authorization_id ;
               
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1;  
     
     
      DROP TEMPORARY TABLE IF EXISTS temp_account_sso;  
      CREATE TEMPORARY TABLE temp_account_sso(
           auth_id  VARCHAR(32) 
          ,account_id VARCHAR(32) 
          ,resource_id VARCHAR(32)   
       )ENGINE=MEMORY;
       
       DROP TEMPORARY TABLE IF EXISTS temp_user_sso;  
      CREATE TEMPORARY TABLE temp_user_sso(
           auth_id  VARCHAR(32) 
          ,user_id VARCHAR(32) 
       )ENGINE=MEMORY; 
       
       DROP TEMPORARY TABLE IF EXISTS temp_account_auth;  
       CREATE TEMPORARY TABLE temp_account_auth(
          account_id VARCHAR(32) 
          ,resource_id VARCHAR(32)   
       )ENGINE=MEMORY;
       
      DROP TEMPORARY TABLE IF EXISTS temp_user_auth;  
      CREATE TEMPORARY TABLE temp_user_auth(  
        user_id VARCHAR(32) 
       )ENGINE=MEMORY;
      
      
      DROP TEMPORARY TABLE IF EXISTS temp_targets;  
       CREATE TEMPORARY TABLE temp_targets(
         target_id VARCHAR(32)   
       )ENGINE=MEMORY;      
      SET autocommit = 0;
         
    
     
     
      IF (temp_user_ids != '' && temp_user_ids IS NOT NULL ) THEN
         SET @temp_sql_target_ids = CONCAT(CONCAT("insert into temp_user_auth values('",REPLACE(temp_user_ids,',',"'),('")),"')"); 
         PREPARE stmt FROM  @temp_sql_target_ids; 
         EXECUTE stmt;      
        
      END IF;       
        
        
           
     IF (temp_user_group_ids != '' && temp_user_group_ids IS NOT NULL ) THEN        
         SET @temp_sql_target_ids = CONCAT(CONCAT("insert into temp_targets values('",REPLACE(temp_user_group_ids,',',"'),('")),"')"); 
         PREPARE stmt FROM  @temp_sql_target_ids; 
         EXECUTE stmt;      
        
         INSERT INTO temp_user_auth(user_id)    
            SELECT  DISTINCT fort_user_group_user.fort_user_id FROM 
         fort_user_group_user,temp_targets
        WHERE fort_user_group_user.fort_user_group_id = temp_targets.target_id ; 
        
        TRUNCATE TABLE temp_targets;
     END IF; 
    
    
    
    IF (temp_account_ids != '' && temp_account_ids IS NOT NULL ) THEN
         SET @temp_sql_target_ids = CONCAT(CONCAT("insert into temp_targets values('",REPLACE(temp_account_ids,',',"'),('")),"')"); 
         PREPARE stmt FROM  @temp_sql_target_ids; 
         EXECUTE stmt;      
        
         INSERT INTO temp_account_auth(account_id,resource_id) 
           SELECT fort_account.fort_account_id, fort_resource.fort_resource_id FROM fort_account,fort_resource,temp_targets 
           WHERE temp_targets.target_id = fort_account.fort_account_id 
           AND fort_resource.fort_resource_id = fort_account.fort_resource_id ;
        
        TRUNCATE TABLE temp_targets;
    END IF; 
    
     
    
     IF (temp_resource_ids != '' && temp_resource_ids IS NOT NULL ) THEN
         SET @temp_sql_target_ids = CONCAT(CONCAT("insert into temp_targets values('",REPLACE(temp_resource_ids,',',"'),('")),"')"); 
         PREPARE stmt FROM  @temp_sql_target_ids; 
         EXECUTE stmt;      
        
         INSERT INTO temp_account_auth(account_id,resource_id)    
                SELECT  fort_account.fort_account_id, fort_resource.fort_resource_id 
                FROM fort_account,fort_resource,temp_targets 
             WHERE 
                   temp_targets.target_id = fort_resource.fort_resource_id 
                AND fort_resource.fort_resource_id = fort_account.fort_resource_id 
                AND fort_resource.fort_parent_id IS NULL AND fort_account.fort_is_allow_authorized = 1 ;
           
         INSERT INTO temp_account_auth(account_id,resource_id) 
             SELECT fort_account.fort_account_id, fort_resource.fort_resource_id FROM fort_account,fort_resource,temp_targets 
             WHERE
                   temp_targets.target_id = fort_resource.fort_resource_id 
                 AND fort_resource.fort_parent_id = fort_account.fort_resource_id 
                 AND fort_resource.fort_parent_id IS NOT NULL AND fort_account.fort_is_allow_authorized = 1 ;
        
        TRUNCATE TABLE temp_targets;
      END IF; 
    
      
     
    
     IF (temp_resource_group_ids != '' && temp_resource_group_ids IS NOT NULL ) THEN 
         SET @temp_sql_target_ids = CONCAT(CONCAT("insert into temp_targets values('",REPLACE(temp_resource_group_ids,',',"'),('")),"')"); 
         PREPARE stmt FROM  @temp_sql_target_ids; 
         EXECUTE stmt;      
        
         INSERT INTO temp_account_auth(account_id,resource_id) 
            SELECT fort_account.fort_account_id, fort_resource.fort_resource_id 
            FROM fort_account,fort_resource,fort_resource_group_resource,temp_targets
                WHERE  fort_resource.fort_resource_id = fort_account.fort_resource_id
                AND fort_resource_group_resource.fort_resource_id = fort_resource.fort_resource_id
                AND fort_resource.fort_parent_id IS NULL AND fort_resource.fort_resource_state <> 2 
                AND fort_account.fort_is_allow_authorized = 1
                AND fort_resource_group_resource.fort_resource_group_id = temp_targets.target_id ;
                
         INSERT INTO temp_account_auth(account_id,resource_id) 
            SELECT fort_account.fort_account_id, fort_resource.fort_resource_id 
            FROM fort_account,fort_resource,fort_resource_group_resource,temp_targets
                WHERE  fort_resource.fort_parent_id = fort_account.fort_resource_id
                AND fort_resource_group_resource.fort_resource_id = fort_resource.fort_resource_id
                AND fort_resource.fort_parent_id IS NOT NULL AND fort_resource.fort_resource_state <> 2 
                AND fort_account.fort_is_allow_authorized = 1
                AND fort_resource_group_resource.fort_resource_group_id = temp_targets.target_id;
        TRUNCATE TABLE temp_targets;
      END IF; 
      
     
     DEALLOCATE PREPARE stmt;    
      
     OPEN select_auth_for_all;
   
      
      tempDoubleApproveAllAuthLoop: LOOP  
     
          SET done = 0;
        FETCH select_auth_for_all INTO temp_auth_id,temp_code;  
        
        
        IF done = 1 THEN   
           LEAVE tempDoubleApproveAllAuthLoop;  
        END IF;  
     IF (temp_code&2 = 2 ) THEN
    
        INSERT INTO temp_user_sso(auth_id,user_id) 
               SELECT DISTINCT fort_authorization_target_proxy.fort_authorization_id ,fort_authorization_target_proxy.fort_target_id
               FROM fort_authorization_target_proxy
               WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_id
               AND fort_authorization_target_proxy.fort_target_code = 2; 
     
       END IF;  
       
      IF (temp_code&4 = 4 ) THEN 
         INSERT INTO temp_user_sso(auth_id,user_id)    
                SELECT  DISTINCT t.fort_authorization_id,fort_user_group_user.fort_user_id FROM 
                 fort_user_group_user,
                 ( SELECT fort_authorization_target_proxy.fort_target_id,fort_authorization_target_proxy.fort_authorization_id FROM fort_authorization_target_proxy  
                    WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_id AND  fort_authorization_target_proxy.fort_target_code ='4') t
                  
                  WHERE fort_user_group_user.fort_user_group_id IN ( t.fort_target_id) ; 
      
        END IF;    
    
        
         IF (temp_code&8 = 8 ) THEN
         
         INSERT INTO temp_account_sso(auth_id,account_id,resource_id) 
              SELECT fort_authorization_target_proxy.fort_authorization_id,fort_authorization_target_proxy.fort_target_id,fort_authorization_target_proxy.fort_parent_id
                    FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_id 
                    AND fort_authorization_target_proxy.fort_target_code = 8 ;
         END IF;  
         
         IF (temp_code&16 = 16 ) THEN
              INSERT INTO temp_account_sso(auth_id,account_id,resource_id)    
                    SELECT  fort_authorization_target_proxy.fort_authorization_id,fort_account.fort_account_id, fort_resource.fort_resource_id FROM fort_account,fort_resource,fort_authorization_target_proxy 
            WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_id 
                AND fort_authorization_target_proxy.fort_target_code = 16
            AND fort_authorization_target_proxy.fort_target_id = fort_resource.fort_resource_id 
                    AND fort_resource.fort_resource_id = fort_account.fort_resource_id 
                    AND fort_resource.fort_parent_id IS NULL AND fort_account.fort_is_allow_authorized = 1 ;
       
         INSERT INTO temp_account_sso(auth_id,account_id,resource_id) 
             SELECT fort_authorization_target_proxy.fort_authorization_id,fort_account.fort_account_id, fort_resource.fort_resource_id FROM fort_account,fort_resource,fort_authorization_target_proxy 
             WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_id  
             AND fort_authorization_target_proxy.fort_target_code = 16
             AND fort_authorization_target_proxy.fort_target_id = fort_resource.fort_resource_id 
                     AND fort_resource.fort_parent_id = fort_account.fort_resource_id 
                     AND fort_resource.fort_parent_id IS NOT NULL AND fort_account.fort_is_allow_authorized = 1 ;
                     
         END IF; 
         
    
         
         IF (temp_code&32 = 32 ) THEN
          
         INSERT INTO temp_account_sso(auth_id,account_id,resource_id) 
                SELECT fort_authorization_target_proxy.fort_authorization_id,fort_account.fort_account_id, fort_resource.fort_resource_id 
                FROM fort_account,fort_resource,fort_resource_group_resource,fort_authorization_target_proxy
                    WHERE  fort_resource.fort_resource_id = fort_account.fort_resource_id
                    AND fort_resource_group_resource.fort_resource_id = fort_resource.fort_resource_id
                    AND fort_resource.fort_parent_id IS NULL AND fort_resource.fort_resource_state <> 2 
                    AND fort_account.fort_is_allow_authorized = 1
                    AND fort_authorization_target_proxy.fort_authorization_id = temp_auth_id 
                    AND fort_authorization_target_proxy.fort_target_code =  32 
                    AND fort_resource_group_resource.fort_resource_group_id = fort_authorization_target_proxy.fort_target_id;
                    
         INSERT INTO temp_account_sso(auth_id,account_id,resource_id) 
                SELECT fort_authorization_target_proxy.fort_authorization_id,fort_account.fort_account_id, fort_resource.fort_resource_id 
                FROM fort_account,fort_resource,fort_resource_group_resource,fort_authorization_target_proxy
                    WHERE  fort_resource.fort_parent_id = fort_account.fort_resource_id
                    AND fort_resource_group_resource.fort_resource_id = fort_resource.fort_resource_id
                    AND fort_resource.fort_parent_id IS NOT NULL AND fort_resource.fort_resource_state <> 2 
                    AND fort_account.fort_is_allow_authorized = 1
                    AND fort_authorization_target_proxy.fort_authorization_id = temp_auth_id 
                    AND fort_authorization_target_proxy.fort_target_code =  32
                    AND fort_resource_group_resource.fort_resource_group_id = fort_authorization_target_proxy.fort_target_id;
                    
         END IF;  
          
        END LOOP tempDoubleApproveAllAuthLoop;  
    
     CLOSE select_auth_for_all;  
    
    SELECT fort_process.fort_state INTO temp_process_state FROM fort_authorization,fort_process WHERE fort_authorization.fort_superior_process_id = fort_process.fort_process_id 
    AND fort_authorization.fort_authorization_id = temp_authorization_id;
     
    IF (temp_process_state = '1') THEN 
        SELECT DISTINCT fort_user.fort_user_id AS fort_user_id,fort_user.fort_user_name,fort_resource.fort_resource_name,
        fort_authorization.fort_authorization_name
        FROM temp_account_sso,temp_user_sso,temp_user_auth,temp_account_auth,fort_user,fort_authorization,fort_resource
       WHERE  
         temp_user_auth.user_id = temp_user_sso.user_id 
        AND temp_account_sso.account_id = temp_account_auth.account_id
        AND temp_account_sso.resource_id = temp_account_auth.resource_id 
        AND temp_user_sso.user_id  = fort_user.fort_user_id 
        AND fort_resource.fort_resource_id = temp_account_sso.resource_id
        AND fort_authorization.fort_authorization_id = temp_account_sso.auth_id ;
     END IF;  
   
   
   DROP TABLE temp_account_sso; 
    
   DROP TABLE temp_user_sso; 
     
   DROP TABLE temp_account_auth;
  
   DROP TABLE temp_user_auth;
  
   DROP TABLE temp_targets;
    
    SET autocommit = 1;
    
    END$$

DELIMITER ;



DELIMITER $$

USE `fort`$$

DROP TRIGGER /*!50032 IF EXISTS */ `before_user_delete`$$

CREATE
    /*!50017 DEFINER = 'mysql'@'127.0.0.1' */
    TRIGGER `before_user_delete` BEFORE UPDATE ON `fort_user` 
    FOR EACH ROW BEGIN 
    DECLARE done INT DEFAULT 0;
    DECLARE tmpId1 VARCHAR(24) DEFAULT '';
    DECLARE tmpId2 VARCHAR(24) DEFAULT '';
    DECLARE tmpId3 VARCHAR(24) DEFAULT '';
    DECLARE tmpId4 VARCHAR(24) DEFAULT '';
    DECLARE cur1 CURSOR FOR (SELECT DISTINCT fort_task_participant.fort_process_task_id FROM fort_task_participant WHERE fort_task_participant.fort_user_id = OLD.fort_user_id); 
    DECLARE cur2 CURSOR FOR (SELECT DISTINCT fort_double_approval_application.fort_process_instance_id FROM fort_double_approval_application WHERE fort_double_approval_application.fort_applicant_id = OLD.fort_user_id);
    DECLARE cur3 CURSOR FOR (SELECT DISTINCT fort_superior_approval_application.fort_process_instance_id FROM fort_superior_approval_application WHERE fort_superior_approval_application.fort_applicant_id = OLD.fort_user_id);
    DECLARE cur4 CURSOR FOR (SELECT DISTINCT fort_plan_password_target_proxy.fort_plan_id FROM fort_plan_password_target_proxy WHERE fort_plan_password_target_proxy.fort_target_id = OLD.fort_user_id);
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1; 
    IF NEW.fort_user_state = '2' THEN
        DELETE FROM fort_user_group_user WHERE fort_user_group_user.fort_user_id = OLD.fort_user_id;
        DELETE FROM fort_user_role WHERE fort_user_role.fort_user_id = OLD.fort_user_id;
        DELETE FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_target_id = OLD.fort_user_id;
        DELETE FROM fort_double_approval WHERE fort_double_approval.fort_user_id = OLD.fort_user_id;
        DELETE FROM fort_rule_command_target_proxy WHERE fort_rule_command_target_proxy.fort_target_id = OLD.fort_user_id;
    DELETE FROM fort_rule_time_resource_target_proxy WHERE fort_rule_time_resource_target_proxy.fort_target_id = OLD.fort_user_id;  
        DELETE FROM fort_user_protocol_client WHERE fort_user_protocol_client.fort_user_id = OLD.fort_user_id;
        
        DELETE FROM fort_plan_password_target_proxy WHERE fort_plan_password_target_proxy.fort_target_id = OLD.fort_user_id;
        DELETE FROM fort_system_alarm WHERE fort_system_alarm.fort_user_id = OLD.fort_user_id;
        UPDATE fort_ldap_user SET fort_ldap_user.fort_user_type = '0' WHERE fort_ldap_user.fort_user_id = OLD.fort_user_id;
        UPDATE fort_behavior_guideline SET fort_behavior_guideline.fort_is_locked = '1' WHERE fort_behavior_guideline.fort_create_by = OLD.fort_user_id;
        
        OPEN cur1;
            FETCH cur1 INTO tmpId1;
            WHILE(done != 1) DO 
                SET @fort_state1 = (SELECT DISTINCT fort_process_task_instance.fort_state FROM fort_process_task_instance,fort_task_participant WHERE fort_process_task_instance.fort_process_task_id = tmpId1
                                                                                                                                                 AND fort_task_participant.fort_task_participant_id = fort_process_task_instance.fort_task_participant_id
                                                                                                                                                 AND fort_task_participant.fort_user_id = OLD.fort_user_id);
                IF @fort_state1 = '1' THEN
                    UPDATE fort_process_task_instance SET fort_process_task_instance.fort_state = '4' WHERE fort_process_task_instance.fort_process_task_id = tmpId1;
                END IF;
                FETCH cur1 INTO tmpId1;
            END WHILE;
        CLOSE cur1;
        SET done = 0;
        
        OPEN cur2;
            FETCH cur2 INTO tmpId2;
            WHILE(done != 1) DO
                SET @fort_state2 = (SELECT DISTINCT fort_process_instance.fort_state FROM fort_process_instance WHERE fort_process_instance.fort_process_instance_id = tmpId2);
                IF @fort_state2 = '1' THEN
                    UPDATE fort_process_instance SET fort_process_instance.fort_state = '4' WHERE fort_process_instance.fort_process_instance_id = tmpId2;
                    UPDATE fort_process_task_instance SET fort_process_task_instance.fort_state = '4' WHERE fort_process_task_instance.fort_process_instance_id = tmpId2;
                END IF;
                FETCH cur2 INTO tmpId2;
            END WHILE;
        CLOSE cur2;
        
        SET done = 0;
        OPEN cur3;
            FETCH cur3 INTO tmpId3;
            WHILE(done != 1) DO
                SET @fort_state3 = (SELECT DISTINCT fort_process_instance.fort_state FROM fort_process_instance WHERE fort_process_instance.fort_process_instance_id = tmpId3);
                IF @fort_state3 = '1' THEN
                    UPDATE fort_process_instance SET fort_process_instance.fort_state = '4' WHERE fort_process_instance.fort_process_instance_id = tmpId3;
                    UPDATE fort_process_task_instance SET fort_process_task_instance.fort_state = '4' WHERE fort_process_task_instance.fort_process_instance_id = tmpId3;
                END IF;
                FETCH cur3 INTO tmpId3;
            END WHILE;
        CLOSE cur3;
        
         SET done = 0;
        OPEN cur4;
            FETCH cur4 INTO tmpId4;
            WHILE(done != 1) DO
                SET @fort_state4 = (SELECT DISTINCT fort_plan_password.fort_state  FROM fort_plan_password WHERE fort_plan_password.fort_plan_password_id = tmpId4);
                IF @fort_state4 = '1' THEN
                    UPDATE fort_plan_password SET fort_plan_password.fort_state = '0' WHERE fort_plan_password.fort_plan_password_id = tmpId4;

                END IF;
               
                 SET @fort_state5 = (SELECT DISTINCT fort_plan_password_backup.fort_state  FROM fort_plan_password_backup WHERE fort_plan_password_backup.fort_plan_password_backup_id = tmpId4);
                IF @fort_state5= '1' THEN
                    UPDATE fort_plan_password_backup SET fort_plan_password_backup.fort_state = '0' WHERE fort_plan_password_backup.fort_plan_password_backup_id = tmpId4;
                  
                END IF;
                
                FETCH cur4 INTO tmpId4;
            END WHILE;
        CLOSE cur4;
        
    END IF;
END;
$$

DELIMITER ;


DELIMITER $$

USE `fort`$$

DROP TRIGGER /*!50032 IF EXISTS */ `before_fort_rule_command_delete`$$

CREATE
    /*!50017 DEFINER = 'mysql'@'127.0.0.1' */
    TRIGGER `before_fort_rule_command_delete` BEFORE DELETE ON `fort_rule_command` 
    FOR EACH ROW BEGIN 
    DELETE FROM fort_command WHERE fort_command.fort_rule_command_id = OLD.fort_rule_command_id;
    DELETE FROM fort_rule_command_target_proxy WHERE fort_rule_command_target_proxy.fort_rule_command_id = OLD.fort_rule_command_id;
END;
$$

DELIMITER ;

DELIMITER $$

USE `fort`$$

DROP TRIGGER /*!50032 IF EXISTS */ `before_fort_rule_address_delete`$$

CREATE
    /*!50017 DEFINER = 'mysql'@'127.0.0.1' */
    TRIGGER `before_fort_rule_address_delete` BEFORE DELETE ON `fort_rule_address` 
    FOR EACH ROW BEGIN 
    DELETE FROM fort_ip_mask WHERE fort_ip_mask.fort_rule_address_id = OLD.fort_rule_address_id;
    DELETE FROM fort_ip_range WHERE fort_ip_range.fort_rule_address_id = OLD.fort_rule_address_id;
END;
$$

DELIMITER ;

DELIMITER $$

USE `fort`$$

DROP TRIGGER /*!50032 IF EXISTS */ `before_fort_strategy_password_delete`$$

CREATE
    /*!50017 DEFINER = 'mysql'@'127.0.0.1' */
    TRIGGER `before_fort_strategy_password_delete` BEFORE DELETE ON `fort_strategy_password` 
    FOR EACH ROW BEGIN 
    UPDATE fort_plan_password SET fort_plan_password.fort_new_password = NULL WHERE fort_plan_password.fort_new_password = OLD.fort_strategy_password_id;
END;
$$

DELIMITER ;

DELIMITER $$

USE `fort`$$

DROP TRIGGER /*!50032 IF EXISTS */ `befort_fort_client_tool_delete`$$

CREATE
    /*!50017 DEFINER = 'mysql'@'127.0.0.1' */
    TRIGGER `befort_fort_client_tool_delete` BEFORE DELETE ON `fort_client_tool` 
    FOR EACH ROW BEGIN 
        SET @operationsProtocolId = (SELECT `fort_operations_protocol_id` FROM `fort_protocol_client` WHERE `fort_protocol_client`.`fort_client_tool_id` = old.fort_client_tool_id);
        SELECT `fort_operations_protocol_id` INTO @operationsProtocolId FROM `fort_protocol_client` WHERE `fort_protocol_client`.`fort_client_tool_id` = old.fort_client_tool_id;
        
         DELETE FROM `fort_resource_operations_protocol` WHERE `fort_resource_operations_protocol`.`fort_operations_protocol_id` = @operationsProtocolId;
         DELETE FROM `fort_resource_type_operations_protocol` WHERE `fort_resource_type_operations_protocol`.`fort_operations_protocol_id` = @operationsProtocolId;
         DELETE FROM `fort_protocol_client` WHERE `fort_protocol_client`.`fort_operations_protocol_id` = @operationsProtocolId;
        DELETE FROM `fort_operations_protocol` WHERE `fort_operations_protocol`.`fort_operations_protocol_id` = @operationsProtocolId;
        
    END;
$$

DELIMITER ;

DELIMITER $$

USE `fort`$$

DROP TRIGGER /*!50032 IF EXISTS */ `befort_fort_plan_password_backup_delete`$$

CREATE
    /*!50017 DEFINER = 'mysql'@'127.0.0.1' */
    TRIGGER `befort_fort_plan_password_backup_delete` BEFORE DELETE ON `fort_plan_password_backup` 
    FOR EACH ROW BEGIN 
    DELETE FROM `fort_plan_password_backup_record` WHERE `fort_plan_password_backup_record`.`fort_plan_id` = old.fort_plan_password_backup_id;
    DELETE FROM `fort_plan_password_target_proxy` WHERE `fort_plan_password_target_proxy`.`fort_plan_id` = old.fort_plan_password_backup_id;
    
    END;
$$

DELIMITER ;

DELIMITER $$

USE `fort`$$

DROP TRIGGER /*!50032 IF EXISTS */ `befort_fort_plan_password_delete`$$

CREATE
    /*!50017 DEFINER = 'mysql'@'127.0.0.1' */
    TRIGGER `befort_fort_plan_password_delete` BEFORE DELETE ON `fort_plan_password` 
    FOR EACH ROW BEGIN 
    DELETE FROM `fort_plan_password_backup_record` WHERE `fort_plan_password_backup_record`.`fort_plan_id` = old.fort_plan_password_id;
    DELETE FROM `fort_plan_password_target_proxy` WHERE `fort_plan_password_target_proxy`.`fort_plan_id` = old.fort_plan_password_id;
    
    END;
$$

DELIMITER ;

DELIMITER $$


DROP TRIGGER /*!50032 IF EXISTS */ `tri_del_authorization_rel`$$

CREATE
    /*!50017 DEFINER = 'mysql'@'127.0.0.1' */
    TRIGGER `tri_del_authorization_rel` BEFORE DELETE ON `fort_authorization` 
    FOR EACH ROW BEGIN
    
    UPDATE fort_process_instance SET fort_process_instance.fort_state = '4' WHERE    fort_process_instance.fort_state = '1' AND 
    fort_process_instance.fort_process_id IN(
        SELECT   fort_authorization.fort_superior_process_id   
           FROM  fort_authorization   
               WHERE
                fort_authorization.fort_authorization_id =  OLD.fort_authorization_id
    );
    
    UPDATE fort_process_instance SET fort_process_instance.fort_state = '4' WHERE fort_process_instance.fort_process_instance_id IN(
         SELECT fort_double_approval_application.fort_process_instance_id
         FROM  fort_double_approval,fort_double_approval_application
             WHERE 
             fort_double_approval_application.fort_applicant_id = fort_double_approval.fort_user_id
             AND fort_double_approval.fort_is_candidate = '1' 
             AND  fort_double_approval.fort_authorization_id =  OLD.fort_authorization_id
    );
    
    UPDATE fort_process_task_instance SET fort_process_task_instance.fort_state = '4' WHERE 
              fort_process_task_instance.fort_state = '1' AND 
              fort_process_task_instance.fort_process_instance_id IN(
             SELECT   fort_process_instance.fort_process_instance_id  FROM  fort_process_instance,fort_authorization   
                   WHERE fort_process_instance.fort_process_id = fort_authorization.fort_superior_process_id 
                   AND fort_authorization.fort_authorization_id =  OLD.fort_authorization_id    
     );
    
    UPDATE fort_process_task_instance SET fort_process_task_instance.fort_state = '4' WHERE fort_process_task_instance.fort_state = '1'  
    AND
    fort_process_task_instance.fort_process_instance_id IN(
        SELECT  fort_double_approval_application.fort_process_instance_id
        FROM fort_double_approval,fort_double_approval_application
            WHERE 
              fort_double_approval_application.fort_applicant_id = fort_double_approval.fort_user_id
            AND fort_double_approval.fort_is_candidate = '1' 
            AND  fort_double_approval.fort_authorization_id =  OLD.fort_authorization_id
    );
    
END;
$$

DELIMITER ;


DELIMITER $$

USE `fort`$$

DROP TRIGGER /*!50032 IF EXISTS */ `tri_del_user_group_rel`$$

CREATE
    /*!50017 DEFINER = 'mysql'@'127.0.0.1' */
    TRIGGER `tri_del_user_group_rel` BEFORE DELETE ON `fort_user_group` 
    FOR EACH ROW BEGIN
    
        
        DELETE FROM fort_rule_command_target_proxy  WHERE fort_rule_command_target_proxy.fort_target_id = OLD.fort_user_group_id;
    
    DELETE FROM fort_authorization_target_proxy  WHERE fort_authorization_target_proxy.fort_target_id = OLD.fort_user_group_id;
    
    DELETE FROM fort_user_group_user  WHERE fort_user_group_user.fort_user_group_id = OLD.fort_user_group_id;

     DELETE FROM fort_rule_time_resource_target_proxy  WHERE fort_rule_time_resource_target_proxy.fort_target_id = OLD.fort_user_group_id;

END;
$$

DELIMITER ;


DELIMITER $$

USE `fort`$$

DROP TRIGGER /*!50032 IF EXISTS */ `before_account_delete`$$

CREATE
    /*!50017 DEFINER = 'mysql'@'127.0.0.1' */
    TRIGGER `before_account_delete` BEFORE DELETE ON `fort_account` 
    FOR EACH ROW BEGIN
    

    DELETE 
    FROM fort_authorization_target_proxy
    WHERE fort_authorization_target_proxy.fort_target_id = old.fort_account_id;
    
    DELETE
    FROM fort_plan_password_target_proxy
    WHERE  fort_plan_password_target_proxy.fort_target_id = old.fort_account_id;
    
    DELETE 
    FROM fort_rule_command_target_proxy
    WHERE fort_rule_command_target_proxy.fort_target_id = old.fort_account_id;

        DELETE 
    FROM fort_rule_time_resource_target_proxy
    WHERE fort_rule_time_resource_target_proxy.fort_target_id = old.fort_account_id;

    END;
$$

DELIMITER ;


DELIMITER $$

USE `fort`$$

DROP TRIGGER /*!50032 IF EXISTS */ `tri_del_resource`$$

CREATE
    /*!50017 DEFINER = 'mysql'@'127.0.0.1' */
    TRIGGER `tri_del_resource` BEFORE UPDATE ON `fort_resource` 
    FOR EACH ROW BEGIN
IF new.fort_resource_state=2 || old.fort_department_id <> new.fort_department_id
THEN
 DELETE FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_target_id=old.fort_resource_id;
 DELETE FROM fort_plan_password_target_proxy WHERE fort_plan_password_target_proxy.fort_target_id=old.fort_resource_id;
 DELETE FROM fort_rule_command_target_proxy WHERE fort_rule_command_target_proxy.fort_target_id=old.fort_resource_id;

DELETE FROM fort_rule_time_resource_target_proxy WHERE fort_rule_time_resource_target_proxy.fort_target_id=old.fort_resource_id;

 DELETE FROM fort_resource_application WHERE fort_resource_id=old.fort_resource_id;
 DELETE FROM fort_resource_operations_protocol WHERE fort_resource_id=old.fort_resource_id;
 DELETE FROM fort_account WHERE fort_resource_id=old.fort_resource_id;
 
END IF;
END;
$$

DELIMITER ;

DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `selectSsoResourceListByQuery`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `selectSsoResourceListByQuery`(IN user_id VARCHAR(32),IN fort_resource_name_or_ip VARCHAR(100),IN fort_resource_type VARCHAR(300),IN  fort_department_ids VARCHAR(600),IN fort_authorization_id VARCHAR(100),IN orderField VARCHAR(32),IN limitStart INT,IN limitEnd INT)
BEGIN   
      DECLARE done INT DEFAULT -1;  
      DECLARE temp_auth_id VARCHAR(32); 
      DECLARE temp_code INT;   
      DECLARE temp_resource_id VARCHAR(32);  
      DECLARE temp_resource_type_id VARCHAR(32);
      DECLARE temp_resource_group VARCHAR(300);   
      DECLARE temp_user_group_string VARCHAR(300);  
      DECLARE temp_resource_group_string VARCHAR(3000); 
      DECLARE temp_sql_string TEXT; 
      DECLARE temp_user_sql_string TEXT;
      DECLARE temp_protocol_client TEXT;
      DECLARE temp_operations_protocol TEXT;
            
     
    
      DECLARE select_auth_for_temp_auth_id CURSOR FOR SELECT DISTINCT fort_authorization.fort_authorization_id,
              fort_authorization.fort_authorization_code  FROM fort_authorization,temp_sso 
          WHERE  fort_authorization.fort_authorization_id = temp_sso.auth_id;
      DECLARE select_auth_for_temp_sso CURSOR FOR SELECT fort_resource_id,fort_resource_type_id FROM temp_more_sso;
      
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1;  
      DROP TEMPORARY TABLE IF EXISTS temp_sso;  
      
      CREATE TEMPORARY TABLE temp_sso(
           auth_id  VARCHAR(24) 
          ,account_id VARCHAR(24) 
          ,resource_id VARCHAR(24) 
          ,auth_code INT  
       )ENGINE=MEMORY;
       
          
        DROP TEMPORARY TABLE IF EXISTS temp_more_sso;   
        CREATE TEMPORARY TABLE temp_more_sso(
           fort_resource_id  VARCHAR(24) 
          ,fort_resource_name VARCHAR(32) 
          ,fort_resource_ip VARCHAR(20)
          ,fort_ips VARCHAR(64)
          ,fort_resource_type_name  VARCHAR(32) 
          ,fort_accounts TEXT
          ,fort_resource_type_id VARCHAR(24) 
          ,fort_resource_state VARCHAR(24) 
       );
         
         SET autocommit = 0;
         
         INSERT INTO temp_sso(auth_id) 
               SELECT DISTINCT fort_authorization_target_proxy.fort_authorization_id 
               FROM fort_authorization_target_proxy
               WHERE fort_authorization_target_proxy.fort_target_id = user_id 
               AND fort_authorization_target_proxy.fort_target_code = 2; 
        
          
         INSERT INTO temp_sso(auth_id)       
                SELECT DISTINCT fort_authorization_target_proxy.fort_authorization_id 
                FROM fort_authorization_target_proxy,(SELECT fort_user_group_user.fort_user_group_id AS group_id 
                FROM fort_user_group_user WHERE fort_user_group_user.fort_user_id = user_id ) t_group 
        WHERE fort_authorization_target_proxy.fort_target_id  IN (t_group.group_id) ; 
         
    IF (fort_authorization_id != '' ) THEN
        DELETE FROM temp_sso WHERE auth_id <> fort_authorization_id ;
     END IF; 
     
       
        
      OPEN select_auth_for_temp_auth_id;
   
      
      tempAuthLoop: LOOP  
     
          
        FETCH select_auth_for_temp_auth_id INTO temp_auth_id,temp_code;  
        IF done = 1 THEN   
        LEAVE tempAuthLoop;  
        END IF;  
     
        
         IF (temp_code&8 = 8 ) THEN
         INSERT INTO temp_sso(account_id,resource_id) 
              SELECT DISTINCT fort_account.fort_account_id ,fort_authorization_target_proxy.fort_parent_id
                  FROM fort_authorization_target_proxy,fort_account WHERE 
                  fort_authorization_target_proxy.fort_authorization_id = temp_auth_id 
                  AND fort_authorization_target_proxy.fort_target_id = fort_account.fort_account_id 
                  AND fort_account.fort_is_allow_authorized = 1
                  AND fort_authorization_target_proxy.fort_target_code = 8 ;
         END IF;  
         IF (temp_code&16 = 16 ) THEN
             
              INSERT INTO temp_sso(account_id,resource_id)    
                    SELECT DISTINCT fort_account.fort_account_id, fort_resource.fort_resource_id FROM fort_account,fort_resource,fort_authorization_target_proxy 
            WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_id 
                AND fort_authorization_target_proxy.fort_target_code = 16
            AND fort_authorization_target_proxy.fort_target_id = fort_resource.fort_resource_id 
                    AND fort_resource.fort_resource_id = fort_account.fort_resource_id 
                      AND fort_account.fort_is_allow_authorized = 1 ;
       
         INSERT INTO temp_sso(account_id,resource_id) 
             SELECT DISTINCT fort_account.fort_account_id, fort_resource.fort_resource_id FROM fort_account,fort_resource,fort_authorization_target_proxy 
             WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_id  
             AND fort_authorization_target_proxy.fort_target_code = 16
             AND fort_authorization_target_proxy.fort_target_id = fort_resource.fort_resource_id 
                     AND fort_resource.fort_parent_id = fort_account.fort_resource_id 
                       AND fort_account.fort_is_allow_authorized = 1 ;
                     
         END IF; 
         
         IF (temp_code&32 = 32 ) THEN
         
           
           SELECT GROUP_CONCAT( fort_authorization_target_proxy.fort_target_id ) INTO temp_resource_group_string 
                  FROM fort_authorization_target_proxy WHERE 
                      fort_authorization_target_proxy.fort_authorization_id = temp_auth_id 
                      AND fort_authorization_target_proxy.fort_target_code =  32;   
         
         
         INSERT INTO temp_sso(account_id,resource_id) 
                SELECT DISTINCT fort_account.fort_account_id, fort_resource.fort_resource_id FROM fort_account,fort_resource,fort_resource_group_resource
                    WHERE  fort_resource.fort_resource_id = fort_account.fort_resource_id
                    AND fort_resource_group_resource.fort_resource_id = fort_resource.fort_resource_id
                      AND fort_resource.fort_resource_state <> 2 
                    AND fort_account.fort_is_allow_authorized = 1
                    AND FIND_IN_SET (fort_resource_group_resource.fort_resource_group_id,temp_resource_group_string) >0 ;
                    
         INSERT INTO temp_sso(account_id,resource_id) 
                SELECT DISTINCT fort_account.fort_account_id, fort_resource.fort_resource_id FROM fort_account,fort_resource,fort_resource_group_resource
                    WHERE  fort_resource.fort_parent_id = fort_account.fort_resource_id
                    AND fort_resource_group_resource.fort_resource_id = fort_resource.fort_resource_id
                     AND fort_resource.fort_resource_state <> 2 
                    AND fort_account.fort_is_allow_authorized = 1
                    AND FIND_IN_SET (fort_resource_group_resource.fort_resource_group_id,temp_resource_group_string ) >0 ; 
                    
         END IF;  
        END LOOP tempAuthLoop;  
    
   
    
      
     CLOSE select_auth_for_temp_auth_id;  
       SET temp_sql_string = CONCAT(
       'insert into temp_more_sso(fort_resource_id,fort_resource_name,fort_resource_ip,fort_ips,fort_resource_type_name,fort_accounts,fort_resource_type_id,fort_resource_state)', 
           'SELECT fort_resource.fort_resource_id,',
       'fort_resource.fort_resource_name,fort_resource.fort_resource_ip,',  
           'fort_resource.fort_ips,',
       'fort_resource_type.fort_resource_type_name,',
       'GROUP_CONCAT( DISTINCT( CONCAT( fort_account.fort_account_id,":",fort_account.fort_account_name)) SEPARATOR \'|\') fort_accounts, ',
       ' fort_resource_type.fort_resource_type_id, ',
       ' fort_resource.fort_resource_state ',
            ' FROM ', 
       'temp_sso ,',    
       'fort_account ,',
       'fort_resource ,',
       'fort_resource_type ',
       ' WHERE  ',
       'temp_sso.auth_id IS NULL  ',
       ' AND fort_resource.fort_resource_state <> 2 AND fort_account.fort_is_allow_authorized = 1 ',
       ' AND temp_sso.account_id = fort_account.fort_account_id ',
       ' AND temp_sso.resource_id = fort_resource.fort_resource_id ',
       ' AND (fort_account.fort_resource_id = fort_resource.fort_resource_id or fort_account.fort_resource_id = fort_resource.fort_parent_id)',
       ' AND fort_resource.fort_resource_type_id = fort_resource_type.fort_resource_type_id '
       );
    IF ( fort_resource_name_or_ip != '' ) THEN 
     SET temp_sql_string = CONCAT(temp_sql_string,' AND (fort_resource.fort_resource_name like \'',CONCAT(CONCAT('%',fort_resource_name_or_ip),'%\''),
            ' OR fort_resource.fort_resource_ip like\'', CONCAT(CONCAT('%', fort_resource_name_or_ip),'%\''),')');
    END IF;
    IF ( fort_resource_type != '' ) THEN 
       SET temp_sql_string = CONCAT(temp_sql_string,'  AND FIND_IN_SET(fort_resource.fort_resource_type_id,selectResourceTypeChildList( \'',fort_resource_type,'\'))');
    END IF;
     IF ( fort_department_ids != '' ) THEN 
       SET temp_sql_string = CONCAT(temp_sql_string,' AND  FIND_IN_SET(fort_resource.fort_department_id,\'',fort_department_ids,'\')');
    END IF;
     SET temp_sql_string = CONCAT(temp_sql_string,' group by fort_resource.fort_resource_id');
     IF (orderField != '' ) THEN 
      SET temp_sql_string = CONCAT(temp_sql_string,' ORDER BY ',orderField);
     END IF;
     IF (limitEnd != -1 && limitStart != -1 && limitStart IS NOT NULL  && limitEnd IS NOT NULL   ) THEN 
       SET temp_sql_string = CONCAT(temp_sql_string,' LIMIT ',limitStart,' , ',limitEnd); 
     END IF;
     SET @temp_user_sql_string = temp_sql_string;
     PREPARE stmt FROM  @temp_user_sql_string; 
     
     EXECUTE stmt;      
     DEALLOCATE PREPARE stmt;   
     
     SELECT * FROM temp_more_sso;
    DROP TABLE temp_sso; 
    DROP TABLE temp_more_sso;
    
    SET autocommit = 1;
    
    END$$

DELIMITER ;


DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `selectSsoResourceCountByQuery`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `selectSsoResourceCountByQuery`(IN user_id VARCHAR(32),IN fort_resource_name_or_ip VARCHAR(100),IN fort_resource_type VARCHAR(300),IN fort_department_ids VARCHAR(600),IN fort_authorization_id VARCHAR(50))
BEGIN   
      DECLARE done INT DEFAULT -1;  
      DECLARE temp_auth_id VARCHAR(32); 
      DECLARE temp_code INT;   
      DECLARE temp_resource_id VARCHAR(32);  
      DECLARE temp_resource_type_id VARCHAR(32);
      DECLARE temp_resource_group VARCHAR(300);   
      DECLARE temp_user_group_string VARCHAR(300);  
      DECLARE temp_resource_group_string VARCHAR(300); 
      DECLARE temp_sql_string TEXT; 
      DECLARE temp_user_sql_string TEXT;
      DECLARE temp_protocol_client TEXT;
      DECLARE temp_operations_protocol TEXT;
            
     
      DECLARE select_auth_for_temp_auth_id CURSOR FOR SELECT DISTINCT fort_authorization.fort_authorization_id,fort_authorization.fort_authorization_code  FROM fort_authorization,temp_sso WHERE  fort_authorization.fort_authorization_id = temp_sso.auth_id;
      DECLARE select_auth_for_temp_sso CURSOR FOR SELECT fort_resource_id,fort_resource_type_id FROM temp_more_sso;
      
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1;  
      DROP TEMPORARY TABLE IF EXISTS temp_sso;  
      CREATE TEMPORARY TABLE temp_sso(
          auth_id  VARCHAR(24) 
          ,account_id VARCHAR(24) 
          ,resource_id VARCHAR(24) 
          ,auth_code INT  
       )ENGINE=MEMORY;
        DROP TEMPORARY TABLE IF EXISTS temp_more_sso;   
        CREATE TEMPORARY TABLE temp_more_sso(
           fort_resource_id  VARCHAR(24) 
          ,fort_resource_name VARCHAR(32) 
          ,fort_resource_ip VARCHAR(20)
          ,fort_ips VARCHAR(64)
          ,fort_resource_type_name  VARCHAR(32) 
          ,fort_accounts TEXT
          ,fort_resource_type_id VARCHAR(24) 
          ,fort_resource_state VARCHAR(24) 
       );
         
          SET autocommit = 0; 
         INSERT INTO temp_sso(auth_id) 
               SELECT DISTINCT fort_authorization_target_proxy.fort_authorization_id 
               FROM fort_authorization_target_proxy
               WHERE fort_authorization_target_proxy.fort_target_id = user_id 
               AND fort_authorization_target_proxy.fort_target_code = 2; 
        
          
         INSERT INTO temp_sso(auth_id)       
                SELECT DISTINCT fort_authorization_target_proxy.fort_authorization_id 
                FROM fort_authorization_target_proxy,(SELECT fort_user_group_user.fort_user_group_id AS group_id 
                FROM fort_user_group_user WHERE fort_user_group_user.fort_user_id = user_id ) t_group 
        WHERE fort_authorization_target_proxy.fort_target_id  IN (t_group.group_id) ; 
         
    IF (fort_authorization_id != '' ) THEN
        DELETE FROM temp_sso WHERE auth_id <> fort_authorization_id ;
     END IF; 
        
    IF (fort_authorization_id != '' ) THEN
        DELETE FROM temp_sso WHERE auth_id <> fort_authorization_id ;
     END IF;    
     
        
      OPEN select_auth_for_temp_auth_id;
   
      
      tempAuthLoop: LOOP  
     
          
        FETCH select_auth_for_temp_auth_id INTO temp_auth_id,temp_code;  
        IF done = 1 THEN   
        LEAVE tempAuthLoop;  
        END IF;  
      
        
         IF (temp_code&8 = 8 ) THEN
         INSERT INTO temp_sso(account_id,resource_id) 
         SELECT DISTINCT fort_account.fort_account_id ,fort_authorization_target_proxy.fort_parent_id
            FROM fort_authorization_target_proxy,fort_account WHERE 
        fort_authorization_target_proxy.fort_authorization_id = temp_auth_id 
            AND fort_authorization_target_proxy.fort_target_id = fort_account.fort_account_id 
            AND fort_account.fort_is_allow_authorized = 1
            AND fort_authorization_target_proxy.fort_target_code = 8 ;
         END IF;  
         IF (temp_code&16 = 16 ) THEN
             
              INSERT INTO temp_sso(account_id,resource_id)    
                    SELECT DISTINCT fort_account.fort_account_id, fort_resource.fort_resource_id FROM fort_account,fort_resource,fort_authorization_target_proxy 
            WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_id 
                AND fort_authorization_target_proxy.fort_target_code = 16
            AND fort_authorization_target_proxy.fort_target_id = fort_resource.fort_resource_id 
                    AND fort_resource.fort_resource_id = fort_account.fort_resource_id 
                    AND fort_resource.fort_parent_id IS NULL AND fort_account.fort_is_allow_authorized = 1 ;
       
         INSERT INTO temp_sso(account_id,resource_id) 
             SELECT DISTINCT fort_account.fort_account_id, fort_resource.fort_resource_id FROM fort_account,fort_resource,fort_authorization_target_proxy 
             WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_id  
             AND fort_authorization_target_proxy.fort_target_code = 16
             AND fort_authorization_target_proxy.fort_target_id = fort_resource.fort_resource_id 
                     AND fort_resource.fort_parent_id = fort_account.fort_resource_id 
                     AND fort_resource.fort_parent_id IS NOT NULL AND fort_account.fort_is_allow_authorized = 1 ;
                     
         END IF; 
         
         IF (temp_code&32 = 32 ) THEN
         
           
           SELECT GROUP_CONCAT( fort_authorization_target_proxy.fort_target_id ) INTO temp_resource_group_string 
                  FROM fort_authorization_target_proxy WHERE 
                      fort_authorization_target_proxy.fort_authorization_id = temp_auth_id 
                      AND fort_authorization_target_proxy.fort_target_code =  32;   
         
         
         INSERT INTO temp_sso(account_id,resource_id) 
                SELECT DISTINCT fort_account.fort_account_id, fort_resource.fort_resource_id FROM fort_account,fort_resource,fort_resource_group_resource
                    WHERE  fort_resource.fort_resource_id = fort_account.fort_resource_id
                    AND fort_resource_group_resource.fort_resource_id = fort_resource.fort_resource_id
                    AND fort_resource.fort_parent_id IS NULL AND fort_resource.fort_resource_state <> 2 
                    AND fort_account.fort_is_allow_authorized = 1
                    AND FIND_IN_SET (fort_resource_group_resource.fort_resource_group_id,temp_resource_group_string) >0 ;
                    
         INSERT INTO temp_sso(account_id,resource_id) 
                SELECT DISTINCT fort_account.fort_account_id, fort_resource.fort_resource_id FROM fort_account,fort_resource,fort_resource_group_resource
                    WHERE  fort_resource.fort_parent_id = fort_account.fort_resource_id
                    AND fort_resource_group_resource.fort_resource_id = fort_resource.fort_resource_id
                    AND fort_resource.fort_parent_id IS NOT NULL AND fort_resource.fort_resource_state <> 2 
                    AND fort_account.fort_is_allow_authorized = 1
                    AND FIND_IN_SET (fort_resource_group_resource.fort_resource_group_id,temp_resource_group_string ) >0 ; 
                    
         END IF;  
         
        END LOOP tempAuthLoop;  
    
      
     CLOSE select_auth_for_temp_auth_id;  
     
       SET temp_sql_string = CONCAT(
       'insert into temp_more_sso(fort_resource_id,fort_resource_name,fort_resource_ip,fort_ips,fort_resource_type_name,fort_accounts,fort_resource_type_id,fort_resource_state)', 
           'SELECT fort_resource.fort_resource_id,',
       'fort_resource.fort_resource_name,fort_resource.fort_resource_ip,',  
           'fort_resource.fort_ips,',
       'fort_resource_type.fort_resource_type_name,',
       'GROUP_CONCAT( DISTINCT( CONCAT( fort_account.fort_account_id,":",fort_account.fort_account_name)) SEPARATOR \'|\') fort_accounts, ',
       ' fort_resource_type.fort_resource_type_id, ',
       ' fort_resource.fort_resource_state ',
            ' FROM ', 
       'temp_sso ,',    
       'fort_account ,',
       'fort_resource ,',
       'fort_resource_type ',
       ' WHERE  ',
       'temp_sso.auth_id IS NULL  ',
       ' AND fort_resource.fort_resource_state <> 2 AND fort_account.fort_is_allow_authorized = 1 ',
       ' AND temp_sso.account_id = fort_account.fort_account_id ',
       ' AND temp_sso.resource_id = fort_resource.fort_resource_id ',
       ' AND fort_resource.fort_resource_type_id = fort_resource_type.fort_resource_type_id '
       );
    IF ( fort_resource_name_or_ip != '' ) THEN 
     SET temp_sql_string = CONCAT(temp_sql_string,' AND (fort_resource.fort_resource_name like \'',CONCAT(CONCAT('%',fort_resource_name_or_ip),'%\''),
            ' OR fort_resource.fort_resource_ip like\'', CONCAT(CONCAT('%', fort_resource_name_or_ip),'%\''),')');
    END IF;
    IF ( fort_resource_type != '' ) THEN 
       SET temp_sql_string = CONCAT(temp_sql_string,'  AND FIND_IN_SET(fort_resource.fort_resource_type_id,selectResourceTypeChildList( \'',fort_resource_type,'\'))');
    END IF;
     IF ( fort_department_ids != '' ) THEN 
       SET temp_sql_string = CONCAT(temp_sql_string,' AND  FIND_IN_SET(fort_resource.fort_department_id,\'',fort_department_ids,'\')');
    END IF;
     SET temp_sql_string = CONCAT(temp_sql_string,' group by fort_resource.fort_resource_id');
    
     SET @temp_user_sql_string = temp_sql_string;
     PREPARE stmt FROM  @temp_user_sql_string; 
     
     EXECUTE stmt;      
     DEALLOCATE PREPARE stmt;       
    
    SELECT COUNT(DISTINCT fort_resource_id) FROM  temp_more_sso;   
    
    DROP TABLE temp_sso; 
    DROP TABLE temp_more_sso;
    
    SET autocommit = 1;
    
    END$$

DELIMITER ;


DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `selectSsoDepartmentByUserId`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `selectSsoDepartmentByUserId`(IN user_id VARCHAR(32))
BEGIN   
      DECLARE done INT DEFAULT -1;  
      DECLARE temp_auth_id VARCHAR(32); 
      DECLARE temp_code INT;   
      DECLARE temp_resource_id VARCHAR(32);  
      DECLARE temp_resource_type_id VARCHAR(32);
      DECLARE temp_resource_group VARCHAR(300);   
      DECLARE temp_user_group_string VARCHAR(300);  
      DECLARE temp_resource_group_string VARCHAR(300); 
      DECLARE temp_sql_string TEXT; 
      DECLARE temp_user_sql_string TEXT;
      DECLARE temp_protocol_client TEXT;
      DECLARE temp_operations_protocol TEXT;
            
     
      DECLARE select_auth_for_temp_auth_id CURSOR FOR SELECT DISTINCT fort_authorization.fort_authorization_id,fort_authorization.fort_authorization_code  FROM fort_authorization,temp_sso WHERE  fort_authorization.fort_authorization_id = temp_sso.auth_id;
      DECLARE select_auth_for_temp_sso CURSOR FOR SELECT fort_resource_id,fort_resource_type_id FROM temp_more_sso;
      
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1;  
      DROP TEMPORARY TABLE IF EXISTS temp_sso;  
      CREATE TEMPORARY TABLE temp_sso(
           auth_id  VARCHAR(50) 
          ,account_id VARCHAR(50)
          ,resource_id VARCHAR(50)
          ,auth_name VARCHAR(50) 
       )ENGINE=MEMORY;
       
        DROP TEMPORARY TABLE IF EXISTS temp_more_sso;   
        CREATE TEMPORARY TABLE temp_more_sso(
           fort_resource_id  VARCHAR(24) 
          ,fort_department_id VARCHAR(32) 
          ,fort_resource_ip VARCHAR(20)
          ,fort_ips VARCHAR(64)
          ,fort_resource_type_name  VARCHAR(32) 
          ,fort_protocol_client1 VARCHAR(300)
          ,fort_operations_protocol VARCHAR(300)
          ,fort_accounts VARCHAR(300)
          ,fort_resource_type_id VARCHAR(24) 
       )ENGINE=MEMORY;
         
         SET autocommit = 0;  
         INSERT INTO temp_sso(auth_id) 
               SELECT DISTINCT fort_authorization_target_proxy.fort_authorization_id 
               FROM fort_authorization_target_proxy
               WHERE fort_authorization_target_proxy.fort_target_id = user_id 
               AND fort_authorization_target_proxy.fort_target_code = 2; 
        
          
         INSERT INTO temp_sso(auth_id)       
                SELECT DISTINCT fort_authorization_target_proxy.fort_authorization_id 
                FROM fort_authorization_target_proxy,(SELECT fort_user_group_user.fort_user_group_id AS group_id 
                FROM fort_user_group_user WHERE fort_user_group_user.fort_user_id = user_id ) t_group 
        WHERE fort_authorization_target_proxy.fort_target_id  IN (t_group.group_id) ; 
         
     
     
        
      OPEN select_auth_for_temp_auth_id;
   
      
      tempAuthLoop: LOOP  
     
          
        FETCH select_auth_for_temp_auth_id INTO temp_auth_id,temp_code;  
        IF done = 1 THEN   
        LEAVE tempAuthLoop;  
        END IF;  
      
        
         IF (temp_code&8 = 8 ) THEN
         INSERT INTO temp_sso(account_id,resource_id) 
          SELECT DISTINCT fort_account.fort_account_id ,fort_authorization_target_proxy.fort_parent_id
        FROM fort_authorization_target_proxy,fort_account WHERE 
        fort_authorization_target_proxy.fort_authorization_id = temp_auth_id 
        AND fort_authorization_target_proxy.fort_target_id = fort_account.fort_account_id 
        AND fort_account.fort_is_allow_authorized = 1
        AND fort_authorization_target_proxy.fort_target_code = 8  ;
         END IF; 
          
         IF (temp_code&16 = 16 ) THEN
              INSERT INTO temp_sso(account_id,resource_id)    
                    SELECT DISTINCT fort_account.fort_account_id, fort_resource.fort_resource_id FROM fort_account,fort_resource,fort_authorization_target_proxy 
            WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_id 
                AND fort_authorization_target_proxy.fort_target_code = 16
            AND fort_authorization_target_proxy.fort_target_id = fort_resource.fort_resource_id 
                    AND fort_resource.fort_resource_id = fort_account.fort_resource_id 
                    AND fort_resource.fort_parent_id IS NULL AND fort_account.fort_is_allow_authorized = 1 ;
       
         INSERT INTO temp_sso(account_id,resource_id) 
             SELECT DISTINCT fort_account.fort_account_id, fort_resource.fort_resource_id FROM fort_account,fort_resource,fort_authorization_target_proxy 
             WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_id  
             AND fort_authorization_target_proxy.fort_target_code = 16
             AND fort_authorization_target_proxy.fort_target_id = fort_resource.fort_resource_id 
                     AND fort_resource.fort_parent_id = fort_account.fort_resource_id 
                     AND fort_resource.fort_parent_id IS NOT NULL AND fort_account.fort_is_allow_authorized = 1 ;
         
          END IF; 
         
         IF (temp_code&32 = 32 ) THEN
         
           SELECT GROUP_CONCAT( fort_authorization_target_proxy.fort_target_id ) INTO temp_resource_group_string 
                  FROM fort_authorization_target_proxy WHERE 
                      fort_authorization_target_proxy.fort_authorization_id = temp_auth_id 
                      AND fort_authorization_target_proxy.fort_target_code =  32;   
         
         
         INSERT INTO temp_sso(account_id,resource_id) 
                SELECT DISTINCT fort_account.fort_account_id, fort_resource.fort_resource_id FROM fort_account,fort_resource,fort_resource_group_resource
                    WHERE  fort_resource.fort_resource_id = fort_account.fort_resource_id
                    AND fort_resource_group_resource.fort_resource_id = fort_resource.fort_resource_id
                    AND fort_resource.fort_parent_id IS NULL AND fort_resource.fort_resource_state <> 2 
                    AND fort_account.fort_is_allow_authorized = 1
                    AND FIND_IN_SET (fort_resource_group_resource.fort_resource_group_id,temp_resource_group_string) >0 ;
                    
         INSERT INTO temp_sso(account_id,resource_id) 
                SELECT DISTINCT fort_account.fort_account_id, fort_resource.fort_resource_id FROM fort_account,fort_resource,fort_resource_group_resource
                    WHERE  fort_resource.fort_parent_id = fort_account.fort_resource_id
                    AND fort_resource_group_resource.fort_resource_id = fort_resource.fort_resource_id
                    AND fort_resource.fort_parent_id IS NOT NULL AND fort_resource.fort_resource_state <> 2 
                    AND fort_account.fort_is_allow_authorized = 1
                    AND FIND_IN_SET (fort_resource_group_resource.fort_resource_group_id,temp_resource_group_string ) >0 ; 
         END IF; 
         
        END LOOP tempAuthLoop;  
    
      
     CLOSE select_auth_for_temp_auth_id;  
       SET temp_sql_string = CONCAT(
           'insert into temp_more_sso(fort_resource_id,fort_department_id) SELECT DISTINCT fort_resource.fort_resource_id,',
       'fort_resource.fort_department_id ',
       ' FROM ', 
       'temp_sso ,',    
       'fort_resource ',
       ' WHERE  ',
       'temp_sso.auth_id IS NULL  ',
       'AND temp_sso.resource_id = fort_resource.fort_resource_id  ',
       'AND fort_resource.fort_resource_state <> 2 ',
      ' group by fort_resource.fort_resource_id' );
     SET @temp_user_sql_string =temp_sql_string; 
     PREPARE stmt FROM  @temp_user_sql_string; 
     EXECUTE stmt;        
     DEALLOCATE PREPARE stmt;   
      
    TRUNCATE TABLE temp_sso;
    
    
    INSERT INTO temp_sso(auth_id,account_id,auth_name)  SELECT  DISTINCT fort_department.fort_department_id,fort_department.fort_department_name,fort_department.fort_parent_id
    FROM  fort_department,(SELECT DISTINCT fort_department_id AS group_id  FROM temp_more_sso ) t WHERE FIND_IN_SET(fort_department.fort_department_id,selectDepartmentParentList(t.group_id)) >0;
 
    SELECT  DISTINCT auth_id AS fort_department_id ,account_id AS fort_department_name,auth_name AS fort_parent_id FROM temp_sso;
    DROP TABLE temp_sso; 
    DROP TABLE temp_more_sso;
    
    SET autocommit = 1;
    
    END$$

DELIMITER ;



DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `selectPlanAccountListByQuery`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `selectPlanAccountListByQuery`(IN fortDepartmentId VARCHAR(10000),IN fortAccountName VARCHAR(50),IN fortResourceIp VARCHAR(50),IN fortResourceName VARCHAR(50))
BEGIN   
      DECLARE done INT DEFAULT -1;  
      DECLARE temp_sql_string TEXT; 
 
      DROP TEMPORARY TABLE IF EXISTS tempAccountByAuth; 
      
      CREATE TEMPORARY TABLE tempAccountByAuth(
            fort_account_id  VARCHAR(200) 
           ,fort_account_name VARCHAR(100)
           ,fort_resource_name VARCHAR(100)
           ,fort_resource_id VARCHAR(200)
           ,fort_resource_type_id VARCHAR(200)
           ,fort_resource_type_name VARCHAR(100)
           ,fort_resource_ip VARCHAR(100)
           ,fort_resource_group_name VARCHAR(100) DEFAULT '-'
           ,fort_department_name VARCHAR(100)
       );
     
       
    INSERT INTO tempAccountByAuth(fort_account_id,fort_account_name,fort_resource_id,
          
          fort_resource_name,fort_resource_ip,fort_resource_type_id,fort_resource_type_name,fort_department_name) 
    SELECT 
              fort_account.fort_account_id,fort_account.fort_account_name, 
    
          fort_resource.fort_resource_id,fort_resource.fort_resource_name ,
       
              fort_resource.fort_resource_ip , 
       
             fort_resource_type.fort_resource_type_id,fort_resource_type.fort_resource_type_name ,
              
             fort_department.fort_department_name
       
        FROM fort_account,fort_resource,fort_resource_type,fort_department 
        
        WHERE fort_account.fort_resource_id = fort_resource.fort_resource_id 
       
        AND fort_resource.fort_resource_type_id = fort_resource_type.fort_resource_type_id
       
        AND fort_department.fort_department_id = fort_resource.fort_department_id
       
        AND fort_resource.fort_resource_state !=2 
       
        AND fort_resource.fort_parent_id IS NULL 
      
        AND fort_account.fort_account_name != '$user'
        
        AND fort_account.fort_account_password IS NOT NULL
        
         AND fort_account.fort_is_allow_authorized = '1'
     
        AND fort_account.fort_resource_id IN ( SELECT fort_resource.fort_resource_id FROM fort_resource WHERE FIND_IN_SET(fort_resource.fort_department_id ,fortDepartmentId));
        
     
      INSERT INTO tempAccountByAuth(fort_account_id,fort_account_name,fort_resource_id,
          
             fort_resource_name,fort_resource_ip,fort_resource_type_id,fort_resource_type_name,fort_resource_group_name,fort_department_name) 
     SELECT fort_account.fort_account_id,fort_account.fort_account_name, 
    
            fort_resource.fort_resource_id,fort_resource.fort_resource_name ,
       
                fort_resource.fort_resource_ip , fort_resource_type.fort_resource_type_id,
               
                fort_resource_type.fort_resource_type_name ,   fort_resource_group.fort_resource_group_name,
                
                fort_department.fort_department_name 
              
        FROM    fort_account,fort_resource,fort_resource_type,fort_department,fort_resource_group,fort_resource_group_resource
     
                WHERE fort_account.fort_resource_id = fort_resource.fort_resource_id 
       
        AND    fort_resource.fort_resource_type_id = fort_resource_type.fort_resource_type_id
       
        AND    fort_department.fort_department_id = fort_resource.fort_department_id
    
    AND fort_resource_group_resource.fort_resource_id = fort_account.fort_resource_id
        
        AND fort_resource_group_resource.fort_resource_group_id = fort_resource_group.fort_resource_group_id
       
        AND  fort_resource.fort_resource_state !=2 
       
        AND fort_resource.fort_parent_id IS NULL 
    
        AND fort_account.fort_account_name != '$user'
        
        AND fort_account.fort_account_password IS NOT NULL
        
        AND fort_account.fort_is_allow_authorized = '1'
    
        AND fort_account.fort_resource_id IN ( SELECT fort_resource.fort_resource_id FROM fort_resource WHERE 
        
        FIND_IN_SET(fort_resource_group.fort_resource_group_id,fortDepartmentId));
        
        
        
       
        
     SET temp_sql_string = CONCAT(
          "SELECT GROUP_CONCAT(DISTINCT(CONCAT(fort_account_id,':',fort_account_name)) SEPARATOR '|') AS fort_account_name, 
          
           GROUP_CONCAT(DISTINCT(CONCAT(fort_resource_id,':',fort_resource_name,':',fort_department_name )) SEPARATOR '|') AS fort_resource_name, 
           
           fort_resource_ip AS fort_resource_ip, 
           
           GROUP_CONCAT(DISTINCT(CONCAT(fort_resource_type_id,':',fort_resource_type_name)) SEPARATOR '|') AS fort_account_id",
           
       ' FROM ', 
       'tempAccountByAuth ',    
       ' WHERE  ',
       'fort_resource_id IS NOT NULL'
       );
       
    IF ( fortResourceName != '' ) THEN 
      SET temp_sql_string = CONCAT(temp_sql_string,' AND fort_resource_name like \'',CONCAT('%',fortResourceName,'%\''));
    END IF;
    IF ( fortResourceIp != '' ) THEN 
       SET temp_sql_string = CONCAT(temp_sql_string,' AND fort_resource_ip like \'',CONCAT('%',fortResourceIp,'%\''));
    END IF;
     IF ( fortAccountName != '' ) THEN 
      SET temp_sql_string = CONCAT(temp_sql_string,' AND fort_account_name like \'',CONCAT('%',fortAccountName,'%\''));
    END IF;
     SET temp_sql_string = CONCAT(temp_sql_string,' GROUP BY fort_resource_id');
     SET @temp_user_sql_string = temp_sql_string;
     PREPARE stmt FROM  @temp_user_sql_string; 
     EXECUTE stmt;      
     DEALLOCATE PREPARE stmt;   
     DROP TABLE tempAccountByAuth;
    END$$

DELIMITER ;

DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `checkSuperiorProcess`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `checkSuperiorProcess`(IN temp_authorization_id VARCHAR(200))
BEGIN   
      DECLARE done INT DEFAULT -1;  
      DECLARE temp_auth_id VARCHAR(32); 
      DECLARE temp_auth_check_id VARCHAR(32); 
      DECLARE temp_code INT;  
      DECLARE temp_auth_check_code INT;   
            
      
      DECLARE select_auth_for_all CURSOR FOR SELECT fort_authorization.fort_authorization_id,fort_authorization.fort_authorization_code FROM fort_authorization,fort_process 
              WHERE fort_authorization.fort_superior_process_id = fort_process.fort_process_id AND fort_process.fort_state = '1' 
              AND fort_authorization.fort_authorization_id <> temp_authorization_id;
    
      DECLARE select_auth_for_auth_id CURSOR FOR SELECT DISTINCT fort_authorization.fort_authorization_id,
              fort_authorization.fort_authorization_code  FROM fort_authorization
          WHERE  fort_authorization.fort_authorization_id = temp_authorization_id;
      
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1;  
     
     
      DROP TEMPORARY TABLE IF EXISTS temp_sso;  
      
      CREATE TEMPORARY TABLE temp_sso(
           auth_id  VARCHAR(32) 
          ,account_id VARCHAR(32) 
          ,resource_id VARCHAR(32)   
       )ENGINE=MEMORY;
      
      DROP TEMPORARY TABLE IF EXISTS temp_user_sso;  
      
      CREATE TEMPORARY TABLE temp_user_sso(
           auth_id  VARCHAR(32) 
          ,user_id VARCHAR(32) 
       )ENGINE=MEMORY;
       
       DROP TEMPORARY TABLE IF EXISTS temp_auth_by_id;  
       CREATE TEMPORARY TABLE temp_auth_by_id(
           auth_id  VARCHAR(32) 
          ,account_id VARCHAR(32) 
          ,resource_id VARCHAR(32)   
       )ENGINE=MEMORY;
      
      DROP TEMPORARY TABLE IF EXISTS temp_auth_user_by_id;  
      CREATE TEMPORARY TABLE temp_auth_user_by_id(
           auth_id  VARCHAR(32) 
          ,user_id VARCHAR(32) 
       )ENGINE=MEMORY;
      
      SET autocommit = 0;
         
        
      OPEN select_auth_for_all;
   
      
      tempSuperoirApproveAllAuthLoop: LOOP  
     
         SET done = 0;  
        FETCH select_auth_for_all INTO temp_auth_id,temp_code;  
       
        IF done = 1 THEN    
           LEAVE tempSuperoirApproveAllAuthLoop;  
        END IF;  
    
      IF (temp_code&2 = 2 ) THEN
    
     INSERT INTO temp_user_sso(auth_id,user_id) 
               SELECT DISTINCT fort_authorization_target_proxy.fort_authorization_id  ,fort_authorization_target_proxy.fort_target_id
               FROM fort_authorization_target_proxy
               WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_id
               AND fort_authorization_target_proxy.fort_target_code = 2; 
     
       END IF;  
       
      IF (temp_code&4 = 4 ) THEN 
         INSERT INTO temp_user_sso(auth_id,user_id)    
                SELECT  DISTINCT t.fort_authorization_id,fort_user_group_user.fort_user_id FROM 
         fort_user_group_user,( SELECT fort_authorization_target_proxy.fort_target_id,fort_authorization_target_proxy.fort_authorization_id FROM fort_authorization_target_proxy  
         WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_id AND  fort_authorization_target_proxy.fort_target_code ='4') t
        WHERE fort_user_group_user.fort_user_group_id IN ( t.fort_target_id) ; 
      
        END IF;    
         IF (temp_code&8 = 8 ) THEN
         
         INSERT INTO temp_sso(auth_id,account_id,resource_id) 
              SELECT fort_authorization_target_proxy.fort_authorization_id,fort_authorization_target_proxy.fort_target_id,fort_authorization_target_proxy.fort_parent_id
                    FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_id 
                    AND fort_authorization_target_proxy.fort_target_code = 8 ;
         END IF;  
         
         IF (temp_code&16 = 16 ) THEN
              INSERT INTO temp_sso(auth_id,account_id,resource_id)    
                    SELECT  fort_authorization_target_proxy.fort_authorization_id,fort_account.fort_account_id, fort_resource.fort_resource_id FROM fort_account,fort_resource,fort_authorization_target_proxy 
            WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_id 
                AND fort_authorization_target_proxy.fort_target_code = 16
            AND fort_authorization_target_proxy.fort_target_id = fort_resource.fort_resource_id 
                    AND fort_resource.fort_resource_id = fort_account.fort_resource_id 
                    AND fort_resource.fort_parent_id IS NULL AND fort_account.fort_is_allow_authorized = 1 ;
       
         INSERT INTO temp_sso(auth_id,account_id,resource_id) 
             SELECT fort_authorization_target_proxy.fort_authorization_id,fort_account.fort_account_id, fort_resource.fort_resource_id FROM fort_account,fort_resource,fort_authorization_target_proxy 
             WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_id  
             AND fort_authorization_target_proxy.fort_target_code = 16
             AND fort_authorization_target_proxy.fort_target_id = fort_resource.fort_resource_id 
                     AND fort_resource.fort_parent_id = fort_account.fort_resource_id 
                     AND fort_resource.fort_parent_id IS NOT NULL AND fort_account.fort_is_allow_authorized = 1 ;
                     
         END IF; 
         
    
         
         IF (temp_code&32 = 32 ) THEN
          
         INSERT INTO temp_sso(auth_id,account_id,resource_id) 
                SELECT fort_authorization_target_proxy.fort_authorization_id,fort_account.fort_account_id, fort_resource.fort_resource_id 
                FROM fort_account,fort_resource,fort_resource_group_resource,fort_authorization_target_proxy
                    WHERE  fort_resource.fort_resource_id = fort_account.fort_resource_id
                    AND fort_resource_group_resource.fort_resource_id = fort_resource.fort_resource_id
                    AND fort_resource.fort_parent_id IS NULL AND fort_resource.fort_resource_state <> 2 
                    AND fort_account.fort_is_allow_authorized = 1
                    AND fort_authorization_target_proxy.fort_authorization_id = temp_auth_id 
                    AND fort_authorization_target_proxy.fort_target_code =  32 
                    AND fort_resource_group_resource.fort_resource_group_id = fort_authorization_target_proxy.fort_target_id;
                    
         INSERT INTO temp_sso(auth_id,account_id,resource_id) 
                SELECT fort_authorization_target_proxy.fort_authorization_id,fort_account.fort_account_id, fort_resource.fort_resource_id 
                FROM fort_account,fort_resource,fort_resource_group_resource,fort_authorization_target_proxy
                    WHERE  fort_resource.fort_parent_id = fort_account.fort_resource_id
                    AND fort_resource_group_resource.fort_resource_id = fort_resource.fort_resource_id
                    AND fort_resource.fort_parent_id IS NOT NULL AND fort_resource.fort_resource_state <> 2 
                    AND fort_account.fort_is_allow_authorized = 1
                    AND fort_authorization_target_proxy.fort_authorization_id = temp_auth_id 
                    AND fort_authorization_target_proxy.fort_target_code =  32
                    AND fort_resource_group_resource.fort_resource_group_id = fort_authorization_target_proxy.fort_target_id;
                    
         END IF;  
          
        END LOOP tempSuperoirApproveAllAuthLoop;  
    
     CLOSE select_auth_for_all;  
     
     
     
     SET done = 0;
     
       OPEN select_auth_for_auth_id;
   
      
      tempApproveOneAuthLoop: LOOP  
     
        SET done = 0;
        FETCH select_auth_for_auth_id INTO temp_auth_check_id,temp_auth_check_code;  
        IF done = 1 THEN   
        LEAVE tempApproveOneAuthLoop;  
        END IF;  
   
     IF (temp_auth_check_code&2 = 2 ) THEN
    
     INSERT INTO temp_auth_user_by_id(auth_id,user_id) 
               SELECT DISTINCT fort_authorization_target_proxy.fort_authorization_id  ,fort_authorization_target_proxy.fort_target_id
               FROM fort_authorization_target_proxy
               WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_check_id
               AND fort_authorization_target_proxy.fort_target_code = 2; 
     
       END IF;  
       
      IF (temp_auth_check_code&4 = 4 ) THEN 
         INSERT INTO temp_auth_user_by_id(auth_id,user_id)    
                SELECT  DISTINCT t.fort_authorization_id,fort_user_group_user.fort_user_id FROM 
         fort_user_group_user,( SELECT fort_authorization_target_proxy.fort_target_id,fort_authorization_target_proxy.fort_authorization_id FROM fort_authorization_target_proxy  
         WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_check_id AND  fort_authorization_target_proxy.fort_target_code ='4') t
        WHERE fort_user_group_user.fort_user_group_id IN ( t.fort_target_id) ; 
      
        END IF;    
        
       
     IF (temp_auth_check_code&8 = 8 ) THEN
         
         INSERT INTO temp_auth_by_id(auth_id,account_id,resource_id) 
         
              SELECT fort_authorization_target_proxy.fort_authorization_id,fort_authorization_target_proxy.fort_target_id,fort_authorization_target_proxy.fort_parent_id
                    FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_check_id 
                    AND fort_authorization_target_proxy.fort_target_code = 8 ;
         END IF;  
       
    IF (temp_auth_check_code&16 = 16 ) THEN
             
              INSERT INTO temp_auth_by_id(auth_id,account_id,resource_id)    
                    SELECT  fort_authorization_target_proxy.fort_authorization_id,fort_account.fort_account_id, fort_resource.fort_resource_id FROM fort_account,fort_resource,fort_authorization_target_proxy 
            WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_check_id 
                AND fort_authorization_target_proxy.fort_target_code = 16
            AND fort_authorization_target_proxy.fort_target_id = fort_resource.fort_resource_id 
                    AND fort_resource.fort_resource_id = fort_account.fort_resource_id 
                    AND fort_resource.fort_parent_id IS NULL AND fort_account.fort_is_allow_authorized = 1 ;
       
         INSERT INTO temp_auth_by_id(auth_id,account_id,resource_id) 
             SELECT fort_authorization_target_proxy.fort_authorization_id,fort_account.fort_account_id, fort_resource.fort_resource_id FROM fort_account,fort_resource,fort_authorization_target_proxy 
             WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_check_id  
             AND fort_authorization_target_proxy.fort_target_code = 16
             AND fort_authorization_target_proxy.fort_target_id = fort_resource.fort_resource_id 
                     AND fort_resource.fort_parent_id = fort_account.fort_resource_id 
                     AND fort_resource.fort_parent_id IS NOT NULL AND fort_account.fort_is_allow_authorized = 1 ;
                     
         END IF; 
         
     IF (temp_auth_check_code&32 = 32 ) THEN
         
         
       INSERT INTO temp_auth_by_id(auth_id,account_id,resource_id) 
                SELECT fort_authorization_target_proxy.fort_authorization_id,fort_account.fort_account_id, fort_resource.fort_resource_id 
                FROM fort_account,fort_resource,fort_resource_group_resource,fort_authorization_target_proxy
                    WHERE  fort_resource.fort_resource_id = fort_account.fort_resource_id
                    AND fort_resource_group_resource.fort_resource_id = fort_resource.fort_resource_id
                    AND fort_resource.fort_parent_id IS NULL AND fort_resource.fort_resource_state <> 2 
                    AND fort_account.fort_is_allow_authorized = 1
                    AND fort_authorization_target_proxy.fort_authorization_id = temp_auth_check_id 
                    AND fort_authorization_target_proxy.fort_target_code =  32 
                    AND fort_resource_group_resource.fort_resource_group_id = fort_authorization_target_proxy.fort_target_id;
                    
         INSERT INTO temp_auth_by_id(auth_id,account_id,resource_id) 
                SELECT fort_authorization_target_proxy.fort_authorization_id,fort_account.fort_account_id, fort_resource.fort_resource_id 
                FROM fort_account,fort_resource,fort_resource_group_resource,fort_authorization_target_proxy
                    WHERE  fort_resource.fort_parent_id = fort_account.fort_resource_id
                    AND fort_resource_group_resource.fort_resource_id = fort_resource.fort_resource_id
                    AND fort_resource.fort_parent_id IS NOT NULL AND fort_resource.fort_resource_state <> 2 
                    AND fort_account.fort_is_allow_authorized = 1
                    AND fort_authorization_target_proxy.fort_authorization_id = temp_auth_check_id 
                    AND fort_authorization_target_proxy.fort_target_code =  32
                    AND fort_resource_group_resource.fort_resource_group_id = fort_authorization_target_proxy.fort_target_id;
                    
         END IF;  
         
        END LOOP tempApproveOneAuthLoop;  
    
     CLOSE select_auth_for_auth_id;  
 
    
    SELECT DISTINCT temp_user_sso.user_id AS approve_id,fort_user.fort_user_account AS approve_account ,
         fort_resource.fort_resource_name  AS approve_name
         FROM temp_sso,temp_user_sso ,temp_auth_by_id,temp_auth_user_by_id,fort_user,fort_account,fort_resource
    WHERE  temp_user_sso.auth_id  = temp_sso.auth_id 
         AND temp_auth_by_id.auth_id  = temp_auth_user_by_id.auth_id
         AND temp_sso.account_id = temp_auth_by_id.account_id
         AND temp_sso.resource_id = temp_auth_by_id.resource_id 
         AND temp_user_sso.user_id = temp_auth_user_by_id.user_id
         AND temp_user_sso.user_id = fort_user.fort_user_id
         AND temp_sso.account_id = fort_account.fort_account_id 
         AND fort_resource.fort_resource_id = fort_account.fort_resource_id;
   
    DROP TABLE temp_sso; 
    
    DROP TABLE temp_auth_by_id; 
     
    DROP TABLE temp_user_sso;
    
    DROP TABLE temp_auth_user_by_id;
    
    SET autocommit = 1;
    
    END$$

DELIMITER ;


DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `checkDoubleApprove`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `checkDoubleApprove`(IN user_id TEXT,IN temp_authorization_id VARCHAR(200))
BEGIN   
      DECLARE done INT DEFAULT -1;  
      DECLARE temp_auth_id VARCHAR(32); 
      DECLARE temp_code INT;   
 
      DECLARE temp_sql_string TEXT; 
  
      DECLARE temp_approve_user_id TEXT; 
            
      
      DECLARE select_auth_for_all CURSOR FOR SELECT fort_authorization.fort_authorization_id,
              fort_authorization.fort_authorization_code  FROM fort_authorization 
               WHERE  fort_authorization.fort_authorization_id <> temp_authorization_id 
               AND fort_authorization.fort_double_is_open = '1';
    
      DECLARE select_auth_for_auth_id CURSOR FOR SELECT DISTINCT fort_authorization.fort_authorization_id,
              fort_authorization.fort_authorization_code  FROM fort_authorization 
          WHERE  fort_authorization.fort_authorization_id = temp_authorization_id;
      
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1;  
     
     
      DROP TEMPORARY TABLE IF EXISTS temp_sso;  
      
      CREATE TEMPORARY TABLE temp_sso(
           auth_id  VARCHAR(32) 
          ,account_id VARCHAR(32) 
          ,resource_id VARCHAR(32)   
       )ENGINE=MEMORY;
       
       DROP TEMPORARY TABLE IF EXISTS temp_auth_by_id;  
       CREATE TEMPORARY TABLE temp_auth_by_id(
           auth_id  VARCHAR(32) 
          ,account_id VARCHAR(32) 
          ,resource_id VARCHAR(32)   
       )ENGINE=MEMORY;
      
      DROP TEMPORARY TABLE IF EXISTS temp_approve_user_id;  
      CREATE TEMPORARY TABLE temp_approve_user_id(
           temp_user_id  VARCHAR(32) 
       )ENGINE=MEMORY;
      
      SET autocommit = 0;
         
        
      OPEN select_auth_for_all;
   
      
      tempDoubleApproveAllAuthLoop: LOOP  
     
          
        FETCH select_auth_for_all INTO temp_auth_id,temp_code;  
       
        IF done = 1 THEN   
           LEAVE tempDoubleApproveAllAuthLoop;  
        END IF;  
    
    
        
         IF (temp_code&8 = 8 ) THEN
         
         INSERT INTO temp_sso(auth_id,account_id,resource_id) 
              SELECT fort_authorization_target_proxy.fort_authorization_id,fort_authorization_target_proxy.fort_target_id,fort_authorization_target_proxy.fort_parent_id
                    FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_id 
                    AND fort_authorization_target_proxy.fort_target_code = 8 ;
         END IF;  
         
         IF (temp_code&16 = 16 ) THEN
              INSERT INTO temp_sso(auth_id,account_id,resource_id)    
                    SELECT  fort_authorization_target_proxy.fort_authorization_id,fort_account.fort_account_id, fort_resource.fort_resource_id FROM fort_account,fort_resource,fort_authorization_target_proxy 
            WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_id 
                AND fort_authorization_target_proxy.fort_target_code = 16
            AND fort_authorization_target_proxy.fort_target_id = fort_resource.fort_resource_id 
                    AND fort_resource.fort_resource_id = fort_account.fort_resource_id 
                    AND fort_resource.fort_parent_id IS NULL AND fort_account.fort_is_allow_authorized = 1 ;
       
         INSERT INTO temp_sso(auth_id,account_id,resource_id) 
             SELECT fort_authorization_target_proxy.fort_authorization_id,fort_account.fort_account_id, fort_resource.fort_resource_id FROM fort_account,fort_resource,fort_authorization_target_proxy 
             WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_id  
             AND fort_authorization_target_proxy.fort_target_code = 16
             AND fort_authorization_target_proxy.fort_target_id = fort_resource.fort_resource_id 
                     AND fort_resource.fort_parent_id = fort_account.fort_resource_id 
                     AND fort_resource.fort_parent_id IS NOT NULL AND fort_account.fort_is_allow_authorized = 1 ;
                     
         END IF; 
         
    
         
         IF (temp_code&32 = 32 ) THEN
          
         INSERT INTO temp_sso(auth_id,account_id,resource_id) 
                SELECT fort_authorization_target_proxy.fort_authorization_id,fort_account.fort_account_id, fort_resource.fort_resource_id 
                FROM fort_account,fort_resource,fort_resource_group_resource,fort_authorization_target_proxy
                    WHERE  fort_resource.fort_resource_id = fort_account.fort_resource_id
                    AND fort_resource_group_resource.fort_resource_id = fort_resource.fort_resource_id
                    AND fort_resource.fort_parent_id IS NULL AND fort_resource.fort_resource_state <> 2 
                    AND fort_account.fort_is_allow_authorized = 1
                    AND fort_authorization_target_proxy.fort_authorization_id = temp_auth_id 
                    AND fort_authorization_target_proxy.fort_target_code =  32 
                    AND fort_resource_group_resource.fort_resource_group_id = fort_authorization_target_proxy.fort_target_id;
                    
         INSERT INTO temp_sso(auth_id,account_id,resource_id) 
                SELECT fort_authorization_target_proxy.fort_authorization_id,fort_account.fort_account_id, fort_resource.fort_resource_id 
                FROM fort_account,fort_resource,fort_resource_group_resource,fort_authorization_target_proxy
                    WHERE  fort_resource.fort_parent_id = fort_account.fort_resource_id
                    AND fort_resource_group_resource.fort_resource_id = fort_resource.fort_resource_id
                    AND fort_resource.fort_parent_id IS NOT NULL AND fort_resource.fort_resource_state <> 2 
                    AND fort_account.fort_is_allow_authorized = 1
                    AND fort_authorization_target_proxy.fort_authorization_id = temp_auth_id 
                    AND fort_authorization_target_proxy.fort_target_code =  32
                    AND fort_resource_group_resource.fort_resource_group_id = fort_authorization_target_proxy.fort_target_id;
                    
         END IF;  
          
        END LOOP tempDoubleApproveAllAuthLoop;  
    
     CLOSE select_auth_for_all;  
     
     
     
     SET done = 0;
     
       OPEN select_auth_for_auth_id;
   
      
      tempDoubleApproveOneAuthLoop: LOOP  
     
          
        FETCH select_auth_for_auth_id INTO temp_auth_id,temp_code;  
        IF done = 1 THEN   
        LEAVE tempDoubleApproveOneAuthLoop;  
        END IF;  
     
        
         IF (temp_code&8 = 8 ) THEN
         
         INSERT INTO temp_auth_by_id(auth_id,account_id,resource_id) 
              SELECT fort_authorization_target_proxy.fort_authorization_id,fort_authorization_target_proxy.fort_target_id,fort_authorization_target_proxy.fort_parent_id
                    FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_id 
                    AND fort_authorization_target_proxy.fort_target_code = 8 ;
         END IF;  
         IF (temp_code&16 = 16 ) THEN
             
              INSERT INTO temp_auth_by_id(auth_id,account_id,resource_id)    
                    SELECT  fort_authorization_target_proxy.fort_authorization_id,fort_account.fort_account_id, fort_resource.fort_resource_id FROM fort_account,fort_resource,fort_authorization_target_proxy 
            WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_id 
                AND fort_authorization_target_proxy.fort_target_code = 16
            AND fort_authorization_target_proxy.fort_target_id = fort_resource.fort_resource_id 
                    AND fort_resource.fort_resource_id = fort_account.fort_resource_id 
                    AND fort_resource.fort_parent_id IS NULL AND fort_account.fort_is_allow_authorized = 1 ;
       
         INSERT INTO temp_auth_by_id(auth_id,account_id,resource_id) 
             SELECT fort_authorization_target_proxy.fort_authorization_id,fort_account.fort_account_id, fort_resource.fort_resource_id FROM fort_account,fort_resource,fort_authorization_target_proxy 
             WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_id  
             AND fort_authorization_target_proxy.fort_target_code = 16
             AND fort_authorization_target_proxy.fort_target_id = fort_resource.fort_resource_id 
                     AND fort_resource.fort_parent_id = fort_account.fort_resource_id 
                     AND fort_resource.fort_parent_id IS NOT NULL AND fort_account.fort_is_allow_authorized = 1 ;
                     
         END IF; 
         
         IF (temp_code&32 = 32 ) THEN
         
         
       INSERT INTO temp_auth_by_id(auth_id,account_id,resource_id) 
                SELECT fort_authorization_target_proxy.fort_authorization_id,fort_account.fort_account_id, fort_resource.fort_resource_id 
                FROM fort_account,fort_resource,fort_resource_group_resource,fort_authorization_target_proxy
                    WHERE  fort_resource.fort_resource_id = fort_account.fort_resource_id
                    AND fort_resource_group_resource.fort_resource_id = fort_resource.fort_resource_id
                    AND fort_resource.fort_parent_id IS NULL AND fort_resource.fort_resource_state <> 2 
                    AND fort_account.fort_is_allow_authorized = 1
                    AND fort_authorization_target_proxy.fort_authorization_id = temp_auth_id 
                    AND fort_authorization_target_proxy.fort_target_code =  32 
                    AND fort_resource_group_resource.fort_resource_group_id = fort_authorization_target_proxy.fort_target_id;
                    
         INSERT INTO temp_auth_by_id(auth_id,account_id,resource_id) 
                SELECT fort_authorization_target_proxy.fort_authorization_id,fort_account.fort_account_id, fort_resource.fort_resource_id 
                FROM fort_account,fort_resource,fort_resource_group_resource,fort_authorization_target_proxy
                    WHERE  fort_resource.fort_parent_id = fort_account.fort_resource_id
                    AND fort_resource_group_resource.fort_resource_id = fort_resource.fort_resource_id
                    AND fort_resource.fort_parent_id IS NOT NULL AND fort_resource.fort_resource_state <> 2 
                    AND fort_account.fort_is_allow_authorized = 1
                    AND fort_authorization_target_proxy.fort_authorization_id = temp_auth_id 
                    AND fort_authorization_target_proxy.fort_target_code =  32
                    AND fort_resource_group_resource.fort_resource_group_id = fort_authorization_target_proxy.fort_target_id;
                    
         END IF;  
         
        END LOOP tempDoubleApproveOneAuthLoop;  
    
     CLOSE select_auth_for_auth_id;  
 
     
     SET @temp_approve_user_id = CONCAT(CONCAT("insert into temp_approve_user_id values('",REPLACE(user_id,',',"'),('")),"')"); 
     PREPARE stmt FROM  @temp_approve_user_id; 
     EXECUTE stmt;      
     DEALLOCATE PREPARE stmt;       
    
     
    
     
    SELECT DISTINCT fort_double_approval.fort_user_id AS fort_user_id,fort_user.fort_user_name,
    fort_authorization.fort_authorization_name
        FROM temp_sso,fort_double_approval ,temp_approve_user_id,temp_auth_by_id,fort_user,fort_authorization
   
   WHERE  fort_double_approval.fort_authorization_id  = temp_sso.auth_id 
    AND fort_double_approval.fort_user_id = temp_approve_user_id.temp_user_id 
    AND temp_sso.account_id = temp_auth_by_id.account_id
    AND temp_sso.resource_id = temp_auth_by_id.resource_id 
    AND fort_double_approval.fort_user_id = fort_user.fort_user_id 
    AND  fort_double_approval.fort_is_candidate = '1' 
    AND fort_authorization.fort_authorization_id = fort_double_approval.fort_authorization_id;
     
   
    DROP TABLE temp_sso; 
    
    DROP TABLE temp_auth_by_id; 
     
    DROP TABLE temp_approve_user_id;
    
    SET autocommit = 1;
    
    END$$

DELIMITER ;


DELIMITER $$

USE `fort`$$

DROP TRIGGER /*!50032 IF EXISTS */ `tri_del_resource_group`$$

CREATE
    /*!50017 DEFINER = 'mysql'@'127.0.0.1' */
    TRIGGER `tri_del_resource_group` BEFORE DELETE ON `fort_resource_group` 
    FOR EACH ROW BEGIN

    DELETE FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_target_id=old.fort_resource_group_id;
    DELETE FROM fort_plan_password_target_proxy WHERE fort_plan_password_target_proxy.fort_target_id=old.fort_resource_group_id;
    DELETE FROM fort_rule_command_target_proxy WHERE fort_rule_command_target_proxy.fort_target_id=old.fort_resource_group_id;

    DELETE FROM fort_rule_time_resource_target_proxy WHERE fort_rule_time_resource_target_proxy.fort_target_id=old.fort_resource_group_id;


END;
$$

DELIMITER ;



DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `selectQueryAuthList`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `selectQueryAuthList`(IN authName VARCHAR(32),IN userId VARCHAR(24),IN query_user_name VARCHAR(70),
  IN query_resource_name VARCHAR(50),IN query_resource_ip VARCHAR(50),IN query_account_name VARCHAR(50) )
BEGIN   
      DECLARE done INT DEFAULT -1;  
     
     
     DECLARE temp_sql_string  TEXT ;
     DECLARE query_user_id VARCHAR(50); 
     DECLARE query_department_id TEXT DEFAULT '%%';
     DECLARE temp_id VARCHAR(32); 
         
      DECLARE cur1 CURSOR FOR SELECT  authorization_id  FROM tempQueryAuthId ;
      
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1; 
       
      DROP TEMPORARY TABLE IF EXISTS tempQueryAuthList;  
    
      CREATE TEMPORARY TABLE tempQueryAuthList(
            display_type VARCHAR(5)
           ,auth_id   VARCHAR(24)  
           ,content TEXT
           
       );
    
     DROP TEMPORARY TABLE IF EXISTS tempQueryAuthId;  
     CREATE TEMPORARY TABLE tempQueryAuthId(
            authorization_id VARCHAR(32)  
       )ENGINE=MEMORY;
         
        
    
      
      SET autocommit = 0;   
        
       SET temp_sql_string = 'insert into tempQueryAuthId(authorization_id) SELECT DISTINCT fort_authorization.fort_authorization_id FROM fort_authorization ' ;
 
       IF ( userId != '' ) THEN 
    
         SELECT fort_department_id INTO query_user_id FROM fort_user WHERE fort_user_id =userId;
     
             SELECT GROUP_CONCAT(DISTINCT(selectDepartmentChildList(query_user_id)) SEPARATOR ",")  INTO query_department_id;
    
        END IF;       
       
     IF ( userId != '' ) THEN 
     
           SET temp_sql_string = CONCAT(temp_sql_string,' WHERE FIND_IN_SET(fort_authorization.fort_department_id , "',query_department_id,'")');
           
      END IF;
      
        
       IF ( authName != '' ) THEN 
       
       IF(userId = '') THEN 
               SET temp_sql_string = CONCAT(temp_sql_string,' where fort_authorization.fort_authorization_name LIKE "%',authName,'%"');
          END IF;
          
           IF(userId != '') THEN 
               SET temp_sql_string = CONCAT(temp_sql_string,' and fort_authorization.fort_authorization_name LIKE "%',authName,'%"');
          END IF;
          
      END IF;
    
     SET @temp_user_sql_string =temp_sql_string; 
     PREPARE stmt FROM  @temp_user_sql_string; 
     EXECUTE stmt;      
     DEALLOCATE PREPARE stmt;   
    
     
    
      OPEN cur1;
      
      myLoop: LOOP  
                 
        SET done = 0 ;
        FETCH cur1 INTO temp_id;  
      
        IF done = 1 THEN   
          
          LEAVE myLoop;  
        END IF;                
          IF ( query_user_name  != '' ) THEN
        
           INSERT tempQueryAuthList(display_type,auth_id,content)
           
           SELECT  '2',fort_authorization_target_proxy.fort_authorization_id, CONCAT(fort_user.fort_user_account,' ( ',fort_user.fort_user_name,' ) ')
           
 
           FROM fort_authorization_target_proxy,fort_user,fort_department WHERE fort_authorization_target_proxy.fort_target_id = fort_user.fort_user_id 
            
           AND fort_authorization_target_proxy.fort_authorization_id = temp_id  AND fort_department.fort_department_id = fort_user.fort_department_id
            
           AND fort_authorization_target_proxy.fort_target_code = 2  AND fort_user.fort_user_state <> 2 
                        
           AND ( fort_user.fort_user_account LIKE CONCAT('%',query_user_name,'%')
                OR  fort_user.fort_user_name LIKE CONCAT('%',query_user_name,'%') ) ;
            
          END IF; 
          
          
         IF ( query_user_name  != '' ) THEN
         
         INSERT tempQueryAuthList(display_type,auth_id,content)   
        
         SELECT  '4' ,fort_authorization_target_proxy.fort_authorization_id, fort_user_group.fort_user_group_name
        
          
          FROM fort_authorization_target_proxy,fort_user_group LEFT JOIN  fort_user_group_user 
          
          ON fort_user_group_user.fort_user_group_id = fort_user_group.fort_user_group_id  
          
          LEFT JOIN fort_user 
          
          ON fort_user.fort_user_id = fort_user_group_user.fort_user_id
         
          WHERE fort_authorization_target_proxy.fort_target_id  = fort_user_group.fort_user_group_id 
         
          AND fort_authorization_target_proxy.fort_authorization_id = temp_id
          
          AND fort_authorization_target_proxy.fort_target_code = 4  
          
          AND ( fort_user.fort_user_account LIKE CONCAT('%',query_user_name,'%')
                OR  fort_user.fort_user_name LIKE CONCAT('%',query_user_name,'%') ) ;
                
         END IF; 
         
         IF ( query_resource_name  != '' || query_resource_ip  != '' || query_account_name  != '' ) THEN
         
           INSERT tempQueryAuthList(display_type,auth_id,content)   
          
            SELECT  '32' ,fort_authorization_target_proxy.fort_authorization_id,fort_resource_group.fort_resource_group_name 
         
             FROM fort_authorization_target_proxy,fort_resource_group LEFT JOIN fort_resource_group_resource  ON 
             
             fort_resource_group_resource.fort_resource_group_id = fort_resource_group.fort_resource_group_id 
             
              LEFT JOIN fort_resource 
              
              ON fort_resource_group_resource.fort_resource_id = fort_resource.fort_resource_id  AND fort_resource.fort_resource_state  <> 2  
              
              LEFT JOIN fort_account
              
              ON fort_resource.fort_resource_id = fort_account.fort_resource_id 
        
             WHERE fort_authorization_target_proxy.fort_target_id = fort_resource_group.fort_resource_group_id 
        
             AND fort_authorization_target_proxy.fort_authorization_id = temp_id  
        
             AND fort_authorization_target_proxy.fort_target_code = 32  
                        
         AND  fort_resource.fort_resource_name LIKE CONCAT('%',query_resource_name,'%')
         AND  fort_resource.fort_resource_ip LIKE CONCAT('%',query_resource_ip,'%')
         AND fort_account.fort_account_name LIKE CONCAT('%',query_account_name,'%')  ;  
         
        
         END IF;  
        
          IF ( query_resource_name  != '' || query_resource_ip  != '' || query_account_name  != ''  ) THEN
       
                  
            INSERT tempQueryAuthList(display_type,auth_id,content)  
             
              SELECT '16' ,fort_authorization_target_proxy.fort_authorization_id , CONCAT(fort_resource.fort_resource_name,'( ',fort_resource.fort_resource_ip,' )') 
         
          
              FROM  fort_authorization_target_proxy,fort_resource LEFT JOIN  fort_account
              ON fort_resource.fort_resource_id = fort_account.fort_resource_id
              
              WHERE  fort_authorization_target_proxy.fort_target_id =  fort_resource.fort_resource_id   
               
              AND  fort_authorization_target_proxy.fort_authorization_id = temp_id 
              
              AND  fort_authorization_target_proxy.fort_target_code = 16  AND fort_resource.fort_resource_state  <> 2 
          AND  fort_resource.fort_resource_name LIKE CONCAT('%',query_resource_name,'%')
          AND  fort_resource.fort_resource_ip LIKE CONCAT('%',query_resource_ip,'%')
          AND fort_account.fort_account_name LIKE CONCAT('%',query_account_name,'%') ;  
               
               
         END IF; 
          
    IF ( query_resource_name  != '' || query_resource_ip  != '' || query_account_name  != '' ) THEN
    
           
            INSERT tempQueryAuthList(display_type,auth_id,content)   
     
              SELECT '8',fort_authorization_target_proxy.fort_authorization_id ,
           
               CONCAT(fort_resource.fort_resource_name,'(',fort_resource.fort_resource_ip,' ) -',fort_account.fort_account_name)
               FROM  fort_authorization_target_proxy,fort_resource,fort_account 
              
               WHERE fort_authorization_target_proxy.fort_target_id = fort_account.fort_account_id 
     
               AND   fort_account.fort_resource_id =  fort_resource.fort_resource_id
                
               AND  fort_authorization_target_proxy.fort_authorization_id = temp_id 
              
               AND  fort_authorization_target_proxy.fort_target_code = 8 
                
               AND fort_resource.fort_resource_state  <> 2 
         
           AND  fort_resource.fort_resource_name LIKE CONCAT('%',query_resource_name,'')
           
               AND  fort_resource.fort_resource_ip LIKE CONCAT('%',query_resource_ip,'')
               
           AND fort_account.fort_account_name LIKE CONCAT('%',query_account_name,'%');
       
       END IF;  
       
       END LOOP myLoop; 
                                           
     CLOSE cur1;  
    
    SELECT DISTINCT * FROM tempQueryAuthList;
      
      DROP TABLE tempQueryAuthList;
    
     DROP TABLE tempQueryAuthId;
     
     SET autocommit = 1;  
     
    END$$

DELIMITER ;



DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `selectAuthList`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `selectAuthList`(IN authName VARCHAR(32),IN userId VARCHAR(24),IN query_user_name VARCHAR(50),
  IN query_resource_name VARCHAR(50),IN query_resource_ip VARCHAR(50),IN query_account_name VARCHAR(50),IN query_resource_type_id VARCHAR(50),IN orderField VARCHAR(32),
   IN limitStart INT,IN limitEnd INT )
BEGIN   
      DECLARE done INT DEFAULT -1;  
      DECLARE temp_user TEXT; 
      DECLARE temp_id VARCHAR(32); 
      DECLARE temp_code INT;   
      DECLARE temp_name VARCHAR(32); 
      DECLARE temp_user_group TEXT;   
      DECLARE temp_resource_group TEXT;   
      DECLARE temp_resource TEXT ;
      DECLARE temp_resource_account TEXT ;
      DECLARE temp_user_id TEXT; 
      DECLARE temp_name_id VARCHAR(32); 
      DECLARE temp_user_group_id TEXT ;   
      DECLARE temp_resource_group_id  TEXT ;   
      DECLARE temp_resource_id  TEXT ;
      DECLARE temp_resource_account_id  TEXT ;
      DECLARE temp_postion VARCHAR(32); 
      DECLARE temp_sql_string  TEXT ;
         
      DECLARE query_user_id VARCHAR(50); 
      DECLARE query_department_id TEXT DEFAULT '%%';
      
      
      DECLARE query_user_name_result TEXT; 
      DECLARE query_resouce_name_result TEXT;
      DECLARE query_resouce_ip_result TEXT;
      DECLARE query_account_name_result TEXT;
      DECLARE query_resouce_type_id_result TEXT;
      
      DECLARE query_account_name_middle TEXT;
      DECLARE query_resource_name_middle TEXT;
      DECLARE query_resource_ip_middle TEXT;
      DECLARE query_resource_type_id_middle TEXT;
      DECLARE query_user_name_middle TEXT;
     
     
      DECLARE temp_sql_query  TEXT ;
      
      
      DECLARE superior_info TEXT DEFAULT '';
      DECLARE superior_task_participant INT;
      DECLARE superior_concurrent_rule INT;
      DECLARE temp_root_task_id VARCHAR(50);
      DECLARE tempChd VARCHAR(100);
      DECLARE sTemp VARCHAR(100);
      DECLARE order_num INT DEFAULT 0;
       
      DECLARE cur1 CURSOR FOR SELECT  authorization_id  FROM tempAuthId ;
      
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1; 
       
      DROP TEMPORARY TABLE IF EXISTS tempAuthList;  
    
      CREATE TEMPORARY TABLE tempAuthList(
            auth_id   VARCHAR(24)  DEFAULT 0
           ,auth_code INT
           ,fort_authorization_name VARCHAR(32)
           ,auth_user TEXT
           ,auth_user_id TEXT
           ,auth_user_group TEXT
           ,auth_user_group_id TEXT
           ,auth_resource_group TEXT 
           ,auth_resource_group_id TEXT 
           ,auth_resource TEXT  
           ,auth_resource_id TEXT    
           ,auth_resource_account TEXT 
           ,auth_resource_account_id TEXT  
           ,auth_resource_name_query TEXT  
           ,auth_resource_ip_query TEXT  
           ,auth_account_name_query TEXT  
           ,auth_user_name_query TEXT  
           ,auth_superior_info TEXT
           ,auth_resource_type_id_query TEXT  
       );
    
     DROP TEMPORARY TABLE IF EXISTS tempAuthId;  
     CREATE TEMPORARY TABLE tempAuthId(
            authorization_id VARCHAR(32)  
       )ENGINE=MEMORY;
         
        
    
      
      SET autocommit = 0;   
        
       SET temp_sql_string = 'insert into tempAuthId(authorization_id) SELECT DISTINCT fort_authorization.fort_authorization_id FROM fort_authorization ' ;
 
       IF ( userId != '' ) THEN 
    
         SELECT fort_department_id INTO query_user_id FROM fort_user WHERE fort_user_id =userId;
     
             SELECT GROUP_CONCAT(DISTINCT(selectDepartmentChildList(query_user_id)) SEPARATOR ",")  INTO query_department_id;
    
        END IF;       
       
     IF ( userId != '' ) THEN 
     
           SET temp_sql_string = CONCAT(temp_sql_string,' WHERE FIND_IN_SET(fort_authorization.fort_department_id , "',query_department_id,'")');
           
      END IF;
      
        
       IF ( authName != '' ) THEN 
       
       IF(userId = '' || userId IS NULL) THEN 
               SET temp_sql_string = CONCAT(temp_sql_string,' where fort_authorization.fort_authorization_name LIKE "%',authName,'%"');
          END IF;
          
           IF(userId != '') THEN 
               SET temp_sql_string = CONCAT(temp_sql_string,' and fort_authorization.fort_authorization_name LIKE "%',authName,'%"');
          END IF;
          
      END IF;
    
     SET @temp_user_sql_string =temp_sql_string; 
     PREPARE stmt FROM  @temp_user_sql_string; 
     EXECUTE stmt;      
     DEALLOCATE PREPARE stmt;   
    
     
    
      OPEN cur1;
      
      myLoop: LOOP  
                 
        SET done = 0 ;
        FETCH cur1 INTO temp_id;  
      
        IF done = 1 THEN   
          
          LEAVE myLoop;  
        END IF;                
          
      SELECT fort_authorization.fort_authorization_name, fort_authorization.fort_authorization_code INTO temp_name, temp_code FROM fort_authorization 
      
          WHERE fort_authorization.fort_authorization_id = temp_id;
         
          INSERT INTO tempAuthList(auth_id,auth_code,fort_authorization_name,auth_user,auth_user_group,auth_resource_group,auth_user_name_query,
          
          auth_resource_name_query,auth_resource_ip_query,auth_account_name_query) 
          
           VALUES (temp_id,NULL,temp_name,NULL,NULL,NULL,'','','',''); 
         
       IF (temp_code&2 = 2 ) THEN
        
        SELECT  GROUP_CONCAT(DISTINCT(CONCAT('userReplace&#160;&#160;',fort_user.fort_user_account,' ( ',fort_user.fort_user_name,' ) ')) SEPARATOR '|') ,
        
                GROUP_CONCAT(DISTINCT(CONCAT('user!#:',fort_user.fort_user_id)) SEPARATOR '|')  ,
                  
                GROUP_CONCAT(DISTINCT(CONCAT(fort_user.fort_user_name,':',fort_user.fort_user_account)) SEPARATOR '|')  
               
                INTO temp_user , temp_user_id,query_user_name_result
            
            FROM fort_authorization_target_proxy,fort_user,fort_department WHERE fort_authorization_target_proxy.fort_target_id = fort_user.fort_user_id 
            
            AND fort_authorization_target_proxy.fort_authorization_id = temp_id  AND fort_department.fort_department_id = fort_user.fort_department_id
            
            AND fort_authorization_target_proxy.fort_target_code = 2  AND fort_user.fort_user_state <> 2 ;   
                
            
            UPDATE tempAuthList SET auth_user = temp_user,auth_user_id = temp_user_id,auth_user_name_query = query_user_name_result  WHERE auth_id = temp_id ;
          END IF; 
          
          SET query_user_name_result = '';
          
         IF (temp_code&4 = 4 ) THEN
        
          SELECT GROUP_CONCAT(DISTINCT(CONCAT('userGroupReplace&#160;&#160;',fort_user_group.fort_user_group_name)) SEPARATOR '|') ,
        
                 GROUP_CONCAT(DISTINCT(CONCAT('userGroup!#:',fort_user_group.fort_user_group_id)) SEPARATOR '|'),
          
                 GROUP_CONCAT(DISTINCT(CONCAT(fort_user.fort_user_account,':',fort_user.fort_user_name)) SEPARATOR '|') 
          
          INTO temp_user_group , temp_user_group_id,query_user_name_result
          
          FROM fort_authorization_target_proxy,fort_user_group LEFT JOIN  fort_user_group_user 
          
          ON fort_user_group_user.fort_user_group_id = fort_user_group.fort_user_group_id  
          
          LEFT JOIN fort_user 
          
          ON fort_user.fort_user_id = fort_user_group_user.fort_user_id
         
          WHERE fort_authorization_target_proxy.fort_target_id  = fort_user_group.fort_user_group_id 
         
          AND fort_authorization_target_proxy.fort_authorization_id = temp_id 
          AND fort_authorization_target_proxy.fort_target_code = 4 ;
            
            
          SELECT auth_user_name_query INTO query_user_name_middle FROM tempAuthList WHERE auth_id = temp_id ;
          
          SET query_user_name_result = CONCAT( IFNULL(query_user_name_result,''),IFNULL(query_user_name_middle,'') );
          UPDATE tempAuthList SET auth_user_group = temp_user_group,auth_user_group_id = temp_user_group_id ,auth_user_name_query = query_user_name_result  
          
          WHERE auth_id = temp_id ;
         END IF; 
         
    
         
         IF (temp_code & 32 = 32 ) THEN
         
             SELECT   GROUP_CONCAT(DISTINCT(CONCAT('resourceGroupReplace&#160;&#160;',fort_resource_group.fort_resource_group_name)) SEPARATOR '|') ,
         
              GROUP_CONCAT(DISTINCT(CONCAT('resourceGroup!#:',fort_resource_group.fort_resource_group_id)) SEPARATOR '|'),
       
                  GROUP_CONCAT(DISTINCT( fort_resource.fort_resource_name ) SEPARATOR '|'), 
           
              GROUP_CONCAT(DISTINCT(fort_resource.fort_resource_ip) SEPARATOR '|'),
               GROUP_CONCAT(DISTINCT(fort_resource.fort_resource_type_id  ) SEPARATOR '|'),
              GROUP_CONCAT(DISTINCT(fort_account.fort_account_name) SEPARATOR '|') 
            
             INTO temp_resource_group , temp_resource_group_id , query_resouce_name_result , query_resouce_ip_result ,
query_resouce_type_id_result , query_account_name_result
                 
             FROM fort_authorization_target_proxy,fort_resource_group LEFT JOIN fort_resource_group_resource  ON 
             
             fort_resource_group_resource.fort_resource_group_id = fort_resource_group.fort_resource_group_id 
             
              LEFT JOIN fort_resource 
              
              ON fort_resource_group_resource.fort_resource_id = fort_resource.fort_resource_id  AND fort_resource.fort_resource_state  <> 2  
              
              LEFT JOIN fort_account
              
              ON fort_resource.fort_resource_id = fort_authorization_target_proxy.fort_parent_id 
        
             WHERE fort_authorization_target_proxy.fort_target_id = fort_resource_group.fort_resource_group_id 
        
             AND fort_authorization_target_proxy.fort_authorization_id = temp_id 
        
             AND fort_authorization_target_proxy.fort_target_code = 32 ;
             
    
             
            UPDATE  tempAuthList SET auth_resource_group = temp_resource_group,auth_resource_group_id = temp_resource_group_id ,
                    auth_resource_name_query = query_resouce_name_result ,auth_resource_ip_query = query_resouce_ip_result ,
  auth_resource_type_id_query = query_resouce_type_id_result , 
 auth_account_name_query = query_account_name_result
           
            WHERE auth_id = temp_id ;
            
       SET query_resouce_name_result = '';
     
       SET query_resouce_ip_result = '';
       SET query_resouce_type_id_result = '';
       SET query_account_name_result = '';
    
         END IF;  
        
          IF (temp_code&16 = 16 ) THEN
       
          SELECT GROUP_CONCAT(DISTINCT(CONCAT('resourceReplace&#160;&#160;',fort_resource.fort_resource_name,'( ',fort_resource.fort_resource_ip,' )')) SEPARATOR '|') ,
         
                 GROUP_CONCAT(DISTINCT(CONCAT('resource!#:',fort_resource.fort_resource_id)) SEPARATOR '|'),
                
                 GROUP_CONCAT(DISTINCT( fort_resource.fort_resource_name ) SEPARATOR '|'), 
           
                 GROUP_CONCAT(DISTINCT(fort_resource.fort_resource_ip) SEPARATOR '|'),
                  GROUP_CONCAT(DISTINCT(fort_resource.fort_resource_type_id) SEPARATOR '|'),
                 GROUP_CONCAT(DISTINCT(fort_account.fort_account_name) SEPARATOR '|')  
                 
              INTO temp_resource , temp_resource_id , query_resouce_name_result , query_resouce_ip_result ,query_resouce_type_id_result, query_account_name_result
             
              FROM  fort_authorization_target_proxy,fort_resource LEFT JOIN  fort_account
               ON fort_resource.fort_resource_id = fort_account.fort_resource_id
              
              WHERE  fort_authorization_target_proxy.fort_target_id =  fort_resource.fort_resource_id   
              
              AND  fort_authorization_target_proxy.fort_authorization_id = temp_id 
             
              AND  fort_authorization_target_proxy.fort_target_code = 16  AND fort_resource.fort_resource_state  <> 2 ;
            
         
                
                      SELECT auth_resource_name_query,auth_resource_ip_query,auth_resource_type_id_query,auth_account_name_query INTO query_resource_name_middle,
                   
                           query_resource_ip_middle , query_resource_type_id_middle,query_account_name_middle
                     
                      FROM tempAuthList WHERE auth_id = temp_id ;
          
          SET query_resouce_name_result = CONCAT( IFNULL(query_resouce_name_result,''), IFNULL(query_resource_name_middle,'') );
          SET query_resouce_ip_result = CONCAT( IFNULL( query_resouce_ip_result,''), IFNULL(query_resource_ip_middle,''));
   SET query_resouce_type_id_result = CONCAT( IFNULL( query_resouce_type_id_result,''), IFNULL(query_resource_type_id_middle,''));
          SET query_account_name_result = CONCAT( IFNULL( query_account_name_result,''),IFNULL( query_account_name_middle,'') );
          
              UPDATE tempAuthList SET auth_resource = temp_resource,auth_resource_id = temp_resource_id ,
                     auth_resource_name_query = query_resouce_name_result ,auth_resource_ip_query = query_resouce_ip_result ,
 auth_resource_type_id_query = query_resouce_type_id_result , 
                     auth_account_name_query = query_account_name_result
             
              WHERE auth_id = temp_id ;
              
         SET query_resouce_name_result = '' , query_resource_name_middle = '';
     
     SET query_resouce_ip_result = '' , query_resource_ip_middle = '';
       SET query_resouce_type_id_result = '' , query_resource_type_id_middle = '';
     SET query_account_name_result = '' ,query_account_name_middle = '' ;
         END IF; 
          
    IF (temp_code&8 = 8 ) THEN
    
           SELECT GROUP_CONCAT(DISTINCT(CONCAT('accountReplace&#160;&#160;',fort_resource.fort_resource_name,'(',fort_resource.fort_resource_ip,' ) -',fort_account.fort_account_name,fort_authorization_target_proxy.`fort_target_id`,'!')) SEPARATOR '|')  ,
           
                  GROUP_CONCAT(DISTINCT(CONCAT('account!#:',fort_account.fort_account_id,fort_authorization_target_proxy.`fort_authorization_target_proxy_id`)) SEPARATOR '|'),
                
                  GROUP_CONCAT(DISTINCT( fort_resource.fort_resource_name ) SEPARATOR '|'), 
           
          GROUP_CONCAT(DISTINCT(fort_resource.fort_resource_ip) SEPARATOR '|'),
          GROUP_CONCAT(DISTINCT(fort_resource.fort_resource_type_id) SEPARATOR '|'), 
          GROUP_CONCAT(DISTINCT(fort_account.fort_account_name) SEPARATOR '|')   
                  
                  INTO temp_resource_account ,temp_resource_account_id , query_resouce_name_result , query_resouce_ip_result 
,query_resouce_type_id_result,query_account_name_result
         
               FROM  fort_authorization_target_proxy,fort_resource,fort_account 
              
               WHERE fort_authorization_target_proxy.fort_target_id = fort_account.fort_account_id 
     
                AND   fort_authorization_target_proxy.fort_parent_id  =  fort_resource.fort_resource_id
                
                AND  fort_authorization_target_proxy.fort_authorization_id = temp_id 
              
                AND  fort_authorization_target_proxy.fort_target_code = 8 
                
                AND fort_resource.fort_resource_state  <> 2 ;
        
          SELECT auth_resource_name_query,auth_resource_ip_query,auth_resource_type_id_query,auth_account_name_query INTO query_resource_name_middle,
                   
                           query_resource_ip_middle ,query_resource_type_id_middle, query_account_name_middle
                     
         FROM tempAuthList WHERE auth_id = temp_id ;
          
         SET query_resouce_name_result = CONCAT( IFNULL(query_resouce_name_result,''), IFNULL(query_resource_name_middle,'') );
     SET query_resouce_ip_result = CONCAT( IFNULL( query_resouce_ip_result,''),IFNULL( query_resource_ip_middle,'') );
   SET query_resouce_type_id_result = CONCAT( IFNULL( query_resouce_type_id_result,''),IFNULL( query_resource_type_id_middle,'') );
     SET query_account_name_result = CONCAT( IFNULL( query_account_name_result,''),IFNULL(query_account_name_middle,'') );
                        
        UPDATE  tempAuthList SET auth_resource_account = temp_resource_account,auth_resource_account_id = temp_resource_account_id , 
                auth_resource_name_query = query_resouce_name_result ,auth_resource_ip_query = query_resouce_ip_result ,
 auth_resource_type_id_query =  query_resouce_type_id_result ,
auth_account_name_query = query_account_name_result
        WHERE auth_id = temp_id ;
       
        SET query_resouce_name_result = '' , query_resource_name_middle = '';
     
    SET query_resouce_ip_result = '' , query_resource_ip_middle = '',query_resouce_type_id_result = '';
     
    SET query_account_name_result = '' ,query_account_name_middle = '' ;
       
       
       END IF;  
       
    SET temp_root_task_id = NULL ,superior_task_participant = NULL,superior_concurrent_rule = NULL ,superior_info = NULL;
           
    SELECT fort_process_task.fort_process_task_id INTO temp_root_task_id FROM  fort_process_task, fort_process ,fort_authorization
              WHERE fort_process_task.fort_process_id = fort_process.fort_process_id
              AND fort_process_task.fort_parent_id IS NULL
              AND fort_authorization.fort_superior_process_id = fort_process.fort_process_id
              AND fort_authorization.fort_authorization_id = temp_id;
  
        IF (temp_root_task_id IS NOT NULL  ) THEN     
    
           SELECT fort_process_task.fort_concurrent_rule,COUNT(DISTINCT fort_task_participant.fort_user_id) 
           
           INTO   superior_concurrent_rule,superior_task_participant
           
           FROM fort_process_task , fort_task_participant 
           
           WHERE fort_process_task.fort_process_task_id = fort_task_participant.fort_process_task_id
        
           AND fort_process_task.fort_process_task_id = temp_root_task_id;
        
          IF (superior_task_participant IS NULL  ) THEN 
          
        SET superior_task_participant = 0;  
          
          END IF;
          
         IF (superior_concurrent_rule IS NULL  ) THEN 
          
                SET superior_concurrent_rule = 0;             
          
         END IF;
          SET superior_info = CONCAT('0orderNum:',superior_task_participant,':',superior_concurrent_rule);
          SET tempChd = temp_root_task_id ;
          SET sTemp ='';
    
          WHILE tempChd IS NOT NULL DO 
             
             SET sTemp = CONCAT(sTemp,',',tempChd);
            
             SELECT GROUP_CONCAT(fort_process_task_id) INTO tempChd FROM fort_process_task WHERE FIND_IN_SET(fort_parent_id,tempChd)>0; 
            
             SET order_num =order_num+1;
             
             SELECT fort_process_task.fort_concurrent_rule,COUNT(DISTINCT fort_task_participant.fort_user_id) 
                      
                        INTO  superior_concurrent_rule,superior_task_participant
           
                     FROM fort_process_task , fort_task_participant 
           
                     WHERE fort_process_task.fort_process_task_id = fort_task_participant.fort_process_task_id
             
                     AND fort_process_task.fort_process_task_id = tempChd;
                     
                      IF (superior_task_participant IS NULL  ) THEN 
           
                      SET superior_task_participant =0; 
          
                      END IF;
          
                    IF (superior_concurrent_rule IS NULL  ) THEN 
                
                            SET superior_concurrent_rule = 0;             
          
                    END IF;
           SET superior_info = CONCAT(superior_info,'|',order_num,'orderNum:',superior_task_participant,':',superior_concurrent_rule);   
         
         END WHILE; 
         
       END IF;  
       UPDATE  tempAuthList SET auth_superior_info = superior_info WHERE auth_id = temp_id ;
     
       END LOOP myLoop;                                     
     CLOSE cur1;  
       
     SET temp_sql_query = ' SELECT tempAuthList.auth_id,tempAuthList.fort_authorization_name AS auth_name ,tempAuthList.auth_user ,tempAuthList.auth_user_group ,
             
             tempAuthList.auth_resource_group,tempAuthList.auth_resource,tempAuthList.auth_resource_account,tempAuthList.auth_user_id,
             
             tempAuthList.auth_user_group_id,tempAuthList.auth_resource_group_id,tempAuthList.auth_resource_id,tempAuthList.auth_resource_account_id ,auth_superior_info 
             
             FROM  tempAuthList 
             
             WHERE tempAuthList.auth_id <> 0' ;
 
       IF ( query_user_name  != '' ) THEN 
          
            SET temp_sql_query = CONCAT(temp_sql_query,' AND  auth_user_name_query LIKE "%',query_user_name,'%" ');
      
        END IF;       
       
      IF ( query_resource_name  != '' ) THEN 
      
            SET temp_sql_query = CONCAT(temp_sql_query,' AND  auth_resource_name_query LIKE "%',query_resource_name,'%" ');
    
      END IF; 
      
      IF ( query_resource_ip  != '' ) THEN 
      
            SET temp_sql_query = CONCAT(temp_sql_query,' AND  auth_resource_ip_query LIKE "%',query_resource_ip,'%" ');
    
      END IF; 
      
      IF ( query_account_name  != '' ) THEN 
      
            SET temp_sql_query = CONCAT(temp_sql_query,' AND  auth_account_name_query LIKE "%',query_account_name,'%" ');
    
      END IF; 
  IF ( query_resource_type_id  != '' ) THEN 
      
            SET temp_sql_query = CONCAT(temp_sql_query,' AND  FIND_IN_SET(auth_resource_type_id_query,selectResourceTypeChildList(',query_resource_type_id,')) ');
    
      END IF; 
      
      
     SELECT POSITION('asc' IN orderField) INTO temp_postion;    
    
     IF ( temp_postion > 0) THEN
            
          SET temp_sql_query = CONCAT(temp_sql_query,' ORDER BY tempAuthList.fort_authorization_name ASC  ');
          
    ELSE 
    
         SET temp_sql_query = CONCAT(temp_sql_query,' ORDER BY tempAuthList.fort_authorization_name DESC  ');
         
      END IF; 
      
     IF ( limitStart IS NOT NULL  && limitEnd IS NOT NULL  ) THEN 
           SET temp_sql_query = CONCAT(temp_sql_query,'  LIMIT ',limitStart,' , ',limitEnd);
      END IF;
      
      
     SET @temp_user_sql_string =temp_sql_query; 
     PREPARE stmt FROM  @temp_user_sql_string; 
     EXECUTE stmt;      
     DEALLOCATE PREPARE stmt;       
    
      
      DROP TABLE tempAuthList;
    
     DROP TABLE tempAuthId;
     
     SET autocommit = 1;  
     
    END$$

DELIMITER ;


DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `selectAuthListCount`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `selectAuthListCount`(IN authName VARCHAR(32),IN userId VARCHAR(24),IN query_user_name VARCHAR(50),
  IN query_resource_name VARCHAR(50),IN query_resource_ip VARCHAR(50),IN query_account_name VARCHAR(50),IN query_resource_type_id VARCHAR(50),IN orderField VARCHAR(32),
   IN limitStart INT,IN limitEnd INT )
BEGIN   
      DECLARE done INT DEFAULT -1;  
      DECLARE temp_user TEXT; 
      DECLARE temp_id VARCHAR(32); 
      DECLARE temp_code INT;   
      DECLARE temp_name VARCHAR(32); 
      DECLARE temp_user_group TEXT;   
      DECLARE temp_resource_group TEXT;   
      DECLARE temp_resource TEXT ;
      DECLARE temp_resource_account TEXT ;
      DECLARE temp_user_id TEXT; 
      DECLARE temp_name_id VARCHAR(32); 
      DECLARE temp_user_group_id TEXT ;   
      DECLARE temp_resource_group_id  TEXT ;   
      DECLARE temp_resource_id  TEXT ;
      DECLARE temp_resource_account_id  TEXT ;
      DECLARE temp_postion VARCHAR(32); 
      DECLARE temp_sql_string  TEXT ;
         
      DECLARE query_user_id VARCHAR(30); 
      DECLARE query_department_id TEXT DEFAULT '%%';
      
      
      DECLARE query_user_name_result TEXT; 
      DECLARE query_resouce_name_result TEXT;
      DECLARE query_resouce_ip_result TEXT;
      DECLARE query_account_name_result TEXT;
      DECLARE query_resouce_type_id_result TEXT;
      
      
      DECLARE query_account_name_middle TEXT;
      DECLARE query_resource_name_middle TEXT;
      DECLARE query_resource_ip_middle TEXT;
      DECLARE query_resource_type_id_middle TEXT;
      DECLARE query_user_name_middle TEXT;
     
     
      DECLARE temp_sql_query  TEXT ;
      
      
      DECLARE superior_info TEXT DEFAULT '';
      DECLARE superior_task_participant INT;
      DECLARE superior_concurrent_rule INT;
      DECLARE temp_root_task_id VARCHAR(50);
      DECLARE tempChd VARCHAR(100);
      DECLARE sTemp VARCHAR(100);
      DECLARE order_num INT DEFAULT 0;
       
      DECLARE cur1 CURSOR FOR SELECT  authorization_id  FROM tempAuthId ;
      
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1; 
       
      DROP TEMPORARY TABLE IF EXISTS tempAuthList;  
    
      CREATE TEMPORARY TABLE tempAuthList(
            auth_id   VARCHAR(24)  DEFAULT 0
           ,auth_code INT
           ,fort_authorization_name VARCHAR(32)
           ,auth_user TEXT
           ,auth_user_id TEXT
           ,auth_user_group TEXT
           ,auth_user_group_id TEXT
           ,auth_resource_group TEXT 
           ,auth_resource_group_id TEXT 
           ,auth_resource TEXT  
           ,auth_resource_id TEXT    
           ,auth_resource_account TEXT 
           ,auth_resource_account_id TEXT  
           ,auth_resource_name_query TEXT  
           ,auth_resource_ip_query TEXT  
           ,auth_account_name_query TEXT  
           ,auth_user_name_query TEXT  
           ,auth_superior_info TEXT
           ,auth_resource_type_id_query TEXT  
       );
    
     DROP TEMPORARY TABLE IF EXISTS tempAuthId;  
     CREATE TEMPORARY TABLE tempAuthId(
            authorization_id VARCHAR(32)  
       )ENGINE=MEMORY;
         
        
    
      
      SET autocommit = 0;   
        
       SET temp_sql_string = 'insert into tempAuthId(authorization_id) SELECT DISTINCT fort_authorization.fort_authorization_id FROM fort_authorization ' ;
 
       IF ( userId != '' ) THEN 
    
         SELECT fort_department_id INTO query_user_id FROM fort_user WHERE fort_user_id =userId;
     
             SELECT GROUP_CONCAT(DISTINCT(selectDepartmentChildList(query_user_id)) SEPARATOR ",")  INTO query_department_id;
    
        END IF;       
       
     IF ( userId != '' ) THEN 
     
           SET temp_sql_string = CONCAT(temp_sql_string,' WHERE FIND_IN_SET(fort_authorization.fort_department_id , "',query_department_id,'")');
           
      END IF;
      
        
       IF ( authName != '' ) THEN 
       
       IF(userId = '' || userId IS NULL) THEN 
               SET temp_sql_string = CONCAT(temp_sql_string,' where fort_authorization.fort_authorization_name LIKE "%',authName,'%"');
          END IF;
          
           IF(userId != '') THEN 
               SET temp_sql_string = CONCAT(temp_sql_string,' and fort_authorization.fort_authorization_name LIKE "%',authName,'%"');
          END IF;
          
      END IF;
    
     SET @temp_user_sql_string =temp_sql_string; 
     PREPARE stmt FROM  @temp_user_sql_string; 
     EXECUTE stmt;      
     DEALLOCATE PREPARE stmt;   
    
     
    
      OPEN cur1;
      
      myLoop: LOOP  
                 
        SET done = 0 ;
        FETCH cur1 INTO temp_id;  
      
        IF done = 1 THEN   
          
          LEAVE myLoop;  
        END IF;                
          
      SELECT fort_authorization.fort_authorization_name, fort_authorization.fort_authorization_code INTO temp_name, temp_code FROM fort_authorization 
      
          WHERE fort_authorization.fort_authorization_id = temp_id;
         
          INSERT INTO tempAuthList(auth_id,auth_code,fort_authorization_name,auth_user,auth_user_group,auth_resource_group,auth_user_name_query,
          
          auth_resource_name_query,auth_resource_ip_query,auth_account_name_query) 
          
           VALUES (temp_id,NULL,temp_name,NULL,NULL,NULL,'','','',''); 
         
          IF (temp_code&2 = 2 ) THEN
        
        SELECT  GROUP_CONCAT(DISTINCT(CONCAT('userReplace&#160;&#160;',fort_user.fort_user_account,' ( ',fort_user.fort_user_name,' ) ')) SEPARATOR '|') ,
        
                GROUP_CONCAT(DISTINCT(CONCAT('user!#:',fort_user.fort_user_id)) SEPARATOR '|')  ,
                  
                GROUP_CONCAT(DISTINCT(CONCAT(fort_user.fort_user_name,':',fort_user.fort_user_account)) SEPARATOR '|')  
               
                INTO temp_user , temp_user_id,query_user_name_result
            
            FROM fort_authorization_target_proxy,fort_user,fort_department WHERE fort_authorization_target_proxy.fort_target_id = fort_user.fort_user_id 
            
            AND fort_authorization_target_proxy.fort_authorization_id = temp_id  AND fort_department.fort_department_id = fort_user.fort_department_id
            
            AND fort_authorization_target_proxy.fort_target_code = 2  AND fort_user.fort_user_state <> 2 ;   
                
            
            UPDATE tempAuthList SET auth_user = temp_user,auth_user_id = temp_user_id,auth_user_name_query = query_user_name_result  WHERE auth_id = temp_id ;
          END IF; 
          
          SET query_user_name_result = '';
          
         IF (temp_code&4 = 4 ) THEN
        
          SELECT GROUP_CONCAT(DISTINCT(CONCAT('userGroupReplace&#160;&#160;',fort_user_group.fort_user_group_name)) SEPARATOR '|') ,
        
                 GROUP_CONCAT(DISTINCT(CONCAT('userGroup!#:',fort_user_group.fort_user_group_id)) SEPARATOR '|'),
          
                 GROUP_CONCAT(DISTINCT(CONCAT(fort_user.fort_user_account,':',fort_user.fort_user_name)) SEPARATOR '|') 
          
          INTO temp_user_group , temp_user_group_id,query_user_name_result
          
          FROM fort_authorization_target_proxy,fort_user_group LEFT JOIN  fort_user_group_user 
          
          ON fort_user_group_user.fort_user_group_id = fort_user_group.fort_user_group_id  
          
          LEFT JOIN fort_user 
          
          ON fort_user.fort_user_id = fort_user_group_user.fort_user_id
         
          WHERE fort_authorization_target_proxy.fort_target_id  = fort_user_group.fort_user_group_id 
         
          AND fort_authorization_target_proxy.fort_authorization_id = temp_id 
          AND fort_authorization_target_proxy.fort_target_code = 4 ;
            
            
          SELECT auth_user_name_query INTO query_user_name_middle FROM tempAuthList WHERE auth_id = temp_id ;
          
          SET query_user_name_result = CONCAT( IFNULL(query_user_name_result,''),IFNULL(query_user_name_middle,'') );
            
          UPDATE tempAuthList SET auth_user_group = temp_user_group,auth_user_group_id = temp_user_group_id ,auth_user_name_query = query_user_name_result  
          
          WHERE auth_id = temp_id ;
         END IF; 
         
         IF (temp_code & 32 = 32 ) THEN
         
             SELECT   GROUP_CONCAT(DISTINCT(CONCAT('resourceGroupReplace&#160;&#160;',fort_resource_group.fort_resource_group_name)) SEPARATOR '|') ,
         
              GROUP_CONCAT(DISTINCT(CONCAT('resourceGroup!#:',fort_resource_group.fort_resource_group_id)) SEPARATOR '|'),
       
                  GROUP_CONCAT(DISTINCT( fort_resource.fort_resource_name ) SEPARATOR '|'), 
           
              GROUP_CONCAT(DISTINCT(fort_resource.fort_resource_ip) SEPARATOR '|'),
              
              GROUP_CONCAT(DISTINCT(fort_resource.fort_resource_type_id  ) SEPARATOR '|'),
                
              GROUP_CONCAT(DISTINCT(fort_account.fort_account_name) SEPARATOR '|') 
            
             INTO temp_resource_group , temp_resource_group_id , query_resouce_name_result , query_resouce_ip_result ,
            query_resouce_type_id_result , query_account_name_result
                 
             FROM fort_authorization_target_proxy,fort_resource_group LEFT JOIN fort_resource_group_resource  ON 
             
             fort_resource_group_resource.fort_resource_group_id = fort_resource_group.fort_resource_group_id 
             
              LEFT JOIN fort_resource 
              
              ON fort_resource_group_resource.fort_resource_id = fort_resource.fort_resource_id  AND fort_resource.fort_resource_state  <> 2  
              
              LEFT JOIN fort_account
              
              ON fort_resource.fort_resource_id = fort_account.fort_resource_id 
        
             WHERE fort_authorization_target_proxy.fort_target_id = fort_resource_group.fort_resource_group_id 
        
             AND fort_authorization_target_proxy.fort_authorization_id = temp_id 
        
             AND fort_authorization_target_proxy.fort_target_code = 32 ;
             
    
             
            UPDATE  tempAuthList SET auth_resource_group = temp_resource_group,auth_resource_group_id = temp_resource_group_id ,
                    auth_resource_name_query = query_resouce_name_result ,auth_resource_ip_query = query_resouce_ip_result ,
                auth_resource_type_id_query = query_resouce_type_id_result ,   auth_account_name_query = query_account_name_result
           
            WHERE auth_id = temp_id ;
            
       SET query_resouce_name_result = '';
     
       SET query_resouce_ip_result = '';
       
        SET query_resouce_type_id_result = '';
     
       SET query_account_name_result = '';
    
         END IF;  
        
          IF (temp_code&16 = 16 ) THEN
       
          SELECT GROUP_CONCAT(DISTINCT(CONCAT('resourceReplace&#160;&#160;',fort_resource.fort_resource_name,'( ',fort_resource.fort_resource_ip,' )')) SEPARATOR '|') ,
         
                 GROUP_CONCAT(DISTINCT(CONCAT('resource!#:',fort_resource.fort_resource_id)) SEPARATOR '|'),
                
                 GROUP_CONCAT(DISTINCT( fort_resource.fort_resource_name ) SEPARATOR '|'), 
           
                 GROUP_CONCAT(DISTINCT(fort_resource.fort_resource_ip) SEPARATOR '|'),
                 
                 GROUP_CONCAT(DISTINCT(fort_resource.fort_resource_type_id) SEPARATOR '|'),
               
                 GROUP_CONCAT(DISTINCT(fort_account.fort_account_name) SEPARATOR '|')  
                 
              INTO temp_resource , temp_resource_id , query_resouce_name_result , query_resouce_ip_result ,query_resouce_type_id_result
              , query_account_name_result
             
              FROM  fort_authorization_target_proxy,fort_resource LEFT JOIN  fort_account
               ON fort_resource.fort_resource_id = fort_account.fort_resource_id
              
              WHERE  fort_authorization_target_proxy.fort_target_id =  fort_resource.fort_resource_id   
              
              AND  fort_authorization_target_proxy.fort_authorization_id = temp_id 
             
              AND  fort_authorization_target_proxy.fort_target_code = 16  AND fort_resource.fort_resource_state  <> 2 ;
            
         
                
                      SELECT auth_resource_name_query,auth_resource_ip_query,auth_resource_type_id_query
                      ,auth_account_name_query INTO query_resource_name_middle,
                   
                           query_resource_ip_middle ,query_resource_type_id_middle, query_account_name_middle
                     
                      FROM tempAuthList WHERE auth_id = temp_id ;
          
           SET query_resouce_name_result = CONCAT( IFNULL(query_resouce_name_result,''), IFNULL(query_resource_name_middle,'') );
          SET query_resouce_ip_result = CONCAT( IFNULL( query_resouce_ip_result,''), IFNULL(query_resource_ip_middle,''));
          
          SET query_resouce_type_id_result = CONCAT( IFNULL( query_resouce_type_id_result,''), IFNULL(query_resource_type_id_middle,''));
          SET query_account_name_result = CONCAT( IFNULL( query_account_name_result,''),IFNULL( query_account_name_middle,'') );
          
              UPDATE tempAuthList SET auth_resource = temp_resource,auth_resource_id = temp_resource_id ,
                     auth_resource_name_query = query_resouce_name_result ,auth_resource_ip_query = query_resouce_ip_result ,
                    auth_resource_type_id_query = query_resouce_type_id_result , auth_account_name_query = query_account_name_result
             
              WHERE auth_id = temp_id ;
              
         SET query_resouce_name_result = '' , query_resource_name_middle = '';
     
     SET query_resouce_ip_result = '' , query_resource_ip_middle = '';
     
      SET query_resouce_type_id_result = '' , query_resource_type_id_middle = '';
     
     SET query_account_name_result = '' ,query_account_name_middle = '' ;
         END IF; 
          
    IF (temp_code&8 = 8 ) THEN
    
           SELECT GROUP_CONCAT(DISTINCT(CONCAT('accountReplace&#160;&#160;',fort_resource.fort_resource_name,'(',fort_resource.fort_resource_ip,' ) -',fort_account.fort_account_name)) SEPARATOR '|')  ,
           
                  GROUP_CONCAT(DISTINCT(CONCAT('account!#:',fort_account.fort_account_id)) SEPARATOR '|'),
                
                  GROUP_CONCAT(DISTINCT( fort_resource.fort_resource_name ) SEPARATOR '|'), 
           
          GROUP_CONCAT(DISTINCT(fort_resource.fort_resource_ip) SEPARATOR '|'),
         
          GROUP_CONCAT(DISTINCT(fort_resource.fort_resource_type_id) SEPARATOR '|'),
               
          GROUP_CONCAT(DISTINCT(fort_account.fort_account_name) SEPARATOR '|')   
                  
                  INTO temp_resource_account ,temp_resource_account_id , query_resouce_name_result , query_resouce_ip_result 
                  ,query_resouce_type_id_result, query_account_name_result
         
               FROM  fort_authorization_target_proxy,fort_resource,fort_account 
              
               WHERE fort_authorization_target_proxy.fort_target_id = fort_account.fort_account_id 
     
                AND   fort_authorization_target_proxy.fort_parent_id =  fort_resource.fort_resource_id
                
                AND  fort_authorization_target_proxy.fort_authorization_id = temp_id 
              
                AND  fort_authorization_target_proxy.fort_target_code = 8 
                
                AND fort_resource.fort_resource_state  <> 2 ;
        
          SELECT auth_resource_name_query,auth_resource_ip_query,auth_resource_type_id_query,auth_account_name_query 
          INTO query_resource_name_middle,
                   
                           query_resource_ip_middle ,query_resource_type_id_middle, query_account_name_middle
                     
         FROM tempAuthList WHERE auth_id = temp_id ;
          
     SET query_resouce_name_result = CONCAT( IFNULL(query_resouce_name_result,''), IFNULL(query_resource_name_middle,'') );
     SET query_resouce_ip_result = CONCAT( IFNULL( query_resouce_ip_result,''),IFNULL( query_resource_ip_middle,'') );
     SET query_resouce_type_id_result = CONCAT( IFNULL( query_resouce_type_id_result,''),IFNULL( query_resource_type_id_middle,'') );
     SET query_account_name_result = CONCAT( IFNULL( query_account_name_result,''),IFNULL(query_account_name_middle,'') );
                        
        UPDATE  tempAuthList SET auth_resource_account = temp_resource_account,auth_resource_account_id = temp_resource_account_id , 
                auth_resource_name_query = query_resouce_name_result ,auth_resource_ip_query = query_resouce_ip_result ,
              auth_resource_type_id_query =  query_resouce_type_id_result ,  auth_account_name_query = query_account_name_result
        WHERE auth_id = temp_id ;
       
        SET query_resouce_name_result = '' , query_resource_name_middle = '';
     
    SET query_resouce_ip_result = '' , query_resource_ip_middle = '', query_resouce_type_id_result = '';
     
    SET query_account_name_result = '' ,query_account_name_middle = '' ;
       
       
       END IF;  
       
    SET temp_root_task_id = NULL ,superior_task_participant = NULL,superior_concurrent_rule = NULL ,superior_info = NULL;
           
    SELECT fort_process_task.fort_process_task_id INTO temp_root_task_id FROM  fort_process_task, fort_process ,fort_authorization
              WHERE fort_process_task.fort_process_id = fort_process.fort_process_id
              AND fort_process_task.fort_parent_id IS NULL
              AND fort_authorization.fort_superior_process_id = fort_process.fort_process_id
              AND fort_authorization.fort_authorization_id = temp_id;
  
        IF (temp_root_task_id IS NOT NULL  ) THEN     
    
           SELECT fort_process_task.fort_concurrent_rule,COUNT(DISTINCT fort_task_participant.fort_user_id) 
           
           INTO   superior_concurrent_rule,superior_task_participant
           
           FROM fort_process_task , fort_task_participant 
           
           WHERE fort_process_task.fort_process_task_id = fort_task_participant.fort_process_task_id
        
           AND fort_process_task.fort_process_task_id = temp_root_task_id;
        
          IF (superior_task_participant IS NULL  ) THEN 
          
        SET superior_task_participant = 0;  
          
          END IF;
          
         IF (superior_concurrent_rule IS NULL  ) THEN 
          
                SET superior_concurrent_rule = 0;             
          
         END IF;
          SET superior_info = CONCAT('0orderNum:',superior_task_participant,':',superior_concurrent_rule);
          SET tempChd = temp_root_task_id ;
          SET sTemp ='';
    
          WHILE tempChd IS NOT NULL DO 
             
             SET sTemp = CONCAT(sTemp,',',tempChd);
            
             SELECT GROUP_CONCAT(fort_process_task_id) INTO tempChd FROM fort_process_task WHERE FIND_IN_SET(fort_parent_id,tempChd)>0; 
            
             SET order_num =order_num+1;
             
             SELECT fort_process_task.fort_concurrent_rule,COUNT(DISTINCT fort_task_participant.fort_user_id) 
                      
                        INTO  superior_concurrent_rule,superior_task_participant
           
                     FROM fort_process_task , fort_task_participant 
           
                     WHERE fort_process_task.fort_process_task_id = fort_task_participant.fort_process_task_id
             
                     AND fort_process_task.fort_process_task_id = tempChd;
                     
                      IF (superior_task_participant IS NULL  ) THEN 
           
                      SET superior_task_participant =0; 
          
                      END IF;
          
                    IF (superior_concurrent_rule IS NULL  ) THEN 
                
                            SET superior_concurrent_rule = 0;             
          
                    END IF;
           SET superior_info = CONCAT(superior_info,'|',order_num,'orderNum:',superior_task_participant,':',superior_concurrent_rule);   
         
         END WHILE; 
         
       END IF;  
       UPDATE  tempAuthList SET auth_superior_info = superior_info WHERE auth_id = temp_id ;
     
       END LOOP myLoop;                                     
     CLOSE cur1;  
    
     SET temp_sql_query = ' SELECT count( DISTINCT tempAuthList.auth_id )
             
             FROM  tempAuthList 
             
             WHERE tempAuthList.auth_id <> 0' ;
 
       IF ( query_user_name  != '' ) THEN 
          
            SET temp_sql_query = CONCAT(temp_sql_query,' AND  auth_user_name_query LIKE "%',query_user_name,'%" ');
      
        END IF;       
       
      IF ( query_resource_name  != '' ) THEN 
      
            SET temp_sql_query = CONCAT(temp_sql_query,' AND  auth_resource_name_query LIKE "%',query_resource_name,'%" ');
    
      END IF; 
      
      IF ( query_resource_ip  != '' ) THEN 
      
            SET temp_sql_query = CONCAT(temp_sql_query,' AND  auth_resource_ip_query LIKE "%',query_resource_ip,'%" ');
    
      END IF; 
      
      IF ( query_account_name  != '' ) THEN 
      
            SET temp_sql_query = CONCAT(temp_sql_query,' AND  auth_account_name_query LIKE "%',query_account_name,'%" ');
    
      END IF; 
      
       IF ( query_resource_type_id  != '' ) THEN 
      
            SET temp_sql_query = CONCAT(temp_sql_query,' AND  FIND_IN_SET(auth_resource_type_id_query,selectResourceTypeChildList(',query_resource_type_id,')) ');
    
      END IF; 
      
 
     SET @temp_user_sql_string =temp_sql_query; 
     PREPARE stmt FROM  @temp_user_sql_string; 
     EXECUTE stmt;      
     DEALLOCATE PREPARE stmt;       
    
      
      DROP TABLE tempAuthList;
    
     DROP TABLE tempAuthId;
     
     SET autocommit = 1;  
     
    END$$

DELIMITER ;



DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `selectRuleCommandByCommand`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `selectRuleCommandByCommand`(IN userId VARCHAR(32),IN accountId VARCHAR(32),IN commandValue VARCHAR(256))
BEGIN   
    
     DECLARE rule_while_id VARCHAR(32); 
     DECLARE rule_while_into_id VARCHAR(32);
     DECLARE order_num INT DEFAULT 0 ;
     
     DECLARE temp_rule_command_id VARCHAR(32); 
     
    DROP TEMPORARY TABLE IF EXISTS temp_rule_command_order; 
    CREATE TEMPORARY TABLE temp_rule_command_order(
            rule_command_order_id VARCHAR(50),
            rule_command_order_num INT
       )ENGINE=MEMORY;  
       
       DROP TEMPORARY TABLE IF EXISTS temp_rule_command;    
    CREATE TEMPORARY TABLE temp_rule_command(
            rule_command_id VARCHAR(30),
            rule_command_order INT 
       )ENGINE=MEMORY;  
      
    SET autocommit = 0;
    
     SELECT  fort_rule_command.fort_rule_command_id INTO rule_while_into_id  FROM  fort_rule_command  WHERE fort_rule_command.fort_prior_id IS NULL;
         
          INSERT INTO  temp_rule_command_order(rule_command_order_id,rule_command_order_num)  VALUE (rule_while_into_id,0);
  
     leave_rule_while : WHILE rule_while_into_id IS NOT NULL DO         
               
              
         SET rule_while_id =rule_while_into_id;
         
         SET rule_while_into_id = NULL;
         SELECT fort_rule_command.fort_rule_command_id INTO rule_while_into_id FROM fort_rule_command WHERE fort_rule_command.fort_prior_id = rule_while_id;  
          IF( rule_while_into_id IS  NULL ) THEN
                LEAVE leave_rule_while;
             
             END IF;
         SET order_num =order_num+1;
         
         INSERT INTO  temp_rule_command_order(rule_command_order_id,rule_command_order_num)  VALUE (rule_while_into_id,order_num);
        END WHILE; 
        
    
    INSERT INTO  temp_rule_command(rule_command_id,rule_command_order) 
        SELECT DISTINCT a.fort_rule_command_id,temp_rule_command_order.rule_command_order_num FROM
            (SELECT fort_rule_command_target_proxy.fort_rule_command_id FROM fort_rule_command_target_proxy WHERE fort_rule_command_target_proxy.fort_target_code='8' AND fort_rule_command_target_proxy.fort_target_id = accountId
               
             UNION ALL
             SELECT fort_rule_command_target_proxy.fort_rule_command_id FROM fort_rule_command_target_proxy WHERE fort_rule_command_target_proxy.fort_target_code='16' AND fort_rule_command_target_proxy.fort_target_id
            IN(SELECT fort_account.fort_resource_id FROM fort_account WHERE fort_account.fort_account_id = accountId)
               
               UNION ALL
            SELECT  fort_rule_command_target_proxy.fort_rule_command_id FROM fort_rule_command_target_proxy WHERE fort_rule_command_target_proxy.fort_target_code='32' AND fort_rule_command_target_proxy.fort_target_id
             IN(SELECT fort_resource_group_resource.fort_resource_group_id FROM fort_resource_group_resource WHERE fort_resource_group_resource.fort_resource_id IN(
               SELECT fort_account.fort_resource_id FROM fort_account WHERE fort_account.fort_account_id = accountId )  )     
           ) a,
         (SELECT fort_rule_command_target_proxy.fort_rule_command_id  FROM fort_rule_command_target_proxy WHERE fort_rule_command_target_proxy.fort_target_code='2' AND fort_rule_command_target_proxy.fort_target_id = userId       
       
             UNION ALL
          SELECT fort_rule_command_target_proxy.fort_rule_command_id  FROM fort_rule_command_target_proxy WHERE fort_rule_command_target_proxy.fort_target_code='4'
             AND fort_rule_command_target_proxy.fort_target_id
            IN(SELECT fort_user_group_user.fort_user_group_id FROM fort_user_group_user WHERE fort_user_group_user.fort_user_id = userId)
        ) b,temp_rule_command_order
        
        WHERE a.fort_rule_command_id = b.fort_rule_command_id AND temp_rule_command_order.rule_command_order_id = a.fort_rule_command_id 
       ;
    
        
     SELECT temp_rule_command.rule_command_id INTO temp_rule_command_id FROM temp_rule_command,fort_command,fort_rule_command WHERE 
           temp_rule_command.rule_command_id = fort_rule_command.fort_rule_command_id
       AND 
           temp_rule_command.rule_command_id = fort_command.fort_rule_command_id 
       
       AND  
            fort_rule_command.fort_rule_command_state = '1'
       
       AND   fort_command.fort_command_value LIKE CONCAT('%',commandValue,'%')   
           
       ORDER BY temp_rule_command.rule_command_order 
       LIMIT 1 ;
 
    SELECT fort_user.fort_user_id , fort_user.fort_user_name ,fort_user.fort_user_account   
    FROM fort_rule_command_target_proxy,fort_user 
    WHERE 
    
    fort_rule_command_target_proxy.fort_rule_command_id  =  temp_rule_command_id
       
       AND fort_rule_command_target_proxy.fort_target_code = 64
       
       AND fort_user.fort_user_id = fort_rule_command_target_proxy.fort_target_id;

      DROP TABLE temp_rule_command;
      DROP TABLE temp_rule_command_order;
   
   SET autocommit = 1;
    
    END$$

DELIMITER ;

DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `getRuleTimeResource`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `getRuleTimeResource`()
BEGIN
    DECLARE done INT DEFAULT -1; 
    
    DECLARE temp_id  VARCHAR(24);
    DECLARE temp_type  VARCHAR(1);
    DECLARE temp_state VARCHAR(1);
    DECLARE temp_prior_id  VARCHAR(24);
    DECLARE temp_next_id  VARCHAR(24);
    DECLARE temp_start_time DATETIME;
    DECLARE temp_end_time DATETIME;
    DECLARE temp_month_start_time  VARCHAR(2);
    DECLARE temp_month_end_time  VARCHAR(2);
    DECLARE temp_week_start_time  VARCHAR(1);
    DECLARE temp_week_end_time  VARCHAR(1);
    DECLARE temp_day_start_time  VARCHAR(8);
    DECLARE temp_day_end_time  VARCHAR(8);    
    DECLARE temp_time VARCHAR(100);
    DECLARE temp_user TEXT DEFAULT ''; 
    DECLARE temp_resource TEXT DEFAULT '';
    DECLARE temp_target_code INT;
    DECLARE temp_target_id VARCHAR(24); 
    
    DECLARE cur1 CURSOR FOR  SELECT DISTINCT 
    fort_rule_time_resource.fort_rule_time_resource_id,
    fort_rule_time_resource.fort_rule_type,   
    fort_rule_time_resource.fort_rule_state,
    fort_rule_time_resource.fort_prior_id,
    fort_rule_time_resource.fort_next_id,
    fort_rule_time_resource.fort_start_time,  
    fort_rule_time_resource.fort_end_time,  
    fort_rule_time_resource.fort_month_start_time,  
    fort_rule_time_resource.fort_month_end_time,  
    fort_rule_time_resource.fort_week_start_time,  
    fort_rule_time_resource.fort_week_end_time,  
    fort_rule_time_resource.fort_day_start_time,  
    fort_rule_time_resource.fort_day_end_time  
    FROM fort_rule_time_resource;
    
    DECLARE cur2 CURSOR FOR  SELECT DISTINCT 
    fort_target_code,fort_target_id
    FROM temp_authorization;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1;  
    
    DROP TEMPORARY TABLE IF EXISTS temp_strategy;   
    CREATE TEMPORARY TABLE temp_strategy(
         fort_rule_time_resource_id  VARCHAR(24) NOT NULL
        ,fort_rule_type VARCHAR(1)
        ,fort_rule_state VARCHAR(1)
        ,fort_prior_id VARCHAR(24)
        ,fort_next_id VARCHAR(24)
        ,fort_user TEXT
        ,fort_resource TEXT
        ,fort_time VARCHAR(100)
    );
    DROP TEMPORARY TABLE IF EXISTS temp_authorization;
    CREATE TEMPORARY TABLE temp_authorization(      
        fort_target_code INT 
        ,fort_target_id VARCHAR(24)
    );
    SET temp_resource = '';
    SET temp_user = '';
    SET temp_time = '';
    
    OPEN cur1;
    myLoop: LOOP  
        FETCH cur1 INTO temp_id,temp_type,temp_state,temp_prior_id,temp_next_id,temp_start_time,temp_end_time,temp_month_start_time,temp_month_end_time,temp_week_start_time,temp_week_end_time,
        temp_day_start_time,temp_day_end_time;     
        IF done = 1 THEN   
            LEAVE myLoop;
        END IF;
        
       
        INSERT INTO temp_strategy(fort_rule_time_resource_id,fort_rule_type,fort_rule_state,fort_prior_id,fort_next_id)
        VALUES(temp_id,temp_type,temp_state,temp_prior_id,temp_next_id);
        
        IF temp_month_start_time IS NULL THEN
        SET temp_month_start_time = '1';
        END IF;
        
        IF temp_month_end_time IS NULL THEN
        SET temp_month_end_time = '31';
        END IF;
        
        IF temp_week_start_time IS NULL THEN
        SET temp_week_start_time = '1';
        END IF;
        
        IF temp_week_end_time IS NULL THEN
        SET temp_week_end_time = '0';
        END IF;
        
        IF temp_day_start_time IS NULL THEN
        SET temp_day_start_time = '0';
        END IF;
        
        IF temp_day_end_time IS NULL THEN
        SET temp_day_end_time = '23';
        END IF;
        
         SET temp_time = 
        CONCAT(temp_start_time,',',temp_end_time,';',temp_month_start_time,',',temp_month_end_time,';',temp_week_start_time,',',temp_week_end_time,';',temp_day_start_time,',',temp_day_end_time);
        
        UPDATE temp_strategy SET fort_time = temp_time WHERE fort_rule_time_resource_id = temp_id;
        
        INSERT INTO  temp_authorization
        SELECT fort_target_code,fort_target_id FROM fort_rule_time_resource_target_proxy WHERE fort_rule_time_resource_id = temp_id;
        OPEN cur2;
        typeLoop:LOOP
            FETCH cur2 INTO temp_target_code,temp_target_id;
            IF done = 1 THEN 
                SET done = -1;
                LEAVE typeLoop;
            END IF;
            IF temp_target_code=2 THEN
                IF temp_user='' THEN
                    SELECT CONCAT(CONCAT(fort_user_account,'(',fort_user_name,')')) INTO temp_user  
                    FROM fort_user WHERE fort_user_id = temp_target_id;             
                ELSE 
                    SELECT CONCAT(temp_user,'</br>',CONCAT(fort_user_account,'(',fort_user_name,')')) INTO temp_user  
                    FROM fort_user WHERE fort_user_id = temp_target_id;
                END IF;
            END IF;
            IF temp_target_code=4 THEN 
                IF temp_user='' THEN
                    SELECT fort_user_group_name INTO temp_user FROM fort_user_group WHERE fort_user_group_id = temp_target_id;              
                ELSE                
                    SELECT CONCAT(temp_user,'</br>',fort_user_group_name) INTO temp_user FROM fort_user_group WHERE fort_user_group_id = temp_target_id;
                END IF;
            END IF;             
            IF temp_target_code=8 THEN
                IF temp_resource='' THEN
                    SELECT CONCAT(CONCAT(resource.fort_resource_name,'(',resource.fort_resource_ip,') - ',account.fort_account_name))   
                    INTO temp_resource
                    FROM fort_resource resource,fort_account account
                    WHERE resource.fort_resource_id = account.fort_resource_id
                    AND account.fort_account_id = temp_target_id;
                ELSE
                    SELECT CONCAT(temp_resource,'</br>',CONCAT(resource.fort_resource_name,'(',resource.fort_resource_ip,') - ',account.fort_account_name)) 
                    INTO temp_resource
                    FROM fort_resource resource,fort_account account
                    WHERE resource.fort_resource_id = account.fort_resource_id
                    AND account.fort_account_id = temp_target_id;
                END IF;
            END IF;  
            IF temp_target_code=16 THEN
                IF temp_resource='' THEN
                    SELECT CONCAT(CONCAT(fort_resource_name,'(',fort_resource_ip,')'))  
                    INTO temp_resource
                    FROM fort_resource resource
                    WHERE resource.fort_resource_id = temp_target_id;
                ELSE
                    SELECT CONCAT(temp_resource,'</br>',CONCAT(fort_resource_name,'(',fort_resource_ip,')'))    
                    INTO temp_resource
                    FROM fort_resource resource
                    WHERE resource.fort_resource_id = temp_target_id;
                END IF;
            END IF; 
            IF temp_target_code=32 THEN
                IF temp_resource='' THEN
                    SELECT fort_resource_group_name 
                    INTO temp_resource
                    FROM fort_resource_group 
                    WHERE fort_resource_group_id = temp_target_id;
                ELSE
                    SELECT CONCAT(temp_resource,'</br>',fort_resource_group_name)   
                    INTO temp_resource
                    FROM fort_resource_group 
                    WHERE fort_resource_group_id = temp_target_id;
                END IF;
            END IF; 
        END LOOP typeLoop; 
        CLOSE cur2; 
        
        DELETE FROM temp_authorization;
        
        UPDATE temp_strategy SET fort_user=temp_user,fort_resource=temp_resource,fort_time = temp_time WHERE fort_rule_time_resource_id=temp_id;
        SET temp_resource = '';
        SET temp_user = '';
     END LOOP myLoop;   
  /* 关闭游标 */ 
    CLOSE cur1;
    SELECT fort_rule_time_resource_id,fort_rule_type,fort_rule_state,fort_prior_id,fort_next_id,fort_user,fort_resource,fort_time
    FROM temp_strategy;
      
    DROP TABLE temp_authorization;
    DROP TABLE temp_strategy;
END$$

DELIMITER ;

DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `moveRuleTimeResource`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `moveRuleTimeResource`(IN `move_id` VARCHAR(50),IN `down_id` VARCHAR(50))
BEGIN   
    DECLARE downPrior_id VARCHAR(24);
    DECLARE downPrior_priorId VARCHAR(24);
    DECLARE downPrior_nextId VARCHAR(24);
    DECLARE move_priorId VARCHAR(24);
    DECLARE move_nextId VARCHAR(24);
    DECLARE down_priorId VARCHAR(24);
    DECLARE down_nextId VARCHAR(24);
    DECLARE movePrior_id VARCHAR(24);
    DECLARE movePrior_priorId VARCHAR(24);
    DECLARE movePrior_nextId VARCHAR(24);
    DECLARE moveNext_id VARCHAR(24);
    DECLARE moveNext_priorId VARCHAR(24);
    DECLARE moveNext_nextId VARCHAR(24);    
    
    SELECT fort_prior_id,fort_next_id INTO move_priorId,move_nextId FROM fort_rule_time_resource WHERE fort_rule_time_resource_id=move_id;
    
    SELECT fort_rule_time_resource_id,fort_prior_id,fort_next_id INTO movePrior_id,movePrior_priorId,movePrior_nextId 
    FROM fort_rule_time_resource WHERE fort_rule_time_resource_id=move_priorId;
    
    SELECT fort_rule_time_resource_id,fort_prior_id,fort_next_id INTO moveNext_id,moveNext_priorId,moveNext_nextId 
    FROM fort_rule_time_resource WHERE fort_rule_time_resource_id=move_nextId;
    
    SELECT fort_prior_id,fort_next_id INTO down_priorId,down_nextId FROM fort_rule_time_resource WHERE fort_rule_time_resource_id=down_id; 
    
    SELECT fort_rule_time_resource_id,fort_prior_id,fort_next_id INTO downPrior_id,downPrior_priorId,downPrior_nextId 
    FROM fort_rule_time_resource WHERE fort_rule_time_resource_id=down_priorId;
    
    IF (downPrior_id IS NOT NULL) THEN  
        UPDATE fort_rule_time_resource SET fort_prior_id=downPrior_priorId,fort_next_id=move_id  WHERE fort_rule_time_resource_id=downPrior_id;     
    END IF;
    
    SELECT fort_prior_id,fort_next_id INTO down_priorId,down_nextId FROM fort_rule_time_resource WHERE fort_rule_time_resource_id=down_id;  
    
    SELECT fort_prior_id,fort_next_id INTO downPrior_priorId,downPrior_nextId FROM fort_rule_time_resource WHERE fort_rule_time_resource_id=downPrior_id;
    
    IF (downPrior_id IS NOT NULL) THEN      
        UPDATE fort_rule_time_resource SET fort_prior_id=downPrior_id,fort_next_id=down_id WHERE fort_rule_time_resource_id=move_id;
    ELSE
        UPDATE fort_rule_time_resource SET fort_prior_id=NULL,fort_next_id=down_id WHERE fort_rule_time_resource_id=move_id;
    END IF;
    
    SELECT fort_prior_id,fort_next_id INTO down_priorId,down_nextId FROM fort_rule_time_resource WHERE fort_rule_time_resource_id=down_id; 
    
    IF (down_id IS NOT NULL) THEN       
        UPDATE fort_rule_time_resource SET fort_prior_id=move_id,fort_next_id=down_nextId WHERE fort_rule_time_resource_id=down_id;
    END IF;
    
    SELECT fort_prior_id,fort_next_id INTO movePrior_priorId,movePrior_nextId FROM fort_rule_time_resource WHERE fort_rule_time_resource_id=movePrior_id;
    
    IF (movePrior_id IS NOT NULL) THEN
        UPDATE fort_rule_time_resource SET fort_prior_id=movePrior_priorId,fort_next_id=moveNext_id WHERE fort_rule_time_resource_id=movePrior_id;      
    END IF;
    
    SELECT fort_prior_id,fort_next_id INTO moveNext_priorId,moveNext_nextId FROM fort_rule_time_resource WHERE fort_rule_time_resource_id=moveNext_id;
    
    IF (moveNext_id IS NOT NULL) THEN
        UPDATE fort_rule_time_resource SET fort_prior_id=movePrior_id,fort_next_id=moveNext_nextId WHERE fort_rule_time_resource_id=moveNext_id;        
    END IF;
    
END$$

DELIMITER ;


DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `selectRuleTimeById`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `selectRuleTimeById`(IN fort_rule_time_id VARCHAR(32))
BEGIN   
      DECLARE done INT DEFAULT -1;  
    
      DECLARE temp_user TEXT; 
      DECLARE temp_user_group TEXT;   
      DECLARE temp_resource_group TEXT;   
      DECLARE temp_resource TEXT;
      DECLARE temp_resource_account TEXT; 
      DROP TEMPORARY TABLE IF EXISTS tempRuleTime; 
      CREATE TEMPORARY TABLE tempRuleTime(
            rule_time_id  VARCHAR(24) NOT NULL
           ,rule_time_user TEXT
           ,rule_time_user_group TEXT
           ,rule_time_resource_group TEXT
           ,rule_time_resource TEXT  
           ,rule_time_resource_account TEXT
       );
       
      SET autocommit = 0;  
    
          
        INSERT INTO tempRuleTime(rule_time_id,rule_time_user,rule_time_user_group,rule_time_resource_group)  VALUES (fort_rule_time_id,NULL,NULL,NULL);     
        
       
           SELECT GROUP_CONCAT(DISTINCT(CONCAT(fort_user.fort_user_id,':',fort_user.fort_user_account,':',fort_user.fort_user_name,':',fort_department.fort_department_name)) SEPARATOR '|')   INTO temp_user
           
            FROM fort_rule_time_resource_target_proxy,fort_user,fort_department WHERE fort_rule_time_resource_target_proxy.fort_target_id = fort_user.fort_user_id 
            
            AND fort_rule_time_resource_target_proxy.fort_rule_time_resource_id = fort_rule_time_id  AND fort_department.fort_department_id = fort_user.fort_department_id
            
            AND fort_rule_time_resource_target_proxy.fort_target_code = 2 AND fort_user.fort_user_state  <> 2;   
          
            UPDATE  tempRuleTime SET rule_time_user = temp_user WHERE rule_time_id = fort_rule_time_id ;
         
           SELECT GROUP_CONCAT(DISTINCT(CONCAT(fort_user_group.fort_user_group_id,':',fort_user_group.fort_user_group_name ,':',fort_department.fort_department_name)) SEPARATOR  '|') INTO temp_user_group
 
                     FROM fort_rule_time_resource_target_proxy,fort_user_group,fort_department 
 
                      WHERE fort_rule_time_resource_target_proxy.fort_target_id  = fort_user_group.fort_user_group_id 
 
                      AND fort_rule_time_resource_target_proxy.fort_rule_time_resource_id = fort_rule_time_id  AND fort_department.fort_department_id = fort_user_group.fort_department_id
                      
                      AND fort_rule_time_resource_target_proxy.fort_target_code = 4;        
 
            UPDATE  tempRuleTime SET rule_time_user_group = temp_user_group WHERE rule_time_id = fort_rule_time_id ;
      
         
     
          
          SELECT GROUP_CONCAT(DISTINCT(CONCAT(fort_resource_group.fort_resource_group_id,':',fort_resource_group.fort_resource_group_name,':',fort_department.fort_department_name)) SEPARATOR  '|')  INTO temp_resource_group
  
              FROM fort_rule_time_resource_target_proxy,fort_resource_group,fort_department
    
              WHERE fort_rule_time_resource_target_proxy.fort_target_id = fort_resource_group.fort_resource_group_id 
    
              AND fort_rule_time_resource_target_proxy.fort_rule_time_resource_id = fort_rule_time_id AND fort_department.fort_department_id = fort_resource_group.fort_department_id
    
              AND fort_rule_time_resource_target_proxy.fort_target_code = 32 ;   
        
         UPDATE  tempRuleTime SET rule_time_resource_group = temp_resource_group WHERE rule_time_id = fort_rule_time_id ;
           SELECT GROUP_CONCAT(DISTINCT(CONCAT(fort_resource.fort_resource_id,':',fort_resource.fort_resource_name,':',fort_resource.fort_resource_ip,':',
         
                    fort_resource_type.fort_resource_type_name,":",fort_department.fort_department_name)) SEPARATOR '|')  INTO temp_resource
             
                    FROM  fort_rule_time_resource_target_proxy,fort_resource ,fort_resource_type ,fort_department
              
                    WHERE 
                          fort_rule_time_resource_target_proxy.fort_target_id =  fort_resource.fort_resource_id
                    AND 
                          fort_resource.fort_department_id = fort_department.fort_department_id
                    AND 
                           fort_resource.fort_resource_type_id = fort_resource_type.fort_resource_type_id
                    AND 
                           fort_rule_time_resource_target_proxy.fort_rule_time_resource_id = fort_rule_time_id
                    AND 
                           fort_rule_time_resource_target_proxy.fort_target_code = 16 AND fort_resource.fort_resource_state  <> 2 ;   
            
                  
          UPDATE    tempRuleTime SET rule_time_resource = temp_resource WHERE rule_time_id = fort_rule_time_id ;
     
     
    
        SELECT GROUP_CONCAT( DISTINCT( CONCAT(fort_resource.fort_resource_id,":",fort_resource.fort_resource_name,":",fort_resource.fort_resource_ip,":",
            
                fort_resource_type.fort_resource_type_id,":",fort_resource_type.fort_resource_type_name,":",fort_account.fort_account_id,":",
            
                fort_account.fort_account_name,":",fort_department.fort_department_name)) SEPARATOR '|')  INTO temp_resource_account
         
                FROM  fort_rule_time_resource_target_proxy,fort_resource,fort_account,fort_resource_type  ,fort_department
              
               WHERE 
                     fort_rule_time_resource_target_proxy.fort_target_id = fort_account.fort_account_id 
             
                AND 
                      fort_department.fort_department_id = fort_resource.fort_department_id
                AND 
                     fort_account.fort_resource_id =  fort_resource.fort_resource_id
                AND 
                     fort_resource_type.fort_resource_type_id = fort_resource.fort_resource_type_id
                AND 
                     fort_rule_time_resource_target_proxy.fort_rule_time_resource_id = fort_rule_time_id
                AND 
                     fort_rule_time_resource_target_proxy.fort_target_code = 8 AND fort_resource.fort_resource_state  <> 2 ;
                     
      UPDATE tempRuleTime SET rule_time_resource_account = temp_resource_account WHERE rule_time_id = fort_rule_time_id ;
        
      
        
    
     SELECT tempRuleTime.rule_time_id,tempRuleTime.rule_time_user ,tempRuleTime.rule_time_user_group ,tempRuleTime.rule_time_resource_group,tempRuleTime.rule_time_resource,tempRuleTime.rule_time_resource_account FROM  tempRuleTime;
      
     DROP TABLE tempRuleTime;
     
     SET autocommit = 1;
     
     
    END$$

DELIMITER ;


DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `selectRuleTimeByUserId`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `selectRuleTimeByUserId`(IN userId VARCHAR(32),IN accountId VARCHAR(32))
BEGIN   
    
     DECLARE rule_while_id VARCHAR(32); 
     DECLARE rule_while_into_id VARCHAR(32);
     DECLARE order_num INT DEFAULT 0 ;
     
     DECLARE temp_rule_time_id VARCHAR(32); 
     
    DROP TEMPORARY TABLE IF EXISTS temp_rule_time_order; 
    CREATE TEMPORARY TABLE temp_rule_time_order(
            rule_time_order_id VARCHAR(32),
            rule_time_order_num INT
       )ENGINE=MEMORY;  
       
       DROP TEMPORARY TABLE IF EXISTS temp_rule_time;    
    CREATE TEMPORARY TABLE temp_rule_time(
            rule_time_id VARCHAR(32),
            rule_time_order INT 
       )ENGINE=MEMORY;  
      
    SET autocommit = 0;
    
     SELECT  fort_rule_time_resource.fort_rule_time_resource_id INTO rule_while_into_id  FROM  fort_rule_time_resource  WHERE fort_rule_time_resource.fort_prior_id IS NULL;
         
          INSERT INTO  temp_rule_time_order(rule_time_order_id,rule_time_order_num)  VALUE (rule_while_into_id,0);
  
     leave_rule_while : WHILE rule_while_into_id IS NOT NULL DO         
               
              
         SET rule_while_id =rule_while_into_id;
         
         SET rule_while_into_id = NULL;
         SELECT fort_rule_time_resource.fort_rule_time_resource_id INTO rule_while_into_id FROM fort_rule_time_resource WHERE fort_rule_time_resource.fort_prior_id = rule_while_id;  
        
          IF ( rule_while_into_id IS  NULL ) THEN
                LEAVE leave_rule_while;
             
             END IF;
         SET order_num =order_num+1;
         
         INSERT INTO  temp_rule_time_order(rule_time_order_id,rule_time_order_num)  VALUE (rule_while_into_id,order_num);
        END WHILE; 

    
    INSERT INTO  temp_rule_time(rule_time_id,rule_time_order) 
        SELECT DISTINCT a.fort_rule_time_resource_id,temp_rule_time_order.rule_time_order_num FROM
            (SELECT fort_rule_time_resource_target_proxy.fort_rule_time_resource_id FROM fort_rule_time_resource_target_proxy WHERE fort_rule_time_resource_target_proxy.fort_target_code='8' AND fort_rule_time_resource_target_proxy.fort_target_id = accountId
               
             UNION ALL
             SELECT fort_rule_time_resource_target_proxy.fort_rule_time_resource_id FROM fort_rule_time_resource_target_proxy WHERE fort_rule_time_resource_target_proxy.fort_target_code='16' AND fort_rule_time_resource_target_proxy.fort_target_id
            
            IN(SELECT fort_account.fort_resource_id FROM fort_account WHERE fort_account.fort_account_id = accountId)
               
               UNION ALL
            SELECT  fort_rule_time_resource_target_proxy.fort_rule_time_resource_id FROM fort_rule_time_resource_target_proxy WHERE fort_rule_time_resource_target_proxy.fort_target_code='32' AND fort_rule_time_resource_target_proxy.fort_target_id
             IN(SELECT fort_resource_group_resource.fort_resource_group_id FROM fort_resource_group_resource WHERE fort_resource_group_resource.fort_resource_id IN(
               SELECT fort_account.fort_resource_id FROM fort_account WHERE fort_account.fort_account_id = accountId )  )     
           ) a,
         (SELECT fort_rule_time_resource_target_proxy.fort_rule_time_resource_id  FROM fort_rule_time_resource_target_proxy WHERE fort_rule_time_resource_target_proxy.fort_target_code='2' AND fort_rule_time_resource_target_proxy.fort_target_id = userId       
       
             UNION ALL
          SELECT fort_rule_time_resource_target_proxy.fort_rule_time_resource_id  FROM fort_rule_time_resource_target_proxy WHERE fort_rule_time_resource_target_proxy.fort_target_code='4'
             AND fort_rule_time_resource_target_proxy.fort_target_id
            IN(SELECT fort_user_group_user.fort_user_group_id FROM fort_user_group_user WHERE fort_user_group_user.fort_user_id = userId)
        ) b,temp_rule_time_order
        
        WHERE a.fort_rule_time_resource_id = b.fort_rule_time_resource_id AND temp_rule_time_order.rule_time_order_id = a.fort_rule_time_resource_id 
       ;
    

     SELECT fort_rule_time_resource.*  FROM temp_rule_time,fort_rule_time_resource WHERE 
           temp_rule_time.rule_time_id = fort_rule_time_resource.fort_rule_time_resource_id
       
       AND  
            fort_rule_time_resource.fort_rule_state = '1' 
       
        ORDER BY temp_rule_time.rule_time_order ASC;
 
    
      DROP TABLE temp_rule_time;
      DROP TABLE temp_rule_time_order;
   
   SET autocommit = 1;
    
    END$$

DELIMITER ;


DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `getSuperiorApproversByAuthId`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `getSuperiorApproversByAuthId`(IN authId VARCHAR(32))
BEGIN   
      
    DECLARE approval TEXT DEFAULT ''; 
    DECLARE done INT DEFAULT 0; 
    DECLARE process_id VARCHAR(24);
    DECLARE state VARCHAR(1);
    DECLARE process_task_id VARCHAR(24);
    DECLARE parent_id VARCHAR(24) DEFAULT NULL;
    DECLARE processCount INT DEFAULT 0;
    DECLARE num INT DEFAULT 0;
    DECLARE rule VARCHAR(8);
    DECLARE user_id VARCHAR(24);
    DECLARE users TEXT DEFAULT '';
        
    DECLARE cur1 CURSOR FOR SELECT fort_user_id 
    FROM fort_task_participant 
    WHERE fort_task_participant.fort_process_task_id = process_task_id;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1;   
    
    DROP TEMPORARY TABLE IF EXISTS temp_process;   
     
    CREATE TEMPORARY TABLE temp_process(   
        fort_process_id VARCHAR(24),
        fort_approval TEXT,
        fort_state VARCHAR(1)         
    ); 
          
        SELECT fort_superior_process_id INTO process_id FROM fort_authorization WHERE fort_authorization_id = authId;
        
        SELECT fort_state INTO state FROM fort_process WHERE fort_process_id = process_id;
    approveLoop1: LOOP
        IF parent_id IS NULL THEN
            SELECT COUNT(fort_process_task_id) INTO processCount
            FROM fort_process_task 
            WHERE fort_process_task.fort_process_id = process_id 
            AND fort_process_task.fort_parent_id IS NULL;
        ELSE        
            SELECT COUNT(fort_process_task_id) INTO processCount
            FROM fort_process_task 
            WHERE fort_process_task.fort_process_id = process_id 
            AND fort_process_task.fort_parent_id = parent_id;
        END IF;
        IF processCount=0 THEN
            LEAVE approveLoop1;
        END IF;
        
        IF parent_id IS NULL THEN
            SELECT fort_process_task_id,fort_concurrent_rule INTO process_task_id,rule
            FROM fort_process_task 
            WHERE fort_process_task.fort_process_id = process_id 
            AND fort_process_task.fort_parent_id IS NULL;
        ELSE        
            SELECT fort_process_task_id,fort_concurrent_rule INTO process_task_id,rule
            FROM fort_process_task 
            WHERE fort_process_task.fort_process_id = process_id 
            AND fort_process_task.fort_parent_id = parent_id;
        END IF;
        
        SET parent_id = process_task_id;
        
        OPEN cur1;
        
        approveLoop2:LOOP       
            FETCH cur1 INTO user_id; 
            
            IF done = 1 THEN 
                SET done = 0;
                LEAVE approveLoop2;  
            END IF;
            SELECT CONCAT(users,fort_user_id,':',fort_user_account,'(',fort_user_name,')',';') INTO users
            FROM fort_user
            WHERE fort_user_id = user_id;           
        END LOOP;
        
        CLOSE cur1;
        
        SET num = num+1;
        
        SET approval = CONCAT(approval,num,';:;',users,';:;',rule,'|');
        SET users = '';
    END LOOP approveLoop1;   
    
    IF  approval!='' THEN
    
        INSERT INTO temp_process(fort_process_id,fort_approval,fort_state) VALUES(process_id,approval,state);
        END IF;
        
        SELECT fort_process_id,fort_approval,fort_state FROM temp_process;
        
    DROP TABLE temp_process;
END$$

DELIMITER ;


DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `selectForeignClientById`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `selectForeignClientById`(IN fort_resource_id VARCHAR(100),IN fort_resource_type_id VARCHAR(100))
BEGIN   
     
     DECLARE temp_protocol_client TEXT;
     DECLARE temp_operations_protocol TEXT;
     
      DROP TEMPORARY TABLE IF EXISTS temp_protocol_client_table;      
      CREATE TEMPORARY TABLE temp_protocol_client_table(
          id VARCHAR(24) 
         , fort_approve_clicent VARCHAR(24) 
         , fort_approve_state VARCHAR(24)   
         ,fort_protocol_client TEXT 
         ,fort_operations_protocol TEXT 
       );
       SET autocommit = 0;
    
       INSERT INTO temp_protocol_client_table(id) VALUES('100001');
     
     
     
       IF (FIND_IN_SET('1000000000001',selectResourceTypePid(fort_resource_type_id ))) THEN
                 
              SELECT DISTINCT GROUP_CONCAT( DISTINCT(CONCAT(fort_protocol_client.fort_client_tool_id,":",fort_client_tool.fort_client_tool_name)) SEPARATOR '|') ,
              GROUP_CONCAT(DISTINCT(CONCAT("protoco",":",fort_operations_protocol.fort_operations_protocol_id,":",fort_operations_protocol.fort_operations_protocol_name)) SEPARATOR '|') INTO temp_protocol_client,temp_operations_protocol
          
          FROM fort_resource_operations_protocol ,fort_operations_protocol ,fort_protocol_client ,fort_client_tool 
         
          WHERE  fort_resource_operations_protocol.fort_operations_protocol_id = fort_operations_protocol.fort_operations_protocol_id 
          
          AND fort_operations_protocol.fort_operations_protocol_id = fort_protocol_client.fort_operations_protocol_id 
          
          AND fort_protocol_client.fort_client_tool_id = fort_client_tool.fort_client_tool_id 
          
          AND fort_resource_operations_protocol.fort_resource_id = fort_resource_id;   
         
         UPDATE  temp_protocol_client_table SET fort_protocol_client = temp_protocol_client,fort_operations_protocol = temp_operations_protocol  WHERE id = '100001' ;  
         END IF;  
         
         IF (FIND_IN_SET('1000000000002',selectResourceTypePid(fort_resource_type_id ))|| FIND_IN_SET('1000000000003',selectResourceTypePid(fort_resource_type_id )) ) THEN
          
           SELECT DISTINCT GROUP_CONCAT( DISTINCT(CONCAT(fort_protocol_client.fort_client_tool_id,":",fort_client_tool.fort_client_tool_name)) SEPARATOR '|') ,
  
                     GROUP_CONCAT( DISTINCT(CONCAT( "application",":",fort_application_release_server.fort_application_release_server_id,":",fort_application_release_server.fort_application_release_server_name)) SEPARATOR '|') INTO temp_protocol_client,temp_operations_protocol
           
               FROM   fort_resource ,fort_resource_operations_protocol,fort_operations_protocol , fort_protocol_client ,fort_client_tool ,fort_resource_application , fort_application_release_server 
              
               WHERE    fort_resource_application.fort_resource_id = fort_resource.fort_resource_id 
               AND fort_resource_application.fort_application_release_server_id = fort_application_release_server.fort_application_release_server_id 
               AND  fort_resource.fort_resource_id = fort_resource_operations_protocol.fort_resource_id
               AND fort_resource_operations_protocol.fort_operations_protocol_id = fort_protocol_client.fort_operations_protocol_id  
           AND fort_protocol_client.fort_client_tool_id = fort_client_tool.fort_client_tool_id   
           AND  fort_resource.fort_resource_id = fort_resource_id ;
           
               UPDATE  temp_protocol_client_table SET fort_protocol_client = temp_protocol_client,fort_operations_protocol = temp_operations_protocol  WHERE id = '100001' ;    
    
     END IF; 
     
      SELECT  id,fort_protocol_client,fort_operations_protocol,fort_approve_clicent,fort_approve_state FROM temp_protocol_client_table;
      
 DROP TABLE temp_protocol_client_table;
  SET autocommit = 1;
  
    END$$

DELIMITER ;



DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `selectForeignUserAuth`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `selectForeignUserAuth`(IN fort_user_id VARCHAR(32),IN fort_user_account VARCHAR(100),
IN fort_user_name  VARCHAR(100),IN fort_department_id VARCHAR(32),IN fort_resource_ip VARCHAR(32),IN fort_resource_type_id VARCHAR(32))
BEGIN   
      DECLARE done INT DEFAULT -1;  
      DECLARE temp_auth_id VARCHAR(32); 
      DECLARE temp_code INT;  
      DECLARE temp_sql_string TEXT; 
      
      DECLARE select_auth_for_foreign CURSOR FOR 
         SELECT  DISTINCT fort_authorization_target_proxy.fort_authorization_id,fort_authorization.fort_authorization_code
              FROM  fort_authorization_target_proxy,fort_authorization,fort_user,(    SELECT fort_user.fort_user_id 
              FROM fort_user
              WHERE
                  fort_user.fort_department_id IN ( 
                     SELECT   t.fort_department_id  FROM fort_user,fort_department user_department,fort_department t
                     WHERE fort_user.fort_department_id = user_department.fort_department_id 
                     AND fort_user.fort_user_id = fort_user_id
                     AND t.fort_full_name  LIKE CONCAT('%',user_department.fort_full_name,'%') )
                ) t
              WHERE fort_authorization_target_proxy.fort_authorization_id = fort_authorization.fort_authorization_id        
              AND fort_authorization_target_proxy.fort_target_id = t.fort_user_id;     
              
               
            
         
      
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1;  
    
      DROP TEMPORARY TABLE IF EXISTS temp_foreign_account;  
      CREATE TEMPORARY TABLE temp_foreign_account(
           auth_id  VARCHAR(32) 
          ,account_id VARCHAR(32) 
          ,resource_id VARCHAR(32)   
       )ENGINE=MEMORY;
       
      DROP TEMPORARY TABLE IF EXISTS temp_user;  
      CREATE TEMPORARY TABLE temp_user(
            auth_id  VARCHAR(32) 
           ,user_id  VARCHAR(32) 
       )ENGINE=MEMORY;
       
      DROP TEMPORARY TABLE IF EXISTS temp_not_department;  
      CREATE TEMPORARY TABLE temp_not_department(
            department_id  VARCHAR(32)
       )ENGINE=MEMORY;
      
      
             
      
      
      SET autocommit = 0;
      
      
      INSERT INTO temp_not_department(department_id)
               SELECT   t.fort_department_id  FROM fort_user,fort_department user_department,fort_department t
                     WHERE fort_user.fort_department_id = user_department.fort_department_id 
                     AND fort_user.fort_user_id = fort_user_id
                     AND t.fort_full_name NOT LIKE CONCAT('%',user_department.fort_full_name,'%');
            
      OPEN select_auth_for_foreign;
      tempForeignAuthLoop: LOOP  
     
        SET done = -1;
        
        FETCH select_auth_for_foreign INTO temp_auth_id,temp_code;  
        
        IF done = 1 THEN   
           LEAVE tempForeignAuthLoop;  
        END IF;  
    
    
        
         IF (temp_code&8 = 8 ) THEN
         
         INSERT INTO temp_foreign_account(auth_id,account_id,resource_id) 
              SELECT fort_authorization_target_proxy.fort_authorization_id,fort_authorization_target_proxy.fort_target_id,fort_authorization_target_proxy.fort_parent_id
                    FROM fort_authorization_target_proxy,fort_resource ,temp_not_department WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_id 
                    AND fort_authorization_target_proxy.fort_target_code = 8 
                    AND fort_resource.fort_resource_id = fort_authorization_target_proxy.fort_parent_id
                    AND  fort_resource.fort_department_id = temp_not_department.department_id;
         END IF;  
         
         IF (temp_code&16 = 16 ) THEN
              INSERT INTO temp_foreign_account(auth_id,account_id,resource_id)    
                    SELECT  fort_authorization_target_proxy.fort_authorization_id,fort_account.fort_account_id, fort_resource.fort_resource_id 
                    FROM fort_account,fort_resource,fort_authorization_target_proxy,temp_not_department 
            WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_id 
                AND fort_authorization_target_proxy.fort_target_code = 16
                AND fort_authorization_target_proxy.fort_target_id = fort_resource.fort_resource_id 
                AND fort_resource.fort_resource_id = fort_account.fort_resource_id 
                AND fort_resource.fort_parent_id IS NULL 
                AND fort_account.fort_is_allow_authorized = 1 
                AND fort_resource.fort_department_id = temp_not_department.department_id ;
       
         INSERT INTO temp_foreign_account(auth_id,account_id,resource_id) 
             SELECT fort_authorization_target_proxy.fort_authorization_id,fort_account.fort_account_id, fort_resource.fort_resource_id 
             FROM fort_account,fort_resource,fort_authorization_target_proxy ,temp_not_department
             WHERE fort_authorization_target_proxy.fort_authorization_id = temp_auth_id  
             AND fort_authorization_target_proxy.fort_target_code = 16
             AND fort_authorization_target_proxy.fort_target_id = fort_resource.fort_resource_id 
             AND fort_resource.fort_parent_id = fort_account.fort_resource_id 
             AND fort_resource.fort_parent_id IS NOT NULL 
             AND fort_account.fort_is_allow_authorized = 1 
             AND fort_resource.fort_department_id = temp_not_department.department_id;
                     
         END IF; 
         
    
         
         IF (temp_code&32 = 32 ) THEN
          
         INSERT INTO temp_foreign_account(auth_id,account_id,resource_id) 
                SELECT fort_authorization_target_proxy.fort_authorization_id,fort_account.fort_account_id, fort_resource.fort_resource_id 
                FROM fort_account,fort_resource,fort_resource_group_resource,fort_authorization_target_proxy,temp_not_department
                    WHERE  fort_resource.fort_resource_id = fort_account.fort_resource_id
                    AND fort_resource_group_resource.fort_resource_id = fort_resource.fort_resource_id
                    AND fort_resource.fort_parent_id IS NULL AND fort_resource.fort_resource_state <> 2 
                    AND fort_account.fort_is_allow_authorized = 1
                    AND fort_authorization_target_proxy.fort_authorization_id = temp_auth_id 
                    AND fort_authorization_target_proxy.fort_target_code =  32 
                    AND fort_resource_group_resource.fort_resource_group_id = fort_authorization_target_proxy.fort_target_id 
                    AND fort_resource.fort_department_id = temp_not_department.department_id;
                    
         INSERT INTO temp_foreign_account(auth_id,account_id,resource_id) 
                SELECT fort_authorization_target_proxy.fort_authorization_id,fort_account.fort_account_id, fort_resource.fort_resource_id 
                FROM fort_account,fort_resource,fort_resource_group_resource,fort_authorization_target_proxy,temp_not_department
                    WHERE  fort_resource.fort_parent_id = fort_account.fort_resource_id
                    AND fort_resource_group_resource.fort_resource_id = fort_resource.fort_resource_id
                    AND fort_resource.fort_parent_id IS NOT NULL AND fort_resource.fort_resource_state <> 2 
                    AND fort_account.fort_is_allow_authorized = 1
                    AND fort_authorization_target_proxy.fort_authorization_id = temp_auth_id 
                    AND fort_authorization_target_proxy.fort_target_code =  32
                    AND fort_resource_group_resource.fort_resource_group_id = fort_authorization_target_proxy.fort_target_id 
                    AND fort_resource.fort_department_id = temp_not_department.department_id;
                    
         END IF;  
          
        END LOOP tempForeignAuthLoop;  
    
     CLOSE select_auth_for_foreign;  
     

    INSERT INTO temp_user(auth_id,user_id)
    SELECT fort_authorization_target_proxy.fort_authorization_id  ,fort_user.fort_user_id  FROM fort_user,fort_department,fort_authorization_target_proxy 
    WHERE fort_user.fort_department_id = fort_department.fort_department_id 
    AND fort_authorization_target_proxy.fort_target_id = fort_user.fort_user_id
    AND fort_authorization_target_proxy.fort_target_code = '2'
    AND fort_department.fort_full_name  LIKE ( SELECT CONCAT('%',fort_department.fort_full_name,'%') FROM fort_user,fort_department 
    WHERE fort_user.fort_department_id = fort_department.fort_department_id AND fort_user.fort_user_id = fort_user_id ) ;
     
         SET temp_sql_string = CONCAT(
       'SELECT DISTINCT fort_user.fort_user_account,fort_user.fort_user_name,fort_department.fort_department_name,fort_resource.fort_resource_name,fort_resource.fort_resource_ip,
    fort_resource_type.fort_resource_type_name ,fort_account.fort_account_name
    FROM temp_user,temp_foreign_account,fort_user,fort_department,fort_resource,fort_account,fort_resource_type
    WHERE
     temp_user.auth_id = temp_foreign_account.auth_id
     AND fort_user.fort_user_id = temp_user.user_id
     AND temp_foreign_account.account_id = fort_account.fort_account_id
     AND fort_account.fort_resource_id = fort_resource.fort_resource_id
     AND fort_resource.fort_resource_type_id = fort_resource_type.fort_resource_type_id
     AND fort_resource.fort_department_id = fort_department.fort_department_id  ');
    
    IF ( fort_resource_ip != '' ) THEN 
     SET temp_sql_string = CONCAT(temp_sql_string,' AND  fort_resource.fort_resource_ip like\'', CONCAT('%', fort_resource_ip,'%\''));
    END IF;
   
    IF ( fort_user_account != '' ) THEN 
     SET temp_sql_string = CONCAT(temp_sql_string,'  AND fort_user.fort_user_account LIKE \'', CONCAT('%', fort_user_account,'%\''));
    END IF;
    
    
    IF ( fort_user_name != '' ) THEN 
     SET temp_sql_string = CONCAT(temp_sql_string,'  AND  fort_user.fort_user_name LIKE\'', CONCAT('%', fort_user_name,'%\''));
    END IF;
    
    IF ( fort_resource_type_id != '' ) THEN 
       SET temp_sql_string = CONCAT(temp_sql_string,'  AND FIND_IN_SET(fort_resource.fort_resource_type_id,selectResourceTypeChildList( \'',fort_resource_type_id,'\'))');
    END IF;
    
     IF ( fort_department_id != '' ) THEN 
       SET temp_sql_string = CONCAT(temp_sql_string,' AND  FIND_IN_SET(fort_resource.fort_department_id,selectDepartmentChildList( \'',fort_department_id,'\'))');
    END IF;

      SET temp_sql_string = CONCAT(temp_sql_string,'  ORDER BY fort_user.fort_user_id,fort_resource.fort_department_id,',
    'fort_resource.fort_resource_id,fort_resource_type.fort_resource_type_id ');

     SET @temp_user_sql_string = temp_sql_string;
     PREPARE stmt FROM  @temp_user_sql_string; 
     EXECUTE stmt;      
     DEALLOCATE PREPARE stmt;           
     
    DROP TABLE temp_foreign_account; 
     
    DROP TABLE temp_user;
    
    DROP TABLE temp_not_department;
    
    
    SET autocommit = 1;
    
    END$$

DELIMITER ;


DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `selectApprovalRecord`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `selectApprovalRecord`(IN fort_process_instance_id VARCHAR(100))
BEGIN   
    
     DECLARE done INT DEFAULT -1; 
     DECLARE temp_user INTEGER; 
     DECLARE temp_user_group_code INTEGER;
     DECLARE temp_double_user INTEGER;
     DECLARE temp_status VARCHAR(10);
     
     DECLARE temp_process_task_state VARCHAR(50);
     
     DECLARE temp_root_task_id VARCHAR(50);
     DECLARE tempChd TEXT;  
     DECLARE sTemp TEXT ;  
     DECLARE order_num INT DEFAULT 0 ;
     DECLARE temp_process_task_order_id VARCHAR(50);
     DECLARE temp_process_task_order_num INTEGER;
     
      DECLARE cur1 CURSOR FOR SELECT  temp_process_task_order.process_task_order_id,temp_process_task_order.process_task_order_num 
           FROM temp_process_task_order WHERE  temp_process_task_order.process_task_order_id IS NOT NULL;
      
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1; 
     
      DROP TEMPORARY TABLE IF EXISTS temp_process_task_record; 
      CREATE TEMPORARY TABLE temp_process_task_record(
         process_task_name VARCHAR(100) 
         ,user_id VARCHAR(50) 
         ,user_name VARCHAR(100)  
         ,user_account VARCHAR(100) 
         ,user_department_full VARCHAR(10000)
         ,approval_result VARCHAR(100) 
         ,approval_opinions VARCHAR(2000)   
         ,approval_time VARCHAR(100)
         ,process_task_id VARCHAR(50) 
         ,process_task_rule VARCHAR(50) 
         ,process_task_order_num INTEGER
       )ENGINE=MEMORY;
       
    
    
    
    DROP TEMPORARY TABLE IF EXISTS temp_process_task_order; 
    CREATE TEMPORARY TABLE temp_process_task_order(
            process_task_order_id VARCHAR(50),
            process_task_order_num INT
       )ENGINE=MEMORY;
       
       
      SET autocommit = 0;
         
    SELECT fort_process_task.fort_process_task_id INTO temp_root_task_id FROM  fort_process_task, fort_process_instance
              WHERE fort_process_task.fort_process_id = fort_process_instance.fort_process_id
              AND fort_process_task.fort_parent_id IS NULL
              AND fort_process_instance.fort_process_instance_id = fort_process_instance_id;
       
        INSERT INTO  temp_process_task_order(process_task_order_id,process_task_order_num)  VALUE (temp_root_task_id,0);
        SET tempChd = temp_root_task_id ;
         SET sTemp ='';
         WHILE tempChd IS NOT NULL DO 
                 
         SET sTemp = CONCAT(sTemp,',',tempChd);
         SELECT GROUP_CONCAT(fort_process_task_id) INTO tempChd FROM fort_process_task WHERE FIND_IN_SET(fort_parent_id,tempChd)>0; 
         SET order_num =order_num+1;
         
         INSERT INTO  temp_process_task_order(process_task_order_id,process_task_order_num)  VALUE (tempChd,order_num);
    
     END WHILE; 
    
    OPEN cur1;
      
      myLoop: LOOP  
          SET done = -1;
          
        FETCH cur1 INTO temp_process_task_order_id,temp_process_task_order_num;  
      
        IF done = 1 THEN   
          LEAVE myLoop;  
        END IF;  
        INSERT INTO temp_process_task_record(process_task_name,user_id,user_name,user_account,approval_result
        ,approval_opinions,approval_time,process_task_id ,user_department_full,process_task_rule)
    SELECT fort_process_task.fort_process_task_name,fort_task_participant.fort_user_id ,
               fort_user.fort_user_name ,fort_user.fort_user_account,
            CASE fort_process_task_instance.fort_state
               WHEN '1' THEN 'wait'
               WHEN '2' THEN 'pass'
               WHEN '3' THEN 'deny' 
               WHEN '4' THEN 'expire' 
            END AS approval_result
       ,fort_approval_record.fort_approval_opinions,fort_process_task_instance.fort_end_time,
       fort_process_task.fort_process_task_id ,fort_department.fort_full_name,fort_process_task.fort_concurrent_rule
       FROM fort_process_task,fort_task_participant,fort_user,fort_department,fort_process_task_instance LEFT JOIN fort_approval_record 
       ON fort_process_task_instance.fort_process_task_instance_id = fort_approval_record.fort_process_task_instance_id
       
       WHERE fort_process_task.fort_process_task_id = fort_process_task_instance.fort_process_task_id
       AND fort_process_task_instance.fort_task_participant_id = fort_task_participant.fort_task_participant_id
       AND fort_task_participant.fort_user_id = fort_user.fort_user_id
       AND fort_process_task_instance.fort_parent_id IS NOT NULL
       AND fort_process_task_instance.fort_process_task_id =temp_process_task_order_id
       AND fort_process_task_instance.fort_process_instance_id =fort_process_instance_id 
       AND fort_department.fort_department_id = fort_user.fort_department_id;
    
       UPDATE temp_process_task_record SET process_task_order_num = temp_process_task_order_num WHERE process_task_id = temp_process_task_order_id;
   
    SET temp_process_task_state = NULL;
    
       SELECT DISTINCT fort_process_task_instance.fort_process_task_instance_id INTO temp_process_task_state  FROM fort_process_task_instance WHERE 
       fort_process_task_instance.fort_process_task_id = temp_process_task_order_id AND 
       fort_process_task_instance.fort_process_instance_id =fort_process_instance_id  LIMIT 1;
       
    IF (temp_process_task_state IS NULL ) THEN 
    
     INSERT INTO temp_process_task_record( process_task_name,user_id,user_name,user_account,approval_result,process_task_id ,
     user_department_full,process_task_rule )
         
         SELECT fort_process_task.fort_process_task_name,fort_task_participant.fort_user_id ,
               fort_user.fort_user_name ,fort_user.fort_user_account,'noStart',fort_process_task.fort_process_task_id,
               fort_department.fort_full_name,fort_process_task.fort_concurrent_rule
               
       FROM fort_process_task,fort_task_participant,fort_user,fort_department
       WHERE 
      fort_process_task.fort_process_task_id = fort_task_participant.fort_process_task_id
       AND fort_task_participant.fort_user_id = fort_user.fort_user_id
       AND fort_process_task.fort_process_task_id =temp_process_task_order_id 
       AND fort_department.fort_department_id = fort_user.fort_department_id ;
       
       UPDATE temp_process_task_record SET process_task_order_num = temp_process_task_order_num WHERE process_task_id = temp_process_task_order_id;
    
    
    END IF;
    
    
    END LOOP myLoop; 
                                             
   CLOSE cur1;  
   
   
   SELECT DISTINCT * FROM temp_process_task_record ORDER BY process_task_order_num DESC;
   DROP TABLE temp_process_task_record;
   
   SET autocommit = 1;
    
    END$$

DELIMITER ;



DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `selectResourceAccounts`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `selectResourceAccounts`(IN Ids VARCHAR(10000))
BEGIN
      DECLARE temp_resource_id VARCHAR(50);
      DECLARE temp_resource_type_parent_id VARCHAR(50);
      DECLARE temp_resource_parent_id VARCHAR(50);
      DECLARE isYuKong INT DEFAULT 0;  
      DECLARE num INT DEFAULT 0;      
      DECLARE done INT DEFAULT 0; 
     
      DECLARE cur1 CURSOR FOR SELECT resource_id FROM resource_ids;
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1;          
     
      DROP TEMPORARY TABLE IF EXISTS resource_ids;  
      CREATE TEMPORARY TABLE resource_ids(
         resource_id  VARCHAR(32) 
    );
    
    DROP TEMPORARY TABLE IF EXISTS temp_resource;    
    CREATE TEMPORARY TABLE temp_resource(
        fort_resource_name VARCHAR(32), 
	fort_resource_ip VARCHAR(32),
	fort_database_name VARCHAR(32), 
	fort_resource_type_name VARCHAR(32),
	fort_department_name VARCHAR(32),	
	fort_parent_ip VARCHAR(16),
	fort_account_name VARCHAR(32),
	fort_is_allow_authorized VARCHAR(32),
	fort_account_password VARCHAR(256)
       );      
     SET @resource_ids = CONCAT(CONCAT("insert into resource_ids values('",REPLACE(Ids,',',"'),('")),"')"); 
     PREPARE stmt FROM  @resource_ids; 
     EXECUTE stmt;      
     DEALLOCATE PREPARE stmt;        
     
    
   OPEN cur1;  
      approveLoop: LOOP  
             
        SET  done = 0; 
        FETCH cur1 INTO temp_resource_id;
        
        
      IF done = 1 THEN  
            LEAVE approveLoop;  
      END IF;
    
      #查询资源类型父ID
      SELECT fort_resource_type.fort_parent_id INTO temp_resource_type_parent_id FROM fort_resource_type WHERE fort_resource_type.fort_resource_type_id IN 
      (SELECT fort_resource.fort_resource_type_id FROM fort_resource WHERE fort_resource.fort_resource_id=temp_resource_id);
       #查询资源父ID
       SELECT fort_parent_id INTO temp_resource_parent_id FROM fort_resource WHERE fort_resource_id=temp_resource_id;
      
      IF temp_resource_type_parent_id ='1000000000005'&& temp_resource_parent_id IS NOT NULL THEN
       SET isYuKong = 1;
      END IF;
      
      #独立主机及其它资源
      IF temp_resource_type_parent_id !='1000000000005' || isYuKong=0 THEN
      SELECT COUNT(*) INTO num FROM fort_account WHERE fort_account.fort_resource_id=temp_resource_id; 
      
      IF num=0 THEN
          
          INSERT INTO temp_resource( fort_resource_name,fort_resource_ip,fort_database_name,fort_resource_type_name,fort_department_name,fort_parent_ip)
          SELECT fort_resource.fort_resource_name,fort_resource.fort_resource_ip,fort_resource.fort_database_name,fort_resource_type.fort_resource_type_name,fort_department.fort_department_name,
          (CASE WHEN fort_resource.fort_parent_id IS NULL THEN NULL ELSE (
	SELECT a.fort_resource_ip FROM fort_resource a WHERE a.fort_resource_id = fort_resource.fort_parent_id) END) fort_another_ip FROM fort_resource,
	fort_department,fort_resource_type WHERE fort_resource_type.fort_resource_type_id = fort_resource.fort_resource_type_id
 	AND fort_department.fort_department_id=fort_resource.fort_department_id AND fort_resource.fort_resource_id=temp_resource_id;
      
      END IF;
      IF num>0 THEN 
       
        INSERT INTO temp_resource( fort_resource_name,fort_resource_ip,fort_database_name,fort_resource_type_name,fort_department_name,fort_parent_ip,fort_account_name,fort_account_password,fort_is_allow_authorized)
          SELECT fort_resource.fort_resource_name,fort_resource.fort_resource_ip,fort_resource.fort_database_name,fort_resource_type.fort_resource_type_name,fort_department.fort_department_name,
          (CASE WHEN fort_resource.fort_parent_id IS NULL THEN NULL ELSE (
	SELECT a.fort_resource_ip FROM fort_resource a WHERE a.fort_resource_id = fort_resource.fort_parent_id) END) fort_another_ip,fort_account.fort_account_name,
	fort_account.fort_account_password,fort_account.fort_is_allow_authorized FROM fort_resource,
	fort_department,fort_resource_type,fort_account WHERE fort_account.fort_resource_id = fort_resource.fort_resource_id AND fort_resource_type.fort_resource_type_id = fort_resource.fort_resource_type_id
 	AND fort_department.fort_department_id=fort_resource.fort_department_id AND fort_resource.fort_resource_id=temp_resource_id;
      END IF;
    END IF;
    
    #域内主机
    IF isYuKong = 1 THEN
      #   SELECT COUNT(*) INTO num FROM fort_account WHERE fort_account.fort_resource_id=temp_resource_parent_id; 
     
  
     #  IF num=0 THEN
          
          INSERT INTO temp_resource( fort_resource_name,fort_resource_ip,fort_database_name,fort_resource_type_name,fort_department_name,fort_parent_ip)
          SELECT fort_resource.fort_resource_name,fort_resource.fort_resource_ip,fort_resource.fort_database_name,fort_resource_type.fort_resource_type_name,fort_department.fort_department_name,
          (CASE WHEN fort_resource.fort_parent_id IS NULL THEN NULL ELSE (
	SELECT a.fort_resource_ip FROM fort_resource a WHERE a.fort_resource_id = fort_resource.fort_parent_id) END) fort_another_ip FROM fort_resource,
	fort_department,fort_resource_type WHERE fort_resource_type.fort_resource_type_id = fort_resource.fort_resource_type_id
 	AND fort_department.fort_department_id=fort_resource.fort_department_id AND fort_resource.fort_resource_id=temp_resource_id;
      
    #  END IF;
   #   IF num>0 THEN 
       
    #    INSERT INTO temp_resource( fort_resource_name,fort_resource_ip,fort_database_name,fort_resource_type_name,fort_department_name,fort_parent_ip,fort_account_name,fort_account_password,fort_is_allow_authorized)
    #      SELECT fort_resource.fort_resource_name,fort_resource.fort_resource_ip,fort_resource.fort_database_name,fort_resource_type.fort_resource_type_name,fort_department.fort_department_name,
    #      (CASE WHEN fort_resource.fort_parent_id IS NULL THEN NULL ELSE (
#	SELECT a.fort_resource_ip FROM fort_resource a WHERE a.fort_resource_id = fort_resource.fort_parent_id) END) fort_another_ip,fort_account.fort_account_name,
#       fort_account.fort_account_password,fort_account.fort_is_allow_authorized FROM fort_resource,
#	fort_department,fort_resource_type,fort_account WHERE fort_account.fort_resource_id = fort_resource.fort_parent_id AND fort_resource_type.fort_resource_type_id = fort_resource.fort_resource_type_id
 #	AND fort_department.fort_department_id=fort_resource.fort_department_id AND fort_resource.fort_resource_id=temp_resource_id;
 #     END IF;
      
    END IF;    
     
    
     END LOOP approveLoop;         
  CLOSE cur1;  
    SELECT DISTINCT * FROM temp_resource;
      DROP TABLE temp_resource;
      DROP TABLE resource_ids;  
 END$$

DELIMITER ;


DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `selectOperatorClientByQuery`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `selectOperatorClientByQuery`(IN fort_resource_id VARCHAR(100),IN fort_resource_type_id VARCHAR(100),IN fort_user_id VARCHAR(100),IN fort_account_id VARCHAR(100),IN fort_web_session VARCHAR(100))
BEGIN   
    
   
     DECLARE temp_superior_process_status VARCHAR(10);
     DECLARE temp_superior_process_id VARCHAR(50);
      
      
     DROP TEMPORARY TABLE IF EXISTS temp_protocol_client_table; 
      
      CREATE TEMPORARY TABLE temp_protocol_client_table(
          id VARCHAR(24) 
         , fort_approve_clicent VARCHAR(24) 
         , fort_approve_state VARCHAR(24)   
         ,fort_protocol_client TEXT 
         ,fort_operations_protocol TEXT 
       );
       
         SET autocommit = 0;
         
         
     INSERT INTO temp_protocol_client_table(id) VALUES('100001');
     
  
     CALL hasProcessId(fort_user_id,fort_account_id,fort_resource_id,temp_superior_process_id);
           
    IF (temp_superior_process_id  IS  NULL  )  THEN 
        
           CALL selectClientByDoubleApprove(fort_resource_id,fort_resource_type_id,fort_user_id,fort_account_id,fort_web_session);
     
     END IF;      
            
     IF (temp_superior_process_id  IS NOT NULL  )  THEN 
       
           CALL selectSuperiorApproval(fort_user_id,fort_account_id,temp_superior_process_id,fort_web_session,fort_resource_id,temp_superior_process_status);
     
     END IF;     
     # 访问审批 为2 紧急访问审批 4  双人为 8 如果访问审批和紧急都出现值为24 访问审批和双人 28   
         
     IF (temp_superior_process_id  IS NOT NULL &&  temp_superior_process_status = '0')  THEN 
             UPDATE  temp_protocol_client_table SET fort_approve_clicent = '2' WHERE id = '100001' ;
             CALL selectClientByDoubleApprove(fort_resource_id,fort_resource_type_id,fort_user_id,fort_account_id,fort_web_session);
     END IF;      
    
     IF (temp_superior_process_id  IS NOT NULL &&  temp_superior_process_status = '1')  THEN 
     
            UPDATE  temp_protocol_client_table SET fort_approve_clicent = '2' WHERE id = '100001' ;
            CALL selectClientByDoubleApprove(fort_resource_id,fort_resource_type_id,fort_user_id,fort_account_id,fort_web_session);
     
     END IF;  
    
     IF (temp_superior_process_id  IS NOT NULL &&  temp_superior_process_status = '2')  THEN 
       
          UPDATE  temp_protocol_client_table SET fort_approve_clicent = '24' WHERE id = '100001' ;
     
     END IF;  
   
      
    SELECT  id,fort_protocol_client,fort_operations_protocol,fort_approve_clicent,fort_approve_state FROM temp_protocol_client_table ORDER BY fort_operations_protocol; 
    DROP TABLE temp_protocol_client_table;
   
    SET autocommit = 1;
    
    
    END$$

DELIMITER ;


DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `hasDoubleApproverId`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `hasDoubleApproverId`(IN userId VARCHAR(32),IN accountId VARCHAR(32),IN resourceId VARCHAR(32),OUT double_approve_id VARCHAR(32) )
BEGIN   
      DECLARE temp_auth_id VARCHAR(32);
   
      DECLARE temp_double_id VARCHAR(32);
     
      DECLARE temp_count VARCHAR(5);   
      
      DECLARE temp_double_count INTEGER;  
     
      DECLARE temp_is_candidate INTEGER;   
      
      DECLARE done INT DEFAULT 0; 
     
      
 
      DECLARE cur1 CURSOR FOR SELECT authorizationId FROM authorizationIdBySelectUserIdAndAccount;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1;      
   
    DROP TEMPORARY TABLE IF EXISTS temp_double_process;   
    CREATE TEMPORARY TABLE temp_double_process(
            double_approver_id VARCHAR(32)
       ); 
       
    DROP TEMPORARY TABLE IF EXISTS authorizationIdBySelectUserIdAndAccount;   
    CREATE TEMPORARY TABLE authorizationIdBySelectUserIdAndAccount(
            authorizationId VARCHAR(100)
     )ENGINE=MEMORY;     
      
     CALL selectAuthIdByUserIdAndAccountId(userId,accountId,resourceId);
      
      
      OPEN cur1;
      
    approveLoop: LOOP  
          SET done=0;      
        FETCH cur1 INTO temp_auth_id;
        
        IF done = 1 THEN  
                LEAVE approveLoop;  
            END IF;
            
        SELECT fort_authorization_id INTO temp_double_id FROM fort_authorization WHERE 
             fort_authorization.fort_authorization_id = temp_auth_id AND fort_authorization.fort_double_is_open = '1' ;
             
     SELECT COUNT(DISTINCT fort_double_approval_id) INTO temp_double_count FROM fort_double_approval WHERE 
           fort_double_approval.fort_authorization_id = temp_auth_id  AND fort_double_approval.fort_is_approver = '1' 
            AND fort_double_approval.fort_user_id <>  userId; 
      
              
     SELECT COUNT(DISTINCT fort_double_approval_id) INTO temp_is_candidate FROM fort_double_approval WHERE 
           fort_double_approval.fort_authorization_id = temp_auth_id  AND fort_double_approval.fort_is_candidate = '1'
            AND fort_double_approval.fort_user_id =  userId ;   
                
                IF (  temp_double_id IS NOT NULL &&   temp_double_count > 0 && temp_is_candidate > 0) THEN
                   INSERT INTO temp_double_process(double_approver_id) VALUES(temp_double_id);
                   
               END IF;
  
    END LOOP approveLoop;
        
        
    
      
    CLOSE cur1;       
        SELECT COUNT(DISTINCT double_approver_id) INTO double_approve_id FROM temp_double_process;
     
      DROP TABLE temp_double_process;
  
    END$$

DELIMITER ;


DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `selectClientByDoubleApprove`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `selectClientByDoubleApprove`(IN fort_resource_id VARCHAR(100),IN fort_resource_type_id VARCHAR(100),IN fort_user_id VARCHAR(100),IN fort_account_id VARCHAR(100),IN fort_web_session VARCHAR(100))
BEGIN   
     
     DECLARE temp_num INTEGER;
     DECLARE temp_double_user INTEGER;
     DECLARE temp_status VARCHAR(10);     
     DECLARE temp_approve_clicent VARCHAR(10); 
     
     CALL hasDoubleApproverId(fort_user_id,fort_account_id,fort_resource_id,temp_num) ;
    
    IF (temp_num = 0 ) THEN
    
        
       CALL selectClientByresourceIdAndResouceTypeId(fort_resource_id,fort_resource_type_id);
     
     END IF;
     
  IF ( temp_num > 0 ) THEN 
      CALL selectApproverStatus(fort_user_id,fort_account_id,fort_resource_id,fort_web_session,temp_status);
    
      SELECT fort_approve_clicent INTO temp_approve_clicent FROM temp_protocol_client_table WHERE id = '100001';
      IF (temp_approve_clicent IS NULL) THEN
      
         SET  temp_approve_clicent = '';
      END IF;   
    
     IF (temp_status <> 2 || temp_status IS NULL )  THEN 
     
            SET temp_approve_clicent = CONCAT(temp_approve_clicent,'8'); 
            UPDATE  temp_protocol_client_table SET fort_approve_clicent = temp_approve_clicent,fort_approve_state = temp_status WHERE id = '100001' ;
     
     END IF;  
     
     IF (temp_status = 2) THEN  
               
             CALL selectClientByresourceIdAndResouceTypeId(fort_resource_id,fort_resource_type_id);
                 
      END IF;
        
   END IF;    
 
    END$$

DELIMITER ;



DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `selectAuthIdByUserIdAndAccountId`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `selectAuthIdByUserIdAndAccountId`(IN userId VARCHAR(32),IN accountId VARCHAR(32),IN resourceId VARCHAR(32))
BEGIN   
     
      INSERT INTO authorizationIdBySelectUserIdAndAccount SELECT a.fort_authorization_id FROM
(
SELECT fort_authorization_target_proxy.fort_authorization_id FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_target_code='8' 
AND fort_authorization_target_proxy.fort_target_id = accountId AND fort_authorization_target_proxy.fort_parent_id = resourceId
UNION 
SELECT fort_authorization_target_proxy.fort_authorization_id FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_target_code='16'
 AND fort_authorization_target_proxy.fort_target_id = resourceId
UNION
SELECT DISTINCT
     fort_authorization_target_proxy.fort_authorization_id FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_target_code='32' AND fort_authorization_target_proxy.fort_target_id
     IN(SELECT fort_resource_group_resource.fort_resource_group_id FROM fort_resource_group_resource WHERE fort_resource_group_resource.fort_resource_id = resourceId )     
     ) a,
    
     (
    
     SELECT fort_authorization_target_proxy.fort_authorization_id 
     FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_target_code='2' AND fort_authorization_target_proxy.fort_target_id = userId       
      UNION
         SELECT fort_authorization_target_proxy.fort_authorization_id  FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_target_code='4'
          AND fort_authorization_target_proxy.fort_target_id
         IN(SELECT fort_user_group_user.fort_user_group_id FROM fort_user_group_user WHERE fort_user_group_user.fort_user_id = userId)
    
    ) b
    
    WHERE a.fort_authorization_id = b.fort_authorization_id;
     
    END$$

DELIMITER ;



DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `selectApproverStatus`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `selectApproverStatus`(IN fort_user_id VARCHAR(100),IN fort_account_id VARCHAR(100),IN fort_resource_id VARCHAR(100),IN fort_web_session VARCHAR(100),OUT approverStatus INTEGER)
BEGIN 
     SELECT fort_process_instance.fort_state INTO approverStatus FROM  fort_process_instance ,fort_double_approval_application
     WHERE fort_double_approval_application.fort_account_id = fort_account_id 
     AND fort_double_approval_application.fort_resource_id = fort_resource_id
     AND fort_double_approval_application.fort_applicant_id = fort_user_id  
     AND fort_double_approval_application.fort_web_session = fort_web_session
     AND fort_double_approval_application.fort_session IS NULL 
    AND fort_double_approval_application.fort_process_instance_id = fort_process_instance.fort_process_instance_id 
    ORDER BY fort_process_instance.fort_end_time DESC,fort_apply_create_time DESC LIMIT 1 ;
   
    END$$

DELIMITER ;



DELIMITER $$

USE `fort`$$

DROP PROCEDURE IF EXISTS `hasProcessId`$$

CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `hasProcessId`(IN userId VARCHAR(32),IN accountId VARCHAR(32),IN resourceId VARCHAR(32),OUT processId VARCHAR(32))
BEGIN   
      DECLARE temp_auth_id VARCHAR(50);
      DECLARE temp_process_id VARCHAR(50);
      DECLARE temp_superior_state VARCHAR(50);
      DECLARE temp_user_sum INT;
      DECLARE temp_second_user_id VARCHAR(50);
      DECLARE temp_approver_name VARCHAR(50);
      DECLARE temp_approver_password VARCHAR(50);      
      DECLARE done INT DEFAULT 0; 
     
      
 /*  设置游标*/
      DECLARE cur1 CURSOR FOR SELECT a.fort_authorization_id FROM
(
SELECT fort_authorization_target_proxy.fort_authorization_id FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_target_code='8' 
 AND fort_authorization_target_proxy.fort_target_id = accountId AND fort_authorization_target_proxy.fort_parent_id = resourceId
UNION 
SELECT fort_authorization_target_proxy.fort_authorization_id FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_target_code='16' 
AND fort_authorization_target_proxy.fort_target_id = resourceId
UNION
SELECT DISTINCT
     fort_authorization_target_proxy.fort_authorization_id FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_target_code='32' AND fort_authorization_target_proxy.fort_target_id
     IN(SELECT fort_resource_group_resource.fort_resource_group_id FROM fort_resource_group_resource WHERE fort_resource_group_resource.fort_resource_id = resourceId )     
     ) a,
    
     (
    
     SELECT fort_authorization_target_proxy.fort_authorization_id 
     FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_target_code='2' AND fort_authorization_target_proxy.fort_target_id = userId       
      UNION
         SELECT fort_authorization_target_proxy.fort_authorization_id  FROM fort_authorization_target_proxy WHERE fort_authorization_target_proxy.fort_target_code='4'
          AND fort_authorization_target_proxy.fort_target_id
         IN(SELECT fort_user_group_user.fort_user_group_id FROM fort_user_group_user WHERE fort_user_group_user.fort_user_id = userId)
    
    ) b
    
    WHERE a.fort_authorization_id = b.fort_authorization_id;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1;      
   /* 打开游标 */
    DROP TEMPORARY TABLE IF EXISTS temp_process;    
    CREATE TEMPORARY TABLE temp_process(
            process_id VARCHAR(600)
       )ENGINE=MEMORY;  
      
      OPEN cur1;
    /* 循环开始 */  
    approveLoop: LOOP  
              SET done = 0;
              
           FETCH cur1 INTO temp_auth_id;
                
          IF done = 1 THEN  
            LEAVE approveLoop;  
           END IF;
           
                SELECT fort_superior_process_id INTO temp_process_id FROM fort_authorization WHERE fort_authorization_id = temp_auth_id;
             
                SELECT fort_state INTO temp_superior_state FROM fort_process WHERE fort_process_id = temp_process_id;
                
                IF temp_superior_state = 1 THEN
                   INSERT INTO temp_process(process_id) VALUES(temp_process_id);
                   
               END IF;
       
    END LOOP approveLoop;
    
        
    
    /* 关闭游标 */  
    CLOSE cur1;   
    
     
    SELECT DISTINCT(process_id) INTO processId FROM  temp_process LIMIT 1;
     DROP TABLE temp_process;
    END$$

DELIMITER ;