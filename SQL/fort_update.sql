USE `fort`;

SET FOREIGN_KEY_CHECKS = 0; 
SET unique_checks=0; 




ALTER TABLE fort_department ADD fort_order INT COMMENT '排序';

ALTER TABLE fort_privilege ADD fort_privilege_name_enus  VARCHAR(32) COMMENT '权限英文名称';
ALTER TABLE fort_privilege MODIFY fort_privilege_code  VARCHAR(64) NOT NULL COMMENT '权限代码';
ALTER TABLE fort_privilege ADD fort_privilege_role_type   VARCHAR(1) COMMENT '权限角色类型（1:系统级2部门级3系统级+部门级）';

DROP TABLE IF EXISTS fort_privilege_mutex_target_proxy;
DROP TABLE IF EXISTS fort_privilege_mutex;


ALTER TABLE fort_audit_log ADD  fort_file_server     VARCHAR(6) COMMENT '文件服务器';


ALTER TABLE fort_resource_group ADD fort_order INT COMMENT '排序';

ALTER TABLE fort_resource_type ADD fort_resource_type_name_enus VARCHAR(32) COMMENT '资源类型英文名称';

ALTER TABLE fort_role MODIFY fort_role_type VARCHAR(1) COMMENT '角色类型(0:初始化1:系统级2:部门级3:默认角色)';

ALTER TABLE fort_role_authorization_scope DROP COLUMN fort_role_name;
ALTER TABLE fort_role_authorization_scope DROP COLUMN fort_controllable_role_name;

DROP TABLE IF EXISTS fort_role_mutex;
CREATE TABLE fort_role_mutex
(
   fort_role_mutex_id   VARCHAR(24) NOT NULL COMMENT '角色互斥ID',
   fort_role_id         VARCHAR(24) NOT NULL COMMENT '角色ID',
   fort_mutex_role_id   VARCHAR(24) NOT NULL COMMENT '互斥角色ID',
   PRIMARY KEY (fort_role_mutex_id)
);
ALTER TABLE fort_role_mutex COMMENT '角色互斥';

ALTER TABLE fort_system_alarm ADD fort_host_name  VARCHAR(32) COMMENT '主机名';

DROP TABLE IF EXISTS fort_three_uniform_user;
CREATE TABLE fort_three_uniform_user
(
   fort_three_uniform_user_id VARCHAR(24) NOT NULL COMMENT '三统一用户ID',
   fort_user_id         VARCHAR(24) COMMENT '用户ID',
   fort_user_account    VARCHAR(32) COMMENT '用户帐号',
   fort_guid            VARCHAR(36) COMMENT '认证标识',
   fort_user_guid       VARCHAR(36) COMMENT '人员标识',
   fort_logon_name      VARCHAR(36) COMMENT '登录名称',
   fort_user_type       VARCHAR(1) COMMENT '用户类型（0.新发现 1.已导入 2.排除）',
   fort_create_date     DATETIME COMMENT '创建时间',
   fort_last_edit_date  DATETIME COMMENT '修改时间',
   PRIMARY KEY (fort_three_uniform_user_id)
);

ALTER TABLE fort_three_uniform_user COMMENT '三统一同步用户';
ALTER TABLE fort_three_uniform_user ADD CONSTRAINT FK_USER_REL_THREE_UNIFORM FOREIGN KEY (fort_user_id)
      REFERENCES fort_user (fort_user_id) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE fort_user_group ADD fort_order  INT COMMENT '排序';


INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1001010000001', 'SSO:命令详情', NULL, 'm_sso:commandDetail', '3', '1', '1001010000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1001010000002', 'SSO:回放', NULL, 'm_sso:playback', '3', '1', '1001010000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1001010000003', 'SSO:下载', NULL, 'm_sso:download', '3', '1', '1001010000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1001010000004', 'SSO:审批记录', NULL, 'm_sso:examRecord', '3', '1', '1001010000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1001010000005', 'SSO:查看历史', NULL, 'm_sso:history', '3', '1', '1001010000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1001010000006', 'SSO:键盘记录', NULL, 'm_sso:keyboardRecord', '3', '1', '1001010000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1001010000007', 'SSO:文件传输', NULL, 'm_sso:fileTransmission', '3', '1', '1001010000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1001010000008', 'SSO:行为指引', NULL, 'm_sso:behaviorGuide', '3', '1', '1001010000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1001010000009', 'SSO:补充运维备注信息', NULL, 'm_sso:supOpeRemInfo', '3', '1', '1001010000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1001010000010', 'SSO:监控', NULL, 'm_sso:monitor', '3', '1', '1001010000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1001010000011', 'SSO:窗体识别', NULL, 'm_sso:formRecognition', '3', '1', '1001010000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1001010000012', 'SSO:剪切板', NULL, 'm_sso:cutBoad', '3', '1', '1001010000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1001010000013', 'SSO:阻断', NULL, 'm_sso:interdict', '3', '1', '1001010000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002010100001', '部门:添加', NULL, 'm_department:add', '3', '1', '1002010100000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002010100002', '部门:编辑', NULL, 'm_department:edit', '3', '1', '1002010100000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002010100003', '部门:删除', NULL, 'm_department:delete', '3', '1', '1002010100000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002010200001', '资源组:添加资源组', NULL, 'm_resource_group:addResGroup', '3', '2', '1002010200000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002010200002', '资源组:编辑资源组', NULL, 'm_resource_group:editResGroup', '3', '2', '1002010200000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002010200003', '资源组:删除资源组', NULL, 'm_resource_group:deleteResGroup', '3', '2', '1002010200000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002010200004', '资源组:添加资源', NULL, 'm_resource_group:addResource', '3', '2', '1002010200000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002010200005', '资源组:删除资源', NULL, 'm_resource_group:deleteResource', '3', '2', '1002010200000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002010300001', '用户组:添加用户组', NULL, 'm_user_group:addUserGroup', '3', '2', '1002010300000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002010300002', '用户组:编辑用户组', NULL, 'm_user_group:editUserGroup', '3', '2', '1002010300000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002010300003', '用户组:删除用户组', NULL, 'm_user_group:deleteUserGroup', '3', '2', '1002010300000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002010300004', '用户组:添加用户', NULL, 'm_user_group:addUser', '3', '2', '1002010300000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002010300005', '用户组:删除用户', NULL, 'm_user_group:deleteUser', '3', '2', '1002010300000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002020000001', '用户:添加', NULL, 'm_user:add', '3', '3', '1002020000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002020000002', '用户:删除', NULL, 'm_user:delete', '3', '3', '1002020000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002020000003', '用户:编辑', NULL, 'm_user:edit', '3', '3', '1002020000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002020000004', '用户:导入', NULL, 'm_user:import', '3', '3', '1002020000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002020000005', '用户:导出', NULL, 'm_user:export', '3', '3', '1002020000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002020000006', '用户:导入模板下载', NULL, 'm_user:impTempDownload', '3', '3', '1002020000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002020000007', '用户:打印密码信封', NULL, 'm_user:printPwdEnvelope', '3', '3', '1002020000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002020000008', '用户:角色', NULL, 'm_user:editRole', '3', '3', '1002020000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002020000009', '用户:用户状态', NULL, 'm_user:userState', '3', '3', '1002020000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002020000010', '用户:证书', NULL, 'm_user:certificate', '3', '3', '1002020000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002030000001', '资源:添加', NULL, 'm_resource:add', '3', '2', '1002030000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002030000002', '资源:删除', NULL, 'm_resource:delete', '3', '2', '1002030000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002030000003', '资源:编辑', NULL, 'm_resource:edit', '3', '2', '1002030000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002030000004', '资源:资源自动发现', NULL, 'm_resource:resAutomaticFind', '3', '2', '1002030000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002030000005', '资源:导入', NULL, 'm_resource:import', '3', '2', '1002030000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002030000006', '资源:导出', NULL, 'm_resource:export', '3', '2', '1002030000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002030000007', '资源:导入模板下载', NULL, 'm_resource:impTempDownload', '3', '2', '1002030000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002030000008', '资源:打印密码信封', NULL, 'm_resource:printPwdEnvelope', '3', '2', '1002030000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002030000009', '资源:帐号添加', NULL, 'm_resource:accountAdd', '3', '2', '1002030000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002030000010', '资源:帐号删除', NULL, 'm_resource:accountDelete', '3', '2', '1002030000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002030000011', '资源:帐号编辑', NULL, 'm_resource:accountEdit', '3', '2', '1002030000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002030000012', '资源:发现帐号', NULL, 'm_resource:findAccount', '3', '2', '1002030000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002030000013', '资源:帐号打印密码信封', NULL, 'm_resource:accPrintPwdEnve', '3', '2', '1002030000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002030000014', '资源:帐号是否可授权', NULL, 'm_resource:accWhetherAuth', '3', '2', '1002030000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002040000001', '授权:授权报表', NULL, 'm_authorization:authReportForms', '3', '2', '1002040000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002040000002', '授权:导出', NULL, 'm_authorization:export', '3', '2', '1002040000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002040000003', '授权:导入', NULL, 'm_authorization:import', '3', '2', '1002040000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002040000004', '授权:添加', NULL, 'm_authorization:add', '3', '2', '1002040000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002040000005', '授权:删除', NULL, 'm_authorization:delete', '3', '2', '1002040000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002040000006', '授权:编辑', NULL, 'm_authorization:edit', '3', '2', '1002040000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002040000007', '授权:保存访问审批', NULL, 'm_authorization:saveVisitExam', '3', '2', '1002040000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002040000008', '授权:编辑双人授权', NULL, 'm_authorization:doubleAuth', '3', '2', '1002040000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002040000009', '授权:可访问外部授权报表', NULL, 'm_authorization:canVisitOutAuthForm', '3', '2', '1002040000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002050100001', '命令规则:添加', NULL, 'm_command_rule:add', '3', '2', '1002050100000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002050100002', '命令规则:删除', NULL, 'm_command_rule:delete', '3', '2', '1002050100000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002050100003', '命令规则:编辑', NULL, 'm_command_rule:edit', '3', '2', '1002050100000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002050100004', '命令规则:排序', NULL, 'm_command_rule:sort', '3', '2', '1002050100000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002050100005', '命令规则:状态', NULL, 'm_command_rule:state', '3', '2', '1002050100000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002050200001', '时间规则:添加', NULL, 'm_time_rule:add', '3', '2', '1002050200000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002050200002', '时间规则:删除', NULL, 'm_time_rule:delete', '3', '2', '1002050200000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002050200003', '时间规则:编辑', NULL, 'm_time_rule:edit', '3', '2', '1002050200000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002050300001', '地址规则:添加', NULL, 'm_address_rule:add', '3', '2', '1002050300000', 'operationsManagement/rule/address/rule-address-list');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002050300002', '地址规则:删除', NULL, 'm_address_rule:delete', '3', '2', '1002050300000', 'operationsManagement/rule/address/rule-address-list');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002050300003', '地址规则:编辑', NULL, 'm_address_rule:edit', '3', '2', '1002050300000', 'operationsManagement/rule/address/rule-address-list');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002050400001', '资源时间规则:添加', NULL, 'm_time_resource_rule:add', '3', '2', '1002050400000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002050400002', '资源时间规则:删除', NULL, 'm_time_resource_rule:delete', '3', '2', '1002050400000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002050400003', '资源时间规则:编辑', NULL, 'm_time_resource_rule:edit', '3', '2', '1002050400000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002050400004', '资源时间规则:排序', NULL, 'm_time_resource_rule:sort', '3', '2', '1002050400000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002050400005', '资源时间规则:默认动作', NULL, 'm_time_resource_rule:defaultAction', '3', '2', '1002050400000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002060100001', '行为指引类型:添加', NULL, 'm_behavior_guideline_type:add', '3', '2', '1002060100000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002060100002', '行为指引类型:删除', NULL, 'm_behavior_guideline_type:delete', '3', '2', '1002060100000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002060100003', '行为指引类型:编辑', NULL, 'm_behavior_guideline_type:edit', '3', '2', '1002060100000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002060200001', '命令库定义:导入命令库', NULL, 'm_behavior_guideline_command:importCommLib', '3', '2', '1002060200000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002060200002', '命令库定义:导出命令库', NULL, 'm_behavior_guideline_command:exportCommLib', '3', '2', '1002060200000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002060200003', '命令库定义:添加', NULL, 'm_behavior_guideline_command:add', '3', '2', '1002060200000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002060200004', '命令库定义:删除', NULL, 'm_behavior_guideline_command:delete', '3', '2', '1002060200000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002060200005', '命令库定义:编辑', NULL, 'm_behavior_guideline_command:edit', '3', '2', '1002060200000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002060200006', '命令库定义:添加命令选项', NULL, 'm_behavior_guideline_command:addCommOption', '3', '2', '1002060200000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002060200007', '命令库定义:删除命令选项', NULL, 'm_behavior_guideline_command:deleteCommOption', '3', '2', '1002060200000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002060200008', '命令库定义:编辑命令选项', NULL, 'm_behavior_guideline_command:editCommOption', '3', '2', '1002060200000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002060300001', '行为指引:添加', NULL, 'm_behavior_guideline:add', '3', '2', '1002060300000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002060300002', '行为指引:删除', NULL, 'm_behavior_guideline:delete', '3', '2', '1002060300000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002060300003', '行为指引:编辑', NULL, 'm_behavior_guideline:edit', '3', '2', '1002060300000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002060300004', '行为指引:停用或启用', NULL, 'm_behavior_guideline:stopOrStart', '3', '2', '1002060300000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1003010000001', '运维审计:审计删除', NULL, 'm_audit:auditDelete', '3', '1', '1003010000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1003010000002', '运维审计:命令详情', '', 'm_audit:commandDetail', '3', '3', '1003010000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1003010000003', '运维审计:回放', '', 'm_audit:playback', '3', '3', '1003010000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1003010000004', '运维审计:下载', '', 'm_audit:download', '3', '3', '1003010000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1003010000005', '运维审计:审批记录', '', 'm_audit:examRecord', '3', '3', '1003010000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1003010000006', '运维审计:查看历史', '', 'm_audit:history', '3', '3', '1003010000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1003010000007', '运维审计:键盘记录', '', 'm_audit:keyboardRecord', '3', '3', '1003010000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1003010000008', '运维审计:文件传输', '', 'm_audit:fileTransmission', '3', '3', '1003010000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1003010000009', '运维审计:行为指引', '', 'm_audit:behaviorGuide', '3', '3', '1003010000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1003010000010', '运维审计:补充运维备注信息', '', 'm_audit:supOpeRemInfo', '3', '3', '1003010000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1003010000011', '运维审计:监控', '', 'm_audit:monitor', '3', '3', '1003010000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1003010000012', '运维审计:窗体识别', NULL, 'm_audit:formRecognition', '3', '3', '1003010000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1003010000013', '运维审计:剪切板', '', 'm_audit:cutBoad', '3', '3', '1003010000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1003010000014', '运维审计:阻断', '', 'm_audit:interdict', '3', '3', '1003010000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1003010000015', '运维审计:指引提取', '', 'm_audit:extract', '3', '3', '1003010000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1003030000001', '告警归纳:查看详情', NULL, 'm_alarm:detail', '3', '3', '1003030000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1004010000001', '流程任务:查看详情', NULL, 'm_process_approval:detail', '3', '3', '1004010000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1004010000002', '流程任务:审批记录', NULL, 'm_process_approval:auditRecord', '3', '3', '1004010000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1004030000001', '申请历史:查看详情', NULL, 'm_personal_process:detail', '3', '3', '1004030000000', '');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1004030000002', '申请历史:审批记录', NULL, 'm_personal_process:auditRecord', '3', '3', '1004030000000', '');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1004040000001', '个人历史:查看详情', NULL, 'm_personal_history:detail', '3', '3', '1004040000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1004040000002', '个人历史:审批记录', NULL, 'm_personal_history:auditRecord', '3', '3', '1004040000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1004050000001', '部门历史:查看详情', NULL, 'm_department_history:detail', '3', '2', '1004050000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1004050000002', '部门历史:审批记录', NULL, 'm_department_history:auditRecord', '3', '2', '1004050000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1004060000001', '全部历史:查看详情', NULL, 'm_all_history:detail', '3', '1', '1004060000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1004060000002', '全部历史:审批记录', NULL, 'm_all_history:auditRecord', '3', '1', '1004060000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1005010100001', '口令修改计划:添加', NULL, 'm_password_modify_plan:add', '3', '2', '1005010100000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1005010100002', '口令修改计划:删除', NULL, 'm_password_modify_plan:delete', '3', '2', '1005010100000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1005010100003', '口令修改计划:编辑', NULL, 'm_password_modify_plan:edit', '3', '2', '1005010100000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1005010100004', '口令修改计划:备份文件查看', NULL, 'm_password_modify_plan:backupFileView', '3', '2', '1005010100000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1005010100005', '口令修改计划:备份文件删除', NULL, 'm_password_modify_plan:backupFileDelete', '3', '2', '1005010100000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1005010100006', '口令修改计划:备份文件下载', NULL, 'm_password_modify_plan:backupFileDown', '3', '2', '1005010100000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1005010100007', '口令修改计划:立即修改', NULL, 'm_password_modify_plan:immediateUpdate', '3', '2', '1005010100000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1005010100008', '口令修改计划:帐号列表', NULL, 'm_password_modify_plan:accountList', '3', '2', '1005010100000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1005010100009', '口令修改计划:日志', NULL, 'm_password_modify_plan:log', '3', '2', '1005010100000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1005010200001', '口令备份计划:添加', NULL, 'm_password_backup_plan:add', '3', '2', '1005010200000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1005010200002', '口令备份计划:删除', NULL, 'm_password_backup_plan:delete', '3', '2', '1005010200000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1005010200003', '口令备份计划:编辑', NULL, 'm_password_backup_plan:edit', '3', '2', '1005010200000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1005010200004', '口令备份计划:备份文件查看', NULL, 'm_password_backup_plan:backupFileView', '3', '2', '1005010200000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1005010200005', '口令备份计划:备份文件删除', NULL, 'm_password_backup_plan:backupFileDelete', '3', '2', '1005010200000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1005010200006', '口令备份计划:备份文件下载', NULL, 'm_password_backup_plan:backupFileDown', '3', '2', '1005010200000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1005010200007', '口令备份计划:立即备份', NULL, 'm_password_backup_plan:immediateBackup', '3', '2', '1005010200000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1005010200008', '口令备份计划:帐号列表', NULL, 'm_password_backup_plan:accountList', '3', '2', '1005010200000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1005010300001', '口令备份FTP:保存', NULL, 'm_password_backup_ftp:save', '3', '2', '1005010300000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1006010100001', '配置审计报表:添加模板', NULL, 'm_config_audit_report:addTemplet', '3', '3', '1006010100000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1006010100002', '配置审计报表:删除模板', NULL, 'm_config_audit_report:deleteTemplet', '3', '3', '1006010100000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1006010100003', '配置审计报表:查询报表', NULL, 'm_config_audit_report:queryReportForms', '3', '3', '1006010100000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1006010200001', '运维审计报表:添加模板', NULL, 'm_maintain_audit_report:addTemplet', '3', '3', '1006010200000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1006010200002', '运维审计报表:删除模板', NULL, 'm_maintain_audit_report:deleteTemplet', '3', '3', '1006010200000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1006010200003', '运维审计报表:查询报表', NULL, 'm_maintain_audit_report:queryReportForms', '3', '3', '1006010200000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1007010000001', '角色定义:添加', NULL, 'm_role_definition:add', '3', '1', '1007010000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1007010000002', '角色定义:编辑', NULL, 'm_role_definition:edit', '3', '1', '1007010000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1007010000003', '角色定义:删除', NULL, 'm_role_definition:delete', '3', '1', '1007010000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1007020000000', '角色互斥定义', NULL, 'm_role_mutex_definition', '1', '1', '1007000000000', 'role/role-mutex');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1007020000001', '角色互斥定义:保存', NULL, 'm_role_mutex_definition:save', '3', '1', '1007020000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008020100001', 'NTP:保存', NULL, 'm_ntp:save', '3', '1', '1008020100000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008020200001', 'SYSLOG:测试', NULL, 'm_syslog:test', '3', '1', '1008020200000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008020200002', 'SYSLOG:保存', NULL, 'm_syslog:save', '3', '1', '1008020200000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008020300001', '邮件:测试', NULL, 'm_mail:test', '3', '1', '1008020300000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008020300002', '邮件:保存', NULL, 'm_mail:save', '3', '1', '1008020300000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008020400001', '密码信封:保存', NULL, 'm_password_envelop:save', '3', '1', '1008020400000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008020500001', '应用发布:添加', NULL, 'm_app_release:add', '3', '1', '1008020500000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008020500002', '应用发布:编辑', NULL, 'm_app_release:edit', '3', '1', '1008020500000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008020500003', '应用发布:删除', NULL, 'm_app_release:delete', '3', '1', '1008020500000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008030100001', '设备运行状态:查看启动日志', NULL, 'm_device_running_status:startupLog', '3', '1', '1008030100000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008030500001', '关机重启:关机', NULL, 'm_shut_reboot:shutdown', '3', '1', '1008030500000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008030500002', '关机重启:重启', NULL, 'm_shut_reboot:restart', '3', '1', '1008030500000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008040100001', '网卡配置:设置网卡', NULL, 'm_network_card_config:setNetworkCard', '3', '1', '1008040100000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008040100002', '网卡配置:清空网卡', NULL, 'm_network_card_config:clearNetworkCard', '3', '1', '1008040100000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008040200001', '路由配置:添加', NULL, 'm_route_config:add', '3', '1', '1008040200000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008040200002', '路由配置:删除', NULL, 'm_route_config:delete', '3', '1', '1008040200000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008050100001', '配置备份还原:立刻备份', NULL, 'm_config_backup_restore:immeBackup', '3', '1', '1008050100000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008050100002', '配置备份还原:保存', NULL, 'm_config_backup_restore:save', '3', '1', '1008050100000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008050100003', '配置备份还原:备份文件', NULL, 'm_config_backup_restore:backupFile', '3', '1', '1008050100000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008050200001', '初始化设置:还原系统配置', NULL, 'm_restore_setting:resSysConf', '3', '1', '1008050200000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008050200002', '初始化设置:清空数据库', NULL, 'm_restore_setting:clearDataBase', '3', '1', '1008050200000', 'system/backup-restore/restore-factory-settings');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008050200003', '初始化设置:清空审计文件', NULL, 'm_restore_setting:clearAuditFile', '3', '1', '1008050200000', 'system/backup-restore/restore-factory-settings');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008060000001', '客户端配置:添加', NULL, 'm_client_config:add', '3', '1', '1008060000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008060000002', '客户端配置:编辑', NULL, 'm_client_config:edit', '3', '1', '1008060000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008060000003', '客户端配置:删除', NULL, 'm_client_config:delete', '3', '1', '1008060000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008070000001', '双机管理:保存', NULL, 'm_dual_management:save', '3', '1', '1008070000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008080100001', '审计留存:保存', NULL, 'm_audit_retained:save', '3', '1', '1008080100000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008080200001', '审计存储扩展:添加', NULL, 'm_audit_storage_extend:add', '3', '1', '1008080200000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008080200002', '审计存储扩展:删除', NULL, 'm_audit_storage_extend:delete', '3', '1', '1008080200000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008090000001', 'AD定时抽取:立即发现', NULL, 'm_ad_regular_extract:immeFind', '3', '1', '1008090000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008090000002', 'AD定时抽取:周期发现', NULL, 'm_ad_regular_extract:cycleFind', '3', '1', '1008090000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008090000003', 'AD定时抽取:关闭定时', NULL, 'm_ad_regular_extract:closeQuartz', '3', '1', '1008090000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008090000004', 'AD定时抽取:左右移动按钮', NULL, 'm_ad_regular_extract:move', '3', '1', '1008090000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008090000005', 'AD定时抽取:保存策略', NULL, 'm_ad_regular_extract:saveStrategy', '3', '1', '1008090000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008090000006', 'AD定时抽取:清空历史记录', NULL, 'm_ad_regular_extract:clearRecord', '3', '1', '1008090000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008100000001', '使用授权:保存', NULL, 'm_use_authorization:save', '3', '1', '1008100000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008100000002', '使用授权:logo上传', NULL, 'm_use_authorization:logoUpload', '3', '1', '1008100000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008100000003', '使用授权:升级包上传', NULL, 'm_use_authorization:upPackageUpload', '3', '1', '1008100000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008110000001', '集中管理:应用', NULL, 'm_concentration_management:application', '3', '1', '1008110000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008110000002', '集中管理:添加', NULL, 'm_concentration_management:add', '3', '1', '1008110000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008110000003', '集中管理:编辑', NULL, 'm_concentration_management:edit', '3', '1', '1008110000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008110000004', '集中管理:删除设备', NULL, 'm_concentration_management:deleteEquipment', '3', '1', '1008110000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008110000005', '集中管理:上传补丁', NULL, 'm_concentration_management:uploadPatch', '3', '1', '1008110000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008110000006', '集中管理:出厂设置', NULL, 'm_concentration_management:factorySet', '3', '1', '1008110000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008110000007', '集中管理:安装', NULL, 'm_concentration_management:install', '3', '1', '1008110000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008110000008', '集中管理:删除补丁', NULL, 'm_concentration_management:deletePatch', '3', '1', '1008110000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008110000009', '集中管理:卸载', NULL, 'm_concentration_management:uninstall', '3', '1', '1008110000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008110000010', '集中管理:保存', NULL, 'm_concentration_management:save', '3', '1', '1008110000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1009010000001', '认证强度:保存', NULL, 'm_authentication_strength:save', '3', '1', '1009010000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1009020100001', '告警归纳:查看详情', NULL, 'm_alarm_induction:detail', '3', '1', '1009020100000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1009020200001', '告警配置:保存', NULL, 'm_alarm_configuration:save', '3', '1', '1009020200000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1009030000001', '会话配置:查看上级策略', NULL, 'm_session_config:upperStrategy', '3', '1', '1009030000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1009030000002', '会话配置:保存', NULL, 'm_session_config:save', '3', '1', '1009030000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1009040000001', '密码策略:查看上级策略', NULL, 'm_password_strategy:upperStrategy', '3', '1', '1009040000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1009040000002', '密码策略:添加', NULL, 'm_password_strategy:add', '3', '1', '1009040000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1009040000003', '密码策略:编辑', NULL, 'm_password_strategy:edit', '3', '1', '1009040000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1009040000004', '密码策略:删除', NULL, 'm_password_strategy:delete', '3', '1', '1009040000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1009050000001', '审计外发策略:保存', NULL, 'audit_send_strategy:save', '3', '1', '1009050000000', NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('2000000000006', '密码包接收人', NULL, 'password_packet_receiver', '4', NULL, NULL, NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('2000000000007', '密钥接收人', NULL, 'key_receiver', '4', NULL, NULL, NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1010000000000', '三统一用户', NULL, 'three_uniform', '1', '1', NULL, NULL);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1010010000000', '三统一用户同步', NULL, 'three_uniform:user', '1', '1', '1010000000000', '/foreign/threeUniform/threeUniformOperationsManagement/threeUniformUser/user-threeuniform');


INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1005010100010', '口令修改计划:状态', null, 'm_password_modify_plan:state', '3', '2', '1005010100000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1005010200009', '口令备份计划:状态', null, 'm_password_backup_plan:state', '3', '2', '1005010200000', null);

INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000503','1000000000005','1005010100010');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000504','1000000000005','1005010200009');

INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000505','1000000000006','1005010100010');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000506','1000000000006','1005010200009');

UPDATE fort_privilege SET fort_privilege_role_type='1' WHERE fort_privilege_id='1001000000000';
UPDATE fort_privilege SET fort_privilege_role_type='1' WHERE fort_privilege_id='1001010000000';
UPDATE fort_privilege SET fort_privilege_role_type='3' WHERE fort_privilege_id='1002000000000';
UPDATE fort_privilege SET fort_privilege_role_type='3' WHERE fort_privilege_id='1002010000000';
UPDATE fort_privilege SET fort_privilege_role_type='1' WHERE fort_privilege_id='1002010100000';
UPDATE fort_privilege SET fort_privilege_role_type='2' WHERE fort_privilege_id='1002010200000';
UPDATE fort_privilege SET fort_privilege_role_type='2' WHERE fort_privilege_id='1002010300000';
UPDATE fort_privilege SET fort_privilege_role_type='3' WHERE fort_privilege_id='1002020000000';
UPDATE fort_privilege SET fort_privilege_role_type='2' WHERE fort_privilege_id='1002030000000';
UPDATE fort_privilege SET fort_privilege_role_type='2' WHERE fort_privilege_id='1002040000000';  
UPDATE fort_privilege SET fort_privilege_role_type='2' WHERE fort_privilege_id='1002050000000';
UPDATE fort_privilege SET fort_privilege_role_type='2' WHERE fort_privilege_id='1002050100000';
UPDATE fort_privilege SET fort_privilege_role_type='2' WHERE fort_privilege_id='1002050200000';
UPDATE fort_privilege SET fort_privilege_role_type='2' WHERE fort_privilege_id='1002050300000';
UPDATE fort_privilege SET fort_privilege_role_type='2' WHERE fort_privilege_id='1002050400000';
UPDATE fort_privilege SET fort_privilege_role_type='2' WHERE fort_privilege_id='1002060000000';
UPDATE fort_privilege SET fort_privilege_role_type='2' WHERE fort_privilege_id='1002060100000';
UPDATE fort_privilege SET fort_privilege_role_type='2' WHERE fort_privilege_id='1002060200000';
UPDATE fort_privilege SET fort_privilege_role_type='2' WHERE fort_privilege_id='1002060300000';
UPDATE fort_privilege SET fort_privilege_role_type='3' WHERE fort_privilege_id='1003000000000';
UPDATE fort_privilege SET fort_privilege_role_type='3' WHERE fort_privilege_id='1003010000000';  
UPDATE fort_privilege SET fort_privilege_role_type='3' WHERE fort_privilege_id='1003020000000';
UPDATE fort_privilege SET fort_privilege_role_type='3' WHERE fort_privilege_id='1003030000000'; 
UPDATE fort_privilege SET fort_privilege_role_type='3' WHERE fort_privilege_id='1004000000000';
UPDATE fort_privilege SET fort_privilege_role_type='3' WHERE fort_privilege_id='1004010000000';
UPDATE fort_privilege SET fort_privilege_role_type='3' WHERE fort_privilege_id='1004030000000';
UPDATE fort_privilege SET fort_privilege_role_type='3',fort_url='process/approval-history-list?processType=personal_approval' WHERE fort_privilege_id='1004040000000';
UPDATE fort_privilege SET fort_privilege_role_type='2',fort_url='process/approval-history-list?processType=department_approval' WHERE fort_privilege_id='1004050000000';
UPDATE fort_privilege SET fort_privilege_role_type='1',fort_url='process/approval-history-list?processType=all_approval' WHERE fort_privilege_id='1004060000000';
UPDATE fort_privilege SET fort_privilege_role_type='2' WHERE fort_privilege_id='1005000000000';
UPDATE fort_privilege SET fort_privilege_role_type='2' WHERE fort_privilege_id='1005010000000';
UPDATE fort_privilege SET fort_privilege_role_type='2' WHERE fort_privilege_id='1005010100000';
UPDATE fort_privilege SET fort_privilege_role_type='2' WHERE fort_privilege_id='1005010200000';
UPDATE fort_privilege SET fort_privilege_role_type='2' WHERE fort_privilege_id='1005010300000';
UPDATE fort_privilege SET fort_privilege_role_type='3' WHERE fort_privilege_id='1006000000000';
UPDATE fort_privilege SET fort_privilege_role_type='3' WHERE fort_privilege_id='1006010000000';
UPDATE fort_privilege SET fort_privilege_role_type='3' WHERE fort_privilege_id='1006010100000';
UPDATE fort_privilege SET fort_privilege_role_type='3' WHERE fort_privilege_id='1006010200000';
UPDATE fort_privilege SET fort_privilege_role_type='1',fort_privilege_type='1' WHERE fort_privilege_id='1007000000000';
UPDATE fort_privilege SET fort_privilege_role_type='1',fort_url='role/role-list' WHERE fort_privilege_id='1007010000000';
UPDATE fort_privilege SET fort_privilege_role_type='1' WHERE fort_privilege_id='1008000000000';
UPDATE fort_privilege SET fort_privilege_role_type='1' WHERE fort_privilege_id='1008020000000';
UPDATE fort_privilege SET fort_privilege_role_type='1' WHERE fort_privilege_id='1008020100000';
UPDATE fort_privilege SET fort_privilege_role_type='1' WHERE fort_privilege_id='1008020200000';
UPDATE fort_privilege SET fort_privilege_role_type='1' WHERE fort_privilege_id='1008020300000';
UPDATE fort_privilege SET fort_privilege_role_type='1' WHERE fort_privilege_id='1008020400000';
UPDATE fort_privilege SET fort_privilege_role_type='1' WHERE fort_privilege_id='1008020500000';
UPDATE fort_privilege SET fort_privilege_role_type='1' WHERE fort_privilege_id='1008030000000';
UPDATE fort_privilege SET fort_privilege_role_type='1' WHERE fort_privilege_id='1008030100000';  
UPDATE fort_privilege SET fort_privilege_role_type='1' WHERE fort_privilege_id='1008030300000';
UPDATE fort_privilege SET fort_privilege_role_type='1' WHERE fort_privilege_id='1008030400000';
UPDATE fort_privilege SET fort_privilege_role_type='1' WHERE fort_privilege_id='1008030500000';
UPDATE fort_privilege SET fort_privilege_role_type='1' WHERE fort_privilege_id='1008030600000';
UPDATE fort_privilege SET fort_privilege_role_type='1' WHERE fort_privilege_id='1008040000000';
UPDATE fort_privilege SET fort_privilege_role_type='1' WHERE fort_privilege_id='1008040100000';
UPDATE fort_privilege SET fort_privilege_role_type='1' WHERE fort_privilege_id='1008040200000';
UPDATE fort_privilege SET fort_privilege_role_type='1' WHERE fort_privilege_id='1008050000000';
UPDATE fort_privilege SET fort_privilege_role_type='1' WHERE fort_privilege_id='1008050100000';
UPDATE fort_privilege SET fort_privilege_role_type='1' WHERE fort_privilege_id='1008050200000';
UPDATE fort_privilege SET fort_privilege_role_type='1' WHERE fort_privilege_id='1008060000000';
UPDATE fort_privilege SET fort_privilege_role_type='1' WHERE fort_privilege_id='1008070000000'; 
UPDATE fort_privilege SET fort_privilege_role_type='1' WHERE fort_privilege_id='1008080000000';
UPDATE fort_privilege SET fort_privilege_role_type='1' WHERE fort_privilege_id='1008080100000';
UPDATE fort_privilege SET fort_privilege_role_type='1' WHERE fort_privilege_id='1008080200000';
UPDATE fort_privilege SET fort_privilege_role_type='1' WHERE fort_privilege_id='1008090000000';
UPDATE fort_privilege SET fort_privilege_role_type='1' WHERE fort_privilege_id='1008100000000';
UPDATE fort_privilege SET fort_privilege_role_type='1' WHERE fort_privilege_id='1008110000000';
UPDATE fort_privilege SET fort_privilege_role_type='1' WHERE fort_privilege_id='1009000000000';
UPDATE fort_privilege SET fort_privilege_role_type='1' WHERE fort_privilege_id='1009010000000';
UPDATE fort_privilege SET fort_privilege_role_type='1' WHERE fort_privilege_id='1009020000000';
UPDATE fort_privilege SET fort_privilege_role_type='1' WHERE fort_privilege_id='1009020100000';
UPDATE fort_privilege SET fort_privilege_role_type='1' WHERE fort_privilege_id='1009020200000';
UPDATE fort_privilege SET fort_privilege_role_type='1' WHERE fort_privilege_id='1009030000000';
UPDATE fort_privilege SET fort_privilege_role_type='1' WHERE fort_privilege_id='1009040000000';
UPDATE fort_privilege SET fort_privilege_role_type='1' WHERE fort_privilege_id='1009050000000';
  
