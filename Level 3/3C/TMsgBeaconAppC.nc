#include <Timer.h>
#include "../../TimeSyncCommon.h"
#include "printf.h"

configuration TMsgBeaconAppC{}

implementation
{
	components TMsgBeaconC as App;

	components ActiveMessageC as AM;

	components LocalTimeMilliC;
	components MainC, LedsC;
	components SerialPrintfC,SerialStartC;

	components UserButtonC;
	components CC2420PacketC;
	components CC2420ActiveMessageC;

	components new TimerMilliC() as Timer1;
	components new TimerMilliC() as Timer2;
	components new TimerMilliC() as Timer3;
	components new TimerMilliC() as Timer4;


//components ends here
//----------------------------------------------------------------------------------------------------------------------------------------------------------------------

	App.CC2420Packet -> CC2420PacketC;
	App -> CC2420ActiveMessageC.CC2420Packet;
	App.Get -> UserButtonC;
	App.Notify -> UserButtonC;

	App.Boot -> MainC.Boot;
	App.AMControl -> AM;
	App.Packet -> AM;

	App.TSReceive -> AM.Receive[AM_TS_3C];
	App.DataReceive -> AM.Receive[AM_D_3C];
	App.TSReceive_Head -> AM.Receive[AM_TS_Head_3C];
	App.DataReceive_Head -> AM.Receive[AM_D_Head_3C];

	App.Send_1 -> AM.AMSend[AM_TS_30];
	App.Send_2 -> AM.AMSend[AM_TS_31];
	App.Send_3 -> AM.AMSend[AM_TS_32];
	App.Send_4 -> AM.AMSend[AM_TS_33];
	App.Send_5 -> AM.AMSend[AM_TS_34];
	App.Send_6 -> AM.AMSend[AM_TS_35];
	App.Send_7 -> AM.AMSend[AM_TS_36];
	App.Send_8 -> AM.AMSend[AM_TS_37];
	App.Send_9 -> AM.AMSend[AM_TS_38];
	App.Send_A -> AM.AMSend[AM_TS_39];
	App.Send_B -> AM.AMSend[AM_TS_3A];
	App.Send_C -> AM.AMSend[AM_TS_3B];
	App.Send_D -> AM.AMSend[AM_TS_3D];
	App.Send_E -> AM.AMSend[AM_TS_3E];

	App.Send_1_Data -> AM.AMSend[AM_D_30];
	App.Send_2_Data -> AM.AMSend[AM_D_31];
	App.Send_3_Data -> AM.AMSend[AM_D_32];
	App.Send_4_Data -> AM.AMSend[AM_D_33];
	App.Send_5_Data -> AM.AMSend[AM_D_34];
	App.Send_6_Data -> AM.AMSend[AM_D_35];
	App.Send_7_Data -> AM.AMSend[AM_D_36];
	App.Send_8_Data -> AM.AMSend[AM_D_37];
	App.Send_9_Data -> AM.AMSend[AM_D_38];
	App.Send_A_Data -> AM.AMSend[AM_D_39];
	App.Send_B_Data -> AM.AMSend[AM_D_3A];
	App.Send_C_Data -> AM.AMSend[AM_D_3B];
	App.Send_D_Data -> AM.AMSend[AM_D_3D];
	App.Send_E_Data -> AM.AMSend[AM_D_3E];

	App.Send_Super_0 -> AM.AMSend[AM_TS_Head_20];
	App.Send_Super_1 -> AM.AMSend[AM_TS_Head_21];
	App.Send_Super_2 -> AM.AMSend[AM_TS_Head_22];
	App.Send_Super_3 -> AM.AMSend[AM_TS_Head_23];
	App.Send_Super_4 -> AM.AMSend[AM_TS_Head_24];
	App.Send_Super_5 -> AM.AMSend[AM_TS_Head_25];
	App.Send_Super_6 -> AM.AMSend[AM_TS_Head_26];
	App.Send_Super_7 -> AM.AMSend[AM_TS_Head_27];
	App.Send_Super_8 -> AM.AMSend[AM_TS_Head_28];
	App.Send_Super_9 -> AM.AMSend[AM_TS_Head_29];
	App.Send_Super_A -> AM.AMSend[AM_TS_Head_2A];
	App.Send_Super_B -> AM.AMSend[AM_TS_Head_2B];
	App.Send_Super_C -> AM.AMSend[AM_TS_Head_2C];
	App.Send_Super_D -> AM.AMSend[AM_TS_Head_2D];
	App.Send_Super_E -> AM.AMSend[AM_TS_Head_2E];
	App.Send_Super_0_Data -> AM.AMSend[AM_D_Head_20];
	App.Send_Super_1_Data -> AM.AMSend[AM_D_Head_21];
	App.Send_Super_2_Data -> AM.AMSend[AM_D_Head_22];
	App.Send_Super_3_Data -> AM.AMSend[AM_D_Head_23];
	App.Send_Super_4_Data -> AM.AMSend[AM_D_Head_24];
	App.Send_Super_5_Data -> AM.AMSend[AM_D_Head_25];
	App.Send_Super_6_Data -> AM.AMSend[AM_D_Head_26];
	App.Send_Super_7_Data -> AM.AMSend[AM_D_Head_27];
	App.Send_Super_8_Data -> AM.AMSend[AM_D_Head_28];
	App.Send_Super_9_Data -> AM.AMSend[AM_D_Head_29];
	App.Send_Super_A_Data -> AM.AMSend[AM_D_Head_2A];
	App.Send_Super_B_Data -> AM.AMSend[AM_D_Head_2B];
	App.Send_Super_C_Data -> AM.AMSend[AM_D_Head_2C];
	App.Send_Super_D_Data -> AM.AMSend[AM_D_Head_2D];
	App.Send_Super_E_Data -> AM.AMSend[AM_D_Head_2E];

	/*
	App.Send_Sub_0 -> AM.AMSend[AM_TS_Head_30];
	App.Send_Sub_1 -> AM.AMSend[AM_TS_Head_31];
	App.Send_Sub_2 -> AM.AMSend[AM_TS_Head_32];
	App.Send_Sub_3 -> AM.AMSend[AM_TS_Head_33];
	App.Send_Sub_4 -> AM.AMSend[AM_TS_Head_34];
	App.Send_Sub_5 -> AM.AMSend[AM_TS_Head_35];
	App.Send_Sub_6 -> AM.AMSend[AM_TS_Head_36];
	App.Send_Sub_7 -> AM.AMSend[AM_TS_Head_37];
	App.Send_Sub_8 -> AM.AMSend[AM_TS_Head_38];
	App.Send_Sub_9 -> AM.AMSend[AM_TS_Head_39];
	App.Send_Sub_A -> AM.AMSend[AM_TS_Head_3A];
	App.Send_Sub_B -> AM.AMSend[AM_TS_Head_3B];
	App.Send_Sub_C -> AM.AMSend[AM_TS_Head_3C];
	App.Send_Sub_D -> AM.AMSend[AM_TS_Head_3D];
	App.Send_Sub_E -> AM.AMSend[AM_TS_Head_3E];
	*/

	App.Leds -> LedsC;

	App.LocalTime -> LocalTimeMilliC;

	App.Timer_ts -> Timer1;
	App.Timer_data -> Timer2;
	App.SleepTimer -> Timer3;
	App.Timer_ts_head -> Timer4;

}