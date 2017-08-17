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


//components ends here
//----------------------------------------------------------------------------------------------------------------------------------------------------------------------

	App.CC2420Packet -> CC2420PacketC;
	App -> CC2420ActiveMessageC.CC2420Packet;
	App.Get -> UserButtonC;
	App.Notify -> UserButtonC;

	App.Boot -> MainC.Boot;
	App.AMControl -> AM;
	App.Packet -> AM;

	App.TSReceive_Head -> AM.Receive[AM_TS_00];
	App.DataReceive_Head -> AM.Receive[AM_D_00];

	App.Send_Sub_0 -> AM.AMSend[AM_TS_Head_10];
	App.Send_Sub_1 -> AM.AMSend[AM_TS_Head_11];
	App.Send_Sub_2 -> AM.AMSend[AM_TS_Head_12];
	App.Send_Sub_3 -> AM.AMSend[AM_TS_Head_13];
	App.Send_Sub_4 -> AM.AMSend[AM_TS_Head_14];
	App.Send_Sub_5 -> AM.AMSend[AM_TS_Head_15];
	App.Send_Sub_6 -> AM.AMSend[AM_TS_Head_16];
	App.Send_Sub_7 -> AM.AMSend[AM_TS_Head_17];
	App.Send_Sub_8 -> AM.AMSend[AM_TS_Head_18];
	App.Send_Sub_9 -> AM.AMSend[AM_TS_Head_19];
	App.Send_Sub_A -> AM.AMSend[AM_TS_Head_1A];
	App.Send_Sub_B -> AM.AMSend[AM_TS_Head_1B];
	App.Send_Sub_C -> AM.AMSend[AM_TS_Head_1C];
	App.Send_Sub_D -> AM.AMSend[AM_TS_Head_1D];
	App.Send_Sub_E -> AM.AMSend[AM_TS_Head_1E];
	
	App.Leds -> LedsC;

	App.LocalTime -> LocalTimeMilliC;

	App.SleepTimer -> Timer1;
	App.Timer_ts_head -> Timer2;
}