UPDATE fort_privilege SET fort_privilege_code='m_user:role' WHERE fort_privilege_id='1002020000008';

DELETE FROM fort_privilege WHERE fort_privilege_id='1008070100000';
DELETE FROM fort_privilege WHERE fort_privilege_id='1008030200000';

UPDATE fort_role SET fort_role_type='4' WHERE fort_role_id='1000000000007';


INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000144','1000000000001','1002020000001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000145','1000000000001','1002020000002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000146','1000000000001','1002020000003');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000147','1000000000001','1002020000008');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000148','1000000000001','1002020000009');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000149','1000000000001','1002020000010');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000150','1000000000001','1007010000001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000151','1000000000001','1007010000002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000152','1000000000001','1007010000003');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000153','1000000000001','1007020000001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000154','1000000000007','1001010000001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000155','1000000000007','1001010000002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000156','1000000000007','1001010000003');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000157','1000000000007','1001010000004');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000158','1000000000007','1001010000005');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000159','1000000000007','1001010000006');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000160','1000000000007','1001010000007');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000161','1000000000007','1001010000008');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000162','1000000000007','1001010000009');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000163','1000000000007','1001010000010');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000164','1000000000007','1001010000011');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000165','1000000000007','1001010000012');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000166','1000000000007','1004010000001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000167','1000000000007','1004010000002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000168','1000000000007','1004030000001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000169','1000000000007','1004030000002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000170','1000000000007','1004040000001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000171','1000000000007','1004040000002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000172','1000000000008','2000000000001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000173','1000000000007','1001010000013');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000174','1000000000001','1008000000000');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000175','1000000000001','1008110000000');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000176','1000000000001','1008110000001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000177','1000000000001','1008110000002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000178','1000000000001','1008110000003');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000179','1000000000001','1008110000004');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000180','1000000000001','1008110000005');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000181','1000000000001','1008110000006');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000182','1000000000001','1008110000007');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000183','1000000000001','1008110000008');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000184','1000000000001','1008110000009');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000185','1000000000001','1008110000010');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000186','1000000000001','1007020000000');

INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000187','1000000000002','1002010100001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000188','1000000000002','1002010100002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000189','1000000000002','1002010100003');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000190','1000000000002','1002020000001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000191','1000000000002','1002020000002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000192','1000000000002','1002020000003');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000193','1000000000002','1002020000004');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000194','1000000000002','1002020000005');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000195','1000000000002','1002020000006');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000196','1000000000002','1002020000007');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000197','1000000000002','1002020000008');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000198','1000000000002','1002020000009');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000199','1000000000002','1002020000010');


INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000200','1000000000002','1004010000001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000201','1000000000002','1004010000002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000202','1000000000002','1004030000001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000203','1000000000002','1004030000002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000204','1000000000002','1004040000001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000205','1000000000002','1004040000002');

INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000206','1000000000002','1008020100001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000207','1000000000002','1008020200001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000208','1000000000002','1008020200002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000209','1000000000002','1008020300001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000210','1000000000002','1008020300002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000211','1000000000002','1008020400001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000212','1000000000002','1008020500001');

INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000213','1000000000002','1008020500002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000214','1000000000002','1008020500003');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000215','1000000000002','1008030100001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000216','1000000000002','1008030500001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000217','1000000000002','1008030500002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000218','1000000000002','1008040100001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000219','1000000000002','1008040100002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000220','1000000000002','1008040200001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000221','1000000000002','1008040200002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000222','1000000000002','1008050100001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000223','1000000000002','1008050100002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000224','1000000000002','1008050100003');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000225','1000000000002','1008050200001');

INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000226','1000000000002','1008050200002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000227','1000000000002','1008050200003');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000228','1000000000002','1008060000001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000229','1000000000002','1008060000002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000230','1000000000002','1008060000003');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000231','1000000000002','1008070000001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000232','1000000000002','1008080100001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000233','1000000000002','1008080200001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000234','1000000000002','1008080200002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000235','1000000000002','1008090000001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000236','1000000000002','1008090000002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000237','1000000000002','1008090000003');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000238','1000000000002','1008090000004');

INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000239','1000000000002','1008090000005');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000240','1000000000002','1008090000006');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000241','1000000000002','1008100000001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000242','1000000000002','1008100000002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000243','1000000000002','1008100000003');

INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000244','1000000000002','1008110000001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000245','1000000000002','1008110000002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000246','1000000000002','1008110000003');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000247','1000000000002','1008110000004');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000248','1000000000002','1008110000005');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000249','1000000000002','1008110000006');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000250','1000000000002','1008110000007');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000251','1000000000002','1008110000008');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000252','1000000000002','1008110000009');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000253','1000000000002','1008110000010');

INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000254','1000000000002','1009010000001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000255','1000000000002','1009020100001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000256','1000000000002','1009020200001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000257','1000000000002','1009030000001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000258','1000000000002','1009030000002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000259','1000000000002','1009040000001');

INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000260','1000000000002','1009040000002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000261','1000000000002','1009040000003');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000262','1000000000002','1009040000004');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000263','1000000000002','1009050000001');


INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000264','1000000000003','1003010000001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000265','1000000000003','1003010000002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000266','1000000000003','1003010000003');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000267','1000000000003','1003010000004');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000268','1000000000003','1003010000005');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000269','1000000000003','1003010000006');


INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000270','1000000000002','1003010000006');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000271','1000000000002','1003010000007');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000272','1000000000002','1003010000008');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000273','1000000000002','1003010000009');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000274','1000000000003','1003010000010');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000275','1000000000003','1003010000011');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000276','1000000000003','1003010000012');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000277','1000000000003','1003010000013');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000278','1000000000003','1003010000014');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000279','1000000000003','1003010000015');


INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000280','1000000000002','1003030000001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000281','1000000000002','1004060000001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000282','1000000000002','1004060000002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000283','1000000000002','1006010100001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000284','1000000000003','1006010100002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000285','1000000000003','1006010100003');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000286','1000000000003','1006010200001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000287','1000000000003','1006010200002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000288','1000000000003','1006010200003');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000289','1000000000004','1006010200003');





INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000410','1000000000004','1002060100001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000411','1000000000004','1002060100002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000412','1000000000004','1002060100003');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000413','1000000000004','1002060200001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000414','1000000000004','1002060200002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000415','1000000000004','1002060200003');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000416','1000000000004','1002060200004');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000417','1000000000004','1002060200005');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000418','1000000000004','1002060200006');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000419','1000000000004','1002060200007');

INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000420','1000000000004','1002060200008');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000421','1000000000004','1002060300001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000422','1000000000004','1002060300002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000423','1000000000004','1002060300003');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000424','1000000000004','1002060300004');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000425','1000000000004','1003010000001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000426','1000000000004','1003010000002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000427','1000000000004','1003010000003');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000428','1000000000004','1003010000004');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000429','1000000000004','1003010000005');

INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000290','1000000000004','1003010000006');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000291','1000000000004','1003010000007');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000292','1000000000004','1003010000008');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000293','1000000000004','1003010000009');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000294','1000000000004','1003010000010');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000295','1000000000004','1003010000011');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000296','1000000000004','1003010000012');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000297','1000000000004','1003010000013');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000298','1000000000004','1003010000014');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000299','1000000000004','1003010000015');

INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000300','1000000000004','1004050000001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000301','1000000000004','1004050000002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000302','1000000000004','1006010100001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000303','1000000000004','1006010100002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000304','1000000000004','1006010100003');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000305','1000000000004','1006010200001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000306','1000000000004','1006010200002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000307','1000000000004','1006010200003');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000308','1000000000005','1002010200001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000309','1000000000005','1002010200002');


INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000310','1000000000005','1002010200003');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000311','1000000000005','1002010200004');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000312','1000000000005','1002010200005');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000313','1000000000005','1002010300001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000314','1000000000005','1002010300002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000315','1000000000005','1002010300003');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000316','1000000000005','1002010300004');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000317','1000000000005','1002010300005');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000318','1000000000005','1002020000001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000319','1000000000005','1002020000002');

INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000320','1000000000005','1002020000003');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000321','1000000000005','1002020000004');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000322','1000000000005','1002020000005');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000323','1000000000005','1002020000006');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000324','1000000000005','1002020000007');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000325','1000000000005','1002020000008');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000326','1000000000005','1002020000009');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000327','1000000000005','1002020000010');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000328','1000000000005','1002030000001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000329','1000000000005','1002030000002');

INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000430','1000000000005','1002030000003');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000431','1000000000005','1002030000004');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000432','1000000000005','1002030000005');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000433','1000000000005','1002030000006');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000434','1000000000005','1002030000007');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000435','1000000000005','1002030000008');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000436','1000000000005','1002030000009');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000437','1000000000005','1002030000010');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000438','1000000000005','1002030000011');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000439','1000000000005','1002030000012');

INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000330','1000000000005','1002030000013');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000331','1000000000005','1002030000014');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000332','1000000000005','1002040000001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000333','1000000000005','1002040000002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000334','1000000000005','1002040000003');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000335','1000000000005','1002040000004');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000336','1000000000005','1002040000005');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000337','1000000000005','1002040000006');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000338','1000000000005','1002040000007');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000339','1000000000005','1002040000008');

INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000340','1000000000005','1002040000009');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000341','1000000000005','1002050100001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000342','1000000000005','1002050100002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000343','1000000000005','1002050100003');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000344','1000000000005','1002050100004');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000345','1000000000005','1002050100005');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000346','1000000000005','1002050200001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000347','1000000000005','1002050200002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000348','1000000000005','1002050200003');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000349','1000000000005','1002050300001');

INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000350','1000000000005','1002050300002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000351','1000000000005','1002050300003');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000352','1000000000005','1002050400001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000353','1000000000005','1002050400002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000354','1000000000005','1002050400003');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000355','1000000000005','1002050400004');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000356','1000000000005','1002050400005');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000357','1000000000005','1002060100001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000358','1000000000005','1002060100002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000359','1000000000005','1002060100003');


INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000360','1000000000005','1002060200001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000361','1000000000005','1002060200002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000362','1000000000005','1002060200003');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000363','1000000000005','1002060200004');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000364','1000000000005','1002060200005');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000365','1000000000005','1002060200006');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000366','1000000000005','1002060200007');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000367','1000000000005','1002060200008');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000368','1000000000005','1002060300001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000369','1000000000005','1002060300002');

INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000370','1000000000005','1002060300003');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000371','1000000000005','1002060300004');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000372','1000000000005','1004010000001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000373','1000000000005','1004010000002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000374','1000000000005','1004030000001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000375','1000000000005','1004030000002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000376','1000000000005','1004040000001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000377','1000000000005','1004040000002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000378','1000000000005','1005010100001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000379','1000000000005','1005010100002');

INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000380','1000000000005','1005010100003');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000381','1000000000005','1005010100004');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000382','1000000000005','1005010100005');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000383','1000000000005','1005010100006');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000384','1000000000005','1005010100007');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000385','1000000000005','1005010100008');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000386','1000000000005','1005010100009');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000387','1000000000005','1005010200001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000388','1000000000005','1005010200002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000389','1000000000005','1005010200003');

INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000480','1000000000005','1005010200004');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000481','1000000000005','1005010200005');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000482','1000000000005','1005010200006');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000483','1000000000005','1005010200007');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000484','1000000000005','1005010200008');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000485','1000000000005','1005010300001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000486','1000000000006','1004010000001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000487','1000000000006','1004010000002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000488','1000000000006','1004030000001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000489','1000000000006','1004030000002');

INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000390','1000000000006','1004040000001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000391','1000000000006','1004040000002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000392','1000000000006','1005010100001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000393','1000000000006','1005010100002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000394','1000000000006','1005010100003');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000395','1000000000006','1005010100004');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000396','1000000000006','1005010100005');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000397','1000000000006','1005010100006');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000398','1000000000006','1005010100007');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000399','1000000000006','1005010100008');

INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000400','1000000000006','1005010100009');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000401','1000000000006','1005010200002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000402','1000000000006','1005010200003');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000403','1000000000006','1005010200004');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000404','1000000000006','1005010200005');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000405','1000000000006','1005010200006');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000406','1000000000006','1005010200007');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000407','1000000000006','1005010200008');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000408','1000000000006','1005010200001');


INSERT INTO fort_role_privilege VALUES('1000000000490','1000000000003','1006010100001');
INSERT INTO fort_role_privilege VALUES('1000000000491','1000000000005','1002050100006');
INSERT INTO fort_role_privilege VALUES('1000000000492','1000000000003','1004060000001');
INSERT INTO fort_role_privilege VALUES('1000000000493','1000000000003','1004060000002');


INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000500','1000000000005','2000000000006');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000501','1000000000002','2000000000007');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000502','1000000000006','2000000000007');



INSERT INTO `fort_role_mutex` (`fort_role_mutex_id`, `fort_role_id`, `fort_mutex_role_id`) VALUES('1000000000001','1000000000002','1000000000003');
INSERT INTO `fort_role_mutex` (`fort_role_mutex_id`, `fort_role_id`, `fort_mutex_role_id`) VALUES('1000000000002','1000000000005','1000000000003');
INSERT INTO `fort_role_mutex` (`fort_role_mutex_id`, `fort_role_id`, `fort_mutex_role_id`) VALUES('1000000000003','1000000000005','1000000000004');
INSERT INTO `fort_role_mutex` (`fort_role_mutex_id`, `fort_role_id`, `fort_mutex_role_id`) VALUES('1000000000004','1000000000005','1000000000006');
INSERT INTO `fort_role_mutex` (`fort_role_mutex_id`, `fort_role_id`, `fort_mutex_role_id`) VALUES('1000000000005','1000000000002','1000000000004');


INSERT INTO fort_role_authorization_scope (fort_role_authorization_scope_id,fort_role_id,fort_controllable_role_id) VALUES('1000000000012','1000000000001','1000000000004');
INSERT INTO fort_role_authorization_scope (fort_role_authorization_scope_id,fort_role_id,fort_controllable_role_id) VALUES('1000000000013','1000000000001','1000000000005');
INSERT INTO fort_role_authorization_scope (fort_role_authorization_scope_id,fort_role_id,fort_controllable_role_id) VALUES('1000000000014','1000000000001','1000000000006');
INSERT INTO fort_role_authorization_scope (fort_role_authorization_scope_id,fort_role_id,fort_controllable_role_id) VALUES('1000000000016','1000000000001','1000000000008');

DELETE FROM fort_role_authorization_scope WHERE fort_controllable_role_id='1000000000007';




UPDATE fort_privilege SET fort_privilege_code='m_behavior_guideline_type' WHERE fort_privilege_id='1002060100000';
UPDATE fort_privilege SET fort_privilege_code='m_behavior_guideline_type:add' WHERE fort_privilege_id='1002060300001';
UPDATE fort_privilege SET fort_privilege_code='m_behavior_guideline_type:delete' WHERE fort_privilege_id='1002060300002';
UPDATE fort_privilege SET fort_privilege_code='m_behavior_guideline_type:edit' WHERE fort_privilege_id='1002060300003';

UPDATE fort_privilege SET fort_privilege_code='m_behavior_guideline_command:commOptionAdd' WHERE fort_privilege_id='1002060200006';
UPDATE fort_privilege SET fort_privilege_code='m_behavior_guideline_command:commOptionDelete' WHERE fort_privilege_id='1002060200007';
UPDATE fort_privilege SET fort_privilege_code='m_behavior_guideline_command:commOptionEdit' WHERE fort_privilege_id='1002060200008';

UPDATE fort_privilege SET fort_privilege_code='m_user_group:addTheUser' WHERE fort_privilege_id='1002010300004';
UPDATE fort_privilege SET fort_privilege_code='m_user_group:deleteTheUser' WHERE fort_privilege_id='1002010300005';

UPDATE fort_privilege SET fort_url='audit/operational/operational-audit-list?SsoAudit=m_audit' WHERE fort_privilege_id='1003010000000';


INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002050100006', '命令规则:部署', NULL, 'm_command_rule:deploy', '3', '2', '1002050100000', NULL);

UPDATE fort_privilege SET fort_privilege_code='m_behavior_guideline:add' WHERE fort_privilege_id='1002060300001';
UPDATE fort_privilege SET fort_privilege_code='m_behavior_guideline:delete' WHERE fort_privilege_id='1002060300002';
UPDATE fort_privilege SET fort_privilege_code='m_behavior_guideline:edit' WHERE fort_privilege_id='1002060300003';


DELIMITER $$
DROP PROCEDURE IF EXISTS `changeOrder`$$
CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `changeOrder`()
BEGIN   
     DECLARE done INT DEFAULT -1; 
     DECLARE temp_department_id VARCHAR(24);
     DECLARE temp_new_department_id VARCHAR(24);
     DECLARE num INT(11);
     DECLARE cur1 CURSOR FOR  SELECT DISTINCT fort_department_id FROM fort_department;
     DECLARE cur2 CURSOR FOR  SELECT DISTINCT fort_department_id FROM fort_department WHERE fort_parent_id = temp_department_id;
     DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1;
     SET num = 1;
     OPEN cur1; 
     myLoop: LOOP  
	FETCH cur1 INTO temp_department_id;       
        IF done = 1 THEN  
		SET done = -1;
            LEAVE myLoop; 
        END IF;
        OPEN cur2;
        
        myLoop2:LOOP
		FETCH cur2 INTO temp_new_department_id;      
		IF done = 1 THEN
			SET num = 1;
			SET done = -1;
			LEAVE myLoop2; 
		END IF;
		UPDATE  fort_department SET fort_order=num WHERE fort_department_id = temp_new_department_id;
		SET num = num+1;
        END LOOP myLoop2;
        CLOSE cur2;
    END LOOP myLoop;  
    CLOSE cur1;  
END$$

DELIMITER ;

CALL changeOrder();

DROP PROCEDURE IF EXISTS `changeOrder`;


DELIMITER $$
DROP PROCEDURE IF EXISTS `changeResourceOrder`$$
CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `changeResourceOrder`()
BEGIN   
     DECLARE done INT DEFAULT -1; 
     DECLARE temp_department_id VARCHAR(24);
     DECLARE temp_new_department_id VARCHAR(24);
     DECLARE num INT(11);
     DECLARE cur1 CURSOR FOR  SELECT DISTINCT fort_department_id FROM fort_department;
     DECLARE cur2 CURSOR FOR  SELECT DISTINCT fort_resource_group_id FROM fort_resource_group WHERE fort_department_id = temp_department_id;
     DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1; 
     SET num = 1;
     OPEN cur1; 
     myLoop: LOOP  
	FETCH cur1 INTO temp_department_id;       
        IF done = 1 THEN  
		SET done = -1;
            LEAVE myLoop; 
        END IF;
        OPEN cur2;
        
        myLoop2:LOOP
		FETCH cur2 INTO temp_new_department_id;      
		IF done = 1 THEN
			SET num = 1;
			SET done = -1;
			LEAVE myLoop2; 
		END IF;
		UPDATE  fort_resource_group SET fort_order=num WHERE fort_resource_group_id = temp_new_department_id;
		SET num = num+1;
        END LOOP myLoop2;
        CLOSE cur2;
    END LOOP myLoop;  
    CLOSE cur1;  
