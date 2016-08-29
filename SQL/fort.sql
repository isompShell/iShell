USE `fort`;
SET FOREIGN_KEY_CHECKS = 0; 
SET unique_checks=0; 


drop table if exists fort_account;

drop table if exists fort_application_release_server;

drop table if exists fort_application_release_server_account;

drop table if exists fort_approval_record;

drop table if exists fort_audit_approval_application;

drop table if exists fort_audit_command_log;

drop table if exists fort_audit_log;

drop table if exists fort_audit_title_log;

drop table if exists fort_authorization;

drop table if exists fort_authorization_target_proxy;

drop table if exists fort_behavior_guideline;

drop table if exists fort_behavior_guideline_set;

drop table if exists fort_behavior_guideline_set_element;

drop table if exists fort_behavior_guideline_set_guideline;

drop table if exists fort_behavior_guideline_type;

drop table if exists fort_client_tool;

drop table if exists fort_command;

drop table if exists fort_command_approval_application;

drop table if exists fort_command_element;

drop table if exists fort_department;

drop table if exists fort_double_approval;

drop table if exists fort_double_approval_application;

drop table if exists fort_forbidden_character;

drop table if exists fort_guideline_command;

drop table if exists fort_guideline_command_option;

drop table if exists fort_guideline_command_type;

drop table if exists fort_ip_mask;

drop table if exists fort_ip_range;

drop table if exists fort_keyboard_assembly3;

drop table if exists fort_ldap_user;

drop table if exists fort_message;

drop table if exists fort_message_type;

drop table if exists fort_operations_protocol;

drop table if exists fort_password_approval_application;

drop table if exists fort_plan_password;

drop table if exists fort_plan_password_backup;

drop table if exists fort_plan_password_backup_record;

drop table if exists fort_plan_password_target_proxy;

drop table if exists fort_privilege;

drop table if exists fort_process;

drop table if exists fort_process_instance;

drop table if exists fort_process_task;

drop table if exists fort_process_task_instance;

drop table if exists fort_protocol_client;

drop table if exists fort_report_template_audit_log;

drop table if exists fort_report_template_system_log;

drop table if exists fort_resource;

drop table if exists fort_resource_application;

drop table if exists fort_resource_group;

drop table if exists fort_resource_group_resource;

drop table if exists fort_resource_operations_protocol;

drop table if exists fort_resource_type;

drop table if exists fort_resource_type_operations_protocol;

drop table if exists fort_role;

drop table if exists fort_role_activation_approval_application;

drop table if exists fort_role_authorization_scope;

drop table if exists fort_role_mutex;

drop table if exists fort_role_privilege;

drop table if exists fort_rule_address;

drop table if exists fort_rule_command;

drop table if exists fort_rule_command_target_proxy;

drop table if exists fort_rule_time;

drop table if exists fort_rule_time_resource;

drop table if exists fort_rule_time_resource_target_proxy;

drop table if exists fort_strategy_password;

drop table if exists fort_superior_approval_application;

drop table if exists fort_system_alarm;

drop table if exists fort_system_alarm_type;

drop table if exists fort_system_log;

drop table if exists fort_system_log_type;

drop table if exists fort_task_participant;

drop table if exists fort_three_uniform_user;

drop table if exists fort_user;

drop table if exists fort_user_group;

drop table if exists fort_user_group_user;

drop table if exists fort_user_protocol_client;

drop table if exists fort_user_role;

/*==============================================================*/
/* Table: fort_account                                          */
/*==============================================================*/
create table fort_account
(
   fort_account_id      varchar(24) not null comment '资源帐号ID',
   fort_resource_id     varchar(24) comment '资源ID',
   fort_account_name    varchar(64) not null comment '资源帐号名称',
   fort_account_password varchar(256) comment '资源帐号密码',
   fort_uid             varchar(8) comment 'UID',
   fort_is_allow_authorized varchar(1) comment '是否允许授权（1:可以授权,0:不可授权）',
   fort_is_database_account varchar(1) comment '是数据库帐号（1:是数据库帐号0:不是数据库帐号）',
   fort_create_date     datetime comment '创建时间',
   fort_create_by       varchar(24) comment '创建人',
   fort_last_edit_date  datetime comment '最后修改时间',
   fort_last_edit_by    varchar(24) comment '最后修改人',
   fort_description     varchar(256) comment '描述',
   fort_field1          varchar(32) comment '预留字段1',
   fort_field2          varchar(32) comment '预留字段2',
   fort_field3          varchar(32) comment '预留字段3',
   fort_field4          varchar(32) comment '预留字段4',
   fort_field5          varchar(32) comment '预留字段5',
   fort_field6          varchar(32) comment '预留字段6',
   fort_field7          varchar(32) comment '预留字段7',
   fort_field8          varchar(32) comment '预留字段8',
   fort_field9          varchar(32) comment '预留字段9',
   fort_field10         varchar(32) comment '预留字段10',
   primary key (fort_account_id)
);

alter table fort_account comment '资源帐号';

/*==============================================================*/
/* Table: fort_application_release_server                       */
/*==============================================================*/
create table fort_application_release_server
(
   fort_application_release_server_id varchar(24) not null comment '应用发布服务器ID',
   fort_application_release_server_name varchar(32) not null comment '应用发布服务器名称',
   fort_application_release_server_ip varchar(32) comment '应用发布服务器IP',
   fort_application_release_server_account varchar(32) comment '应用发布服务器帐号',
   fort_application_release_server_password varchar(32) comment '应用发布服务器口令',
   fort_application_release_server_port varchar(8) comment '应用发布服务器端口',
   fort_description     varchar(256) comment '描述',
   fort_create_date     datetime comment '创建时间',
   fort_create_by       varchar(24) comment '创建人',
   fort_last_edit_date  datetime comment '最后修改时间',
   fort_last_edit_by    varchar(24) comment '最后修改人',
   primary key (fort_application_release_server_id)
);

alter table fort_application_release_server comment '应用发布服务器';

/*==============================================================*/
/* Table: fort_application_release_server_account               */
/*==============================================================*/
create table fort_application_release_server_account
(
   fort_account_id      varchar(24) not null comment '帐号ID',
   fort_application_release_server_id varchar(24) comment '应用发布服务器ID',
   fort_account_name    varchar(64) comment '帐号名称',
   fort_account_password varchar(256) comment '帐号密码',
   primary key (fort_account_id)
);

alter table fort_application_release_server_account comment '应用发布帐号';

/*==============================================================*/
/* Table: fort_approval_record                                  */
/*==============================================================*/
create table fort_approval_record
(
   fort_approval_record_id varchar(24) not null comment '审批记录ID',
   fort_process_task_instance_id varchar(24) not null comment '流程任务实例ID',
   fort_target_id       varchar(24) not null comment '审批目标ID',
   fort_target_code     varchar(32) not null comment '审批目标代码',
   fort_approver_id     varchar(24) comment '审批人ID',
   fort_approver_name   varchar(32) comment '审批人名称',
   fort_approver_account varchar(32) comment '审批人帐号',
   fort_approval_result varchar(1) comment '审批结果',
   fort_approval_time   datetime comment '审批时间',
   fort_approval_opinions varchar(256) comment '审批意见',
   primary key (fort_approval_record_id)
);

alter table fort_approval_record comment '审批记录';

/*==============================================================*/
/* Table: fort_audit_approval_application                       */
/*==============================================================*/
create table fort_audit_approval_application
(
   fort_audit_approval_application_id varchar(24) not null comment '审计审批申请单ID',
   fort_process_id      varchar(24) comment '流程ID',
   fort_process_instance_id varchar(24) comment '流程实例ID',
   fort_session         varchar(32) comment '会话号',
   fort_applicant_id    varchar(24) comment '申请人ID',
   fort_apply_create_time datetime comment '申请发起时间',
   fort_user_id         varchar(24) comment '审计用户ID',
   fort_user_account    varchar(64) comment '审计用户帐号',
   fort_user_name       varchar(64) comment '审计用户名称',
   fort_ip              varchar(32) comment '审计用户IP',
   fort_account_id      varchar(24) comment '申请帐号ID',
   fort_account_name    varchar(32) comment '申请帐号名称',
   fort_resource_id     varchar(24) comment '申请资源ID',
   fort_resource_name   varchar(32) comment '申请资源名称',
   fort_resource_ip     varchar(32) comment '申请资源IP',
   fort_resource_type   varchar(32) comment '申请资源类型',
   fort_operations_protocol_name varchar(32) comment '运维协议名称',
   fort_start_time      datetime comment '开始时间',
   fort_end_time        datetime comment '结束时间',
   primary key (fort_audit_approval_application_id)
);

alter table fort_audit_approval_application comment '审计审批申请单';

/*==============================================================*/
/* Table: fort_audit_command_log                                */
/*==============================================================*/
create table fort_audit_command_log
(
   fort_audit_command_log_id varchar(24) not null comment '行为审计命令日志ID',
   fort_audit_id        varchar(24) not null comment '行为审计日志ID',
   fort_command         varchar(256) not null comment '行为审计命令值',
   fort_session         varchar(32) not null comment '会话号',
   fort_size            varchar(16) comment '大小',
   fort_state           varchar(1) comment '命令执行状态，1成功0失败',
   fort_run_time        datetime comment '执行时间',
   fort_guideline_state varchar(1) comment '指引状态（1:匹配指引0:不匹配指引）',
   fort_description     varchar(256) comment '描述',
   primary key (fort_audit_command_log_id)
);

alter table fort_audit_command_log comment '行为审计命令日志';

/*==============================================================*/
/* Table: fort_audit_log                                        */
/*==============================================================*/
create table fort_audit_log
(
   fort_audit_id        varchar(24) not null comment '行为审计日志ID',
   fort_session         varchar(32) not null comment '会话号',
   fort_web_session     varchar(32) comment 'WEB SESSION ID',
   fort_double_process_id varchar(24) comment '双人流程ID',
   fort_superior_process_id varchar(24) comment '上级审批流程ID',
   fort_operations_protocol_id varchar(24) comment '运维协议ID',
   fort_operations_protocol_name varchar(64) comment '运维协议名称',
   fort_user_id         varchar(24) comment '用户ID',
   fort_user_account    varchar(64) comment '用户帐号',
   fort_user_name       varchar(64) comment '用户名称',
   fort_ip              varchar(32) comment '用户IP',
   fort_resource_type_id varchar(24) comment '资源类型ID',
   fort_resource_type_name varchar(32) comment '资源类型名称',
   fort_resource_id     varchar(24) comment '资源ID',
   fort_resource_name   varchar(32) comment '资源名称',
   fort_resource_ip     varchar(32) comment '资源IP',
   fort_account_id      varchar(24) comment '资源帐号ID',
   fort_account_name    varchar(32) comment '资源帐号名称',
   fort_start_time      datetime comment '开始时间',
   fort_end_time        datetime comment '结束时间',
   fort_accesstype      varchar(32) comment '存储类型',
   fort_file_server     varchar(24) comment '文件服务器',
   fort_state           varchar(1) comment '归档状态（0未归档1已归档）',
   fort_field1          varchar(32) comment '预留字段1',
   fort_field2          varchar(32) comment '预留字段2',
   fort_field3          varchar(32) comment '预留字段3',
   primary key (fort_audit_id)
);

alter table fort_audit_log comment '行为审计日志';

/*==============================================================*/
/* Table: fort_audit_title_log                                  */
/*==============================================================*/
create table fort_audit_title_log
(
   fort_audit_title_log_id varchar(24) not null comment '行为审计标题日志表ID',
   fort_audit_id        varchar(24) comment '行为审计日志ID',
   fort_version         varchar(4) comment '版本',
   fort_session         varchar(32) comment '会话号',
   fort_time            datetime comment '时间',
   fort_frame           varchar(24) comment '帧',
   fort_type            varchar(4) comment '标题类型',
   fort_title           varchar(256) comment '标题',
   primary key (fort_audit_title_log_id)
);

alter table fort_audit_title_log comment '行为审计标题日志';

/*==============================================================*/
/* Table: fort_authorization                                    */
/*==============================================================*/
create table fort_authorization
(
   fort_authorization_id varchar(24) not null comment '授权ID',
   fort_department_id   varchar(24) not null comment '部门ID',
   fort_authorization_name varchar(32) not null comment '授权名称',
   fort_authorization_code int comment '授权代码',
   fort_double_is_open  varchar(1) comment '开启双人审批(1开启2关闭)',
   fort_superior_process_id varchar(24) comment '上级审批流程ID',
   fort_create_date     datetime comment '创建时间',
   fort_create_by       varchar(24) comment '创建人',
   fort_last_edit_date  datetime comment '最后修改时间',
   fort_last_edit_by    varchar(24) comment '最后修改人',
   fort_description     varchar(256) comment '描述',
   fort_field1          varchar(32) comment '预留字段1',
   fort_field2          varchar(32) comment '预留字段2',
   fort_field3          varchar(32) comment '预留字段3',
   primary key (fort_authorization_id)
);

alter table fort_authorization comment '授权';

/*==============================================================*/
/* Table: fort_authorization_target_proxy                       */
/*==============================================================*/
create table fort_authorization_target_proxy
(
   fort_authorization_target_proxy_id varchar(24) not null comment '授权目标代理ID',
   fort_authorization_id varchar(24) comment '授权ID',
   fort_target_id       varchar(24) comment '目标ID',
   fort_target_code     int comment '目标代码',
   fort_is_up_super     varchar(1) comment '是否提权',
   fort_parent_id       varchar(24) comment '所属目标ID',
   primary key (fort_authorization_target_proxy_id)
);

alter table fort_authorization_target_proxy comment '授权目标代理';

/*==============================================================*/
/* Table: fort_behavior_guideline                               */
/*==============================================================*/
create table fort_behavior_guideline
(
   fort_behavior_guideline_id varchar(24) not null comment '行为指引ID',
   fort_behavior_guideline_type_id varchar(24) comment '行为指引类型ID',
   fort_behavior_guideline_name varchar(32) not null comment '行为指引名称',
   fort_is_open         varchar(1) comment '是开启的（1开启0关闭）',
   fort_is_locked       varchar(1) comment '是被锁的（1开锁0被锁）',
   fort_description     varchar(256) comment '描述',
   fort_create_date     datetime comment '创建时间',
   fort_create_by       varchar(24) comment '创建人',
   fort_last_edit_date  datetime comment '最后修改时间',
   fort_last_edit_by    varchar(24) comment '最后修改人',
   primary key (fort_behavior_guideline_id)
);

alter table fort_behavior_guideline comment '行为指引';

/*==============================================================*/
/* Table: fort_behavior_guideline_set                           */
/*==============================================================*/
create table fort_behavior_guideline_set
(
   fort_behavior_guideline_set_id varchar(24) not null comment '行为指引集ID',
   fort_session         varchar(32) not null comment '会话号',
   fort_description     varchar(256) comment '描述',
   primary key (fort_behavior_guideline_set_id)
);

alter table fort_behavior_guideline_set comment '行为指引集';

/*==============================================================*/
/* Table: fort_behavior_guideline_set_element                   */
/*==============================================================*/
create table fort_behavior_guideline_set_element
(
   fort_behavior_guideline_set_element_id varchar(24) not null comment '行为指引集原组ID',
   fort_behavior_guideline_set_id varchar(24) comment '行为指引集ID',
   fort_command         varchar(32) not null comment '命令',
   fort_command_option  varchar(256) comment '选项',
   fort_description     varchar(256) comment '命令描述',
   primary key (fort_behavior_guideline_set_element_id)
);

alter table fort_behavior_guideline_set_element comment '行为指引集关联命令原组';

/*==============================================================*/
/* Table: fort_behavior_guideline_set_guideline                 */
/*==============================================================*/
create table fort_behavior_guideline_set_guideline
(
   fort_behavior_guideline_set_guideline_id varchar(24) not null comment '行为指引集指引ID',
   fort_behavior_guideline_set_id varchar(24) comment '行为指引集ID',
   fort_behavior_guideline_name varchar(32) comment '行为指引名称',
   fort_behavior_guideline_type varchar(128) comment '行为指引类型',
   primary key (fort_behavior_guideline_set_guideline_id)
);

alter table fort_behavior_guideline_set_guideline comment '行为指引集关联指引';

/*==============================================================*/
/* Table: fort_behavior_guideline_type                          */
/*==============================================================*/
create table fort_behavior_guideline_type
(
   fort_behavior_guideline_type_id varchar(24) not null comment '行为指引类型ID',
   fort_parent_id       varchar(24) comment '父节点ID',
   fort_behavior_guideline_type_name varchar(32) not null comment '行为指引类型名称',
   fort_behavior_guideline_type_full_name varchar(128) comment '行为指引类型全称',
   primary key (fort_behavior_guideline_type_id)
);

alter table fort_behavior_guideline_type comment '行为指引类型';

/*==============================================================*/
/* Table: fort_client_tool                                      */
/*==============================================================*/
create table fort_client_tool
(
   fort_client_tool_id  varchar(24) not null comment '客户端工具ID',
   fort_client_tool_name varchar(64) not null comment '客户端工具名称',
   fort_action_script   varchar(512) comment '动作流脚本',
   fort_is_custom       varchar(1) comment '自定义',
   primary key (fort_client_tool_id)
);

alter table fort_client_tool comment '客户端工具';

/*==============================================================*/
/* Table: fort_command                                          */
/*==============================================================*/
create table fort_command
(
   fort_command_id      varchar(24) not null comment '命令ID',
   fort_rule_command_id varchar(24) not null comment '命令规则ID',
   fort_command_value   varchar(256) not null comment '命令',
   primary key (fort_command_id)
);

alter table fort_command comment '命令表';

/*==============================================================*/
/* Table: fort_command_approval_application                     */
/*==============================================================*/
create table fort_command_approval_application
(
   fort_command_approval_application_id varchar(24) not null comment '双人审批申请单ID',
   fort_process_id      varchar(24) comment '流程ID',
   fort_process_instance_id varchar(24) comment '流程实例ID',
   fort_session         varchar(32) comment '会话号',
   fort_command_context varchar(2048) comment '审批命令上下文',
   fort_apply_create_time datetime comment '申请发起时间',
   fort_account_id      varchar(24) comment '申请帐号ID',
   fort_account_name    varchar(32) comment '申请帐号名称',
   fort_resource_id     varchar(24) comment '申请资源ID',
   fort_resource_name   varchar(32) comment '申请资源名称',
   fort_resource_ip     varchar(32) comment '申请资源IP',
   fort_resource_type   varchar(32) comment '申请资源类型',
   fort_applicant_id    varchar(24) comment '申请人ID',
   fort_description     varchar(256) comment '描述',
   primary key (fort_command_approval_application_id)
);

alter table fort_command_approval_application comment '命令审批申请单';

/*==============================================================*/
/* Table: fort_command_element                                  */
/*==============================================================*/
create table fort_command_element
(
   fort_command_element_id varchar(24) not null comment '命令原组ID',
   fort_behavior_guideline_id varchar(24) comment '行为指引ID',
   fort_command         varchar(32) not null comment '命令',
   fort_command_option_code varchar(128) comment '选项代码（包含颜色表达式的选项字符串）',
   fort_command_option  varchar(128) comment '选项',
   fort_command_type    varchar(128) comment '命令分类',
   fort_regular         varchar(128) comment '正则',
   fort_description     varchar(256) comment '命令描述',
   primary key (fort_command_element_id)
);

alter table fort_command_element comment '命令原组';

/*==============================================================*/
/* Table: fort_department                                       */
/*==============================================================*/
create table fort_department
(
   fort_department_id   varchar(24) not null comment '部门ID',
   fort_department_name varchar(64) not null comment '部门名称',
   fort_full_name       varchar(256) comment '部门全称',
   fort_parent_id       varchar(24) comment '上级部门ID',
   fort_order           int comment '排序',
   fort_create_date     datetime comment '创建时间',
   fort_create_by       varchar(24) comment '创建人',
   fort_last_edit_date  datetime comment '最后修改时间',
   fort_last_edit_by    varchar(24) comment '最后修改人',
   primary key (fort_department_id)
);

alter table fort_department comment '部门';

/*==============================================================*/
/* Table: fort_double_approval                                  */
/*==============================================================*/
create table fort_double_approval
(
   fort_double_approval_id varchar(24) not null comment '双人审批ID',
   fort_authorization_id varchar(24) not null comment '授权ID',
   fort_user_id         varchar(24) not null comment '关联用户ID',
   fort_is_candidate    varchar(1) comment '是候选人(1是候选人0不是候选人)',
   fort_is_approver     varchar(1) comment '是审批人(1是审批人0不是审批人)',
   primary key (fort_double_approval_id)
);

alter table fort_double_approval comment '双人审批';

/*==============================================================*/
/* Table: fort_double_approval_application                      */
/*==============================================================*/
create table fort_double_approval_application
(
   fort_double_approval_application_id varchar(24) not null comment '双人审批申请单ID',
   fort_process_id      varchar(24) comment '流程ID',
   fort_process_instance_id varchar(24) comment '流程实例ID',
   fort_web_session     varchar(32) comment 'WEB SESSION',
   fort_session         varchar(32) comment '会话号',
   fort_apply_create_time datetime comment '申请发起时间',
   fort_account_id      varchar(24) comment '申请帐号ID',
   fort_account_name    varchar(32) comment '申请帐号名称',
   fort_resource_id     varchar(24) comment '申请资源ID',
   fort_resource_name   varchar(32) comment '申请资源名称',
   fort_resource_ip     varchar(32) comment '申请资源IP',
   fort_resource_type   varchar(32) comment '申请资源类型',
   fort_applicant_id    varchar(24) comment '申请人ID',
   fort_description     varchar(256) comment '描述',
   primary key (fort_double_approval_application_id)
);

alter table fort_double_approval_application comment '双人审批申请单';

/*==============================================================*/
/* Table: fort_forbidden_character                              */
/*==============================================================*/
create table fort_forbidden_character
(
   fort_forbidden_character_id varchar(24) not null comment '禁止字符ID',
   fort_strategy_password_id varchar(24) not null comment '口令策略ID',
   fort_forbidden_character_value varchar(32) comment '禁止字符',
   primary key (fort_forbidden_character_id)
);

alter table fort_forbidden_character comment '口令策略禁止字符';

/*==============================================================*/
/* Table: fort_guideline_command                                */
/*==============================================================*/
create table fort_guideline_command
(
   fort_guideline_command_id varchar(24) not null comment '指引命令ID',
   fort_guideline_command_type_id varchar(24) comment '指引命令分类ID',
   fort_guideline_command_name varchar(32) not null comment '指引命令名称',
   fort_guideline_command_grammar varchar(128) comment '指引命令语法',
   fort_description     varchar(256) comment '描述',
   primary key (fort_guideline_command_id)
);

