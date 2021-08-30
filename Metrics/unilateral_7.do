******************************************************************************************************
****************************************** REPLICATION DATA ******************************************
******************************************************************************************************
************************************ Searching for a Better Life *************************************
****************** Predicting International Migration with Online Search Keywords ********************
******************************************************************************************************
****************************                                        ******************************** 
******************************************************************************************************

log close _all
set more off
clear
set seed 123456


global ReplicationData "C:\Users\Kadyrbek Sultakeev\Desktop\Replication\ReplicationData"
global EXPORT "C:\Users\Kadyrbek Sultakeev\Desktop\Replication\EXPORT"


use "$ReplicationData\keywords_ext2.dta", clear

regress migration road_quality_destination railroad_quality_destination airtr_quality_destination electricity_quality_destination fixedtel_destination mobile_destination technology_destination internet_destination fxinternet_destination  railroad_origin airtr_origin  fexedtel_origin mobile_origin technology_origin internet_origin fxinternet_origin manuf_tradeflow_baci gatt_d


regress migration road_quality_destination railroad_quality_destination airtr_quality_destination electricity_quality_destination fixedtel_destination mobile_destination technology_destination internet_destination fxinternet_destination  railroad_origin airtr_origin  fexedtel_origin mobile_origin technology_origin internet_origin fxinternet_origin manuf_tradeflow_baci gatt_d  БишкекМосква поезд авиабилет работа жумуш квартира




exit