END$$

DELIMITER ;

CALL changeResourceOrder();

DROP PROCEDURE IF EXISTS `changeResourceOrder`;


DELIMITER $$
DROP PROCEDURE IF EXISTS `changeUserOrder`$$
CREATE DEFINER=`mysql`@`127.0.0.1` PROCEDURE `changeUserOrder`()
BEGIN   
     DECLARE done INT DEFAULT -1; 
     DECLARE temp_department_id VARCHAR(24);
     DECLARE temp_new_department_id VARCHAR(24);
     DECLARE num INT(11);
     DECLARE cur1 CURSOR FOR  SELECT DISTINCT fort_department_id FROM fort_department;
     DECLARE cur2 CURSOR FOR  SELECT DISTINCT fort_user_group_id FROM fort_user_group WHERE fort_department_id = temp_department_id;
     DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1; 
     SET num = 1;
     OPEN cur1; 
     myLoop: LOOP  
	FETCH cur1 INTO temp_department_id;       
        IF done = 1 THEN  
		SET done = -1;
            LEAVE myLoop; 
        END IF;
        OPEN cur2;
        
        myLoop2:LOOP
		FETCH cur2 INTO temp_new_department_id;
		IF done = 1 THEN
			SET num = 1;
			SET done = -1;
			LEAVE myLoop2; 
		END IF;
		UPDATE  fort_user_group SET fort_order=num WHERE fort_user_group_id = temp_new_department_id;
		SET num = num+1;
        END LOOP myLoop2;
        CLOSE cur2;
    END LOOP myLoop;  
    CLOSE cur1;  
END$$

DELIMITER ;

CALL changeUserOrder();

DROP PROCEDURE IF EXISTS `changeUserOrder`;

ALTER TABLE fort_account MODIFY  fort_account_id      varchar(24) not null comment '资源帐号ID';
ALTER TABLE fort_account MODIFY  fort_resource_id     varchar(24) comment '资源ID';

ALTER TABLE fort_application_release_server MODIFY fort_application_release_server_id varchar(24) not null comment '应用发布服务器ID';

ALTER TABLE fort_approval_record MODIFY fort_approval_record_id varchar(24) not null comment '审批记录ID';
   
  
ALTER TABLE fort_approval_record MODIFY fort_process_task_instance_id varchar(24) not null comment '流程任务实例ID';
ALTER TABLE fort_approval_record MODIFY  fort_target_id       varchar(24) not null comment '审批目标ID';
ALTER TABLE fort_approval_record MODIFY fort_approver_id     varchar(24) comment '审批人ID';

ALTER TABLE fort_audit_approval_application MODIFY    fort_audit_approval_application_id varchar(24) not null comment '审计审批申请单ID';  
ALTER TABLE fort_audit_approval_application MODIFY fort_process_id      varchar(24) comment '流程ID';
ALTER TABLE fort_audit_approval_application MODIFY fort_process_instance_id varchar(24) comment '流程实例ID';

ALTER TABLE fort_audit_approval_application MODIFY    fort_applicant_id    varchar(24) comment '申请人ID';
ALTER TABLE fort_audit_approval_application MODIFY fort_user_id         varchar(24) comment '审计用户ID';
ALTER TABLE fort_audit_approval_application MODIFY fort_account_id      varchar(24) comment '申请帐号ID';
ALTER TABLE fort_audit_approval_application MODIFY fort_resource_id     varchar(24) comment '申请资源ID';

ALTER TABLE fort_audit_command_log MODIFY fort_audit_command_log_id varchar(24) not null comment '行为审计命令日志ID';
ALTER TABLE fort_audit_command_log MODIFY  fort_audit_id        varchar(24) not null comment '行为审计日志ID';

ALTER TABLE fort_audit_log MODIFY fort_audit_id        varchar(24) not null comment '行为审计日志ID';
ALTER TABLE fort_audit_log MODIFY  fort_double_process_id varchar(24) comment '双人流程ID';
  
  
ALTER TABLE fort_audit_log MODIFY  fort_superior_process_id varchar(24) comment '上级审批流程ID';
ALTER TABLE fort_audit_log MODIFY  fort_operations_protocol_id varchar(24) comment '运维协议ID';
ALTER TABLE fort_audit_log MODIFY fort_user_id         varchar(24) comment '用户ID';
ALTER TABLE fort_audit_log MODIFY  fort_resource_type_id varchar(24) comment '资源类型ID';
ALTER TABLE fort_audit_log MODIFY  fort_resource_id     varchar(24) comment '资源ID';

ALTER TABLE fort_audit_log MODIFY  fort_account_id      varchar(24) comment '资源帐号ID';


ALTER TABLE fort_audit_title_log MODIFY  fort_audit_title_log_id varchar(24) not null comment '行为审计标题日志表ID';
 
ALTER TABLE fort_audit_title_log MODIFY   fort_audit_id        varchar(24) comment '行为审计日志ID';

ALTER TABLE fort_authorization MODIFY  fort_authorization_id varchar(24) not null comment '授权ID';
   
ALTER TABLE fort_authorization MODIFY fort_department_id   varchar(24) not null comment '部门ID';

ALTER TABLE fort_authorization MODIFY fort_superior_process_id varchar(24) comment '上级审批流程ID';

ALTER TABLE fort_authorization_target_proxy MODIFY  fort_authorization_target_proxy_id varchar(24) not null comment '授权目标代理ID';
   
   
ALTER TABLE fort_authorization_target_proxy MODIFY fort_authorization_id varchar(24) comment '授权ID';
ALTER TABLE fort_authorization_target_proxy MODIFY fort_target_id       varchar(24) comment '目标ID';

ALTER TABLE fort_authorization_target_proxy MODIFY  fort_parent_id       varchar(24) comment '所属目标ID';

ALTER TABLE fort_behavior_guideline MODIFY  fort_behavior_guideline_id varchar(24) not null comment '行为指引ID';
  
ALTER TABLE fort_behavior_guideline MODIFY  fort_behavior_guideline_type_id varchar(24) comment '行为指引类型ID';

ALTER TABLE fort_behavior_guideline_set MODIFY    fort_behavior_guideline_set_id varchar(24) not null comment '行为指引集ID';
ALTER TABLE fort_behavior_guideline_set_element MODIFY  fort_behavior_guideline_set_element_id varchar(24) not null comment '行为指引集原组ID';
   
ALTER TABLE fort_behavior_guideline_set_element MODIFY fort_behavior_guideline_set_id varchar(24) comment '行为指引集ID';


ALTER TABLE fort_behavior_guideline_set_guideline MODIFY fort_behavior_guideline_set_guideline_id varchar(24) not null comment '行为指引集指引ID';
  
ALTER TABLE fort_behavior_guideline_set_guideline MODIFY  fort_behavior_guideline_set_id varchar(24) comment '行为指引集ID';

ALTER TABLE fort_behavior_guideline_type MODIFY  fort_behavior_guideline_type_id varchar(24) not null comment '行为指引类型ID';
  
ALTER TABLE fort_behavior_guideline_type MODIFY  fort_parent_id       varchar(24) comment '父节点ID';
ALTER TABLE fort_client_tool MODIFY fort_client_tool_id  varchar(24) not null comment '客户端工具ID';

ALTER TABLE fort_command MODIFY fort_command_id      varchar(24) not null comment '命令ID';
   
ALTER TABLE fort_command MODIFY fort_rule_command_id varchar(24) not null comment '命令规则ID';

ALTER TABLE fort_command_approval_application MODIFY  fort_command_approval_application_id varchar(24) not null comment '双人审批申请单ID';

   
ALTER TABLE fort_command_approval_application MODIFY    fort_process_id      varchar(24) comment '流程ID';
ALTER TABLE fort_command_approval_application MODIFY fort_process_instance_id varchar(24) comment '流程实例ID';
ALTER TABLE fort_command_approval_application MODIFY    fort_account_id      varchar(24) comment '申请帐号ID';

ALTER TABLE fort_command_approval_application MODIFY  fort_resource_id     varchar(24) comment '申请资源ID';
ALTER TABLE fort_command_approval_application MODIFY fort_applicant_id    varchar(24) comment '申请人ID';
ALTER TABLE fort_command_element MODIFY  fort_command_element_id varchar(24) not null comment '命令原组ID';
   
ALTER TABLE fort_command_element MODIFY fort_behavior_guideline_id varchar(24) comment '行为指引ID';

ALTER TABLE fort_department MODIFY   fort_department_id   varchar(24) not null comment '部门ID';
ALTER TABLE fort_department MODIFY fort_parent_id       varchar(24) comment '上级部门ID';


ALTER TABLE fort_double_approval MODIFY  fort_double_approval_id varchar(24) not null comment '双人审批ID';
  
  
ALTER TABLE fort_double_approval MODIFY  fort_authorization_id varchar(24) not null comment '授权ID';
ALTER TABLE fort_double_approval MODIFY  fort_user_id         varchar(24) not null comment '关联用户ID';

ALTER TABLE fort_double_approval_application MODIFY  fort_double_approval_application_id varchar(24) not null comment '双人审批申请单ID';
 
  
ALTER TABLE fort_double_approval_application MODIFY   fort_process_id      varchar(24) comment '流程ID';
ALTER TABLE fort_double_approval_application MODIFY  fort_process_instance_id varchar(24) comment '流程实例ID';
ALTER TABLE fort_double_approval_application MODIFY fort_account_id      varchar(24) comment '申请帐号ID';
ALTER TABLE fort_double_approval_application MODIFY fort_resource_id     varchar(24) comment '申请资源ID';
ALTER TABLE fort_double_approval_application MODIFY fort_applicant_id    varchar(24) comment '申请人ID';
ALTER TABLE fort_forbidden_character MODIFY  fort_forbidden_character_id varchar(24) not null comment '禁止字符ID';
   
ALTER TABLE fort_forbidden_character MODIFY fort_strategy_password_id varchar(24) not null comment '口令策略ID';
ALTER TABLE fort_guideline_command MODIFY fort_guideline_command_id varchar(24) not null comment '指引命令ID';
 

ALTER TABLE fort_guideline_command MODIFY   fort_guideline_command_type_id varchar(24) comment '指引命令分类ID';



ALTER TABLE fort_guideline_command_option MODIFY  fort_guideline_command_option_id varchar(24) not null comment '指引命令选项ID';
   
ALTER TABLE fort_guideline_command_option MODIFY fort_guideline_command_id varchar(24) comment '指引命令ID';
ALTER TABLE fort_guideline_command_type MODIFY  fort_guideline_command_type_id varchar(24) not null comment '指引命令分类ID';
  