alter table fort_guideline_command comment '指引命令';

/*==============================================================*/
/* Table: fort_guideline_command_option                         */
/*==============================================================*/
create table fort_guideline_command_option
(
   fort_guideline_command_option_id varchar(24) not null comment '指引命令选项ID',
   fort_guideline_command_id varchar(24) comment '指引命令ID',
   fort_short_name      varchar(16) comment '选项短名称',
   fort_full_name       varchar(32) comment '选项全名称',
   fort_level           varchar(1) not null comment '级别',
   fort_description     varchar(256) comment '说明',
   primary key (fort_guideline_command_option_id)
);

alter table fort_guideline_command_option comment '指引命令选项';

/*==============================================================*/
/* Table: fort_guideline_command_type                           */
/*==============================================================*/
create table fort_guideline_command_type
(
   fort_guideline_command_type_id varchar(24) not null comment '指引命令分类ID',
   fort_parent_id       varchar(24) comment '父节点ID',
   fort_guideline_command_type_name varchar(32) not null comment '指引命令分类名称',
   fort_guideline_command_type_full_name varchar(128) comment '指引命令分类全称',
   primary key (fort_guideline_command_type_id)
);

alter table fort_guideline_command_type comment '指引命令分类';

/*==============================================================*/
/* Table: fort_ip_mask                                          */
/*==============================================================*/
create table fort_ip_mask
(
   fort_ip_mask_id      varchar(24) not null comment 'IP掩码ID',
   fort_rule_address_id varchar(24) comment '地址规则ID',
   fort_ip              varchar(16) comment 'IP地址',
   fort_mask            varchar(32) comment '掩码',
   primary key (fort_ip_mask_id)
);

alter table fort_ip_mask comment 'IP及掩码';

/*==============================================================*/
/* Table: fort_ip_range                                         */
/*==============================================================*/
create table fort_ip_range
(
   fort_ip_range_id     varchar(24) not null comment 'IP区间ID',
   fort_rule_address_id varchar(24) comment '地址规则ID',
   fort_ip_start        varchar(16) not null comment '起始IP',
   fort_ip_end          varchar(16) not null comment '结束IP',
   primary key (fort_ip_range_id)
);

alter table fort_ip_range comment 'IP区间';

/*==============================================================*/
/* Table: fort_keyboard_assembly3                               */
/*==============================================================*/
create table fort_keyboard_assembly3
(
   fort_keyboard_assembly_id varchar(24) not null comment '键盘拼装ID',
   fort_session         varchar(24) not null comment '会话号',
   fort_time            datetime not null comment '时间',
   fort_content         varchar(64) not null comment '内容',
   fort_frame           varchar(24) not null comment '帧',
   primary key (fort_keyboard_assembly_id)
);

alter table fort_keyboard_assembly3 comment '3秒键盘拼装';

/*==============================================================*/
/* Table: fort_ldap_user                                        */
/*==============================================================*/
create table fort_ldap_user
(
   fort_ldap_user_id    varchar(24) not null comment 'LDAP用户ID',
   fort_user_id         varchar(24) comment '用户ID',
   fort_user_account    varchar(64) not null comment '用户帐号',
   fort_ldap_user_name  varchar(64) comment 'LDAP用户名称',
   fort_ldap_user_dn    varchar(256) not null comment 'LDAP用户DN',
   fort_ldap_user_mobile varchar(16) comment '手机',
   fort_ldap_user_phone varchar(16) comment '电话',
   fort_ldap_user_address varchar(128) comment '地址',
   fort_ldap_user_email varchar(64) comment '邮箱',
   fort_user_type       varchar(1) not null comment '用户类型（0.新发现 1.已导入 2.排除）',
   fort_ldap_user_state varchar(1) comment '状态',
   fort_create_date     datetime comment '创建时间',
   fort_last_edit_date  datetime comment '修改时间',
   primary key (fort_ldap_user_id)
);

alter table fort_ldap_user comment 'AD同步用户表';

/*==============================================================*/
/* Table: fort_message                                          */
/*==============================================================*/
create table fort_message
(
   fort_message_id      varchar(24) not null comment '消息ID',
   fort_message_type_id varchar(24) comment '消息类型ID',
   fort_receive_user_id varchar(24) comment '接收人ID',
   fort_receive_user_name varchar(32) comment '接收人名称',
   fort_receive_user_account varchar(32) comment '接收人帐号',
   fort_send_user_id    varchar(24) comment '发送人ID',
   fort_send_user_name  varchar(32) comment '发送人名称',
   fort_send_user_account varchar(32) comment '发送人帐号',
   fort_time            datetime comment '接收时间',
   fort_message_digest  varchar(128) comment '消息摘要',
   fort_state           varchar(1) comment '阅读状态',
   fort_target          varchar(128) comment '目标条件',
   primary key (fort_message_id)
);

alter table fort_message comment '消息表';

/*==============================================================*/
/* Table: fort_message_type                                     */
/*==============================================================*/
create table fort_message_type
(
   fort_message_type_id varchar(24) not null comment '消息类型ID',
   fort_message_type_name varchar(32) not null comment '消息类型名称',
   fort_url             varchar(128) comment '目标URL',
   primary key (fort_message_type_id)
);

alter table fort_message_type comment '消息类型表';

/*==============================================================*/
/* Table: fort_operations_protocol                              */
/*==============================================================*/
create table fort_operations_protocol
(
   fort_operations_protocol_id varchar(24) not null comment '运维协议ID',
   fort_operations_protocol_name varchar(64) not null comment '协议名称',
   fort_operations_protocol_code varchar(32) comment '协议代码',
   primary key (fort_operations_protocol_id)
);

alter table fort_operations_protocol comment '运维协议';

/*==============================================================*/
/* Table: fort_password_approval_application                    */
/*==============================================================*/
create table fort_password_approval_application
(
   fort_password_approval_application_id varchar(24) not null comment '改密审批申请单ID',
   fort_process_id      varchar(24) comment '流程ID',
   fort_process_instance_id varchar(24) comment '流程实例ID',
   fort_apply_create_time datetime comment '申请发起时间',
   fort_account_id      varchar(24) comment '申请帐号ID',
   fort_account_name    varchar(32) comment '申请帐号名称',
   fort_resource_id     varchar(24) comment '申请资源ID',
   fort_resource_name   varchar(32) comment '申请资源名称',
   fort_resource_ip     varchar(32) comment '申请资源IP',
   fort_resource_type   varchar(32) comment '申请资源类型',
   fort_applicant_id    varchar(24) comment '申请人ID',
   fort_description     varchar(256) comment '描述',
   primary key (fort_password_approval_application_id)
);

alter table fort_password_approval_application comment '改密审批申请单';

/*==============================================================*/
/* Table: fort_plan_password                                    */
/*==============================================================*/
create table fort_plan_password
(
   fort_plan_password_id varchar(24) not null comment '密码计划ID',
   fort_department_id   varchar(24) not null comment '部门ID',
   fort_plan_password_name varchar(32) not null comment '密码计划名称',
   fort_state           varchar(1) comment '状态',
   fort_run_mode        varchar(1) not null comment '执行方式',
   fort_first_run_time  datetime comment '首次执行时间',
   fort_end_run_time    datetime comment '截止时间',
   fort_plan_code       int comment '计划CODE',
   fort_run_interval    int comment '间隔周期',
   fort_backup_file_name varchar(32) comment '备份文件名称',
   fort_password_generation_type varchar(1) comment '口令生成方式',
   fort_new_password    varchar(4096) comment '新口令',
   fort_password_send_mode varchar(1) comment '发送方式',
   fort_connect_test    varchar(1) comment '是否拨测',
   fort_create_date     datetime comment '创建时间',
   fort_create_by       varchar(24) comment '创建人',
   fort_last_edit_date  datetime comment '最后修改时间',
   fort_last_edit_by    varchar(24) comment '最后修改人',
   primary key (fort_plan_password_id)
);

alter table fort_plan_password comment '密码计划';

/*==============================================================*/
/* Table: fort_plan_password_backup                             */
/*==============================================================*/
create table fort_plan_password_backup
(
   fort_plan_password_backup_id varchar(24) not null comment '密码备份计划ID',
   fort_department_id   varchar(24) not null comment '部门ID',
   fort_plan_password_backup_name varchar(32) not null comment '密码备份计划名称',
   fort_state           varchar(1) comment '状态',
   fort_run_mode        varchar(1) not null comment '执行方式',
   fort_first_run_time  datetime comment '首次执行时间',
   fort_end_run_time    datetime comment '截止时间',
   fort_plan_code       int comment '计划CODE',
   fort_run_interval    int comment '间隔周期',
   fort_backup_file_name varchar(32) comment '备份文件名称',
   fort_password_send_mode varchar(1) comment '发送方式',
   fort_password_backup_object varchar(1) comment '备份对象',
   fort_connect_test    varchar(1) comment '登陆测试',
   fort_create_date     datetime comment '创建时间',
   fort_create_by       varchar(24) comment '创建人',
   fort_last_edit_date  datetime comment '最后修改时间',
   fort_last_edit_by    varchar(24) comment '最后修改人',
   primary key (fort_plan_password_backup_id)
);

alter table fort_plan_password_backup comment '密码备份计划';

/*==============================================================*/
/* Table: fort_plan_password_backup_record                      */
/*==============================================================*/
create table fort_plan_password_backup_record
(
   fort_plan_password_backup_record_id varchar(24) not null comment '密码计划备份ID',
   fort_plan_id         varchar(24) comment '计划ID',
   fort_operation_user_id varchar(24) comment '操作人ID',
   fort_operation_user  varchar(32) comment '操作人',
   fort_backup_time     datetime comment '备份时间',
   fort_backup_file_name varchar(64) comment '备份文件名称',
   primary key (fort_plan_password_backup_record_id)
);

alter table fort_plan_password_backup_record comment '密码计划备份记录';

/*==============================================================*/
/* Table: fort_plan_password_target_proxy                       */
/*==============================================================*/
create table fort_plan_password_target_proxy
(
   fort_plan_password_target_proxy_id varchar(24) not null comment '密码计划执行目标代理ID',
   fort_plan_id         varchar(24) not null comment '计划ID',
   fort_target_id       varchar(24) not null comment '目标ID',
   fort_target_code     int not null comment '目标代码(1.资源组2.资源3.帐号4.密码管理员5.密钥管理员)',
   primary key (fort_plan_password_target_proxy_id)
);

alter table fort_plan_password_target_proxy comment '密码计划执行目标代理';

/*==============================================================*/
/* Table: fort_privilege                                        */
/*==============================================================*/
create table fort_privilege
(
   fort_privilege_id    varchar(24) not null comment '权限ID',
   fort_privilege_name  varchar(32) not null comment '权限名称',
   fort_privilege_name_enus varchar(32) comment '权限英文名称',
   fort_privilege_code  varchar(64) not null comment '权限代码',
   fort_privilege_type  varchar(1) not null comment '权限类型（1:菜单权限,2:功能权限）',
   fort_privilege_role_type varchar(1) comment '权限角色类型（1:系统级2部门级3系统级+部门级）',
   fort_parent_id       varchar(24) comment '上级权限ID',
   fort_url             varchar(128) comment '目标URL',
   primary key (fort_privilege_id)
);

alter table fort_privilege comment '权限';

/*==============================================================*/
/* Table: fort_process                                          */
/*==============================================================*/
create table fort_process
(
   fort_process_id      varchar(24) not null comment '流程ID',
   fort_process_name    varchar(32) comment '流程名称',
   fort_process_code    varchar(16) comment '流程代码',
   fort_state           varchar(1) comment '流程状态（1开启2关闭）',
   fort_valid_time      int comment '有效期（单位：小时）',
   fort_create_date     datetime comment '创建时间',
   fort_create_by       varchar(24) comment '创建人',
   fort_last_edit_date  datetime comment '最后修改时间',
   fort_last_edit_by    varchar(24) comment '最后修改人',
   primary key (fort_process_id)
);

alter table fort_process comment '流程';

/*==============================================================*/
/* Table: fort_process_instance                                 */
/*==============================================================*/
create table fort_process_instance
(
   fort_process_instance_id varchar(24) not null comment '流程实例ID',
   fort_alias           varchar(32) comment '流程实例别名',
   fort_process_id      varchar(24) comment '流程ID',
   fort_state           varchar(1) not null comment '状态（1进行中2通过3未通过4过期）',
   fort_start_time      datetime comment '开始时间',
   fort_end_time        datetime comment '结束时间',
   fort_create_by       varchar(24) comment '创建人',
   primary key (fort_process_instance_id)
);

alter table fort_process_instance comment '流程实例';

/*==============================================================*/
/* Table: fort_process_task                                     */
/*==============================================================*/
create table fort_process_task
(
   fort_process_task_id varchar(24) not null comment '流程任务ID',
   fort_parent_id       varchar(24) comment '上级任务ID',
   fort_process_id      varchar(24) comment '流程ID',
   fort_process_task_name varchar(32) comment '任务名称',
   fort_participant_type varchar(1) comment '任务参与者类型（1:动态,2:静态）',
   fort_run_mode        varchar(1) comment '执行方式（1:串行,2:并行）',
   fort_task_code       varchar(32) comment '任务代码',
   fort_concurrent_rule varchar(8) comment '并发规则',
   fort_valid_time      int comment '有效期（单位:小时）',
   primary key (fort_process_task_id)
);

alter table fort_process_task comment '流程任务';

/*==============================================================*/
/* Table: fort_process_task_instance                            */
/*==============================================================*/
create table fort_process_task_instance
(
   fort_process_task_instance_id varchar(24) not null comment '流程任务实例ID',
   fort_process_instance_id varchar(24) comment '流程实例ID',
   fort_process_task_id varchar(24) comment '流程任务ID',
   fort_parent_id       varchar(24) comment '父节点ID',
   fort_task_participant_id varchar(24) comment '任务参与者表ID',
   fort_state           varchar(1) not null comment '状态(0待认领 1进行中 2正常通过3未通过4过期)',
   fort_start_time      datetime comment '开始时间',
   fort_end_time        datetime comment '结束时间',
   primary key (fort_process_task_instance_id)
);

alter table fort_process_task_instance comment '流程任务实例';

/*==============================================================*/
/* Table: fort_protocol_client                                  */
/*==============================================================*/
create table fort_protocol_client
(
   fort_protocol_client_id varchar(24) not null comment '运维协议客户端工具主键ID',
   fort_operations_protocol_id varchar(24) not null comment '运维协议ID',
   fort_client_tool_id  varchar(24) comment '客户端工具ID',
   fort_is_default      varchar(1) comment '是否为默认客户端',
   primary key (fort_protocol_client_id)
);

alter table fort_protocol_client comment '运维协议客户端工具关系表';

/*==============================================================*/
/* Table: fort_report_template_audit_log                        */
/*==============================================================*/
create table fort_report_template_audit_log
(
   fort_report_template_id varchar(24) not null comment '系统日志报表模版ID',
   fort_report_template_name varchar(32) not null comment '系统日志报表模版名称',
   fort_user_account    varchar(64) comment '用户帐号',
   fort_user_name       varchar(64) comment '用户名称',
   fort_user_ip         varchar(32) comment '用户IP',
   fort_resource_name   varchar(32) comment '资源名称',
   fort_resource_ip     varchar(32) comment '资源IP',
   fort_account_name    varchar(32) comment '资源帐号',
   fort_resource_type_code int comment '包含资源类型代码',
   fort_protocol_code   int comment '包含协议代码',
   fort_field_code      int comment '包含字段代码',
   fort_start_time      datetime comment '开始时间',
   fort_end_time        datetime comment '结束时间',
   primary key (fort_report_template_id)
);

alter table fort_report_template_audit_log comment '行为审计日志报表模版';

/*==============================================================*/
/* Table: fort_report_template_system_log                       */
/*==============================================================*/
create table fort_report_template_system_log
(
   fort_report_template_id varchar(24) not null comment '系统日志报表模版ID',
   fort_report_template_name varchar(32) not null comment '系统日志报表模版名称',
   fort_user_account    varchar(64) comment '用户帐号',
   fort_user_name       varchar(64) comment '用户名称',
   fort_ip              varchar(32) comment '用户IP',
   fort_module          varchar(32) comment '模块',
   fort_act             varchar(256) comment '操作',
   fort_result_state    varchar(32) comment '操作结果',
   fort_start_time      datetime comment '开始时间',
   fort_end_time        datetime comment '结束时间',
   fort_field_code      int comment '包含字段代码',
   primary key (fort_report_template_id)
);

alter table fort_report_template_system_log comment '系统日志报表模版';

/*==============================================================*/
/* Table: fort_resource                                         */
/*==============================================================*/
create table fort_resource
(
   fort_resource_id     varchar(24) not null comment '资源ID',
   fort_strategy_password_id varchar(24) comment '口令策略ID',
   fort_resource_type_id varchar(24) comment '资源类型ID',
   fort_parent_id       varchar(24) comment '域控或所属系统ID',
   fort_department_id   varchar(24) comment '部门ID',
   fort_rule_time_id    varchar(24) comment '时间规则ID',
   fort_host_name       varchar(64) comment '主机名',
   fort_resource_name   varchar(32) not null comment '资源名称',
   fort_resource_ip     varchar(32) comment '资源IP地址',
   fort_resource_state  varchar(1) comment '资源状态',
   fort_ips             varchar(64) comment 'IPS',
   fort_bs_login_url    varchar(64) comment '登陆URL',
   fort_bs_form_name    varchar(64) comment '表单名称',
   fort_bs_account_attribute varchar(64) comment '帐号属性',
   fort_bs_password_attribute varchar(64) comment '口令属性',
   fort_bs_form_submit_method varchar(64) comment '表单提交方法',
   fort_rdp_code        int comment 'RDP CODE',
   fort_sftp_code       int comment 'SFTP CODE',
   fort_ftp_code        int comment 'FTP CODE',
   fort_samba_code      int comment 'SAMBA CODE',
   fort_admin_account   varchar(64) comment '管理员帐号',
   fort_admin_password  varchar(256) comment '管理员口令',
   fort_admin_password_prompt varchar(64) comment '管理员口令提示符',
   fort_admin_login_prompt varchar(64) comment '管理员登陆提示符',
   fort_connection_protocol varchar(24) comment '连接协议',
   fort_connection_port varchar(8) comment '连接端口',
   fort_coding          varchar(16) comment '编码',
   fort_connection_timeout varchar(64) comment '连接超时',
   fort_analytical_timeout varchar(64) comment '解析超时',
   fort_is_up_super     varchar(1) comment '是否提权',
   fort_up_super_password varchar(64) comment '提权口令',
   fort_up_super_password_prompt varchar(64) comment '提权口令提示符',
   fort_base_dn         varchar(64) comment '域控BASE DN',
   fort_domain_name     varchar(64) comment '域名',
   fort_database_name   varchar(64) comment '数据库名称',
   fort_database_server_name varchar(64) comment '服务名称',
   fort_create_date     datetime comment '创建时间',
   fort_create_by       varchar(24) comment '创建人',
   fort_last_edit_date  datetime comment '最后修改时间',
   fort_last_edit_by    varchar(24) comment '最后修改人',
   fort_description     varchar(256) comment '描述',
   fort_field1          varchar(32) comment '预留字段1',
   fort_field2          varchar(32) comment '预留字段2',
   fort_field3          varchar(32) comment '预留字段3',
   fort_field4          varchar(32) comment '预留字段4',
   fort_field5          varchar(32) comment '预留字段5',
   fort_field6          varchar(32) comment '预留字段6',
   fort_field7          varchar(32) comment '预留字段7',
   fort_field8          varchar(32) comment '预留字段8',
   fort_field9          varchar(32) comment '预留字段9',
   fort_field10         varchar(32) comment '预留字段10',
   primary key (fort_resource_id)
);

alter table fort_resource comment '资源 ';

/*==============================================================*/
/* Table: fort_resource_application                             */
/*==============================================================*/
create table fort_resource_application
(
   fort_resource_application_release_server_id varchar(24) not null comment '资源应用发布服务器主键ID',
   fort_resource_id     varchar(24) not null comment '资源ID',
   fort_application_release_server_id varchar(24) not null comment '应用发布服务器ID',
   fort_create_date     datetime comment '创建时间',
   fort_create_by       varchar(24) comment '创建人',
   fort_last_edit_date  datetime comment '最后修改时间',
   fort_last_edit_by    varchar(24) comment '最后修改人',
   primary key (fort_resource_application_release_server_id)
);

alter table fort_resource_application comment '资源应用发布服务器关系表';

/*==============================================================*/
/* Table: fort_resource_group                                   */
/*==============================================================*/
create table fort_resource_group
(
   fort_resource_group_id varchar(24) not null comment '资源组ID',
   fort_department_id   varchar(24) comment '部门ID',
   fort_resource_group_name varchar(32) not null comment '资源组名称',
   fort_order           int comment '排序',
   fort_create_date     datetime comment '创建时间',
   fort_create_by       varchar(24) comment '创建人',
   fort_last_edit_date  datetime comment '最后修改时间',
   fort_last_edit_by    varchar(24) comment '最后修改人',
   primary key (fort_resource_group_id)
);

alter table fort_resource_group comment '资源组';

/*==============================================================*/
/* Table: fort_resource_group_resource                          */
/*==============================================================*/
create table fort_resource_group_resource
(
   fort_resource_group_resource_id varchar(24) not null comment '资源组资源关系表主键ID',
   fort_resource_group_id varchar(24) comment '资源组ID',
   fort_resource_id     varchar(24) comment '资源ID',
   primary key (fort_resource_group_resource_id)
);

alter table fort_resource_group_resource comment '资源组-资源关系表';

/*==============================================================*/
/* Table: fort_resource_operations_protocol                     */
/*==============================================================*/
create table fort_resource_operations_protocol
(
   fort_resource_operations_protocol_id varchar(24) not null comment '资源协议ID',
   fort_resource_id     varchar(24) not null comment '资源ID',
   fort_operations_protocol_id varchar(24) not null comment '运维协议ID',
   fort_resource_operations_protocol_port varchar(8) comment '资源协议端口',
   primary key (fort_resource_operations_protocol_id)
);

alter table fort_resource_operations_protocol comment '资源运维协议关系表';

