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

	App.TSReceive -> AM.Receive[AM_TS_1E];
	App.DataReceive -> AM.Receive[AM_D_1E];
	App.TSReceive_Head -> AM.Receive[AM_TS_Head_1E];
	App.DataReceive_Head -> AM.Receive[AM_D_Head_1E];

	App.Send_1 -> AM.AMSend[AM_TS_10];
	App.Send_2 -> AM.AMSend[AM_TS_11];
	App.Send_3 -> AM.AMSend[AM_TS_12];
	App.Send_4 -> AM.AMSend[AM_TS_13];
	App.Send_5 -> AM.AMSend[AM_TS_14];
	App.Send_6 -> AM.AMSend[AM_TS_15];
	App.Send_7 -> AM.AMSend[AM_TS_16];
	App.Send_8 -> AM.AMSend[AM_TS_17];
	App.Send_9 -> AM.AMSend[AM_TS_18];
	App.Send_A -> AM.AMSend[AM_TS_19];
	App.Send_B -> AM.AMSend[AM_TS_1A];
	App.Send_C -> AM.AMSend[AM_TS_1B];
	App.Send_D -> AM.AMSend[AM_TS_1C];
	App.Send_E -> AM.AMSend[AM_TS_1D];

	App.Send_1_Data -> AM.AMSend[AM_D_10];
	App.Send_2_Data -> AM.AMSend[AM_D_11];
	App.Send_3_Data -> AM.AMSend[AM_D_12];
	App.Send_4_Data -> AM.AMSend[AM_D_13];
	App.Send_5_Data -> AM.AMSend[AM_D_14];
	App.Send_6_Data -> AM.AMSend[AM_D_15];
	App.Send_7_Data -> AM.AMSend[AM_D_16];
	App.Send_8_Data -> AM.AMSend[AM_D_17];
	App.Send_9_Data -> AM.AMSend[AM_D_18];
	App.Send_A_Data -> AM.AMSend[AM_D_19];
	App.Send_B_Data -> AM.AMSend[AM_D_1A];
	App.Send_C_Data -> AM.AMSend[AM_D_1B];
	App.Send_D_Data -> AM.AMSend[AM_D_1C];
	App.Send_E_Data -> AM.AMSend[AM_D_1D];

	App.Send_Super -> AM.AMSend[AM_TS_00];
	App.Send_Super_Data -> AM.AMSend[AM_D_00];

	App.Send_Sub_0 -> AM.AMSend[AM_TS_Head_20];
	App.Send_Sub_1 -> AM.AMSend[AM_TS_Head_21];
	App.Send_Sub_2 -> AM.AMSend[AM_TS_Head_22];
	App.Send_Sub_3 -> AM.AMSend[AM_TS_Head_23];
	App.Send_Sub_4 -> AM.AMSend[AM_TS_Head_24];
	App.Send_Sub_5 -> AM.AMSend[AM_TS_Head_25];
	App.Send_Sub_6 -> AM.AMSend[AM_TS_Head_26];
	App.Send_Sub_7 -> AM.AMSend[AM_TS_Head_27];
	App.Send_Sub_8 -> AM.AMSend[AM_TS_Head_28];
	App.Send_Sub_9 -> AM.AMSend[AM_TS_Head_29];
	App.Send_Sub_A -> AM.AMSend[AM_TS_Head_2A];
	App.Send_Sub_B -> AM.AMSend[AM_TS_Head_2B];
	App.Send_Sub_C -> AM.AMSend[AM_TS_Head_2C];
	App.Send_Sub_D -> AM.AMSend[AM_TS_Head_2D];
	App.Send_Sub_E -> AM.AMSend[AM_TS_Head_2E];

	App.Leds -> LedsC;

	App.LocalTime -> LocalTimeMilliC;

	App.Timer_ts -> Timer1;
	App.Timer_data -> Timer2;
	App.SleepTimer -> Timer3;
	App.Timer_ts_head -> Timer4;

}