ALTER TABLE fort_guideline_command_type MODIFY  fort_parent_id       varchar(24) comment '父节点ID';
ALTER TABLE fort_ip_mask MODIFY fort_ip_mask_id      varchar(24) not null comment 'IP掩码ID';
  
ALTER TABLE fort_ip_mask MODIFY  fort_rule_address_id varchar(24) comment '地址规则ID';

ALTER TABLE fort_ip_range MODIFY fort_ip_range_id     varchar(24) not null comment 'IP区间ID';
  
ALTER TABLE fort_ip_range MODIFY  fort_rule_address_id varchar(24) comment '地址规则ID';



ALTER TABLE fort_keyboard_assembly3 MODIFY fort_keyboard_assembly_id varchar(24) not null comment '键盘拼装ID';
ALTER TABLE fort_ldap_user MODIFY  fort_ldap_user_id    varchar(24) not null comment 'LDAP用户ID';
 
ALTER TABLE fort_ldap_user MODIFY   fort_user_id         varchar(24) comment '用户ID';
ALTER TABLE fort_message MODIFY  fort_message_id      varchar(24) not null comment '消息ID';
  
   
ALTER TABLE fort_message MODIFY  fort_message_type_id varchar(24) comment '消息类型ID';

ALTER TABLE fort_message MODIFY fort_receive_user_id varchar(24) comment '接收人ID';
ALTER TABLE fort_message MODIFY  fort_send_user_id    varchar(24) comment '发送人ID';
ALTER TABLE fort_message_type MODIFY fort_message_type_id varchar(24) not null comment '消息类型ID';
ALTER TABLE fort_operations_protocol MODIFY fort_operations_protocol_id varchar(24) not null comment '运维协议ID';
ALTER TABLE fort_plan_password MODIFY fort_plan_password_id varchar(24) not null comment '密码计划ID';
   

ALTER TABLE fort_plan_password MODIFY fort_department_id   varchar(24) not null comment '部门ID';
ALTER TABLE fort_plan_password_backup MODIFY  fort_plan_password_backup_id varchar(24) not null comment '密码备份计划ID';

ALTER TABLE fort_plan_password_backup MODIFY    fort_department_id   varchar(24) not null comment '部门ID';
ALTER TABLE fort_plan_password_backup_record MODIFY fort_plan_password_backup_record_id varchar(24) not null comment '密码计划备份ID';
   
  
ALTER TABLE fort_plan_password_backup_record MODIFY fort_plan_id         varchar(24) comment '计划ID';
ALTER TABLE fort_plan_password_backup_record MODIFY  fort_operation_user_id varchar(24) comment '操作人ID';


ALTER TABLE fort_plan_password_target_proxy MODIFY fort_plan_password_target_proxy_id varchar(24) not null comment '密码计划执行目标代理ID';

ALTER TABLE fort_plan_password_target_proxy MODIFY fort_plan_id         varchar(24) not null comment '计划ID';
ALTER TABLE fort_plan_password_target_proxy MODIFY  fort_target_id       varchar(24) not null comment '目标ID';


ALTER TABLE fort_privilege MODIFY  fort_privilege_id    varchar(24) not null comment '权限ID';
ALTER TABLE fort_privilege MODIFY fort_parent_id       varchar(24) comment '上级权限ID';
ALTER TABLE fort_process MODIFY  fort_process_id      varchar(24) not null comment '流程ID';
ALTER TABLE fort_process_instance MODIFY fort_process_instance_id varchar(24) not null comment '流程实例ID';
ALTER TABLE fort_process_instance MODIFY fort_process_id      varchar(24) comment '流程ID';


ALTER TABLE fort_process_task MODIFY fort_process_task_id varchar(24) not null comment '流程任务ID';
  

ALTER TABLE fort_process_task MODIFY  fort_parent_id       varchar(24) comment '上级任务ID';
ALTER TABLE fort_process_task MODIFY    fort_process_id      varchar(24) comment '流程ID';

ALTER TABLE fort_process_task_instance MODIFY  fort_process_task_instance_id varchar(24) not null comment '流程任务实例ID';

ALTER TABLE fort_process_task_instance MODIFY   fort_process_instance_id varchar(24) comment '流程实例ID';
ALTER TABLE fort_process_task_instance MODIFY  fort_process_task_id varchar(24) comment '流程任务ID';
ALTER TABLE fort_process_task_instance MODIFY   fort_parent_id       varchar(24) comment '父节点ID';
ALTER TABLE fort_process_task_instance MODIFY fort_task_participant_id varchar(24) comment '任务参与者表ID';


ALTER TABLE fort_protocol_client MODIFY fort_protocol_client_id varchar(24) not null comment '运维协议客户端工具主键ID';
   

ALTER TABLE fort_protocol_client MODIFY fort_operations_protocol_id varchar(24) not null comment '运维协议ID';
ALTER TABLE fort_protocol_client MODIFY    fort_client_tool_id  varchar(24) comment '客户端工具ID';

ALTER TABLE fort_report_template_audit_log MODIFY  fort_report_template_id varchar(24) not null comment '系统日志报表模版ID';

ALTER TABLE fort_report_template_system_log MODIFY  fort_report_template_id varchar(24) not null comment '系统日志报表模版ID';

ALTER TABLE fort_resource MODIFY fort_resource_id     varchar(24) not null comment '资源ID';
  
ALTER TABLE fort_resource MODIFY fort_strategy_password_id varchar(24) comment '口令策略ID';
ALTER TABLE fort_resource MODIFY fort_resource_type_id varchar(24) comment '资源类型ID';
ALTER TABLE fort_resource MODIFY fort_parent_id       varchar(24) comment '域控或所属系统ID';
ALTER TABLE fort_resource MODIFY fort_department_id   varchar(24) comment '部门ID';
ALTER TABLE fort_resource MODIFY  fort_rule_time_id    varchar(24) comment '时间规则ID';

ALTER TABLE fort_resource_application MODIFY  fort_resource_application_release_server_id varchar(24) not null comment '资源应用发布服务器主键ID';
   
   
ALTER TABLE fort_resource_application MODIFY fort_resource_id     varchar(24) not null comment '资源ID';
ALTER TABLE fort_resource_application MODIFY fort_application_release_server_id varchar(24) not null comment '应用发布服务器ID';

ALTER TABLE fort_resource_group MODIFY fort_resource_group_id varchar(24) not null comment '资源组ID';
   
ALTER TABLE fort_resource_group MODIFY fort_department_id   varchar(24) comment '部门ID';
ALTER TABLE fort_resource_group_resource MODIFY fort_resource_group_resource_id varchar(24) not null comment '资源组资源关系表主键ID';
     
ALTER TABLE fort_resource_group_resource MODIFY fort_resource_group_id varchar(24) comment '资源组ID';
ALTER TABLE fort_resource_group_resource MODIFY  fort_resource_id     varchar(24) comment '资源ID';

ALTER TABLE fort_resource_operations_protocol MODIFY fort_resource_operations_protocol_id varchar(24) not null comment '资源协议ID';
  
   
ALTER TABLE fort_resource_operations_protocol MODIFY  fort_resource_id     varchar(24) not null comment '资源ID';
ALTER TABLE fort_resource_operations_protocol MODIFY fort_operations_protocol_id varchar(24) not null comment '运维协议ID';

ALTER TABLE fort_resource_type MODIFY  fort_resource_type_id varchar(24) not null comment '资源类型ID';
ALTER TABLE fort_resource_type MODIFY fort_parent_id       varchar(24) comment '父节点ID';
ALTER TABLE fort_resource_type_operations_protocol MODIFY fort_resource_type_operations_protocol_id varchar(24) not null comment '资源类型运维协议关系表主键';
   
   
   
ALTER TABLE fort_resource_type_operations_protocol MODIFY fort_resource_type_id varchar(24) comment '资源类型ID';
ALTER TABLE fort_resource_type_operations_protocol MODIFY fort_operations_protocol_id varchar(24) comment '运维协议ID';
ALTER TABLE fort_resource_type_operations_protocol MODIFY fort_behavior_guideline_type_id varchar(24) comment '行为指引类型ID';

ALTER TABLE fort_role MODIFY fort_role_id         varchar(24) not null comment '角色ID';
ALTER TABLE fort_role_authorization_scope MODIFY fort_role_authorization_scope_id varchar(24) not null comment '角色授权范围ID';
   
  
ALTER TABLE fort_role_authorization_scope MODIFY fort_role_id         varchar(24) not null comment '角色ID';
ALTER TABLE fort_role_authorization_scope MODIFY  fort_controllable_role_id varchar(24) not null comment '可控角色ID';
ALTER TABLE fort_role_mutex MODIFY fort_role_mutex_id   varchar(24) not null comment '角色互斥ID';
   
   
ALTER TABLE fort_role_mutex MODIFY fort_role_id         varchar(24) not null comment '角色ID';
ALTER TABLE fort_role_mutex MODIFY fort_mutex_role_id   varchar(24) not null comment '互斥角色ID';
ALTER TABLE fort_role_privilege MODIFY fort_role_privilege_id varchar(24) not null comment '角色权限主键ID';


ALTER TABLE fort_role_privilege MODIFY fort_role_id         varchar(24) comment '角色ID';
ALTER TABLE fort_role_privilege MODIFY fort_privilege_id    varchar(24) comment '权限ID';
ALTER TABLE fort_rule_address MODIFY fort_rule_address_id varchar(24) not null comment '地址规则ID';
  
ALTER TABLE fort_rule_address MODIFY  fort_department_id   varchar(24) comment '部门ID';
ALTER TABLE fort_rule_command MODIFY  fort_rule_command_id varchar(24) not null comment '命令规则ID';
   
ALTER TABLE fort_rule_command MODIFY fort_department_id   varchar(24) comment '部门ID';

ALTER TABLE fort_rule_command MODIFY  fort_prior_id        varchar(24) comment '上一个规则';
 
ALTER TABLE fort_rule_command MODIFY  fort_next_id         varchar(24) comment '下一个规则';
ALTER TABLE fort_rule_command_target_proxy MODIFY fort_rule_command_target_proxy_id varchar(24) not null comment '命令规则目标代理ID';
   
  
ALTER TABLE fort_rule_command_target_proxy MODIFY fort_rule_command_id varchar(24) comment '命令规则ID';
ALTER TABLE fort_rule_command_target_proxy MODIFY  fort_target_id       varchar(24) not null comment '目标ID';


ALTER TABLE fort_rule_command_target_proxy MODIFY fort_parent_id       varchar(24) comment '父节点ID';
ALTER TABLE fort_rule_time MODIFY fort_rule_time_id    varchar(24) not null comment '时间规则ID';

ALTER TABLE fort_rule_time MODIFY    fort_department_id   varchar(24) comment '部门ID';
ALTER TABLE fort_rule_time_resource MODIFY fort_rule_time_resource_id varchar(24) not null comment '资源时间规则ID';
ALTER TABLE fort_rule_time_resource MODIFY  fort_prior_id        varchar(24) comment '上一个规则';
ALTER TABLE fort_rule_time_resource MODIFY fort_next_id         varchar(24) comment '下一个规则';
ALTER TABLE fort_rule_time_resource_target_proxy MODIFY  fort_rule_time_resource_target_proxy_id varchar(24) not null comment '资源时间规则目标代理ID';
   
   
   