/*==============================================================*/
/* Table: fort_resource_type                                    */
/*==============================================================*/
create table fort_resource_type
(
   fort_resource_type_id varchar(24) not null comment '资源类型ID',
   fort_resource_type_name varchar(32) not null comment '资源类型名称',
   fort_resource_type_name_enus varchar(32) comment '资源类型英文名称',
   fort_parent_id       varchar(24) comment '父节点ID',
   fort_resource_type_code varchar(32) comment '资源类型代码',
   primary key (fort_resource_type_id)
);

alter table fort_resource_type comment '资源类型';

/*==============================================================*/
/* Table: fort_resource_type_operations_protocol                */
/*==============================================================*/
create table fort_resource_type_operations_protocol
(
   fort_resource_type_operations_protocol_id varchar(24) not null comment '资源类型运维协议关系表主键',
   fort_resource_type_id varchar(24) comment '资源类型ID',
   fort_operations_protocol_id varchar(24) comment '运维协议ID',
   fort_behavior_guideline_type_id varchar(24) comment '行为指引类型ID',
   primary key (fort_resource_type_operations_protocol_id)
);

alter table fort_resource_type_operations_protocol comment '资源类型运维协议关系表';

/*==============================================================*/
/* Table: fort_role                                             */
/*==============================================================*/
create table fort_role
(
   fort_role_id         varchar(24) not null comment '角色ID',
   fort_role_name       varchar(32) not null comment '角色名称',
   fort_role_short_name varchar(32) comment '角色短名称',
   fort_role_type       varchar(1) comment '角色类型(0:初始化1:系统级2:部门级3:默认角色)',
   fort_weight          int comment '权重',
   fort_state           varchar(1) comment '角色状态（1:启动，0禁用）',
   fort_create_date     datetime comment '创建时间',
   fort_create_by       varchar(24) comment '创建人',
   fort_last_edit_date  datetime comment '最后修改时间',
   fort_last_edit_by    varchar(24) comment '最后修改人',
   fort_field1          varchar(32) comment '预留字段1',
   fort_field2          varchar(32) comment '预留字段2',
   fort_field3          varchar(32) comment '预留字段3',
   primary key (fort_role_id)
);

alter table fort_role comment '角色表';

/*==============================================================*/
/* Table: fort_role_activation_approval_application             */
/*==============================================================*/
create table fort_role_activation_approval_application
(
   fort_role_activation_approval_application_id varchar(24) not null comment '角色激活审批申请单ID',
   fort_process_id      varchar(24) comment '流程ID',
   fort_process_instance_id varchar(24) comment '流程实例ID',
   fort_applicant_id    varchar(24) comment '申请人ID',
   fort_description     varchar(256) comment '描述',
   primary key (fort_role_activation_approval_application_id)
);

alter table fort_role_activation_approval_application comment '角色激活审批申请单';

/*==============================================================*/
/* Table: fort_role_authorization_scope                         */
/*==============================================================*/
create table fort_role_authorization_scope
(
   fort_role_authorization_scope_id varchar(24) not null comment '角色授权范围ID',
   fort_role_id         varchar(24) not null comment '角色ID',
   fort_controllable_role_id varchar(24) not null comment '可控角色ID',
   primary key (fort_role_authorization_scope_id)
);

alter table fort_role_authorization_scope comment '角色授权范围表';

/*==============================================================*/
/* Table: fort_role_mutex                                       */
/*==============================================================*/
create table fort_role_mutex
(
   fort_role_mutex_id   varchar(24) not null comment '角色互斥ID',
   fort_role_id         varchar(24) not null comment '角色ID',
   fort_mutex_role_id   varchar(24) not null comment '互斥角色ID',
   primary key (fort_role_mutex_id)
);

alter table fort_role_mutex comment '角色互斥';

/*==============================================================*/
/* Table: fort_role_privilege                                   */
/*==============================================================*/
create table fort_role_privilege
(
   fort_role_privilege_id varchar(24) not null comment '角色权限主键ID',
   fort_role_id         varchar(24) comment '角色ID',
   fort_privilege_id    varchar(24) comment '权限ID',
   primary key (fort_role_privilege_id)
);

alter table fort_role_privilege comment '权限角色关系表';

/*==============================================================*/
/* Table: fort_rule_address                                     */
/*==============================================================*/
create table fort_rule_address
(
   fort_rule_address_id varchar(24) not null comment '地址规则ID',
   fort_department_id   varchar(24) comment '部门ID',
   fort_rule_address_name varchar(32) not null comment '地址规则名称',
   fort_access_type     varchar(1) not null comment '访问类型:0 禁止访问，1 可访问',
   fort_description     varchar(256) comment '描述',
   fort_create_date     datetime comment '创建时间',
   fort_create_by       varchar(24) comment '创建人',
   fort_last_edit_date  datetime comment '最后修改时间',
   fort_last_edit_by    varchar(24) comment '最后修改人',
   primary key (fort_rule_address_id)
);

alter table fort_rule_address comment '地址规则';

/*==============================================================*/
/* Table: fort_rule_command                                     */
/*==============================================================*/
create table fort_rule_command
(
   fort_rule_command_id varchar(24) not null comment '命令规则ID',
   fort_department_id   varchar(24) comment '部门ID',
   fort_rule_command_type varchar(1) comment '命令规则类型',
   fort_rule_command_authorization_code int comment '命令规则授权代码',
   fort_rule_command_state varchar(1) comment '命令规则状态',
   fort_prior_id        varchar(24) comment '上一个规则',
   fort_next_id         varchar(24) comment '下一个规则',
   fort_level           varchar(1) comment '监控级别',
   fort_create_date     datetime comment '创建时间',
   fort_create_by       varchar(24) comment '创建人',
   fort_last_edit_date  datetime comment '最后修改时间',
   fort_last_edit_by    varchar(24) comment '最后修改人',
   primary key (fort_rule_command_id)
);

alter table fort_rule_command comment '命令规则';

/*==============================================================*/
/* Table: fort_rule_command_target_proxy                        */
/*==============================================================*/
create table fort_rule_command_target_proxy
(
   fort_rule_command_target_proxy_id varchar(24) not null comment '命令规则目标代理ID',
   fort_rule_command_id varchar(24) comment '命令规则ID',
   fort_target_id       varchar(24) not null comment '目标ID',
   fort_target_code     int comment '目标代码',
   fort_parent_id       varchar(24) comment '父节点ID',
   fort_create_date     datetime comment '创建时间',
   fort_create_by       varchar(24) comment '创建人',
   fort_last_edit_date  datetime comment '最后修改时间',
   fort_last_edit_by    varchar(24) comment '最后修改人',
   primary key (fort_rule_command_target_proxy_id)
);

alter table fort_rule_command_target_proxy comment '命令规则目标代理';

/*==============================================================*/
/* Table: fort_rule_time                                        */
/*==============================================================*/
create table fort_rule_time
(
   fort_rule_time_id    varchar(24) not null comment '时间规则ID',
   fort_department_id   varchar(24) comment '部门ID',
   fort_rule_time_name  varchar(32) not null comment '时间规则名称',
   fort_access_type     varchar(1) not null comment '访问类型:0 禁止访问，1 可访问',
   fort_start_time      datetime comment '开始时间',
   fort_end_time        datetime comment '结束时间',
   fort_weeks           varchar(32) comment '周',
   fort_days            varchar(128) comment '日',
   fort_hours           varchar(128) comment '小时',
   fort_create_date     datetime comment '创建时间',
   fort_create_by       varchar(24) comment '创建人',
   fort_last_edit_date  datetime comment '最后修改时间',
   fort_last_edit_by    varchar(24) comment '最后修改人',
   fort_description     varchar(256) comment '描述',
   primary key (fort_rule_time_id)
);

alter table fort_rule_time comment '时间规则';

/*==============================================================*/
/* Table: fort_rule_time_resource                               */
/*==============================================================*/
create table fort_rule_time_resource
(
   fort_rule_time_resource_id varchar(24) not null comment '资源时间规则ID',
   fort_rule_type       varchar(1) comment '规则类型',
   fort_rule_state      varchar(1) comment '规则状态',
   fort_prior_id        varchar(24) comment '上一个规则',
   fort_next_id         varchar(24) comment '下一个规则',
   fort_start_time      datetime comment '开始时间',
   fort_end_time        datetime comment '结束时间',
   fort_month_start_time varchar(2) comment '每月开始时间',
   fort_month_end_time  varchar(2) comment '每月结束时间',
   fort_week_start_time varchar(1) comment '每周开始时间',
   fort_week_end_time   varchar(1) comment '每周结束时间',
   fort_day_start_time  varchar(6) comment '每天开始时间',
   fort_day_end_time    varchar(6) comment '每天结束时间',
   fort_create_date     datetime comment '创建时间',
   fort_create_by       varchar(24) comment '创建人',
   fort_last_edit_date  datetime comment '最后修改时间',
   fort_last_edit_by    varchar(24) comment '最后修改人',
   primary key (fort_rule_time_resource_id)
);

alter table fort_rule_time_resource comment '资源时间规则';

/*==============================================================*/
/* Table: fort_rule_time_resource_target_proxy                  */
/*==============================================================*/
create table fort_rule_time_resource_target_proxy
(
   fort_rule_time_resource_target_proxy_id varchar(24) not null comment '资源时间规则目标代理ID',
   fort_rule_time_resource_id varchar(24) comment '资源时间规则ID',
   fort_target_id       varchar(24) comment '目标ID',
   fort_parent_id       varchar(24) comment '父节点ID',
   fort_target_code     int comment '目标代码',
   fort_create_date     datetime comment '创建时间',
   fort_create_by       varchar(24) comment '创建人',
   fort_last_edit_date  datetime comment '最后修改时间',
   fort_last_edit_by    varchar(24) comment '最后修改人',
   primary key (fort_rule_time_resource_target_proxy_id)
);

alter table fort_rule_time_resource_target_proxy comment '资源时间规则目标代理';

/*==============================================================*/
/* Table: fort_strategy_password                                */
/*==============================================================*/
create table fort_strategy_password
(
   fort_strategy_password_id varchar(24) not null comment '口令策略ID',
   fort_strategy_password_name varchar(32) not null comment '口令策略名称',
   fort_period          int comment '有效天数',
   fort_password_length_min int comment '口令最小长度',
   fort_password_length_max int comment '口令最大长度',
   fort_digital_length  int comment '至少包含数字长度',
   fort_lowercase_letter_length int comment '至少包含小写字母长度',
   fort_capital_letter_length int comment '至少包含大写字母长度',
   fort_special_characters_length int comment '至少包含特殊字符长度',
   fort_description     varchar(256) comment '描述',
   fort_create_date     datetime comment '创建时间',
   fort_create_by       varchar(24) comment '创建人',
   fort_last_edit_date  datetime comment '最后修改时间',
   fort_last_edit_by    varchar(24) comment '最后修改人',
   primary key (fort_strategy_password_id)
);

alter table fort_strategy_password comment '口令策略';

/*==============================================================*/
/* Table: fort_superior_approval_application                    */
/*==============================================================*/
create table fort_superior_approval_application
(
   fort_superior_approval_application_id varchar(24) not null comment '上级审批申请单ID',
   fort_process_id      varchar(24) comment '流程ID',
   fort_process_instance_id varchar(24) comment '流程实例ID(子实力)',
   fort_web_session     varchar(32) comment 'WEB SESSION',
   fort_apply_create_time datetime comment '申请发起时间',
   fort_account_id      varchar(24) comment '申请帐号ID',
   fort_account_name    varchar(32) comment '申请帐号名称',
   fort_resource_id     varchar(24) comment '申请资源ID',
   fort_resource_name   varchar(32) comment '申请资源名称',
   fort_resource_ip     varchar(32) comment '申请资源IP',
   fort_resource_type   varchar(32) comment '申请资源类型',
   fort_applicant_id    varchar(24) comment '申请人ID',
   fort_start_time      datetime comment '开始时间',
   fort_end_time        datetime comment '结束时间',
   fort_description     varchar(256) comment '描述',
   primary key (fort_superior_approval_application_id)
);

alter table fort_superior_approval_application comment '上级审批申请单';

/*==============================================================*/
/* Table: fort_system_alarm                                     */
/*==============================================================*/
create table fort_system_alarm
(
   fort_system_alarm_id varchar(24) not null comment '系统告警ID',
   fort_system_alarm_type_id varchar(24) not null comment '系统告警类型ID',
   fort_user_id         varchar(24) comment '用户ID',
   fort_user_name       varchar(64) comment '用户名称',
   fort_user_account    varchar(64) comment '用户帐号',
   fort_host_name       varchar(32) comment '主机名',
   fort_alarm_time      datetime comment '告警时间',
   fort_alarm_summary   varchar(128) comment '告警摘要',
   fort_alarm_details   varchar(512) comment '告警详情',
   fort_alarm_level     varchar(32) comment '告警级别',
   fort_module          varchar(32) comment '模块',
   fort_src_ip          varchar(16) comment '源IP',
   fort_target_ip       varchar(16) comment '目标IP',
   fort_check_user_id   varchar(24) comment '查看ID',
   fort_check_user_name varchar(128) comment '查看用户名称',
   fort_check_user_account varchar(64) comment '查看用户帐号',
   primary key (fort_system_alarm_id)
);

alter table fort_system_alarm comment '系统告警';

/*==============================================================*/
/* Table: fort_system_alarm_type                                */
/*==============================================================*/
create table fort_system_alarm_type
(
   fort_system_alarm_type_id varchar(24) not null comment '系统告警类型ID',
   fort_parent_id       varchar(24) comment '所属告警类型ID',
   fort_system_alarm_type_name varchar(64) comment '系统告警类型名称',
   fort_alarm_level     varchar(32) comment '告警级别',
   fort_description     varchar(256) comment '描述',
   primary key (fort_system_alarm_type_id)
);

alter table fort_system_alarm_type comment '系统告警类型';

/*==============================================================*/
/* Table: fort_system_log                                       */
/*==============================================================*/
create table fort_system_log
(
   fort_system_log_id   varchar(24) not null comment '系统日志ID',
   fort_system_log_type_id varchar(24) not null comment '系统日志类型ID',
   fort_user_id         varchar(24) comment '用户ID',
   fort_ip              varchar(32) comment '用户IP',
   fort_user_account    varchar(64) comment '用户帐号',
   fort_user_name       varchar(64) comment '用户名称',
   fort_role_name       varchar(32) comment '角色名称',
   fort_act             varchar(2000) comment '操作',
   fort_module          varchar(32) comment '模块',
   fort_result_state    varchar(32) comment '操作结果',
   fort_act_time        datetime comment '操作时间',
   fort_log_level       varchar(32) comment '日志级别',
   fort_field1          varchar(32) comment '预留字段1',
   fort_field2          varchar(32) comment '预留字段2',
   fort_field3          varchar(32) comment '预留字段3',
   primary key (fort_system_log_id)
);

alter table fort_system_log comment '系统日志';

/*==============================================================*/
/* Table: fort_system_log_type                                  */
/*==============================================================*/
create table fort_system_log_type
(
   fort_system_log_type_id varchar(24) not null comment '系统日志类型ID',
   fort_system_log_type_name varchar(32) not null comment '系统日志类型名称',
   primary key (fort_system_log_type_id)
);

alter table fort_system_log_type comment '系统日志类型';

/*==============================================================*/
/* Table: fort_task_participant                                 */
/*==============================================================*/
create table fort_task_participant
(
   fort_task_participant_id varchar(24) not null comment '任务参与者表ID',
   fort_process_task_id varchar(24) comment '流程任务ID',
   fort_user_id         varchar(24) comment '参与者ID',
   primary key (fort_task_participant_id)
);

alter table fort_task_participant comment '任务参与者';

/*==============================================================*/
/* Table: fort_three_uniform_user                               */
/*==============================================================*/
create table fort_three_uniform_user
(
   fort_three_uniform_user_id varchar(24) not null comment '三统一用户ID',
   fort_user_id         varchar(24) comment '用户ID',
   fort_user_account    varchar(1024) comment '用户帐号',
   fort_guid            varchar(36) comment '认证标识',
   fort_user_name       varchar(36) comment '人员姓名',
   fort_user_guid       varchar(36) comment '人员标识',
   fort_logon_name      varchar(36) comment '登录名称',
   fort_user_type       varchar(1) comment '用户类型（0.新发现 1.已导入 2.排除）',
   fort_create_date     datetime comment '创建时间',
   fort_last_edit_date  datetime comment '修改时间',
   primary key (fort_three_uniform_user_id)
);

alter table fort_three_uniform_user comment '三统一同步用户';

/*==============================================================*/
/* Table: fort_user                                             */
/*==============================================================*/
create table fort_user
(
   fort_user_id         varchar(24) not null comment '用户ID',
   fort_rule_address_id varchar(24) comment '地址规则ID',
   fort_rule_time_id    varchar(24) comment '时间规则ID',
   fort_department_id   varchar(24) comment '部门ID',
   fort_user_name       varchar(64) not null comment '用户名称',
   fort_user_password   varchar(32) comment '用户密码',
   fort_edit_password_time datetime comment '修改口令时间',
   fort_user_account    varchar(64) not null comment '用户帐号',
   fort_start_time      datetime comment '帐号有效期开始时间',
   fort_end_time        datetime comment '帐号有效期结束时间',
   fort_last_login_time datetime comment '最后登录时间',
   fort_user_state      varchar(1) comment '状态',
   fort_initialize_password varchar(1) comment '初始化口令',
   fort_company         varchar(64) comment '公司',
   fort_user_mobile     varchar(16) comment '手机',
   fort_user_phone      varchar(16) comment '座机',
   fort_user_email      varchar(64) comment '邮箱',
   fort_user_address    varchar(128) comment '地址',
   fort_authentication_code int comment '认证方式CODE',
   fort_domain_account  varchar(32) comment '域帐号',
   fort_macs            varchar(128) comment 'MAC地址，多个用逗号分割，最多存储4个',
   fort_certificate_id  varchar(32) comment '证书标识',
   fort_fingerprint_authentication_id varchar(32) comment '指纹认证标识',
   fort_face_recognition_id varchar(32) comment '人脸识别标识',
   fort_smart_card_id   varchar(32) comment '智能卡标识',
   fort_radius          varchar(32) comment '令牌号',
   fort_create_way      varchar(1) comment '创建方式（1:系统添加2:execl导入3:AD抽取）',
   fort_create_date     datetime comment '创建时间',
   fort_create_by       varchar(24) comment '创建人',
   fort_last_edit_date  datetime comment '最后修改时间',
   fort_last_edit_by    varchar(24) comment '最后修改人',
   fort_field1          varchar(32) comment '预留字段1',
   fort_field2          varchar(32) comment '预留字段2',
   fort_field3          varchar(32) comment '预留字段3',
   fort_field4          varchar(32) comment '预留字段4',
   fort_field5          varchar(32) comment '预留字段5',
   primary key (fort_user_id)
);

alter table fort_user comment '用户';

/*==============================================================*/
/* Table: fort_user_group                                       */
/*==============================================================*/
create table fort_user_group
(
   fort_user_group_id   varchar(24) not null comment '用户组ID',
   fort_department_id   varchar(24) comment '部门ID',
   fort_user_group_name varchar(32) not null comment '用户组名称',
   fort_order           int comment '排序',
   fort_create_date     datetime comment '创建时间',
   fort_create_by       varchar(24) comment '创建人',
   fort_last_edit_date  datetime comment '最后修改时间',
   fort_last_edit_by    varchar(24) comment '最后修改人',
   primary key (fort_user_group_id)
);

alter table fort_user_group comment '用户组';

/*==============================================================*/
/* Table: fort_user_group_user                                  */
/*==============================================================*/
create table fort_user_group_user
(
   fort_user_group_user_id varchar(24) not null comment '用户组用户关系表主键ID',
   fort_user_group_id   varchar(24) comment '用户组ID',
   fort_user_id         varchar(24) comment '用户ID',
   primary key (fort_user_group_user_id)
);

alter table fort_user_group_user comment '用户组-用户关系表';

/*==============================================================*/
/* Table: fort_user_protocol_client                             */
/*==============================================================*/
create table fort_user_protocol_client
(
   fort_user_protocol_client_id varchar(24) not null comment '用户访问协议客户端ID',
   fort_user_id         varchar(24) not null comment '用户ID',
   fort_client_tool_id  varchar(24) not null comment '客户端工具ID',
   primary key (fort_user_protocol_client_id)
);

alter table fort_user_protocol_client comment '用户访问协议客户端';

/*==============================================================*/
/* Table: fort_user_role                                        */
/*==============================================================*/
create table fort_user_role
(
   fort_user_role_id    varchar(24) not null comment '用户角色关系表ID',
   fort_user_id         varchar(24) comment '用户ID',
   fort_role_id         varchar(24) comment '角色ID',
   primary key (fort_user_role_id)
);

alter table fort_user_role comment '用户角色关系表';

alter table fort_account add constraint FK_ACCOUNT_REL_RESOURCE foreign key (fort_resource_id)
      references fort_resource (fort_resource_id) on delete cascade;

alter table fort_application_release_server_account add constraint FK_FK_ACCOUNT_REL_APPLICATION foreign key (fort_application_release_server_id)
      references fort_application_release_server (fort_application_release_server_id) on delete restrict on update restrict;

alter table fort_audit_command_log add constraint FK_COMMAND_REL_AUDIT foreign key (fort_audit_id)
      references fort_audit_log (fort_audit_id) on delete cascade;

alter table fort_audit_title_log add constraint FK_TITLE_REL_AUDIT foreign key (fort_audit_id)
      references fort_audit_log (fort_audit_id) on delete restrict on update restrict;

alter table fort_authorization add constraint FK_AUTHORIZATION_REL_DEPT foreign key (fort_department_id)
      references fort_department (fort_department_id) on delete restrict on update restrict;

alter table fort_authorization_target_proxy add constraint FK_TARTGET_PROXY_REL_AUTHORIZATION foreign key (fort_authorization_id)
      references fort_authorization (fort_authorization_id) on delete cascade on update restrict;

alter table fort_behavior_guideline add constraint FK_BEHAVIOR_GUIDELINE_REL_TYPE foreign key (fort_behavior_guideline_type_id)
      references fort_behavior_guideline_type (fort_behavior_guideline_type_id) on delete restrict on update restrict;

alter table fort_behavior_guideline_set_element add constraint FK_ELEMENT_REL_BEHAVIOR_GUIDELINE_SET foreign key (fort_behavior_guideline_set_id)
      references fort_behavior_guideline_set (fort_behavior_guideline_set_id) on delete restrict on update restrict;

alter table fort_behavior_guideline_set_guideline add constraint FK_GUIDELINE_REL_BEHAVIOR_GUIDELINE_SET foreign key (fort_behavior_guideline_set_id)
      references fort_behavior_guideline_set (fort_behavior_guideline_set_id) on delete restrict on update restrict;

