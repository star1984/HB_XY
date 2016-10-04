USE HBI_LZ 
GO
--管路滑脱
truncate table T_Glht 
GO
truncate table MPEHR_hl..TSF_Glhtsb 
GO 
--用药错误及临界差错 
truncate table T_Gycc 
GO
truncate table MPEHR_HL..TSF_Gycc 
GO 
--输血反应 
truncate table T_Sxfy 
GO
truncate table MPEHR_HL..TSF_SxFy 
GO 
--投诉与纠纷（非卫生部上报版） 
truncate table T_Tsjf 
GO
truncate table MPEHR_HL..TSF_Tsjf
GO 
--饮食差错
truncate table T_Yscc 
GO
truncate table MPEHR_HL..TSF_Yscc 
GO 
--意外不良事件报告
truncate table T_Ywbl 
GO
truncate table MPEHR_HL..TSF_Blsjsb_ywblsjbg 
GO  
--用血错误 
truncate table T_Ywbl 
GO
truncate table MPEHR_HL..TSF_Yxcw 
GO  
--职业暴露 
truncate table T_Zysh 
GO
truncate table MPEHR_HL..TSF_Zybl
GO  


 