ALTER TABLE fort_rule_time_resource_target_proxy MODIFY fort_rule_time_resource_id varchar(24) comment '资源时间规则ID';
ALTER TABLE fort_rule_time_resource_target_proxy MODIFY fort_target_id       varchar(24) comment '目标ID';
ALTER TABLE fort_rule_time_resource_target_proxy MODIFY fort_parent_id       varchar(24) comment '父节点ID';
ALTER TABLE fort_strategy_password MODIFY  fort_strategy_password_id varchar(24) not null comment '口令策略ID';

ALTER TABLE fort_superior_approval_application MODIFY  fort_superior_approval_application_id varchar(24) not null comment '上级审批申请单ID';
   
   
ALTER TABLE fort_superior_approval_application MODIFY fort_process_id      varchar(24) comment '流程ID';
ALTER TABLE fort_superior_approval_application MODIFY fort_process_instance_id varchar(24) comment '流程实例ID(子实力)';
ALTER TABLE fort_superior_approval_application MODIFY fort_account_id      varchar(24) comment '申请帐号ID';
ALTER TABLE fort_superior_approval_application MODIFY fort_resource_id     varchar(24) comment '申请资源ID';
ALTER TABLE fort_superior_approval_application MODIFY fort_applicant_id    varchar(24) comment '申请人ID';
ALTER TABLE fort_system_alarm MODIFY fort_system_alarm_id varchar(24) not null comment '系统告警ID';
   
  
ALTER TABLE fort_system_alarm MODIFY fort_system_alarm_type_id varchar(24) not null comment '系统告警类型ID';
ALTER TABLE fort_system_alarm MODIFY  fort_user_id         varchar(24) comment '用户ID';
ALTER TABLE fort_system_alarm MODIFY fort_check_user_id   varchar(24) comment '查看ID';
ALTER TABLE fort_system_alarm_type MODIFY fort_system_alarm_type_id varchar(24) not null comment '系统告警类型ID';
   


ALTER TABLE fort_system_alarm_type MODIFY fort_parent_id       varchar(24) comment '所属告警类型ID';


ALTER TABLE fort_system_log MODIFY fort_system_log_id   varchar(24) not null comment '系统日志ID';
   
   
ALTER TABLE fort_system_log MODIFY fort_system_log_type_id varchar(24) not null comment '系统日志类型ID';
ALTER TABLE fort_system_log MODIFY fort_user_id         varchar(24) comment '用户ID';
ALTER TABLE fort_system_log_type MODIFY fort_system_log_type_id varchar(24) not null comment '系统日志类型ID';
ALTER TABLE fort_task_participant MODIFY fort_task_participant_id varchar(24) not null comment '任务参与者表ID';
   
  
ALTER TABLE fort_task_participant MODIFY fort_process_task_id varchar(24) comment '流程任务ID';
ALTER TABLE fort_task_participant MODIFY  fort_user_id         varchar(24) comment '参与者ID';
ALTER TABLE fort_three_uniform_user MODIFY  fort_three_uniform_user_id varchar(24) not null comment '三统一用户ID';
   
ALTER TABLE fort_three_uniform_user MODIFY fort_user_id         varchar(24) comment '用户ID';
ALTER TABLE fort_user MODIFY  fort_user_id         varchar(24) not null comment '用户ID';
   
   
   

ALTER TABLE fort_user MODIFY fort_rule_address_id varchar(24) comment '地址规则ID';
ALTER TABLE fort_user MODIFY fort_rule_time_id    varchar(24) comment '时间规则ID';
ALTER TABLE fort_user MODIFY fort_department_id   varchar(24) comment '部门ID';
ALTER TABLE fort_user MODIFY fort_certificate_id  varchar(32) comment '证书标识';
   
   
   
ALTER TABLE fort_user MODIFY fort_fingerprint_authentication_id varchar(32) comment '指纹认证标识';
ALTER TABLE fort_user MODIFY fort_face_recognition_id varchar(32) comment '人脸识别标识';
ALTER TABLE fort_user MODIFY fort_smart_card_id   varchar(32) comment '智能卡标识';
ALTER TABLE fort_user_group MODIFY fort_user_group_id   varchar(24) not null comment '用户组ID';
  
ALTER TABLE fort_user_group MODIFY  fort_department_id   varchar(24) comment '部门ID';
ALTER TABLE fort_user_group_user MODIFY fort_user_group_user_id varchar(24) not null comment '用户组用户关系表主键ID';
  
 
ALTER TABLE fort_user_group_user MODIFY   fort_user_group_id   varchar(24) comment '用户组ID';


ALTER TABLE fort_user_group_user MODIFY  fort_user_id         varchar(24) comment '用户ID';
ALTER TABLE fort_user_protocol_client MODIFY fort_user_protocol_client_id varchar(24) not null comment '用户访问协议客户端ID';

   
ALTER TABLE fort_user_protocol_client MODIFY   fort_user_id         varchar(24) not null comment '用户ID';
ALTER TABLE fort_user_protocol_client MODIFY fort_client_tool_id  varchar(24) not null comment '客户端工具ID';
ALTER TABLE fort_user_role MODIFY fort_user_role_id    varchar(32) not null comment '用户角色关系表ID';
   
   
ALTER TABLE fort_user_role MODIFY fort_user_id         varchar(24) comment '用户ID';
ALTER TABLE fort_user_role MODIFY fort_role_id         varchar(24) comment '角色ID';


ALTER TABLE fort_account MODIFY fort_create_by       varchar(24) comment '创建人';


ALTER TABLE fort_application_release_server MODIFY fort_create_by       varchar(24) comment '创建人';

ALTER TABLE fort_authorization MODIFY fort_create_by       varchar(24) comment '创建人';

ALTER TABLE fort_behavior_guideline MODIFY fort_create_by       varchar(24) comment '创建人';

ALTER TABLE fort_department MODIFY fort_create_by       varchar(24) comment '创建人';

ALTER TABLE fort_plan_password MODIFY fort_create_by       varchar(24) comment '创建人';

ALTER TABLE fort_plan_password_backup MODIFY fort_create_by       varchar(24) comment '创建人';
ALTER TABLE fort_process MODIFY fort_create_by       varchar(24) comment '创建人';
ALTER TABLE fort_process_instance MODIFY fort_create_by       varchar(24) comment '创建人';
ALTER TABLE fort_resource MODIFY fort_create_by       varchar(24) comment '创建人';
ALTER TABLE fort_resource_application MODIFY fort_create_by       varchar(24) comment '创建人';

ALTER TABLE fort_resource_group MODIFY fort_create_by       varchar(24) comment '创建人';
ALTER TABLE fort_role MODIFY fort_create_by       varchar(24) comment '创建人';
ALTER TABLE fort_rule_address MODIFY fort_create_by       varchar(24) comment '创建人';
ALTER TABLE fort_rule_command MODIFY fort_create_by       varchar(24) comment '创建人';
ALTER TABLE fort_rule_command_target_proxy MODIFY fort_create_by       varchar(24) comment '创建人';

ALTER TABLE fort_rule_time MODIFY fort_create_by       varchar(24) comment '创建人';
ALTER TABLE fort_rule_time_resource MODIFY fort_create_by       varchar(24) comment '创建人';
ALTER TABLE fort_rule_time_resource_target_proxy MODIFY fort_create_by       varchar(24) comment '创建人';


ALTER TABLE fort_strategy_password MODIFY fort_create_by       varchar(24) comment '创建人';
ALTER TABLE fort_user MODIFY fort_create_by       varchar(24) comment '创建人';
ALTER TABLE fort_user_group MODIFY fort_create_by       varchar(24) comment '创建人';


ALTER TABLE fort_account MODIFY fort_last_edit_by    varchar(24) comment '最后修改人';

ALTER TABLE fort_application_release_server MODIFY fort_last_edit_by    varchar(24) comment '最后修改人';

ALTER TABLE fort_authorization MODIFY fort_last_edit_by    varchar(24) comment '最后修改人';
ALTER TABLE fort_behavior_guideline MODIFY fort_last_edit_by    varchar(24) comment '最后修改人';

ALTER TABLE fort_department MODIFY fort_last_edit_by    varchar(24) comment '最后修改人';

ALTER TABLE fort_keyboard_assembly3 MODIFY fort_session         varchar(24) not null comment '会话号';





ALTER TABLE fort_plan_password MODIFY fort_last_edit_by    varchar(24) comment '最后修改人';

ALTER TABLE fort_plan_password_backup MODIFY fort_last_edit_by    varchar(24) comment '最后修改人';
ALTER TABLE fort_process MODIFY fort_last_edit_by    varchar(24) comment '最后修改人';


ALTER TABLE fort_resource MODIFY fort_last_edit_by    varchar(24) comment '最后修改人';


ALTER TABLE fort_resource  MODIFY fort_connection_protocol varchar(24) comment '连接协议';



ALTER TABLE fort_resource_application MODIFY fort_last_edit_by    varchar(24) comment '最后修改人';



ALTER TABLE fort_resource_group MODIFY fort_last_edit_by    varchar(24) comment '最后修改人';

ALTER TABLE fort_role MODIFY fort_last_edit_by    varchar(24) comment '最后修改人';
ALTER TABLE fort_rule_address MODIFY fort_last_edit_by    varchar(24) comment '最后修改人';
ALTER TABLE fort_rule_command MODIFY fort_last_edit_by    varchar(24) comment '最后修改人';

ALTER TABLE fort_rule_command MODIFY fort_prior_id        varchar(24) comment '上一个规则';
   
ALTER TABLE fort_rule_command MODIFY fort_next_id         varchar(24) comment '下一个规则';



ALTER TABLE fort_rule_command_target_proxy MODIFY fort_last_edit_by    varchar(24) comment '最后修改人';
ALTER TABLE fort_rule_time MODIFY fort_last_edit_by    varchar(24) comment '最后修改人';

ALTER TABLE fort_rule_time_resource MODIFY fort_last_edit_by    varchar(24) comment '最后修改人';
ALTER TABLE fort_rule_time_resource MODIFY fort_prior_id        varchar(24) comment '上一个规则';
  

ALTER TABLE fort_rule_time_resource MODIFY fort_next_id         varchar(24) comment '下一个规则';



ALTER TABLE fort_rule_time_resource_target_proxy MODIFY fort_last_edit_by    varchar(24) comment '最后修改人';

ALTER TABLE fort_strategy_password MODIFY fort_last_edit_by    varchar(24) comment '最后修改人';
ALTER TABLE fort_user MODIFY fort_last_edit_by    varchar(24) comment '最后修改人';




ALTER TABLE fort_user_group MODIFY fort_last_edit_by    varchar(24) comment '最后修改人';



UPDATE fort_ldap_user SET fort_ldap_user_dn = CONCAT (fort_ldap_user_dn,':cn') WHERE fort_ldap_user_dn NOT LIKE '%:cn' AND fort_ldap_user_dn IS NOT NULL AND fort_ldap_user_dn <> '';

COMMIT;