alter table fort_behavior_guideline_type add constraint FK_PARENT_BEHAVIOR_GUIDELINE_TYPE foreign key (fort_parent_id)
      references fort_behavior_guideline_type (fort_behavior_guideline_type_id) on delete restrict on update restrict;

alter table fort_command add constraint FK_COMMAND_REL_RULE_COMMAND foreign key (fort_rule_command_id)
      references fort_rule_command (fort_rule_command_id) on delete cascade;

alter table fort_command_element add constraint FK_ELEMENT_REL_BEHAVIOR_GUIDELINE foreign key (fort_behavior_guideline_id)
      references fort_behavior_guideline (fort_behavior_guideline_id) on delete cascade;

alter table fort_department add constraint FK_PARENT_DEPARTMENT foreign key (fort_parent_id)
      references fort_department (fort_department_id) on delete restrict on update restrict;

alter table fort_double_approval add constraint FK_DOUBLE_APPROVAL_REL_AUTHORIZATION foreign key (fort_authorization_id)
      references fort_authorization (fort_authorization_id) on delete cascade;

alter table fort_forbidden_character add constraint FK_FORBIDDEN_REL_PASSWORD foreign key (fort_strategy_password_id)
      references fort_strategy_password (fort_strategy_password_id) on delete cascade;

alter table fort_guideline_command add constraint FK_GUIDELINE_COMMAND_REL_TYPE foreign key (fort_guideline_command_type_id)
      references fort_guideline_command_type (fort_guideline_command_type_id) on delete restrict on update restrict;

alter table fort_guideline_command_option add constraint FK_OPTION_REL_GUIDELINE foreign key (fort_guideline_command_id)
      references fort_guideline_command (fort_guideline_command_id) on delete cascade;

alter table fort_guideline_command_type add constraint FK_PARENT_GUIDELINE_COMMAND_TYPE foreign key (fort_parent_id)
      references fort_guideline_command_type (fort_guideline_command_type_id) on delete restrict on update restrict;

alter table fort_ip_mask add constraint FK_IP_MASK_REL_RULE_ADDRESS foreign key (fort_rule_address_id)
      references fort_rule_address (fort_rule_address_id) on delete cascade;

alter table fort_ip_range add constraint FK_IP_RANGE_REL_RULE_ADDRESS foreign key (fort_rule_address_id)
      references fort_rule_address (fort_rule_address_id) on delete restrict on update restrict;

alter table fort_ldap_user add constraint FK_USER_REL_LDAP foreign key (fort_user_id)
      references fort_user (fort_user_id) on delete restrict on update restrict;

alter table fort_message add constraint FK_MESSAGE_REL_MESSAGE_TYPE foreign key (fort_message_type_id)
      references fort_message_type (fort_message_type_id) on delete restrict on update restrict;

alter table fort_plan_password add constraint FK_PLAN_PWD_REL_DEPT foreign key (fort_department_id)
      references fort_department (fort_department_id) on delete restrict on update restrict;

alter table fort_plan_password_backup add constraint FK_PLAN_PWD_BACKUP_REL_DEPT foreign key (fort_department_id)
      references fort_department (fort_department_id) on delete restrict on update restrict;

alter table fort_privilege add constraint FK_PARENT_PRIVILEGE foreign key (fort_parent_id)
      references fort_privilege (fort_privilege_id) on delete set null;

alter table fort_process_instance add constraint FK_PROCESSI_REL_PROCESS foreign key (fort_process_id)
      references fort_process (fort_process_id) on delete restrict on update restrict;

alter table fort_process_task add constraint FK_PARENT_TASK foreign key (fort_parent_id)
      references fort_process_task (fort_process_task_id) on delete restrict on update restrict;

alter table fort_process_task add constraint FK_TASK_REL_PROCESS foreign key (fort_process_id)
      references fort_process (fort_process_id) on delete restrict on update restrict;

alter table fort_process_task_instance add constraint FK_PARENT_TASKI foreign key (fort_parent_id)
      references fort_process_task_instance (fort_process_task_instance_id) on delete restrict on update restrict;

alter table fort_process_task_instance add constraint FK_TASKI_REL_PARTICIPANT foreign key (fort_task_participant_id)
      references fort_task_participant (fort_task_participant_id) on delete restrict on update restrict;

alter table fort_process_task_instance add constraint FK_TASKI_REL_PROCESSI foreign key (fort_process_instance_id)
      references fort_process_instance (fort_process_instance_id) on delete restrict on update restrict;

alter table fort_process_task_instance add constraint FK_TASKI_REL_TASK foreign key (fort_process_task_id)
      references fort_process_task (fort_process_task_id) on delete restrict on update restrict;

alter table fort_protocol_client add constraint FK_CLIENT_REL_PORTTOCOL foreign key (fort_operations_protocol_id)
      references fort_operations_protocol (fort_operations_protocol_id) on delete restrict on update restrict;

alter table fort_protocol_client add constraint FK_PORTTOCOL_REL_CLIENT foreign key (fort_client_tool_id)
      references fort_client_tool (fort_client_tool_id) on delete restrict on update restrict;

alter table fort_resource add constraint FK_PARENT_RESOURCE foreign key (fort_parent_id)
      references fort_resource (fort_resource_id) on delete restrict on update restrict;

alter table fort_resource add constraint FK_RESOURCE_REL_DEPT foreign key (fort_department_id)
      references fort_department (fort_department_id) on delete set null on update restrict;

alter table fort_resource add constraint FK_RESOURCE_REL_RESOURCE_TYPE foreign key (fort_resource_type_id)
      references fort_resource_type (fort_resource_type_id) on delete restrict on update restrict;

alter table fort_resource add constraint FK_RESOURCE_REL_RULE_TIME foreign key (fort_rule_time_id)
      references fort_rule_time (fort_rule_time_id) on delete set null;

alter table fort_resource add constraint FK_RESOURCE_REL_STRATEGY_PASSWORD foreign key (fort_strategy_password_id)
      references fort_strategy_password (fort_strategy_password_id) on delete set null;

alter table fort_resource_application add constraint FK_APPLICATION_REL_RESOURCE foreign key (fort_resource_id)
      references fort_resource (fort_resource_id) on delete restrict on update restrict;

alter table fort_resource_application add constraint FK_RESOURCE_REL_APPLICATION foreign key (fort_application_release_server_id)
      references fort_application_release_server (fort_application_release_server_id) on delete cascade;

alter table fort_resource_group add constraint FK_RESOURCE_GROUP_REL_DEPARTMENT foreign key (fort_department_id)
      references fort_department (fort_department_id) on delete restrict on update restrict;

alter table fort_resource_group_resource add constraint FK_RESOURCE_GROUP_RESOURCE_REL_RESOURCE foreign key (fort_resource_id)
      references fort_resource (fort_resource_id) on delete restrict on update restrict;

alter table fort_resource_group_resource add constraint FK_RESOURCE_GROUP_RESOURCE_REL_RESOURCE_GROUP foreign key (fort_resource_group_id)
      references fort_resource_group (fort_resource_group_id) on delete cascade;

alter table fort_resource_operations_protocol add constraint FK_POERATIONS_PROTOCOL_REL_RESOURCE foreign key (fort_resource_id)
      references fort_resource (fort_resource_id) on delete restrict on update restrict;

alter table fort_resource_operations_protocol add constraint FK_RESOURCE_REL_POERATIONS_PROTOCOL foreign key (fort_operations_protocol_id)
      references fort_operations_protocol (fort_operations_protocol_id) on delete restrict on update restrict;

alter table fort_resource_type add constraint FK_PARENT_RESOURCETYPE foreign key (fort_parent_id)
      references fort_resource_type (fort_resource_type_id) on delete restrict on update restrict;

alter table fort_resource_type_operations_protocol add constraint FK_POERATIONS_PROTOCOL_REL_RESOURCE_TYPE foreign key (fort_resource_type_id)
      references fort_resource_type (fort_resource_type_id) on delete restrict on update restrict;

alter table fort_resource_type_operations_protocol add constraint FK_RESOURCE_TYPE_REL_POERATIONS_PROTOCOL foreign key (fort_operations_protocol_id)
      references fort_operations_protocol (fort_operations_protocol_id) on delete restrict on update restrict;

alter table fort_resource_type_operations_protocol add constraint FK_REST_OPEP_REL_BGT foreign key (fort_behavior_guideline_type_id)
      references fort_behavior_guideline_type (fort_behavior_guideline_type_id) on delete restrict on update restrict;

alter table fort_role_privilege add constraint FK_PRIVILEGE_REL_ROLE foreign key (fort_role_id)
      references fort_role (fort_role_id) on delete cascade;

alter table fort_role_privilege add constraint FK_ROLE_REL_PRIVILEGE foreign key (fort_privilege_id)
      references fort_privilege (fort_privilege_id) on delete restrict on update restrict;

alter table fort_rule_address add constraint FK_RULE_ADDRESS_REL_DEPT foreign key (fort_department_id)
      references fort_department (fort_department_id) on delete restrict on update restrict;

alter table fort_rule_command add constraint FK_RULE_COMMAND_REL_DEPT foreign key (fort_department_id)
      references fort_department (fort_department_id) on delete restrict on update restrict;

alter table fort_rule_command_target_proxy add constraint FK_TARGET_PROXY_REL_RULE_COMMAND foreign key (fort_rule_command_id)
      references fort_rule_command (fort_rule_command_id) on delete cascade;

alter table fort_rule_time add constraint FK_RULE_TIME_REL_DEPT foreign key (fort_department_id)
      references fort_department (fort_department_id) on delete restrict on update restrict;

alter table fort_rule_time_resource_target_proxy add constraint FK_TARGET_PROXY_REL_RULE_TIME_RESOURCE foreign key (fort_rule_time_resource_id)
      references fort_rule_time_resource (fort_rule_time_resource_id) on delete cascade;

alter table fort_system_alarm add constraint FK_SYSTEM_ALARM_REL_SYSTEM_ALARM_TYPE foreign key (fort_system_alarm_type_id)
      references fort_system_alarm_type (fort_system_alarm_type_id) on delete restrict on update restrict;

alter table fort_system_alarm_type add constraint FK_PARENT_ALARM_TYPE foreign key (fort_parent_id)
      references fort_system_alarm_type (fort_system_alarm_type_id) on delete restrict on update restrict;

alter table fort_system_log add constraint FK_SYSTEM_LOG_REL_SYSTEM_LOG_TYPE foreign key (fort_system_log_type_id)
      references fort_system_log_type (fort_system_log_type_id) on delete restrict on update restrict;

alter table fort_task_participant add constraint FK_PARTICIPANT_REL_TASK foreign key (fort_process_task_id)
      references fort_process_task (fort_process_task_id) on delete restrict on update restrict;

alter table fort_user add constraint FK_USER_REL_DEPT foreign key (fort_department_id)
      references fort_department (fort_department_id) on delete set null on update restrict;

alter table fort_user add constraint FK_USER_REL_RULE_ADDRESS foreign key (fort_rule_address_id)
      references fort_rule_address (fort_rule_address_id) on delete set null;

alter table fort_user add constraint FK_USER_REL_RULE_TIME foreign key (fort_rule_time_id)
      references fort_rule_time (fort_rule_time_id) on delete set null;

alter table fort_user_group add constraint FK_USER_GROUP_REL_DEPARTMENT foreign key (fort_department_id)
      references fort_department (fort_department_id) on delete restrict on update restrict;

alter table fort_user_group_user add constraint FK_USER_GROUP_USER_REL_USER foreign key (fort_user_id)
      references fort_user (fort_user_id) on delete restrict on update restrict;

alter table fort_user_group_user add constraint FK_USER_GROUP_USER_REL_USER_GROUP foreign key (fort_user_group_id)
      references fort_user_group (fort_user_group_id) on delete cascade;

alter table fort_user_protocol_client add constraint FK_PROTOCOL_CLIENT_REL_USER foreign key (fort_user_id)
      references fort_user (fort_user_id) on delete restrict on update restrict;

alter table fort_user_protocol_client add constraint FK_USER_REL_PROTOCOL_CLIENT foreign key (fort_client_tool_id)
      references fort_client_tool (fort_client_tool_id) on delete restrict on update restrict;

alter table fort_user_role add constraint FK_ROLE_REL_USER foreign key (fort_user_id)
      references fort_user (fort_user_id) on delete restrict on update restrict;

alter table fort_user_role add constraint FK_USER_REL_ROLE foreign key (fort_role_id)
      references fort_role (fort_role_id) on delete cascade;


-- ----------------------------
-- Records of fort_privilege
-- ----------------------------

INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1001000000000', '运维操作', null, 'm_operation', '1', '1', null, null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1001010000000', 'SSO', null, 'm_sso', '1', '1', '1001000000000', 'middle?url=operation/sso/sso-left');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1001010000001', 'SSO:命令详情', null, 'm_sso:commandDetail', '3', '1', '1001010000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1001010000002', 'SSO:回放', null, 'm_sso:playback', '3', '1', '1001010000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1001010000003', 'SSO:下载', null, 'm_sso:download', '3', '1', '1001010000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1001010000004', 'SSO:审批记录', null, 'm_sso:examRecord', '3', '1', '1001010000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1001010000005', 'SSO:查看历史', null, 'm_sso:history', '3', '1', '1001010000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1001010000006', 'SSO:键盘记录', null, 'm_sso:keyboardRecord', '3', '1', '1001010000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1001010000007', 'SSO:文件传输', null, 'm_sso:fileTransmission', '3', '1', '1001010000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1001010000008', 'SSO:行为指引', null, 'm_sso:behaviorGuide', '3', '1', '1001010000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1001010000009', 'SSO:补充运维备注信息', null, 'm_sso:supOpeRemInfo', '3', '1', '1001010000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1001010000010', 'SSO:监控', null, 'm_sso:monitor', '3', '1', '1001010000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1001010000011', 'SSO:窗体识别', null, 'm_sso:formRecognition', '3', '1', '1001010000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1001010000012', 'SSO:剪切板', null, 'm_sso:cutBoad', '3', '1', '1001010000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1001010000013', 'SSO:阻断', null, 'm_sso:interdict', '3', '1', '1001010000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002000000000', '运维管理', null, 'm_operation_management', '1', '3', null, null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002010000000', '组织定义', null, 'm_organization', '1', '3', '1002000000000', 'middle?url=operationsManagement/organization/group-left');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002010100000', '部门', null, 'm_department', '', '1', '1002010000000', 'operationsManagement/organization/department/department-group');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002010100001', '部门:添加', null, 'm_department:add', '3', '1', '1002010100000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002010100002', '部门:编辑', null, 'm_department:edit', '3', '1', '1002010100000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002010100003', '部门:删除', null, 'm_department:delete', '3', '1', '1002010100000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002010200000', '资源组', null, 'm_resource_group', '', '2', '1002010000000', 'operationsManagement/organization/resourceGroup/resource-group');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002010200001', '资源组:添加资源组', null, 'm_resource_group:addResGroup', '3', '2', '1002010200000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002010200002', '资源组:编辑资源组', null, 'm_resource_group:editResGroup', '3', '2', '1002010200000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002010200003', '资源组:删除资源组', null, 'm_resource_group:deleteResGroup', '3', '2', '1002010200000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002010200004', '资源组:添加资源', null, 'm_resource_group:addResource', '3', '2', '1002010200000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002010200005', '资源组:删除资源', null, 'm_resource_group:deleteResource', '3', '2', '1002010200000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002010300000', '用户组', null, 'm_user_group', '', '2', '1002010000000', 'operationsManagement/organization/userGroup/user-group');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002010300001', '用户组:添加用户组', null, 'm_user_group:addUserGroup', '3', '2', '1002010300000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002010300002', '用户组:编辑用户组', null, 'm_user_group:editUserGroup', '3', '2', '1002010300000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002010300003', '用户组:删除用户组', null, 'm_user_group:deleteUserGroup', '3', '2', '1002010300000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002010300004', '用户组:添加用户', null, 'm_user_group:addTheUser', '3', '2', '1002010300000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002010300005', '用户组:删除用户', null, 'm_user_group:deleteTheUser', '3', '2', '1002010300000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002020000000', '用户', null, 'm_user', '1', '3', '1002000000000', 'operationsManagement/user/user-list');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002020000001', '用户:添加', null, 'm_user:add', '3', '3', '1002020000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002020000002', '用户:删除', null, 'm_user:delete', '3', '3', '1002020000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002020000003', '用户:编辑', null, 'm_user:edit', '3', '3', '1002020000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002020000004', '用户:导入', null, 'm_user:import', '3', '3', '1002020000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002020000005', '用户:导出', null, 'm_user:export', '3', '3', '1002020000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002020000006', '用户:导入模板下载', null, 'm_user:impTempDownload', '3', '3', '1002020000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002020000007', '用户:打印密码信封', null, 'm_user:printPwdEnvelope', '3', '3', '1002020000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002020000008', '用户:角色', null, 'm_user:role', '3', '3', '1002020000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002020000009', '用户:用户状态', null, 'm_user:userState', '3', '3', '1002020000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002020000010', '用户:证书', null, 'm_user:certificate', '3', '3', '1002020000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002030000000', '资源', null, 'm_resource', '1', '2', '1002000000000', 'operationsManagement/resource/resource-list');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002030000001', '资源:添加', null, 'm_resource:add', '3', '2', '1002030000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002030000002', '资源:删除', null, 'm_resource:delete', '3', '2', '1002030000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002030000003', '资源:编辑', null, 'm_resource:edit', '3', '2', '1002030000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002030000004', '资源:资源自动发现', null, 'm_resource:resAutomaticFind', '3', '2', '1002030000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002030000005', '资源:导入', null, 'm_resource:import', '3', '2', '1002030000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002030000006', '资源:导出', null, 'm_resource:export', '3', '2', '1002030000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002030000007', '资源:导入模板下载', null, 'm_resource:impTempDownload', '3', '2', '1002030000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002030000008', '资源:打印密码信封', null, 'm_resource:printPwdEnvelope', '3', '2', '1002030000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002030000009', '资源:帐号添加', null, 'm_resource:accountAdd', '3', '2', '1002030000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002030000010', '资源:帐号删除', null, 'm_resource:accountDelete', '3', '2', '1002030000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002030000011', '资源:帐号编辑', null, 'm_resource:accountEdit', '3', '2', '1002030000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002030000012', '资源:发现帐号', null, 'm_resource:findAccount', '3', '2', '1002030000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002030000013', '资源:帐号打印密码信封', null, 'm_resource:accPrintPwdEnve', '3', '2', '1002030000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002030000014', '资源:帐号是否可授权', null, 'm_resource:accWhetherAuth', '3', '2', '1002030000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002040000000', '授权', null, 'm_authorization', '1', '2', '1002000000000', 'operationsManagement/authorization/authorization-list');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002040000001', '授权:授权报表', null, 'm_authorization:authReportForms', '3', '2', '1002040000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002040000002', '授权:导出', null, 'm_authorization:export', '3', '2', '1002040000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002040000003', '授权:导入', null, 'm_authorization:import', '3', '2', '1002040000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002040000004', '授权:添加', null, 'm_authorization:add', '3', '2', '1002040000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002040000005', '授权:删除', null, 'm_authorization:delete', '3', '2', '1002040000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002040000006', '授权:编辑', null, 'm_authorization:edit', '3', '2', '1002040000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002040000007', '授权:保存访问审批', null, 'm_authorization:saveVisitExam', '3', '2', '1002040000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002040000008', '授权:编辑双人授权', null, 'm_authorization:doubleAuth', '3', '2', '1002040000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002040000009', '授权:可访问外部授权报表', null, 'm_authorization:canVisitOutAuthForm', '3', '2', '1002040000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002040100000', '访问', null, 'm_department', ' ', null, '1002040000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002040200000', '命令', null, 'm_command', ' ', null, '1002040000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002050000000', '规则定义', null, 'm_rule', '1', '2', '1002000000000', 'middle?url=views/operationsManagement/rule/rule-left');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002050100000', '命令规则', null, 'm_command_rule', '1', '2', '1002050000000', 'operationsManagement/rule/command/rule-command-list');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002050100001', '命令规则:添加', null, 'm_command_rule:add', '3', '2', '1002050100000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002050100002', '命令规则:删除', null, 'm_command_rule:delete', '3', '2', '1002050100000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002050100003', '命令规则:编辑', null, 'm_command_rule:edit', '3', '2', '1002050100000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002050100004', '命令规则:排序', null, 'm_command_rule:sort', '3', '2', '1002050100000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002050100005', '命令规则:状态', null, 'm_command_rule:state', '3', '2', '1002050100000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002050100006', '命令规则:部署', null, 'm_command_rule:deploy', '3', '2', '1002050100000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002050200000', '时间规则', null, 'm_time_rule', '1', '2', '1002050000000', 'operationsManagement/rule/time/rule-time-list');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002050200001', '时间规则:添加', null, 'm_time_rule:add', '3', '2', '1002050200000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002050200002', '时间规则:删除', null, 'm_time_rule:delete', '3', '2', '1002050200000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002050200003', '时间规则:编辑', null, 'm_time_rule:edit', '3', '2', '1002050200000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002050300000', '地址规则', null, 'm_address_rule', '1', '2', '1002050000000', 'operationsManagement/rule/address/rule-address-list');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002050300001', '地址规则:添加', null, 'm_address_rule:add', '3', '2', '1002050300000', 'operationsManagement/rule/address/rule-address-list');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002050300002', '地址规则:删除', null, 'm_address_rule:delete', '3', '2', '1002050300000', 'operationsManagement/rule/address/rule-address-list');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002050300003', '地址规则:编辑', null, 'm_address_rule:edit', '3', '2', '1002050300000', 'operationsManagement/rule/address/rule-address-list');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002050400000', '资源时间规则', null, 'm_time_resource_rule', '1', '2', '1002050000000', 'operationsManagement/rule/time/rule-time-resource-list');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002050400001', '资源时间规则:添加', null, 'm_time_resource_rule:add', '3', '2', '1002050400000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002050400002', '资源时间规则:删除', null, 'm_time_resource_rule:delete', '3', '2', '1002050400000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002050400003', '资源时间规则:编辑', null, 'm_time_resource_rule:edit', '3', '2', '1002050400000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002050400004', '资源时间规则:排序', null, 'm_time_resource_rule:sort', '3', '2', '1002050400000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002050400005', '资源时间规则:默认动作', null, 'm_time_resource_rule:defaultAction', '3', '2', '1002050400000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002060000000', '审计指引', null, 'm_behavior', '1', '2', '1002000000000', 'middle?url=operationsManagement/behaviorguideline/behavior-guideline-left');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002060100000', '行为指引类型', null, 'm_behavior_guideline_type', '1', '2', '1002060000000', 'operationsManagement/behaviorguideline/behavior-guideline-type');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002060100001', '行为指引类型:添加', null, 'm_behavior_guideline_type:add', '3', '2', '1002060100000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002060100002', '行为指引类型:删除', null, 'm_behavior_guideline_type:delete', '3', '2', '1002060100000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002060100003', '行为指引类型:编辑', null, 'm_behavior_guideline_type:edit', '3', '2', '1002060100000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002060200000', '命令库定义', null, 'm_behavior_guideline_command', '1', '2', '1002060000000', 'operationsManagement/behaviorguideline/behavior-guideline-command');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002060200001', '命令库定义:导入命令库', null, 'm_behavior_guideline_command:importCommLib', '3', '2', '1002060200000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002060200002', '命令库定义:导出命令库', null, 'm_behavior_guideline_command:exportCommLib', '3', '2', '1002060200000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002060200003', '命令库定义:添加', null, 'm_behavior_guideline_command:add', '3', '2', '1002060200000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002060200004', '命令库定义:删除', null, 'm_behavior_guideline_command:delete', '3', '2', '1002060200000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002060200005', '命令库定义:编辑', null, 'm_behavior_guideline_command:edit', '3', '2', '1002060200000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002060200006', '命令库定义:添加命令选项', null, 'm_behavior_guideline_command:commOptionAdd', '3', '2', '1002060200000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002060200007', '命令库定义:删除命令选项', null, 'm_behavior_guideline_command:commOptionDelete', '3', '2', '1002060200000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002060200008', '命令库定义:编辑命令选项', null, 'm_behavior_guideline_command:commOptionEdit', '3', '2', '1002060200000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002060300000', '行为指引', null, 'm_behavior_guideline', ' ', '2', '1002060000000', 'operationsManagement/behaviorguideline/behavior-guideline');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002060300001', '行为指引:添加', null, 'm_behavior_guideline:add', '3', '2', '1002060300000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002060300002', '行为指引:删除', null, 'm_behavior_guideline:delete', '3', '2', '1002060300000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002060300003', '行为指引:编辑', null, 'm_behavior_guideline:edit', '3', '2', '1002060300000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1002060300004', '行为指引:停用或启用', null, 'm_behavior_guideline:stopOrStart', '3', '2', '1002060300000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1003000000000', '审计管理', null, 'm_audit', '1', '3', null, null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1003010000000', '运维审计', null, 'm_audit', '1', '3', '1003000000000', 'audit/operational/operational-audit-list?SsoAudit=m_audit');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1003010000001', '运维审计:审计删除', null, 'm_audit:auditDelete', '3', '1', '1003010000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1003010000002', '运维审计:命令详情', '', 'm_audit:commandDetail', '3', '3', '1003010000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1003010000003', '运维审计:回放', '', 'm_audit:playback', '3', '3', '1003010000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1003010000004', '运维审计:下载', '', 'm_audit:download', '3', '3', '1003010000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1003010000005', '运维审计:审批记录', '', 'm_audit:examRecord', '3', '3', '1003010000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1003010000006', '运维审计:查看历史', '', 'm_audit:history', '3', '3', '1003010000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1003010000007', '运维审计:键盘记录', '', 'm_audit:keyboardRecord', '3', '3', '1003010000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1003010000008', '运维审计:文件传输', '', 'm_audit:fileTransmission', '3', '3', '1003010000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1003010000009', '运维审计:行为指引', '', 'm_audit:behaviorGuide', '3', '3', '1003010000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1003010000010', '运维审计:补充运维备注信息', '', 'm_audit:supOpeRemInfo', '3', '3', '1003010000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1003010000011', '运维审计:监控', '', 'm_audit:monitor', '3', '3', '1003010000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1003010000012', '运维审计:窗体识别', null, 'm_audit:formRecognition', '3', '3', '1003010000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1003010000013', '运维审计:剪切板', '', 'm_audit:cutBoad', '3', '3', '1003010000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1003010000014', '运维审计:阻断', '', 'm_audit:interdict', '3', '3', '1003010000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1003010000015', '运维审计:指引提取', '', 'm_audit:extract', '3', '3', '1003010000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1003010100000', '审计列表', null, 'm_audit_list', ' ', null, '1003010000000', 'audit/operational/operational-audit-list');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1003010200000', '审计删除', null, 'm_audit_delete', ' ', null, '1003010000000', 'audit/operational/operational-audit-delete-list');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1003020000000', '配置审计', null, 'm_systemlog', '1', '3', '1003000000000', 'audit/configuration/configuration-audit-list');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1003030000000', '告警归纳', null, 'm_alarm', '1', '3', '1003000000000', 'alarm/alarm-induction-list');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1003030000001', '告警归纳:查看详情', null, 'm_alarm:detail', '3', '3', '1003030000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1003030100000', '列表', null, 'm_list', ' ', null, '1003030000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1004000000000', '流程控制', null, 'm_process', '1', '3', null, null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1004010000000', '流程任务', null, 'm_process_approval', '1', '3', '1004000000000', 'process/task-log-list');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1004010000001', '流程任务:查看详情', null, 'm_process_approval:detail', '3', '3', '1004010000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1004010000002', '流程任务:审计记录', null, 'm_process_approval:auditRecord', '3', '3', '1004010000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1004030000000', '申请历史', null, 'm_personal_process', '1', '3', '1004000000000', 'process/personal-process-list');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1004030000001', '申请历史:查看详情', null, 'm_personal_process:detail', '3', '3', '1004030000000', '');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1004030000002', '申请历史:审计记录', null, 'm_personal_process:auditRecord', '3', '3', '1004030000000', '');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1004040000000', '个人历史', null, 'm_personal_history', '1', '3', '1004000000000', 'process/approval-history-list?processType=personal_approval');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1004040000001', '个人历史:查看详情', null, 'm_personal_history:detail', '3', '3', '1004040000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1004040000002', '个人历史:审计记录', null, 'm_personal_history:auditRecord', '3', '3', '1004040000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1004050000000', '部门历史', null, 'm_department_history', '1', '2', '1004000000000', 'process/approval-history-list?processType=department_approval');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1004050000001', '部门历史:查看详情', null, 'm_department_history:detail', '3', '2', '1004050000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1004050000002', '部门历史:审计记录', null, 'm_department_history:auditRecord', '3', '2', '1004050000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1004060000000', '全部历史', null, 'm_all_history', '1', '1', '1004000000000', 'process/approval-history-list?processType=all_approval');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1004060000001', '全部历史:查看详情', null, 'm_all_history:detail', '3', '1', '1004060000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1004060000002', '全部历史:审计记录', null, 'm_all_history:auditRecord', '3', '1', '1004060000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1005000000000', '计划任务', null, 'm_plan', '1', '2', null, null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1005010000000', '口令计划', null, 'm_plan_password', '1', '2', '1005000000000', 'middle?url=planTask/planTask-left');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1005010100000', '口令修改计划', null, 'm_password_modify_plan', ' ', '2', '1005010000000', 'planTask/planPasswordChange/plan_password_change_list');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1005010100001', '口令修改计划:添加', null, 'm_password_modify_plan:add', '3', '2', '1005010100000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1005010100002', '口令修改计划:删除', null, 'm_password_modify_plan:delete', '3', '2', '1005010100000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1005010100003', '口令修改计划:编辑', null, 'm_password_modify_plan:edit', '3', '2', '1005010100000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1005010100004', '口令修改计划:备份文件查看', null, 'm_password_modify_plan:backupFileView', '3', '2', '1005010100000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1005010100005', '口令修改计划:备份文件删除', null, 'm_password_modify_plan:backupFileDelete', '3', '2', '1005010100000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1005010100006', '口令修改计划:备份文件下载', null, 'm_password_modify_plan:backupFileDown', '3', '2', '1005010100000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1005010100007', '口令修改计划:立即修改', null, 'm_password_modify_plan:immediateUpdate', '3', '2', '1005010100000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1005010100008', '口令修改计划:帐号列表', null, 'm_password_modify_plan:accountList', '3', '2', '1005010100000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1005010100009', '口令修改计划:日志', null, 'm_password_modify_plan:log', '3', '2', '1005010100000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1005010100010', '口令修改计划:状态', null, 'm_password_modify_plan:state', '3', '2', '1005010100000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1005010200000', '口令备份计划', null, 'm_password_backup_plan', ' ', '2', '1005010000000', 'planTask/planPasswordBackup/plan_password_backup_list');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1005010200001', '口令备份计划:添加', null, 'm_password_backup_plan:add', '3', '2', '1005010200000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1005010200002', '口令备份计划:删除', null, 'm_password_backup_plan:delete', '3', '2', '1005010200000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1005010200003', '口令备份计划:编辑', null, 'm_password_backup_plan:edit', '3', '2', '1005010200000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1005010200004', '口令备份计划:备份文件查看', null, 'm_password_backup_plan:backupFileView', '3', '2', '1005010200000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1005010200005', '口令备份计划:备份文件删除', null, 'm_password_backup_plan:backupFileDelete', '3', '2', '1005010200000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1005010200006', '口令备份计划:备份文件下载', null, 'm_password_backup_plan:backupFileDown', '3', '2', '1005010200000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1005010200007', '口令备份计划:立即备份', null, 'm_password_backup_plan:immediateBackup', '3', '2', '1005010200000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1005010200008', '口令备份计划:帐号列表', null, 'm_password_backup_plan:accountList', '3', '2', '1005010200000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1005010200009', '口令备份计划:状态', null, 'm_password_backup_plan:state', '3', '2', '1005010200000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1005010300000', '口令备份FTP', null, 'm_password_backup_ftp', ' ', '2', '1005010000000', 'planTask/planPasswordBackup/plan_password_backup_ftp');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1005010300001', '口令备份FTP:保存', null, 'm_password_backup_ftp:save', '3', '2', '1005010300000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1006000000000', '报表管理', null, 'm_report', '1', '3', null, null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1006010000000', '审计报表', null, 'm_audit_report', '1', '3', '1006000000000', 'middle?url=report/audit-report-left');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1006010100000', '配置审计报表', null, 'm_config_audit_report', ' ', '3', '1006010000000', 'report/internal-audit/internal-audit-report-configuration');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1006010100001', '配置审计报表:添加模板', null, 'm_config_audit_report:addTemplet', '3', '3', '1006010100000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1006010100002', '配置审计报表:删除模板', null, 'm_config_audit_report:deleteTemplet', '3', '3', '1006010100000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1006010100003', '配置审计报表:查询报表', null, 'm_config_audit_report:queryReportForms', '3', '3', '1006010100000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1006010200000', '运维审计报表', null, 'm_maintain_audit_report', ' ', '3', '1006010000000', 'report/behavior-audit/behavior-audit-report-configuration');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1006010200001', '运维审计报表:添加模板', null, 'm_maintain_audit_report:addTemplet', '3', '3', '1006010200000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1006010200002', '运维审计报表:删除模板', null, 'm_maintain_audit_report:deleteTemplet', '3', '3', '1006010200000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1006010200003', '运维审计报表:查询报表', null, 'm_maintain_audit_report:queryReportForms', '3', '3', '1006010200000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1007000000000', '角色管理', null, 'm_role', '1', '1', null, null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1007010000000', '角色定义', null, 'm_role_definition', '1', '1', '1007000000000', 'role/role-list');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1007010000001', '角色定义:添加', null, 'm_role_definition:add', '3', '1', '1007010000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1007010000002', '角色定义:编辑', null, 'm_role_definition:edit', '3', '1', '1007010000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1007010000003', '角色定义:删除', null, 'm_role_definition:delete', '3', '1', '1007010000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1007020000000', '角色互斥定义', null, 'm_role_mutex_definition', '1', '1', '1007000000000', 'role/role-mutex');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1007020000001', '角色互斥定义:保存', null, 'm_role_mutex_definition:save', '3', '1', '1007020000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008000000000', '系统配置', null, 'm_system', '1', '1', null, null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008020000000', '关联服务', null, 'm_associated_services', '1', '1', '1008000000000', 'middle?url=system/related-services/related-services-left');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008020100000', 'NTP', null, 'm_ntp', ' ', '1', '1008020000000', 'system/related-services/ntp/ntp-service');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008020100001', 'NTP:保存', null, 'm_ntp:save', '3', '1', '1008020100000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008020200000', 'SYSLOG', null, 'm_syslog', ' ', '1', '1008020000000', 'system/related-services/syslog/syslog-service');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008020200001', 'SYSLOG:测试', null, 'm_syslog:test', '3', '1', '1008020200000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008020200002', 'SYSLOG:保存', null, 'm_syslog:save', '3', '1', '1008020200000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008020300000', '邮件', null, 'm_mail', ' ', '1', '1008020000000', 'system/related-services/mail/mail-service');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008020300001', '邮件:测试', null, 'm_mail:test', '3', '1', '1008020300000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008020300002', '邮件:保存', null, 'm_mail:save', '3', '1', '1008020300000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008020400000', '密码信封', null, 'm_password_envelop', ' ', '1', '1008020000000', 'system/related-services/password-envelope/password-envelope-service');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008020400001', '密码信封:保存', null, 'm_password_envelop:save', '3', '1', '1008020400000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008020500000', '应用发布', null, 'm_app_release', ' ', '1', '1008020000000', 'system/related-services/application-release/application-release-list');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008020500001', '应用发布:添加', null, 'm_app_release:add', '3', '1', '1008020500000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008020500002', '应用发布:编辑', null, 'm_app_release:edit', '3', '1', '1008020500000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008020500003', '应用发布:删除', null, 'm_app_release:delete', '3', '1', '1008020500000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008030000000', '系统状态', null, 'm_system_state', '1', '1', '1008000000000', 'middle?url=system/system-state/state-left');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008030100000', '设备运行状态', null, 'm_device_running_status', ' ', '1', '1008030000000', 'system/system-state/state');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008030100001', '设备运行状态:查看启动日志', null, 'm_device_running_status:startupLog', '3', '1', '1008030100000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008030300000', '活跃会话', null, 'm_alive_session', '', '1', '1008030000000', 'system/system-state/session-report-configuration');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008030400000', '流量吞吐', null, 'm_flow_spit', '', '1', '1008030000000', 'system/system-state/throughput-configuration');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008030500000', '关机重启', null, 'm_shut_reboot', '', '1', '1008030000000', 'system/system-state/shutdown-restart');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008030500001', '关机重启:关机', null, 'm_shut_reboot:shutdown', '3', '1', '1008030500000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008030500002', '关机重启:重启', null, 'm_shut_reboot:restart', '3', '1', '1008030500000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008030600000', '磁盘健康', null, 'm_disk_health', ' ', '1', '1008030000000', 'system/system-state/disk-health');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008040000000', '网络配置', null, 'm_network_config', '1', '1', '1008000000000', 'middle?url=system/net-config/net-config-left');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008040100000', '网卡配置', null, 'm_network_card_config', ' ', '1', '1008040000000', 'system/net-config/adapter-config');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008040100001', '网卡配置:设置网卡', null, 'm_network_card_config:setNetworkCard', '3', '1', '1008040100000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008040100002', '网卡配置:清空网卡', null, 'm_network_card_config:clearNetworkCard', '3', '1', '1008040100000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008040200000', '路由配置', null, 'm_route_config', ' ', '1', '1008040000000', 'system/net-config/route-config-list');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008040200001', '路由配置:添加', null, 'm_route_config:add', '3', '1', '1008040200000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008040200002', '路由配置:删除', null, 'm_route_config:delete', '3', '1', '1008040200000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008050000000', '备份还原', null, 'm_backup_restore', '1', '1', '1008000000000', 'middle?url=system/backup-restore/config-operation-left');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008050100000', '配置备份还原', null, 'm_config_backup_restore', ' ', '1', '1008050000000', 'system/backup-restore/config-backup-restore');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008050100001', '配置备份还原:立刻备份', null, 'm_config_backup_restore:immeBackup', '3', '1', '1008050100000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008050100002', '配置备份还原:保存', null, 'm_config_backup_restore:save', '3', '1', '1008050100000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008050100003', '配置备份还原:备份文件', null, 'm_config_backup_restore:backupFile', '3', '1', '1008050100000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008050200000', '初始化设置', null, 'm_restore_setting', ' ', '1', '1008050000000', 'system/backup-restore/restore-factory-settings');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008050200001', '初始化设置:还原系统配置', null, 'm_restore_setting:resSysConf', '3', '1', '1008050200000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008050200002', '初始化设置:清空数据库', null, 'm_restore_setting:clearDataBase', '3', '1', '1008050200000', 'system/backup-restore/restore-factory-settings');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008050200003', '初始化设置:清空审计文件', null, 'm_restore_setting:clearAuditFile', '3', '1', '1008050200000', 'system/backup-restore/restore-factory-settings');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008060000000', '客户端配置', null, 'm_client_config', '1', '1', '1008000000000', 'system/other-config/client-manager');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008060000001', '客户端配置:添加', null, 'm_client_config:add', '3', '1', '1008060000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008060000002', '客户端配置:编辑', null, 'm_client_config:edit', '3', '1', '1008060000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008060000003', '客户端配置:删除', null, 'm_client_config:delete', '3', '1', '1008060000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008070000000', '双机管理', null, 'm_dual_management', '1', '1', '1008000000000', 'system/node-management/heartbeat-config');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008070000001', '双机管理:保存', null, 'm_dual_management:save', '3', '1', '1008070000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008080000000', '维护配置', null, 'm_maintain_config', '1', '1', '1008000000000', 'middle?url=system/maintain-configuration/maintain-configuration-left');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008080100000', '审计留存', null, 'm_audit_retained', ' ', '1', '1008080000000', 'system/maintain-configuration/audit-storage-config');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008080100001', '审计留存:保存', null, 'm_audit_retained:save', '3', '1', '1008080100000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008080200000', '审计存储扩展', null, 'm_audit_storage_extend', ' ', '1', '1008080000000', 'system/maintain-configuration/audit-storage-extend-config');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008080200001', '审计存储扩展:添加', null, 'm_audit_storage_extend:add', '3', '1', '1008080200000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008080200002', '审计存储扩展:删除', null, 'm_audit_storage_extend:delete', '3', '1', '1008080200000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008090000000', 'AD定时抽取', null, 'm_ad_regular_extract', '1', '1', '1008000000000', '/system/ad-regular-extract/ldap-extract');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008090000001', 'AD定时抽取:立即发现', null, 'm_ad_regular_extract:immeFind', '3', '1', '1008090000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008090000002', 'AD定时抽取:周期发现', null, 'm_ad_regular_extract:cycleFind', '3', '1', '1008090000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008090000003', 'AD定时抽取:关闭定时', null, 'm_ad_regular_extract:closeQuartz', '3', '1', '1008090000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008090000004', 'AD定时抽取:左右移动按钮', null, 'm_ad_regular_extract:move', '3', '1', '1008090000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008090000005', 'AD定时抽取:保存策略', null, 'm_ad_regular_extract:saveStrategy', '3', '1', '1008090000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008090000006', 'AD定时抽取:清空历史记录', null, 'm_ad_regular_extract:clearRecord', '3', '1', '1008090000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008100000000', '使用授权', null, 'm_use_authorization', '1', '1', '1008000000000', 'system/version/version');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008100000001', '使用授权:保存', null, 'm_use_authorization:save', '3', '1', '1008100000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008100000002', '使用授权:logo上传', null, 'm_use_authorization:logoUpload', '3', '1', '1008100000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008100000003', '使用授权:升级包上传', null, 'm_use_authorization:upPackageUpload', '3', '1', '1008100000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008110000000', '集中管理', null, 'm_concentration_management', '1', '1', '1008000000000', 'system/concentration-management/node-patch-management/patch-management-list');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008110000001', '集中管理:应用', null, 'm_concentration_management:application', '3', '1', '1008110000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008110000002', '集中管理:添加', null, 'm_concentration_management:add', '3', '1', '1008110000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008110000003', '集中管理:编辑', null, 'm_concentration_management:edit', '3', '1', '1008110000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008110000004', '集中管理:删除设备', null, 'm_concentration_management:deleteEquipment', '3', '1', '1008110000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008110000005', '集中管理:上传补丁', null, 'm_concentration_management:uploadPatch', '3', '1', '1008110000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008110000006', '集中管理:出厂设置', null, 'm_concentration_management:factorySet', '3', '1', '1008110000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008110000007', '集中管理:安装', null, 'm_concentration_management:install', '3', '1', '1008110000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008110000008', '集中管理:删除补丁', null, 'm_concentration_management:deletePatch', '3', '1', '1008110000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008110000009', '集中管理:卸载', null, 'm_concentration_management:uninstall', '3', '1', '1008110000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1008110000010', '集中管理:保存', null, 'm_concentration_management:save', '3', '1', '1008110000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1009000000000', '策略配置', null, 'm_strategy', '1', '1', null, null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1009010000000', '认证强度', null, 'm_authentication_strength', '1', '1', '1009000000000', 'strategy/auth/strategy-auth');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1009010000001', '认证强度:保存', null, 'm_authentication_strength:save', '3', '1', '1009010000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1009020000000', '告警策略', null, 'm_alarm_config', '1', '1', '1009000000000', 'middle?url=strategy/alarm/alarm-left');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1009020100000', '告警归纳', null, 'm_alarm_induction', ' ', '1', '1009020000000', 'strategy/alarm/induction/alarm-induction-list');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1009020100001', '告警归纳:查看详情', null, 'm_alarm_induction:detail', '3', '1', '1009020100000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1009020200000', '告警配置', null, 'm_alarm_configuration', ' ', '1', '1009020000000', 'strategy/alarm/config/config-alarm');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1009020200001', '告警配置:保存', null, 'm_alarm_configuration:save', '3', '1', '1009020200000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1009030000000', '会话配置', null, 'm_session_config', '1', '1', '1009000000000', 'strategy/session/strategy-session');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1009030000001', '会话配置:查看上级策略', null, 'm_session_config:upperStrategy', '3', '1', '1009030000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1009030000002', '会话配置:保存', null, 'm_session_config:save', '3', '1', '1009030000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1009040000000', '密码策略', null, 'm_password_strategy', '1', '1', '1009000000000', 'strategy/password/strategy-password-list');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1009040000001', '密码策略:查看上级策略', null, 'm_password_strategy:upperStrategy', '3', '1', '1009040000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1009040000002', '密码策略:添加', null, 'm_password_strategy:add', '3', '1', '1009040000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1009040000003', '密码策略:编辑', null, 'm_password_strategy:edit', '3', '1', '1009040000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1009040000004', '密码策略:删除', null, 'm_password_strategy:delete', '3', '1', '1009040000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1009050000000', '审计外发策略', null, 'audit_send_strategy', '1', '1', '1009000000000', 'strategy/audit/audit-strategy');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1009050000001', '审计外发策略:保存', null, 'audit_send_strategy:save', '3', '1', '1009050000000', null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1010000000000', '三统一用户', null, 'three_uniform', '1', '1', null, null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1010010000000', '三统一用户同步', null, 'three_uniform:user', '1', '1', '1010000000000', '/foreign/threeUniform/threeUniformOperationsManagement/threeUniformUser/user-threeuniform');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('1010020000000', '三统一配置', null, 'three_uniform:config', '1', '1', '1010000000000', '/foreign/threeUniform/threeUniformOperationsManagement/threeuniform-config');
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('2000000000001', '审计查看', null, 'approval_audit_check', '2', null, null, null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('2000000000002', '运维访问 ', null, 'approval_operation_access', '2', null, null, null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('2000000000003', '用户导入', null, 'user_import', '2', null, null, null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('2000000000004', '资源导入', null, 'resource_import', '2', null, null, null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('2000000000005', '审计删除', null, 'audit_delete', '2', null, null, null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('2000000000006', '密码包接收人', null, 'password_packet_receiver', '4', null, null, null);
INSERT INTO fort_privilege (`fort_privilege_id`,`fort_privilege_name`,`fort_privilege_name_enus`,`fort_privilege_code`,`fort_privilege_type`,`fort_privilege_role_type`,`fort_parent_id`,`fort_url`) VALUES ('2000000000007', '解密密钥接收人', null, 'key_receiver', '4', null, null, null);
      
-- ----------------------------
-- Records of fort_client_tool
-- ----------------------------

insert  into `fort_client_tool`(`fort_client_tool_id`,`fort_client_tool_name`,`fort_action_script`,`fort_is_custom`) VALUES ('1000000000001', 'secureCRT', null, null);
insert  into `fort_client_tool`(`fort_client_tool_id`,`fort_client_tool_name`,`fort_action_script`,`fort_is_custom`) VALUES ('1000000000002', 'Xshell', null, null);
insert  into `fort_client_tool`(`fort_client_tool_id`,`fort_client_tool_name`,`fort_action_script`,`fort_is_custom`) VALUES ('1000000000003', 'SSH Secure Shell Client', null, null);
insert  into `fort_client_tool`(`fort_client_tool_id`,`fort_client_tool_name`,`fort_action_script`,`fort_is_custom`) VALUES ('1000000000004', 'netterm', null, null);
insert  into `fort_client_tool`(`fort_client_tool_id`,`fort_client_tool_name`,`fort_action_script`,`fort_is_custom`) VALUES ('1000000000005', 'putty', null, null);
insert  into `fort_client_tool`(`fort_client_tool_id`,`fort_client_tool_name`,`fort_action_script`,`fort_is_custom`) VALUES ('1000000000006', 'sftp', null, null);
insert  into `fort_client_tool`(`fort_client_tool_id`,`fort_client_tool_name`,`fort_action_script`,`fort_is_custom`) VALUES ('1000000000007', 'mstsc', null, null);
insert  into `fort_client_tool`(`fort_client_tool_id`,`fort_client_tool_name`,`fort_action_script`,`fort_is_custom`) VALUES ('1000000000008', 'samba', null, null);
insert  into `fort_client_tool`(`fort_client_tool_id`,`fort_client_tool_name`,`fort_action_script`,`fort_is_custom`) VALUES ('1000000000009', 'MySQL-Front', 'prg=C:/Program Files/MySQL-Front/MySQL-Front.exe,fwt=打开对话,fnc=enter,fwt=数据库登录,dat=pwd,fnc=3tab,fnc=enter', null);
insert  into `fort_client_tool`(`fort_client_tool_id`,`fort_client_tool_name`,`fort_action_script`,`fort_is_custom`) VALUES ('1000000000010', 'PLSQL Developer', 'prg=C:/数据库客户端/PLSQL Developer/plsqldev.exe,fwt=Oracle Logon,fnc=5tab,dat=account,fnc=1tab,dat=pwd,fnc=1tab,dat=dataBase,fnc=1tab,fnc=connect,fnc=1tab,fnc=enter', null);
insert  into `fort_client_tool`(`fort_client_tool_id`,`fort_client_tool_name`,`fort_action_script`,`fort_is_custom`) VALUES ('1000000000011', 'Toad for Oracle', 'prg=C:/Program Files/Quest Software/Toad for Oracle/toad.exe,fwt=TOAD Database Login Version 9.1.0.62,fnc=2tab,dat=account,fnc=1tab,dat=pwd,fnc=2tab,dat=dataBase,fnc=1tab,fnc=connect,fnc=6tab,fnc=enter', null);
insert  into `fort_client_tool`(`fort_client_tool_id`,`fort_client_tool_name`,`fort_action_script`,`fort_is_custom`) VALUES ('1000000000012', 'sqldeveloper', 'prg=C:/SQLDeveloper/sqldeveloper.exe,fwt=Oracle SQL Developer,fnc=2down,fnc=1right,fnc=4tab,dat=account,fnc=1tab,dat=pwd,fnc=2tab,fnc=enter', null);
insert  into `fort_client_tool`(`fort_client_tool_id`,`fort_client_tool_name`,`fort_action_script`,`fort_is_custom`) VALUES ('1000000000013', 'sqlplus10g', 'prg=C:/oracle/product/10.2.0/client_1/BIN/sqlplusw.exe,fwt=登录,dat=account,fnc=1tab,dat=pwd,fnc=1tab,dat=dataBase,fnc=1tab,fnc=enter', null);
insert  into `fort_client_tool`(`fort_client_tool_id`,`fort_client_tool_name`,`fort_action_script`,`fort_is_custom`) VALUES ('1000000000014', '查询分析器', 'prg=C:/Program Files/Microsoft SQL Server/80/Tools/Binn/isqlw.exe,fwt=连接到 SQL Server,fnc=4tab,dat=ip,fnc=4tab,dat=account,fnc=1tab,dat=pwd,fnc=1tab,fnc=enter', null);
insert  into `fort_client_tool`(`fort_client_tool_id`,`fort_client_tool_name`,`fort_action_script`,`fort_is_custom`) VALUES ('1000000000015', 'SQL Server Enterprise Manager(企业管理器)', 'prg=C:/Program Files/Microsoft SQL Server/80/Tools/BINN/SQL Server Enterprise Manager.MSC,fwt=SQL Server Enterprise Manager,fnc=1right,fnc=1down,fnc=1right,fnc=1down,fwt=连接到 SQL Server,fnc=4tab,dat=account,fnc=1tab,dat=pwd,fnc=2tab,fnc=enter', null);
insert  into `fort_client_tool`(`fort_client_tool_id`,`fort_client_tool_name`,`fort_action_script`,`fort_is_custom`) VALUES ('1000000000016', 'SQL Server Management Studio Express', 'prg=C:/Program Files/Microsoft SQL Server/90/Tools/Binn/VSShell/Common7/IDE/ssmsee.exe,fwt=连接到服务器,dat=ip,fnc=2tab,dat=account,fnc=1tab,dat=pwd,fnc=2tab,fnc=enter', null);
insert  into `fort_client_tool`(`fort_client_tool_id`,`fort_client_tool_name`,`fort_action_script`,`fort_is_custom`) VALUES ('1000000000017', 'Sybase Central v4.3', 'prg=C:/sybase/Shared/Sybase Central 4.3/win32/scjview.exe,fwt=Sybase Central,fnc=2down,fnc=altf,fnc=1down,fnc=enter,fnc=1tab,dat=pwd,fnc=10tab,fnc=enter', null);
insert  into `fort_client_tool`(`fort_client_tool_id`,`fort_client_tool_name`,`fort_action_script`,`fort_is_custom`) VALUES ('1000000000018', 'DB2控制中心', 'prg=C:/Program Files/IBM/SQLLIB/BIN/db2cc.bat,fwt=控制中心 - DB2COPY1,fnc=1down,fnc=1right,fnc=1down,fnc=1right,fnc=1down,fnc=1right,fnc=1down,fnc=1right,fnc=1down,fnc=1right,fnc=1down,fnc=1right,fnc=1down,dat=account,fnc=1tab,dat=pwd,fnc=1tab,fnc=enter', null);
insert  into `fort_client_tool`(`fort_client_tool_id`,`fort_client_tool_name`,`fort_action_script`,`fort_is_custom`) VALUES ('1000000000019', 'winsql', 'prg=C:/Program Files/Synametrics Technologies/WinSQL/WinSQL.exe,fwt=ODBC Data Source,fnc=10tab,fnc=connect,fnc=1tab,dat=account,fnc=1tab,dat=pwd,fnc=4tab,fnc=enter', null);
insert  into `fort_client_tool`(`fort_client_tool_id`,`fort_client_tool_name`,`fort_action_script`,`fort_is_custom`) VALUES ('1000000000020', 'C/S', null, null);
insert  into `fort_client_tool`(`fort_client_tool_id`,`fort_client_tool_name`,`fort_action_script`,`fort_is_custom`) VALUES ('1000000000021', 'B/S', null, null);
insert  into `fort_client_tool`(`fort_client_tool_id`,`fort_client_tool_name`,`fort_action_script`,`fort_is_custom`) VALUES ('1000000000023', 'vnc', null, null);
insert  into `fort_client_tool`(`fort_client_tool_id`,`fort_client_tool_name`,`fort_action_script`,`fort_is_custom`) VALUES ('1000000000024', 'x11', null, null);
insert  into `fort_client_tool`(`fort_client_tool_id`,`fort_client_tool_name`,`fort_action_script`,`fort_is_custom`) VALUES ('1000000000025', 'appagent', null, null);
insert  into `fort_client_tool`(`fort_client_tool_id`,`fort_client_tool_name`,`fort_action_script`,`fort_is_custom`) VALUES ('1000000000026', 'sqlplus11g', ' prg=C:/app/Administrator/product/11.2.0/client_2/BIN/sqlplus.exe,fwt=SQL Plus,dat=account@dataBase,fnc=enter,dat=pwd,fnc=enter', null);
insert  into `fort_client_tool`(`fort_client_tool_id`,`fort_client_tool_name`,`fort_action_script`,`fort_is_custom`) VALUES ('1000000000027', 'SQL Server Management Studio Express(2008)', 'prg=C:/Program Files/Microsoft SQL Server/100/Tools/Binn/VSShell/Common7/IDE/Ssms.exe,fwt=连接到服务器,dat=ip,fnc=2tab,dat=account,fnc=1tab,dat=pwd,fnc=2tab,fnc=enter', null);
insert  into `fort_client_tool`(`fort_client_tool_id`,`fort_client_tool_name`,`fort_action_script`,`fort_is_custom`) VALUES ('1000000000028', 'SQL Server Management Studio Express(2014)', 'prg=C:/Program Files (x86)/Microsoft SQL Server/120/Tools/Binn/ManagementStudio/Ssms.exe,fwt=连接到服务器,dat=ip,fnc=2tab,dat=account,fnc=1tab,dat=pwd,fnc=2tab,fnc=enter', null);

-- ----------------------------
-- Records of fort_operations_protocol
-- ----------------------------
insert  into `fort_operations_protocol`(`fort_operations_protocol_id`,`fort_operations_protocol_name`,`fort_operations_protocol_code`) VALUES ('1000000000001', 'SSH1', null);
insert  into `fort_operations_protocol`(`fort_operations_protocol_id`,`fort_operations_protocol_name`,`fort_operations_protocol_code`) VALUES ('1000000000002', 'SSH2', null);
insert  into `fort_operations_protocol`(`fort_operations_protocol_id`,`fort_operations_protocol_name`,`fort_operations_protocol_code`) VALUES ('1000000000003', 'TELNET', null);
insert  into `fort_operations_protocol`(`fort_operations_protocol_id`,`fort_operations_protocol_name`,`fort_operations_protocol_code`) VALUES ('1000000000004', 'FTP', null);
insert  into `fort_operations_protocol`(`fort_operations_protocol_id`,`fort_operations_protocol_name`,`fort_operations_protocol_code`) VALUES ('1000000000005', 'SFTP', null);
insert  into `fort_operations_protocol`(`fort_operations_protocol_id`,`fort_operations_protocol_name`,`fort_operations_protocol_code`) VALUES ('1000000000006', 'X11', null);
insert  into `fort_operations_protocol`(`fort_operations_protocol_id`,`fort_operations_protocol_name`,`fort_operations_protocol_code`) VALUES ('1000000000007', 'VNC', null);
insert  into `fort_operations_protocol`(`fort_operations_protocol_id`,`fort_operations_protocol_name`,`fort_operations_protocol_code`) VALUES ('1000000000008', 'RDP', null);
insert  into `fort_operations_protocol`(`fort_operations_protocol_id`,`fort_operations_protocol_name`,`fort_operations_protocol_code`) VALUES ('1000000000009', 'SAMBA', null);
insert  into `fort_operations_protocol`(`fort_operations_protocol_id`,`fort_operations_protocol_name`,`fort_operations_protocol_code`) VALUES ('1000000000010', 'MYSQL', null);
insert  into `fort_operations_protocol`(`fort_operations_protocol_id`,`fort_operations_protocol_name`,`fort_operations_protocol_code`) VALUES ('1000000000011', 'ORACLEPLSQL', null);
insert  into `fort_operations_protocol`(`fort_operations_protocol_id`,`fort_operations_protocol_name`,`fort_operations_protocol_code`) VALUES ('1000000000012', 'SQLSERVER2000Enterprise', null);
insert  into `fort_operations_protocol`(`fort_operations_protocol_id`,`fort_operations_protocol_name`,`fort_operations_protocol_code`) VALUES ('1000000000013', 'SQLSERVER2005', null);
insert  into `fort_operations_protocol`(`fort_operations_protocol_id`,`fort_operations_protocol_name`,`fort_operations_protocol_code`) VALUES ('1000000000014', 'SQLSERVER2008', null);
insert  into `fort_operations_protocol`(`fort_operations_protocol_id`,`fort_operations_protocol_name`,`fort_operations_protocol_code`) VALUES ('1000000000015', 'SYBASE', null);
insert  into `fort_operations_protocol`(`fort_operations_protocol_id`,`fort_operations_protocol_name`,`fort_operations_protocol_code`) VALUES ('1000000000016', 'DB2', null);
insert  into `fort_operations_protocol`(`fort_operations_protocol_id`,`fort_operations_protocol_name`,`fort_operations_protocol_code`) VALUES ('1000000000017', 'INFORMIX', null);
insert  into `fort_operations_protocol`(`fort_operations_protocol_id`,`fort_operations_protocol_name`,`fort_operations_protocol_code`) VALUES ('1000000000018', 'CS', null);
insert  into `fort_operations_protocol`(`fort_operations_protocol_id`,`fort_operations_protocol_name`,`fort_operations_protocol_code`) VALUES ('1000000000019', 'BS', null);
insert  into `fort_operations_protocol`(`fort_operations_protocol_id`,`fort_operations_protocol_name`,`fort_operations_protocol_code`) VALUES ('1000000000020', 'agent', null);
insert  into `fort_operations_protocol`(`fort_operations_protocol_id`,`fort_operations_protocol_name`,`fort_operations_protocol_code`) VALUES ('1000000000021', 'SQLSERVER2014', null);
insert  into `fort_operations_protocol`(`fort_operations_protocol_id`,`fort_operations_protocol_name`,`fort_operations_protocol_code`) VALUES ('1000000000022', 'SQLSERVER2000query', null);
insert  into `fort_operations_protocol`(`fort_operations_protocol_id`,`fort_operations_protocol_name`,`fort_operations_protocol_code`) VALUES ('1000000000023', 'ORACLEToad', null);
insert  into `fort_operations_protocol`(`fort_operations_protocol_id`,`fort_operations_protocol_name`,`fort_operations_protocol_code`) VALUES ('1000000000024', 'ORACLEsqldeveloper', null);
insert  into `fort_operations_protocol`(`fort_operations_protocol_id`,`fort_operations_protocol_name`,`fort_operations_protocol_code`) VALUES ('1000000000025', 'ORACLEsqlplus10g', null);
insert  into `fort_operations_protocol`(`fort_operations_protocol_id`,`fort_operations_protocol_name`,`fort_operations_protocol_code`) VALUES ('1000000000026', 'ORACLEsqlplus11g', null);
-- ----------------------------
-- Records of fort_protocol_client
-- ----------------------------

insert  into `fort_protocol_client`(`fort_protocol_client_id`,`fort_operations_protocol_id`,`fort_client_tool_id`,`fort_is_default`) VALUES ('1000000000001', '1000000000001', '1000000000001', '1');
insert  into `fort_protocol_client`(`fort_protocol_client_id`,`fort_operations_protocol_id`,`fort_client_tool_id`,`fort_is_default`) VALUES ('1000000000002', '1000000000001', '1000000000002', null);
insert  into `fort_protocol_client`(`fort_protocol_client_id`,`fort_operations_protocol_id`,`fort_client_tool_id`,`fort_is_default`) VALUES ('1000000000003', '1000000000001', '1000000000003', null);
insert  into `fort_protocol_client`(`fort_protocol_client_id`,`fort_operations_protocol_id`,`fort_client_tool_id`,`fort_is_default`) VALUES ('1000000000004', '1000000000001', '1000000000004', null);
insert  into `fort_protocol_client`(`fort_protocol_client_id`,`fort_operations_protocol_id`,`fort_client_tool_id`,`fort_is_default`) VALUES ('1000000000005', '1000000000001', '1000000000005', null);
insert  into `fort_protocol_client`(`fort_protocol_client_id`,`fort_operations_protocol_id`,`fort_client_tool_id`,`fort_is_default`) VALUES ('1000000000006', '1000000000002', '1000000000001', '1');
insert  into `fort_protocol_client`(`fort_protocol_client_id`,`fort_operations_protocol_id`,`fort_client_tool_id`,`fort_is_default`) VALUES ('1000000000007', '1000000000002', '1000000000002', null);
insert  into `fort_protocol_client`(`fort_protocol_client_id`,`fort_operations_protocol_id`,`fort_client_tool_id`,`fort_is_default`) VALUES ('1000000000008', '1000000000002', '1000000000003', null);
insert  into `fort_protocol_client`(`fort_protocol_client_id`,`fort_operations_protocol_id`,`fort_client_tool_id`,`fort_is_default`) VALUES ('1000000000009', '1000000000002', '1000000000004', null);
insert  into `fort_protocol_client`(`fort_protocol_client_id`,`fort_operations_protocol_id`,`fort_client_tool_id`,`fort_is_default`) VALUES ('1000000000010', '1000000000002', '1000000000005', null);
insert  into `fort_protocol_client`(`fort_protocol_client_id`,`fort_operations_protocol_id`,`fort_client_tool_id`,`fort_is_default`) VALUES ('1000000000011', '1000000000003', '1000000000001', '1');
insert  into `fort_protocol_client`(`fort_protocol_client_id`,`fort_operations_protocol_id`,`fort_client_tool_id`,`fort_is_default`) VALUES ('1000000000012', '1000000000003', '1000000000002', null);
insert  into `fort_protocol_client`(`fort_protocol_client_id`,`fort_operations_protocol_id`,`fort_client_tool_id`,`fort_is_default`) VALUES ('1000000000013', '1000000000003', '1000000000003', null);
insert  into `fort_protocol_client`(`fort_protocol_client_id`,`fort_operations_protocol_id`,`fort_client_tool_id`,`fort_is_default`) VALUES ('1000000000014', '1000000000003', '1000000000004', null);
insert  into `fort_protocol_client`(`fort_protocol_client_id`,`fort_operations_protocol_id`,`fort_client_tool_id`,`fort_is_default`) VALUES ('1000000000015', '1000000000003', '1000000000005', null);
insert  into `fort_protocol_client`(`fort_protocol_client_id`,`fort_operations_protocol_id`,`fort_client_tool_id`,`fort_is_default`) VALUES ('1000000000016', '1000000000004', '1000000000006', null);
insert  into `fort_protocol_client`(`fort_protocol_client_id`,`fort_operations_protocol_id`,`fort_client_tool_id`,`fort_is_default`) VALUES ('1000000000017', '1000000000005', '1000000000006', null);
insert  into `fort_protocol_client`(`fort_protocol_client_id`,`fort_operations_protocol_id`,`fort_client_tool_id`,`fort_is_default`) VALUES ('1000000000018', '1000000000006', '1000000000024', null);
insert  into `fort_protocol_client`(`fort_protocol_client_id`,`fort_operations_protocol_id`,`fort_client_tool_id`,`fort_is_default`) VALUES ('1000000000019', '1000000000007', '1000000000023', null);
insert  into `fort_protocol_client`(`fort_protocol_client_id`,`fort_operations_protocol_id`,`fort_client_tool_id`,`fort_is_default`) VALUES ('1000000000020', '1000000000008', '1000000000007', '1');
insert  into `fort_protocol_client`(`fort_protocol_client_id`,`fort_operations_protocol_id`,`fort_client_tool_id`,`fort_is_default`) VALUES ('1000000000021', '1000000000009', '1000000000008', null);
insert  into `fort_protocol_client`(`fort_protocol_client_id`,`fort_operations_protocol_id`,`fort_client_tool_id`,`fort_is_default`) VALUES ('1000000000022', '1000000000010', '1000000000009', '1');
insert  into `fort_protocol_client`(`fort_protocol_client_id`,`fort_operations_protocol_id`,`fort_client_tool_id`,`fort_is_default`) VALUES ('1000000000023', '1000000000011', '1000000000010', '1');
insert  into `fort_protocol_client`(`fort_protocol_client_id`,`fort_operations_protocol_id`,`fort_client_tool_id`,`fort_is_default`) VALUES ('1000000000024', '1000000000023', '1000000000011', null);
insert  into `fort_protocol_client`(`fort_protocol_client_id`,`fort_operations_protocol_id`,`fort_client_tool_id`,`fort_is_default`) VALUES ('1000000000025', '1000000000024', '1000000000012', null);
insert  into `fort_protocol_client`(`fort_protocol_client_id`,`fort_operations_protocol_id`,`fort_client_tool_id`,`fort_is_default`) VALUES ('1000000000026', '1000000000025', '1000000000013', '1');
insert  into `fort_protocol_client`(`fort_protocol_client_id`,`fort_operations_protocol_id`,`fort_client_tool_id`,`fort_is_default`) VALUES ('1000000000027', '1000000000012', '1000000000014', '1');
insert  into `fort_protocol_client`(`fort_protocol_client_id`,`fort_operations_protocol_id`,`fort_client_tool_id`,`fort_is_default`) VALUES ('1000000000028', '1000000000022', '1000000000015', '1');
insert  into `fort_protocol_client`(`fort_protocol_client_id`,`fort_operations_protocol_id`,`fort_client_tool_id`,`fort_is_default`) VALUES ('1000000000029', '1000000000013', '1000000000016', '1');
insert  into `fort_protocol_client`(`fort_protocol_client_id`,`fort_operations_protocol_id`,`fort_client_tool_id`,`fort_is_default`) VALUES ('1000000000030', '1000000000014', '1000000000027', '1');
insert  into `fort_protocol_client`(`fort_protocol_client_id`,`fort_operations_protocol_id`,`fort_client_tool_id`,`fort_is_default`) VALUES ('1000000000031', '1000000000015', '1000000000017', '1');
insert  into `fort_protocol_client`(`fort_protocol_client_id`,`fort_operations_protocol_id`,`fort_client_tool_id`,`fort_is_default`) VALUES ('1000000000032', '1000000000016', '1000000000018', '1');
insert  into `fort_protocol_client`(`fort_protocol_client_id`,`fort_operations_protocol_id`,`fort_client_tool_id`,`fort_is_default`) VALUES ('1000000000033', '1000000000017', '1000000000019', '1');
insert  into `fort_protocol_client`(`fort_protocol_client_id`,`fort_operations_protocol_id`,`fort_client_tool_id`,`fort_is_default`) VALUES ('1000000000034', '1000000000020', '1000000000025', null);
insert  into `fort_protocol_client`(`fort_protocol_client_id`,`fort_operations_protocol_id`,`fort_client_tool_id`,`fort_is_default`) VALUES ('1000000000035', '1000000000026', '1000000000026', null);
insert  into `fort_protocol_client`(`fort_protocol_client_id`,`fort_operations_protocol_id`,`fort_client_tool_id`,`fort_is_default`) VALUES ('1000000000036', '1000000000018', '1000000000020', '1');
insert  into `fort_protocol_client`(`fort_protocol_client_id`,`fort_operations_protocol_id`,`fort_client_tool_id`,`fort_is_default`) VALUES ('1000000000037', '1000000000019', '1000000000021', '1');
insert  into `fort_protocol_client`(`fort_protocol_client_id`,`fort_operations_protocol_id`,`fort_client_tool_id`,`fort_is_default`) VALUES ('1000000000038', '1000000000021', '1000000000028', '1');
-- ----------------------------
-- Records of fort_resource_type
-- ----------------------------
insert  into `fort_resource_type`(`fort_resource_type_id`,`fort_resource_type_name`,`fort_parent_id`,`fort_resource_type_code`) VALUES ('1000000000001', '服务器及设备', null, null);
insert  into `fort_resource_type`(`fort_resource_type_id`,`fort_resource_type_name`,`fort_parent_id`,`fort_resource_type_code`) VALUES ('1000000000002', '应用系统', null, null);
insert  into `fort_resource_type`(`fort_resource_type_id`,`fort_resource_type_name`,`fort_parent_id`,`fort_resource_type_code`) VALUES ('1000000000003', '数据库', null, null);
insert  into `fort_resource_type`(`fort_resource_type_id`,`fort_resource_type_name`,`fort_parent_id`,`fort_resource_type_code`) VALUES ('1000000000004', 'Unix/Linux资源', '1000000000001', null);
insert  into `fort_resource_type`(`fort_resource_type_id`,`fort_resource_type_name`,`fort_parent_id`,`fort_resource_type_code`) VALUES ('1000000000005', 'Windows资源', '1000000000001', null);
insert  into `fort_resource_type`(`fort_resource_type_id`,`fort_resource_type_name`,`fort_parent_id`,`fort_resource_type_code`) VALUES ('1000000000007', '网络设备', '1000000000001', null);
insert  into `fort_resource_type`(`fort_resource_type_id`,`fort_resource_type_name`,`fort_parent_id`,`fort_resource_type_code`) VALUES ('1000000000008', 'MYSQL', '1000000000003', null);
insert  into `fort_resource_type`(`fort_resource_type_id`,`fort_resource_type_name`,`fort_parent_id`,`fort_resource_type_code`) VALUES ('1000000000009', 'ORACLE', '1000000000003', null);
insert  into `fort_resource_type`(`fort_resource_type_id`,`fort_resource_type_name`,`fort_parent_id`,`fort_resource_type_code`) VALUES ('1000000000010', 'MSSQL', '1000000000003', null);
insert  into `fort_resource_type`(`fort_resource_type_id`,`fort_resource_type_name`,`fort_parent_id`,`fort_resource_type_code`) VALUES ('1000000000011', 'SYBASE', '1000000000003', null);
insert  into `fort_resource_type`(`fort_resource_type_id`,`fort_resource_type_name`,`fort_parent_id`,`fort_resource_type_code`) VALUES ('1000000000012', 'INFORMIX', '1000000000003', null);
insert  into `fort_resource_type`(`fort_resource_type_id`,`fort_resource_type_name`,`fort_parent_id`,`fort_resource_type_code`) VALUES ('1000000000013', 'DB2', '1000000000003', null);
insert  into `fort_resource_type`(`fort_resource_type_id`,`fort_resource_type_name`,`fort_parent_id`,`fort_resource_type_code`) VALUES ('1000000000014', 'C/S应用', '1000000000002', null);
insert  into `fort_resource_type`(`fort_resource_type_id`,`fort_resource_type_name`,`fort_parent_id`,`fort_resource_type_code`) VALUES ('1000000000015', 'B/S应用', '1000000000002', null);
insert  into `fort_resource_type`(`fort_resource_type_id`,`fort_resource_type_name`,`fort_parent_id`,`fort_resource_type_code`) VALUES ('1000000000016', 'Common linux', '1000000000004', null);
insert  into `fort_resource_type`(`fort_resource_type_id`,`fort_resource_type_name`,`fort_parent_id`,`fort_resource_type_code`) VALUES ('1000000000017', 'RedHat', '1000000000004', null);
insert  into `fort_resource_type`(`fort_resource_type_id`,`fort_resource_type_name`,`fort_parent_id`,`fort_resource_type_code`) VALUES ('1000000000018', 'Ubuntu', '1000000000004', null);
insert  into `fort_resource_type`(`fort_resource_type_id`,`fort_resource_type_name`,`fort_parent_id`,`fort_resource_type_code`) VALUES ('1000000000019', 'HP unix', '1000000000004', null);
insert  into `fort_resource_type`(`fort_resource_type_id`,`fort_resource_type_name`,`fort_parent_id`,`fort_resource_type_code`) VALUES ('1000000000020', 'AIX(IBM)', '1000000000004', null);
insert  into `fort_resource_type`(`fort_resource_type_id`,`fort_resource_type_name`,`fort_parent_id`,`fort_resource_type_code`) VALUES ('1000000000021', 'SCO unix', '1000000000004', null);
insert  into `fort_resource_type`(`fort_resource_type_id`,`fort_resource_type_name`,`fort_parent_id`,`fort_resource_type_code`) VALUES ('1000000000022', 'Solaris(Sun)', '1000000000004', null);
insert  into `fort_resource_type`(`fort_resource_type_id`,`fort_resource_type_name`,`fort_parent_id`,`fort_resource_type_code`) VALUES ('1000000000023', 'FreeBsd', '1000000000004', null);
insert  into `fort_resource_type`(`fort_resource_type_id`,`fort_resource_type_name`,`fort_parent_id`,`fort_resource_type_code`) VALUES ('1000000000024', 'Common Windows', '1000000000005', null);
insert  into `fort_resource_type`(`fort_resource_type_id`,`fort_resource_type_name`,`fort_parent_id`,`fort_resource_type_code`) VALUES ('1000000000025', 'Windows Server 2003', '1000000000005', null);
insert  into `fort_resource_type`(`fort_resource_type_id`,`fort_resource_type_name`,`fort_parent_id`,`fort_resource_type_code`) VALUES ('1000000000026', 'Windows Server 2008', '1000000000005', null);
insert  into `fort_resource_type`(`fort_resource_type_id`,`fort_resource_type_name`,`fort_parent_id`,`fort_resource_type_code`) VALUES ('1000000000027', 'Windows Server 2012', '1000000000005', null);
insert  into `fort_resource_type`(`fort_resource_type_id`,`fort_resource_type_name`,`fort_parent_id`,`fort_resource_type_code`) VALUES ('1000000000030', 'Common networkequipment', '1000000000007', null);
insert  into `fort_resource_type`(`fort_resource_type_id`,`fort_resource_type_name`,`fort_parent_id`,`fort_resource_type_code`) VALUES ('1000000000031', 'Cisco', '1000000000007', null);
insert  into `fort_resource_type`(`fort_resource_type_id`,`fort_resource_type_name`,`fort_parent_id`,`fort_resource_type_code`) VALUES ('1000000000032', '华为', '1000000000007', null);
insert  into `fort_resource_type`(`fort_resource_type_id`,`fort_resource_type_name`,`fort_parent_id`,`fort_resource_type_code`) VALUES ('1000000000033', 'Cisco ASA', '1000000000007', null);
insert  into `fort_resource_type`(`fort_resource_type_id`,`fort_resource_type_name`,`fort_parent_id`,`fort_resource_type_code`) VALUES ('1000000000034', 'H3C', '1000000000007', null);
insert  into `fort_resource_type`(`fort_resource_type_id`,`fort_resource_type_name`,`fort_parent_id`,`fort_resource_type_code`) VALUES ('1000000000035', '迈普', '1000000000007', null);
insert  into `fort_resource_type`(`fort_resource_type_id`,`fort_resource_type_name`,`fort_parent_id`,`fort_resource_type_code`) VALUES ('1000000000036', '锐捷', '1000000000007', null);
insert  into `fort_resource_type`(`fort_resource_type_id`,`fort_resource_type_name`,`fort_parent_id`,`fort_resource_type_code`) VALUES ('1000000000037', 'Common Oracle', '1000000000009', null);
insert  into `fort_resource_type`(`fort_resource_type_id`,`fort_resource_type_name`,`fort_parent_id`,`fort_resource_type_code`) VALUES ('1000000000038', 'Oracle9i', '1000000000009', null);
insert  into `fort_resource_type`(`fort_resource_type_id`,`fort_resource_type_name`,`fort_parent_id`,`fort_resource_type_code`) VALUES ('1000000000039', 'Oracle10g', '1000000000009', null);
insert  into `fort_resource_type`(`fort_resource_type_id`,`fort_resource_type_name`,`fort_parent_id`,`fort_resource_type_code`) VALUES ('1000000000040', 'Oracle11g', '1000000000009', null);
insert  into `fort_resource_type`(`fort_resource_type_id`,`fort_resource_type_name`,`fort_parent_id`,`fort_resource_type_code`) VALUES ('1000000000041', 'Mssql2000', '1000000000010', null);
insert  into `fort_resource_type`(`fort_resource_type_id`,`fort_resource_type_name`,`fort_parent_id`,`fort_resource_type_code`) VALUES ('1000000000042', 'Mssql2005', '1000000000010', null);
insert  into `fort_resource_type`(`fort_resource_type_id`,`fort_resource_type_name`,`fort_parent_id`,`fort_resource_type_code`) VALUES ('1000000000043', 'Mssql2008', '1000000000010', null);
insert  into `fort_resource_type`(`fort_resource_type_id`,`fort_resource_type_name`,`fort_parent_id`,`fort_resource_type_code`) VALUES ('1000000000044', 'Mssql2014', '1000000000010', null);
insert  into `fort_resource_type`(`fort_resource_type_id`,`fort_resource_type_name`,`fort_parent_id`,`fort_resource_type_code`) VALUES ('1000000000045', 'Centos', '1000000000004', null);
insert  into `fort_resource_type`(`fort_resource_type_id`,`fort_resource_type_name`,`fort_parent_id`,`fort_resource_type_code`) VALUES ('1000000000046', 'Debian', '1000000000004', null);
insert  into `fort_resource_type`(`fort_resource_type_id`,`fort_resource_type_name`,`fort_parent_id`,`fort_resource_type_code`) VALUES ('1000000000047', 'OpenSuSe', '1000000000004', null);
insert  into `fort_resource_type`(`fort_resource_type_id`,`fort_resource_type_name`,`fort_parent_id`,`fort_resource_type_code`) VALUES ('1000000000048', 'Windows2003 域控服务器', '1000000000005', null);
insert  into `fort_resource_type`(`fort_resource_type_id`,`fort_resource_type_name`,`fort_parent_id`,`fort_resource_type_code`) VALUES ('1000000000049', 'Windows2008 域控服务器', '1000000000005', null);
insert  into `fort_resource_type`(`fort_resource_type_id`,`fort_resource_type_name`,`fort_parent_id`,`fort_resource_type_code`) VALUES ('1000000000050', 'Windows2012 域控服务器', '1000000000005', null);
-- ----------------------------
-- Records of fort_resource_type_operations_protocol
-- ----------------------------
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000001', '1000000000004', '1000000000001',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000002', '1000000000004', '1000000000002',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000003', '1000000000004', '1000000000003',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000004', '1000000000004', '1000000000004',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000005', '1000000000004', '1000000000005',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000006', '1000000000004', '1000000000006',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000007', '1000000000004', '1000000000007',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000008', '1000000000005', '1000000000008',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000009', '1000000000005', '1000000000004',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000010', '1000000000005', '1000000000007',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000011', '1000000000005', '1000000000009',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000016', '1000000000040', '1000000000011',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000017', '1000000000039', '1000000000011',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000018', '1000000000038', '1000000000011',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000019', '1000000000037', '1000000000011',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000020', '1000000000030', '1000000000001','1000000000002');
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000021', '1000000000031', '1000000000001','1000000000002');
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000022', '1000000000032', '1000000000001','1000000000002');
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000023', '1000000000033', '1000000000001','1000000000002');
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000024', '1000000000034', '1000000000001','1000000000002');
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000025', '1000000000035', '1000000000001','1000000000002');
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000026', '1000000000036', '1000000000001','1000000000002');
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000027', '1000000000030', '1000000000002','1000000000002');
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000028', '1000000000031', '1000000000002','1000000000002');
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000029', '1000000000032', '1000000000002','1000000000002');
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000030', '1000000000033', '1000000000002','1000000000002');
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000031', '1000000000034', '1000000000002','1000000000002');
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000032', '1000000000035', '1000000000002','1000000000002');
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000033', '1000000000036', '1000000000002','1000000000002');
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000034', '1000000000030', '1000000000003',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000035', '1000000000031', '1000000000003',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000036', '1000000000032', '1000000000003',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000037', '1000000000033', '1000000000003',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000038', '1000000000034', '1000000000003',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000039', '1000000000035', '1000000000003',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000040', '1000000000036', '1000000000003',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000041', '1000000000024', '1000000000004',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000042', '1000000000025', '1000000000004',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000043', '1000000000026', '1000000000004',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000044', '1000000000027', '1000000000004',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000047', '1000000000024', '1000000000007',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000048', '1000000000025', '1000000000007',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000049', '1000000000026', '1000000000007',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000050', '1000000000027', '1000000000007',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000053', '1000000000024', '1000000000008',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000054', '1000000000025', '1000000000008',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000055', '1000000000026', '1000000000008',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000056', '1000000000027', '1000000000008',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000059', '1000000000024', '1000000000009',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000060', '1000000000025', '1000000000009',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000061', '1000000000026', '1000000000009',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000062', '1000000000027', '1000000000009',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000065', '1000000000016', '1000000000001','1000000000001');
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000066', '1000000000017', '1000000000001','1000000000001');
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000067', '1000000000018', '1000000000001','1000000000001');
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000068', '1000000000019', '1000000000001','1000000000001');
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000069', '1000000000020', '1000000000001','1000000000001');
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000070', '1000000000021', '1000000000001','1000000000001');
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000071', '1000000000022', '1000000000001','1000000000001');
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000072', '1000000000023', '1000000000001','1000000000001');
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000073', '1000000000016', '1000000000002','1000000000001');
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000074', '1000000000017', '1000000000002','1000000000001');
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000075', '1000000000018', '1000000000002','1000000000001');
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000076', '1000000000019', '1000000000002','1000000000001');
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000077', '1000000000020', '1000000000002','1000000000001');
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000078', '1000000000021', '1000000000002','1000000000001');
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000079', '1000000000022', '1000000000002','1000000000001');
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000080', '1000000000023', '1000000000002','1000000000001');
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000081', '1000000000016', '1000000000003',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000082', '1000000000017', '1000000000003',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000083', '1000000000018', '1000000000003',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000084', '1000000000019', '1000000000003',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000085', '1000000000020', '1000000000003',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000086', '1000000000021', '1000000000003',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000087', '1000000000022', '1000000000003',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000088', '1000000000023', '1000000000003',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000089', '1000000000016', '1000000000004',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000090', '1000000000017', '1000000000004',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000091', '1000000000018', '1000000000004',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000092', '1000000000019', '1000000000004',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000093', '1000000000020', '1000000000004',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000094', '1000000000021', '1000000000004',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000095', '1000000000022', '1000000000004',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000096', '1000000000023', '1000000000004',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000097', '1000000000016', '1000000000005',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000098', '1000000000017', '1000000000005',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000099', '1000000000018', '1000000000005',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000100', '1000000000019', '1000000000005',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000104', '1000000000020', '1000000000005',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000105', '1000000000021', '1000000000005',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000106', '1000000000022', '1000000000005',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000107', '1000000000023', '1000000000005',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000108', '1000000000016', '1000000000006',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000109', '1000000000017', '1000000000006',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000110', '1000000000018', '1000000000006',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000111', '1000000000019', '1000000000006',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000112', '1000000000020', '1000000000006',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000113', '1000000000021', '1000000000006',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000114', '1000000000022', '1000000000006',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000115', '1000000000023', '1000000000006',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000116', '1000000000016', '1000000000007',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000117', '1000000000017', '1000000000007',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000118', '1000000000018', '1000000000007',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000119', '1000000000019', '1000000000007',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000120', '1000000000020', '1000000000007',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000121', '1000000000021', '1000000000007',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000122', '1000000000022', '1000000000007',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000123', '1000000000023', '1000000000007',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000124', '1000000000013', '1000000000016',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000125', '1000000000012', '1000000000017',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000126', '1000000000011', '1000000000015',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000127', '1000000000008', '1000000000010',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000128', '1000000000041', '1000000000012',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000129', '1000000000042', '1000000000013',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000130', '1000000000043', '1000000000014',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000131', '1000000000014', '1000000000018',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000132', '1000000000015', '1000000000019',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000133', '1000000000044', '1000000000021',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000134', '1000000000007', '1000000000001','1000000000002');
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000135', '1000000000007', '1000000000002','1000000000002');
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000136', '1000000000045', '1000000000002','1000000000001');
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000137', '1000000000045', '1000000000001','1000000000001');
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000138', '1000000000046', '1000000000001','1000000000001');
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000139', '1000000000046', '1000000000002','1000000000001');
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000140', '1000000000047', '1000000000001','1000000000001');
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000141', '1000000000047', '1000000000002','1000000000001');
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000142', '1000000000048', '1000000000004',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000143', '1000000000048', '1000000000007',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000144', '1000000000048', '1000000000008',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000145', '1000000000048', '1000000000009',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000146', '1000000000049', '1000000000004',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000147', '1000000000049', '1000000000007',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000148', '1000000000049', '1000000000008',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000149', '1000000000049', '1000000000009',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000150', '1000000000050', '1000000000004',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000151', '1000000000050', '1000000000007',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000152', '1000000000050', '1000000000008',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000153', '1000000000050', '1000000000009',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000154', '1000000000041', '1000000000022',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000155', '1000000000040', '1000000000023',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000156', '1000000000040', '1000000000024',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000157', '1000000000040', '1000000000025',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000158', '1000000000040', '1000000000026',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000159', '1000000000039', '1000000000023',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000160', '1000000000039', '1000000000024',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000161', '1000000000039', '1000000000025',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000162', '1000000000039', '1000000000026',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000163', '1000000000038', '1000000000023',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000164', '1000000000038', '1000000000024',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000165', '1000000000038', '1000000000025',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000166', '1000000000038', '1000000000026',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000167', '1000000000037', '1000000000023',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000168', '1000000000037', '1000000000024',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000169', '1000000000037', '1000000000025',null);
insert  into `fort_resource_type_operations_protocol`(`fort_resource_type_operations_protocol_id`,`fort_resource_type_id`,`fort_operations_protocol_id`,`fort_behavior_guideline_type_id`) VALUES ('1000000000170', '1000000000037', '1000000000026',null);

-- ----------------------------
-- Records of fort_role
-- ----------------------------

insert into `fort_role` (`fort_role_id`, `fort_role_name`, `fort_role_short_name`, `fort_role_type`, `fort_weight`, `fort_state`, `fort_create_date`, `fort_create_by`, `fort_last_edit_date`, `fort_last_edit_by`, `fort_field1`, `fort_field2`, `fort_field3`) values('1000000000001','初始化用户','初始','0','256','1',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
insert into `fort_role` (`fort_role_id`, `fort_role_name`, `fort_role_short_name`, `fort_role_type`, `fort_weight`, `fort_state`, `fort_create_date`, `fort_create_by`, `fort_last_edit_date`, `fort_last_edit_by`, `fort_field1`, `fort_field2`, `fort_field3`) values('1000000000007','运维操作员','运维','4','4','1',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
insert into `fort_role` (`fort_role_id`, `fort_role_name`, `fort_role_short_name`, `fort_role_type`, `fort_weight`, `fort_state`, `fort_create_date`, `fort_create_by`, `fort_last_edit_date`, `fort_last_edit_by`, `fort_field1`, `fort_field2`, `fort_field3`) values('1000000000008','审计查看审批管理员','审管','3','2','1',NULL,NULL,NULL,NULL,NULL,NULL,NULL);

-- ----------------------------
-- Records of fort_role_authorization_scope
-- ----------------------------

insert into `fort_role_authorization_scope` (`fort_role_authorization_scope_id`, `fort_role_id`, `fort_controllable_role_id`) values('1000000000001','1000000000001','1000000000002');
insert into `fort_role_authorization_scope` (`fort_role_authorization_scope_id`, `fort_role_id`, `fort_controllable_role_id`) values('1000000000002','1000000000001','1000000000003');
insert into `fort_role_authorization_scope` (`fort_role_authorization_scope_id`, `fort_role_id`, `fort_controllable_role_id`) values('1000000000003','1000000000002','1000000000002');
insert into `fort_role_authorization_scope` (`fort_role_authorization_scope_id`, `fort_role_id`, `fort_controllable_role_id`) values('1000000000004','1000000000002','1000000000003');
insert into `fort_role_authorization_scope` (`fort_role_authorization_scope_id`, `fort_role_id`, `fort_controllable_role_id`) values('1000000000005','1000000000002','1000000000005');
insert into `fort_role_authorization_scope` (`fort_role_authorization_scope_id`, `fort_role_id`, `fort_controllable_role_id`) values('1000000000006','1000000000005','1000000000004');
insert into `fort_role_authorization_scope` (`fort_role_authorization_scope_id`, `fort_role_id`, `fort_controllable_role_id`) values('1000000000007','1000000000005','1000000000005');
insert into `fort_role_authorization_scope` (`fort_role_authorization_scope_id`, `fort_role_id`, `fort_controllable_role_id`) values('1000000000008','1000000000005','1000000000006');
insert into `fort_role_authorization_scope` (`fort_role_authorization_scope_id`, `fort_role_id`, `fort_controllable_role_id`) values('1000000000009','1000000000005','1000000000007');
insert into `fort_role_authorization_scope` (`fort_role_authorization_scope_id`, `fort_role_id`, `fort_controllable_role_id`) values('1000000000010','1000000000005','1000000000008');
insert into `fort_role_authorization_scope` (`fort_role_authorization_scope_id`, `fort_role_id`, `fort_controllable_role_id`) values('1000000000011','1000000000005','1000000000009');

-- ----------------------------
-- Records of fort_role_privilege
-- ----------------------------

INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000001','1000000000001','1002000000000');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000002','1000000000001','1002020000000');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000003','1000000000001','1002020000001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000004','1000000000001','1002020000002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000005','1000000000001','1002020000003');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000006','1000000000001','1002020000008');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000007','1000000000001','1002020000009');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000008','1000000000001','1002020000010');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000009','1000000000001','1007000000000');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000010','1000000000001','1007010000000');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000011','1000000000001','1007010000001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000012','1000000000001','1007010000002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000013','1000000000001','1007010000003');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000014','1000000000001','1007020000000');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000015','1000000000001','1007020000001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000016','1000000000007','1001000000000');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000017','1000000000007','1001010000000');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000018','1000000000007','1001010000001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000019','1000000000007','1001010000002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000020','1000000000007','1001010000003');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000021','1000000000007','1001010000004');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000022','1000000000007','1001010000005');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000023','1000000000007','1001010000006');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000024','1000000000007','1001010000007');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000025','1000000000007','1001010000008');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000026','1000000000007','1001010000009');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000027','1000000000007','1001010000010');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000028','1000000000007','1001010000011');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000029','1000000000007','1001010000012');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000030','1000000000007','1004000000000');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000031','1000000000007','1004010000000');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000032','1000000000007','1004010000001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000033','1000000000007','1004010000002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000034','1000000000007','1004030000000');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000035','1000000000007','1004030000001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000036','1000000000007','1004030000002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000037','1000000000007','1004040000000');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000038','1000000000007','1004040000001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000039','1000000000007','1004040000002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000040','1000000000008','2000000000001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000041','1000000000007','1001010000013');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000053','1000000000001','1008000000000');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000042','1000000000001','1008110000000');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000043','1000000000001','1008110000001');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000044','1000000000001','1008110000002');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000045','1000000000001','1008110000003');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000046','1000000000001','1008110000004');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000047','1000000000001','1008110000005');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000048','1000000000001','1008110000006');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000049','1000000000001','1008110000007');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000050','1000000000001','1008110000008');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000051','1000000000001','1008110000009');
INSERT INTO `fort_role_privilege` (`fort_role_privilege_id`, `fort_role_id`, `fort_privilege_id`) VALUES('1000000000052','1000000000001','1008110000010');
-- ----------------------------
-- Records of fort_message_type
-- ----------------------------
insert  into `fort_message_type`(`fort_message_type_id`,`fort_message_type_name`,`fort_url`) VALUE('1000000000001','命令审批','command-approval');
insert  into `fort_message_type`(`fort_message_type_id`,`fort_message_type_name`,`fort_url`) VALUE('1000000000002','访问审批','superior-approval');
insert  into `fort_message_type`(`fort_message_type_id`,`fort_message_type_name`,`fort_url`) VALUE('1000000000003','访问审批结果','superior-approval-result');
insert  into `fort_message_type`(`fort_message_type_id`,`fort_message_type_name`,`fort_url`) VALUE('1000000000004','双人审批','double-approval');
insert  into `fort_message_type`(`fort_message_type_id`,`fort_message_type_name`,`fort_url`) VALUE('1000000000005','双人审批结果','double-approval-result');
insert  into `fort_message_type`(`fort_message_type_id`,`fort_message_type_name`,`fort_url`) VALUE('1000000000006','行为指引补充备注','behavior-guide-supplementary-note');
insert  into `fort_message_type`(`fort_message_type_id`,`fort_message_type_name`,`fort_url`) VALUE('1000000000007','访问审批(紧急)','superior-approval-quick');
-- ----------------------------
-- Records of fort_system_log_type
-- ----------------------------
insert  into `fort_system_log_type`(`fort_system_log_type_id`,`fort_system_log_type_name`) VALUES ('1000000000001', '登录认证');
insert  into `fort_system_log_type`(`fort_system_log_type_id`,`fort_system_log_type_name`) VALUES ('1000000000002', '内部操作');
insert  into `fort_system_log_type`(`fort_system_log_type_id`,`fort_system_log_type_name`) VALUES ('1000000000003', '配置变更');
insert  into `fort_system_log_type`(`fort_system_log_type_id`,`fort_system_log_type_name`) VALUES ('1000000000004', '计划任务');
-- ----------------------------
-- Records of fort_system_alarm_type
-- ----------------------------
insert into `fort_system_alarm_type` (`fort_system_alarm_type_id`, `fort_parent_id`, `fort_system_alarm_type_name`, `fort_alarm_level`, `fort_description`) values('1000000000100',NULL,'审计指引',NULL,NULL);
insert into `fort_system_alarm_type` (`fort_system_alarm_type_id`, `fort_parent_id`, `fort_system_alarm_type_name`, `fort_alarm_level`, `fort_description`) values('1000000000200',NULL,'高危运维(全局)',NULL,NULL);
insert into `fort_system_alarm_type` (`fort_system_alarm_type_id`, `fort_parent_id`, `fort_system_alarm_type_name`, `fort_alarm_level`, `fort_description`) values('1000000000300',NULL,'堡垒运行状态',NULL,NULL);
insert into `fort_system_alarm_type` (`fort_system_alarm_type_id`, `fort_parent_id`, `fort_system_alarm_type_name`, `fort_alarm_level`, `fort_description`) values('1000000000400',NULL,'认证异常',NULL,NULL);
insert into `fort_system_alarm_type` (`fort_system_alarm_type_id`, `fort_parent_id`, `fort_system_alarm_type_name`, `fort_alarm_level`, `fort_description`) values('1000000000500',NULL,'越权访问',NULL,NULL);
insert into `fort_system_alarm_type` (`fort_system_alarm_type_id`, `fort_parent_id`, `fort_system_alarm_type_name`, `fort_alarm_level`, `fort_description`) values('1000000000001','1000000000100','违反行为指引的行为',NULL,NULL);
insert into `fort_system_alarm_type` (`fort_system_alarm_type_id`, `fort_parent_id`, `fort_system_alarm_type_name`, `fort_alarm_level`, `fort_description`) values('1000000000002','1000000000200','执行非法命令',NULL,NULL);
insert into `fort_system_alarm_type` (`fort_system_alarm_type_id`, `fort_parent_id`, `fort_system_alarm_type_name`, `fort_alarm_level`, `fort_description`) values('1000000000003','1000000000200','非法图形操作',NULL,NULL);
insert into `fort_system_alarm_type` (`fort_system_alarm_type_id`, `fort_parent_id`, `fort_system_alarm_type_name`, `fort_alarm_level`, `fort_description`) values('1000000000004','1000000000200','操作高权重主机',NULL,NULL);
insert into `fort_system_alarm_type` (`fort_system_alarm_type_id`, `fort_parent_id`, `fort_system_alarm_type_name`, `fort_alarm_level`, `fort_description`) values('1000000000005','1000000000200','非堡垒运维行为',NULL,NULL);
insert into `fort_system_alarm_type` (`fort_system_alarm_type_id`, `fort_parent_id`, `fort_system_alarm_type_name`, `fort_alarm_level`, `fort_description`) values('1000000000006','1000000000200','上传、下载超大文件',NULL,NULL);
insert into `fort_system_alarm_type` (`fort_system_alarm_type_id`, `fort_parent_id`, `fort_system_alarm_type_name`, `fort_alarm_level`, `fort_description`) values('1000000000007','1000000000300','操作系统运行状态异常',NULL,NULL);
insert into `fort_system_alarm_type` (`fort_system_alarm_type_id`, `fort_parent_id`, `fort_system_alarm_type_name`, `fort_alarm_level`, `fort_description`) values('1000000000008','1000000000300','堡垒关键服务异常',NULL,NULL);
insert into `fort_system_alarm_type` (`fort_system_alarm_type_id`, `fort_parent_id`, `fort_system_alarm_type_name`, `fort_alarm_level`, `fort_description`) values('1000000000009','1000000000400','登录认证失败次数过多',NULL,NULL);
insert into `fort_system_alarm_type` (`fort_system_alarm_type_id`, `fort_parent_id`, `fort_system_alarm_type_name`, `fort_alarm_level`, `fort_description`) values('1000000000010','1000000000500','系统跨越URL权限提交',NULL,NULL);
insert into `fort_system_alarm_type` (`fort_system_alarm_type_id`, `fort_parent_id`, `fort_system_alarm_type_name`, `fort_alarm_level`, `fort_description`) values('1000000000011','1000000000300','CPU使用率超过阈值',NULL,NULL);
insert into `fort_system_alarm_type` (`fort_system_alarm_type_id`, `fort_parent_id`, `fort_system_alarm_type_name`, `fort_alarm_level`, `fort_description`) values('1000000000013','1000000000300','MEM使用率超过阈值',NULL,NULL);
insert into `fort_system_alarm_type` (`fort_system_alarm_type_id`, `fort_parent_id`, `fort_system_alarm_type_name`, `fort_alarm_level`, `fort_description`) values('1000000000012','1000000000300','DISK使用率超过阈值',NULL,NULL);
insert into `fort_system_alarm_type` (`fort_system_alarm_type_id`, `fort_parent_id`, `fort_system_alarm_type_name`, `fort_alarm_level`, `fort_description`) values('1000000000600',NULL,'紧急运维未批准',NULL,NULL);


INSERT INTO fort_department (fort_department_id, fort_department_name,fort_full_name,fort_parent_id,fort_order) VALUES('1000000000001','ROOT部门','ROOT部门',null,0);
INSERT INTO fort_department (fort_department_id, fort_department_name,fort_full_name,fort_parent_id,fort_order) VALUES('1000000000002','临时部门','ROOT部门 -> 临时部门','1000000000001',1);

INSERT INTO fort_user (fort_user_id, fort_department_id, fort_user_name,fort_user_password,fort_user_account,fort_user_state)VALUES('1000000000001','1000000000001','初始化用户','C4CA4238A0B923820DCC509A6F75849B','isomper',1);

INSERT INTO fort_user_role (fort_user_role_id, fort_user_id, fort_role_id) VALUES('1000000000001','1000000000001','1000000000001');

INSERT INTO fort_behavior_guideline_type (fort_behavior_guideline_type_id, fort_parent_id, fort_behavior_guideline_type_name,fort_behavior_guideline_type_full_name) VALUES('1000000000001',null,'LINUX','LINUX');
INSERT INTO fort_behavior_guideline_type (fort_behavior_guideline_type_id, fort_parent_id, fort_behavior_guideline_type_name,fort_behavior_guideline_type_full_name) VALUES('1000000000002',null,'网络设备','网络设备');

INSERT INTO fort_guideline_command_type (fort_guideline_command_type_id, fort_parent_id, fort_guideline_command_type_name) VALUES('1000000000001',null,'命令类型');

/**
 *  双人
 */
INSERT INTO fort_process(fort_process_id,fort_process_name,fort_process_code,fort_state,fort_valid_time,
fort_create_date,fort_create_by,
fort_last_edit_date,fort_last_edit_by) VALUES('1000000000001','双人授权','double_process','1',NULL,NULL,NULL,NULL,NULL);

   INSERT INTO fort_process_task(fort_process_task_id,fort_parent_id,fort_process_id,fort_process_task_name,fort_participant_type,
               fort_run_mode,fort_task_code,fort_concurrent_rule,
               fort_valid_time) VALUES ('1000000000001',NULL,'1000000000001','双人授权','1',NULL,NULL,'1',NULL);

  INSERT INTO fort_process(fort_process_id,fort_process_name,fort_process_code,fort_state,fort_valid_time,
            fort_create_date,fort_create_by,
            fort_last_edit_date,fort_last_edit_by) VALUES('1000000000002','命令审批','command_process','1',NULL,NULL,NULL,NULL,NULL);

 INSERT INTO fort_process_task(fort_process_task_id,fort_parent_id,fort_process_id,fort_process_task_name,fort_participant_type,
            fort_run_mode,fort_task_code,fort_concurrent_rule,
            fort_valid_time) VALUES ('1000000000002',NULL,'1000000000002','命令审批','1',NULL,NULL,'1',NULL);

 INSERT INTO fort_process(fort_process_id,fort_process_name,fort_process_code,fort_state,fort_valid_time,
                    fort_create_date,fort_create_by,
                    fort_last_edit_date,fort_last_edit_by) VALUES('1000000000003','审计审批','audit_process','1',NULL,NULL,NULL,NULL,NULL);

 INSERT INTO fort_process_task(fort_process_task_id,fort_parent_id,fort_process_id,fort_process_task_name,fort_participant_type,
                    fort_run_mode,fort_task_code,fort_concurrent_rule,
                    fort_valid_time) VALUES ('1000000000003',NULL,'1000000000003','审计审批','1',NULL,NULL,'1',NULL);


/*Quartz相关表*/
DROP TABLE IF EXISTS QRTZ_JOB_LISTENERS;
DROP TABLE IF EXISTS QRTZ_TRIGGER_LISTENERS;
DROP TABLE IF EXISTS QRTZ_FIRED_TRIGGERS;
DROP TABLE IF EXISTS QRTZ_PAUSED_TRIGGER_GRPS;
DROP TABLE IF EXISTS QRTZ_SCHEDULER_STATE;
DROP TABLE IF EXISTS QRTZ_LOCKS;
DROP TABLE IF EXISTS QRTZ_SIMPLE_TRIGGERS;
DROP TABLE IF EXISTS QRTZ_CRON_TRIGGERS;
DROP TABLE IF EXISTS QRTZ_BLOB_TRIGGERS;
DROP TABLE IF EXISTS QRTZ_TRIGGERS;
DROP TABLE IF EXISTS QRTZ_JOB_DETAILS;
DROP TABLE IF EXISTS QRTZ_CALENDARS;


CREATE TABLE QRTZ_JOB_DETAILS
  (
    JOB_NAME  VARCHAR(200) NOT NULL,
    JOB_GROUP VARCHAR(200) NOT NULL,
    DESCRIPTION VARCHAR(250) NULL,
    JOB_CLASS_NAME   VARCHAR(250) NOT NULL,
    IS_DURABLE VARCHAR(1) NOT NULL,
    IS_VOLATILE VARCHAR(1) NOT NULL,
    IS_STATEFUL VARCHAR(1) NOT NULL,
    REQUESTS_RECOVERY VARCHAR(1) NOT NULL,
    JOB_DATA BLOB NULL,
    PRIMARY KEY (JOB_NAME,JOB_GROUP)
);

CREATE TABLE QRTZ_JOB_LISTENERS
  (
    JOB_NAME  VARCHAR(200) NOT NULL,
    JOB_GROUP VARCHAR(200) NOT NULL,
    JOB_LISTENER VARCHAR(200) NOT NULL,
    PRIMARY KEY (JOB_NAME,JOB_GROUP,JOB_LISTENER),
    FOREIGN KEY (JOB_NAME,JOB_GROUP)
        REFERENCES QRTZ_JOB_DETAILS(JOB_NAME,JOB_GROUP)
);

CREATE TABLE QRTZ_TRIGGERS
  (
    TRIGGER_NAME VARCHAR(200) NOT NULL,
    TRIGGER_GROUP VARCHAR(200) NOT NULL,
    JOB_NAME  VARCHAR(200) NOT NULL,
    JOB_GROUP VARCHAR(200) NOT NULL,
    IS_VOLATILE VARCHAR(1) NOT NULL,
    DESCRIPTION VARCHAR(250) NULL,
    NEXT_FIRE_TIME BIGINT(13) NULL,
    PREV_FIRE_TIME BIGINT(13) NULL,
    PRIORITY INTEGER NULL,
    TRIGGER_STATE VARCHAR(16) NOT NULL,
    TRIGGER_TYPE VARCHAR(8) NOT NULL,
    START_TIME BIGINT(13) NOT NULL,
    END_TIME BIGINT(13) NULL,
    CALENDAR_NAME VARCHAR(200) NULL,
    MISFIRE_INSTR SMALLINT(2) NULL,
    JOB_DATA BLOB NULL,
    PRIMARY KEY (TRIGGER_NAME,TRIGGER_GROUP),
    FOREIGN KEY (JOB_NAME,JOB_GROUP)
        REFERENCES QRTZ_JOB_DETAILS(JOB_NAME,JOB_GROUP)
);

CREATE TABLE QRTZ_SIMPLE_TRIGGERS
  (
    TRIGGER_NAME VARCHAR(200) NOT NULL,
    TRIGGER_GROUP VARCHAR(200) NOT NULL,
    REPEAT_COUNT BIGINT(7) NOT NULL,
    REPEAT_INTERVAL BIGINT(12) NOT NULL,
    TIMES_TRIGGERED BIGINT(10) NOT NULL,
    PRIMARY KEY (TRIGGER_NAME,TRIGGER_GROUP),
    FOREIGN KEY (TRIGGER_NAME,TRIGGER_GROUP)
        REFERENCES QRTZ_TRIGGERS(TRIGGER_NAME,TRIGGER_GROUP)
);

CREATE TABLE QRTZ_CRON_TRIGGERS
  (
    TRIGGER_NAME VARCHAR(200) NOT NULL,
    TRIGGER_GROUP VARCHAR(200) NOT NULL,
    CRON_EXPRESSION VARCHAR(200) NOT NULL,
    TIME_ZONE_ID VARCHAR(80),
    PRIMARY KEY (TRIGGER_NAME,TRIGGER_GROUP),
    FOREIGN KEY (TRIGGER_NAME,TRIGGER_GROUP)
        REFERENCES QRTZ_TRIGGERS(TRIGGER_NAME,TRIGGER_GROUP)
);

CREATE TABLE QRTZ_BLOB_TRIGGERS
  (
    TRIGGER_NAME VARCHAR(200) NOT NULL,
    TRIGGER_GROUP VARCHAR(200) NOT NULL,
    BLOB_DATA BLOB NULL,
    PRIMARY KEY (TRIGGER_NAME,TRIGGER_GROUP),
    FOREIGN KEY (TRIGGER_NAME,TRIGGER_GROUP)
        REFERENCES QRTZ_TRIGGERS(TRIGGER_NAME,TRIGGER_GROUP)
);

CREATE TABLE QRTZ_TRIGGER_LISTENERS
  (
    TRIGGER_NAME  VARCHAR(200) NOT NULL,
    TRIGGER_GROUP VARCHAR(200) NOT NULL,
    TRIGGER_LISTENER VARCHAR(200) NOT NULL,
    PRIMARY KEY (TRIGGER_NAME,TRIGGER_GROUP,TRIGGER_LISTENER),
    FOREIGN KEY (TRIGGER_NAME,TRIGGER_GROUP)
        REFERENCES QRTZ_TRIGGERS(TRIGGER_NAME,TRIGGER_GROUP)
);


CREATE TABLE QRTZ_CALENDARS
  (
    CALENDAR_NAME  VARCHAR(200) NOT NULL,
    CALENDAR BLOB NOT NULL,
    PRIMARY KEY (CALENDAR_NAME)
);



CREATE TABLE QRTZ_PAUSED_TRIGGER_GRPS
  (
    TRIGGER_GROUP  VARCHAR(200) NOT NULL, 
    PRIMARY KEY (TRIGGER_GROUP)
);

CREATE TABLE QRTZ_FIRED_TRIGGERS
  (
    ENTRY_ID VARCHAR(95) NOT NULL,
    TRIGGER_NAME VARCHAR(200) NOT NULL,
    TRIGGER_GROUP VARCHAR(200) NOT NULL,
    IS_VOLATILE VARCHAR(1) NOT NULL,
    INSTANCE_NAME VARCHAR(200) NOT NULL,
    FIRED_TIME BIGINT(13) NOT NULL,
    PRIORITY INTEGER NOT NULL,
    STATE VARCHAR(16) NOT NULL,
    JOB_NAME VARCHAR(200) NULL,
    JOB_GROUP VARCHAR(200) NULL,
    IS_STATEFUL VARCHAR(1) NULL,
    REQUESTS_RECOVERY VARCHAR(1) NULL,
    PRIMARY KEY (ENTRY_ID)
);

CREATE TABLE QRTZ_SCHEDULER_STATE
  (
    INSTANCE_NAME VARCHAR(200) NOT NULL,
    LAST_CHECKIN_TIME BIGINT(13) NOT NULL,
    CHECKIN_INTERVAL BIGINT(13) NOT NULL,
    PRIMARY KEY (INSTANCE_NAME)
);

CREATE TABLE QRTZ_LOCKS
  (
    LOCK_NAME  VARCHAR(40) NOT NULL, 
    PRIMARY KEY (LOCK_NAME)
);

INSERT INTO QRTZ_LOCKS values('TRIGGER_ACCESS');
INSERT INTO QRTZ_LOCKS values('JOB_ACCESS');
INSERT INTO QRTZ_LOCKS values('CALENDAR_ACCESS');
INSERT INTO QRTZ_LOCKS values('STATE_ACCESS');
INSERT INTO QRTZ_LOCKS values('MISFIRE_ACCESS');

SET FOREIGN_KEY_CHECKS = 1; 
SET unique_checks=1;
commit;