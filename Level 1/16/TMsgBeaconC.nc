#include "../../TimeSyncCommon.h"
#include <UserButton.h>
#include <Timer.h>
#include <printf.h>
#include <stdio.h>
#include "CC2420.h"
#include "AM.h"

module TMsgBeaconC @safe()
{
	uses
	{
		interface Leds;
		interface Boot;

		interface SplitControl as AMControl;
	    interface Packet;
	    interface LocalTime<TMilli>;
	    interface Get<button_state_t>;
	    interface Notify<button_state_t>;
	    interface CC2420Packet;

	    interface Receive as TSReceive;
	    interface Receive as DataReceive;
	    interface Receive as TSReceive_Head;
	    interface Receive as DataReceive_Head;

	    interface AMSend as Send_1;
	    interface AMSend as Send_2;
	    interface AMSend as Send_3;
	    interface AMSend as Send_4;
	    interface AMSend as Send_5;
	    interface AMSend as Send_6;
	    interface AMSend as Send_7;
	    interface AMSend as Send_8;
	    interface AMSend as Send_9;
	    interface AMSend as Send_A;
	    interface AMSend as Send_B;
	    interface AMSend as Send_C;
	    interface AMSend as Send_D;
	    interface AMSend as Send_E;

	    interface AMSend as Send_1_Data;
	    interface AMSend as Send_2_Data;
	    interface AMSend as Send_3_Data;
	    interface AMSend as Send_4_Data;
	    interface AMSend as Send_5_Data;
	    interface AMSend as Send_6_Data;
	    interface AMSend as Send_7_Data;
	    interface AMSend as Send_8_Data;
	    interface AMSend as Send_9_Data;
	    interface AMSend as Send_A_Data;
	    interface AMSend as Send_B_Data;
	    interface AMSend as Send_C_Data;
	    interface AMSend as Send_D_Data;
	    interface AMSend as Send_E_Data;

	    interface AMSend as Send_Super;
	    interface AMSend as Send_Super_Data;

	    interface AMSend as Send_Sub_0;
	    interface AMSend as Send_Sub_1;
	    interface AMSend as Send_Sub_2;
	    interface AMSend as Send_Sub_3;
	    interface AMSend as Send_Sub_4;
	    interface AMSend as Send_Sub_5;
	    interface AMSend as Send_Sub_6;
	    interface AMSend as Send_Sub_7;
	    interface AMSend as Send_Sub_8;
	    interface AMSend as Send_Sub_9;
	    interface AMSend as Send_Sub_A;
	    interface AMSend as Send_Sub_B;
	    interface AMSend as Send_Sub_C;
	    interface AMSend as Send_Sub_D;
	    interface AMSend as Send_Sub_E;

	    interface Timer<TMilli> as SleepTimer;
	    interface Timer<TMilli> as Timer_ts;
	    interface Timer<TMilli> as Timer_data;
	    interface Timer<TMilli> as Timer_ts_head;
	}
}

//module ends here
//---------------------------------------------------------------------------------------------------------------------------------------------------------------------

implementation
{
	uint8_t ID = 6;
	uint8_t LVL = 1;
	uint8_t head_ID;

	uint8_t length;

	ts_msg_t* rcm;
	ts_msg_head_t* rcm_head;

	//level-specific messages starts
	message_t pckt, dpckt, rpckt;
	data_t* data_msg;
	data_t_energy* data_msg_energy;
	data_t* data_in;
	data_t_energy* data_in_energy;
	ts_msg_t* msg;
	ts_msg_t* rmsg;
	//level-specific messages ends

	//super-level-specific messages starts
	message_t pckt_super, dpckt_super;
	data_head_t* data_msg_super;
	data_head_t_energy* data_msg_super_energy;
	data_head_t_energy* rcm_head_energy;
	ts_msg_head_t* msg_super;
	ts_msg_head_t* rmsg_super;
	//super-level-specific messages ends

	//sub-level-specific messages starts
	message_t pckt_sub, rpckt_sub, dpckt_sub;
	data_head_t* data_msg_sub;
	data_head_t* data_in_sub;
	ts_msg_head_t* msg_sub;
	ts_msg_head_t* rmsg_sub;
	//sub-level-specific messages ends

	//non-head stuff starts
	message_t tpckt;
	ts_msg_t* tmsg;
	ts_msg_t* bmsg;

	uint32_t AC_offset, AC_slope, AB_slope_int, AB_offset_int;
	float skewfloat, offsetfloat,AC_slope_float, AC_offset_float, AB_slope, AB_offset;
	int data = 0, counter = 0;
	//non-head stuff ends

	uint32_t A1, A2, A3, A4, B1, B2, B3, B4, C1;
	uint32_t skew, offset;
	int cycle_count = 0 ;								//initial states
	long int cyclesleep2 = 900000;						//sleep timings
	long int timings = 10;							//delay timing
	long int timings2 = 50;
	long int datatimings = 1600;
	long int normal_wait_time = 10;
	long int back_off_case = 0;
	long int wait_time_3 = 50000;
	long int wait_time_1 = 100000;
	long int wait_time_2 = 40000;
	long int wait_time_4 = 10000;
	int back_off = 2; 			

	
	int send = 0;
	
	uint8_t current = 1;
	uint8_t phase = 0;
	uint8_t nodes = 9;
	int head = 1;
	uint16_t new_node;
	uint8_t sub_head = 2*16 + 0;
	uint8_t super_head = 0;
	uint8_t new_sub_head = 2*16+0;
	
//Energy_cal_variables : 

	float voltage = 3 ;

	float ival_send = 9.2;
	float ival_send_head = 15.2;
	float ival_rec = 19.7 ;
	
	float energy_dim = 0;
	float energy_send = 0;
	float energy_rec = 0;
	
	int data_rate = 20000;

	int send_count_ts = 0;
	int send_count_ts_head = 0;
	int send_count_data = 0;
	int send_count_data_head = 0;
	
	int recv_count_ts = 0;
	int recv_count_ts_head = 0;
	int recv_count_data = 0;
	int recv_count_data_head = 0;

	int ps_ts = 29;
	int ps_ts_head = 27 ;
	int ps_data = 23;			//will be 27 in cases where you would be sending the energy value
	int ps_data_head = 23;		//will be 24 in cases where you would be sending the next cluster head id

	int recv_count, send_count;
	int total_recv_count, total_send_count;	
	int int_dim, int_send, int_recv;
	int total_int_dim, total_int_send, total_int_recv;

	int min_energy = 30000;
	uint8_t new_head = 2*16 + 0;

	int send_cycle = 5;

	int ts_duration = 120;

	int cycles = 0;

	uint8_t inc_val = 0;



//------------------------------------------------------------------------------------------------------------------------------------------------------------------
//functions start here

	event void Boot.booted()
	{
		call Notify.enable();
		call AMControl.start();
	}

	event void AMControl.startDone(error_t err)
	{
		if (err == SUCCESS)
		{	
	  		head = 0;
	  		current = 1;
	  		phase = 0;
			cycle_count++;

//for resetting energy_cal_counters
			send_count_ts = 0;
			send_count_ts_head = 0;
			send_count_data = 0;
			send_count_data_head = 0;
			
			recv_count_ts = 0;
			recv_count_ts_head = 0;
			recv_count_data = 0;
			recv_count_data_head = 0;

			//call Timer_ts_head.startPeriodic(1000);

			//---------------------------------------------------
			int_send = 0;
			int_recv = 0;
			int_recv = 0;
			send_count = 0;
			recv_count = 0;
			//---------------------------------------------------
		}
		else
		{
			call AMControl.start();
		}
	}

	event void Notify.notify( button_state_t state )
	{
		//comes into play only if  user_button is pressed
 	}

 	 event void AMControl.stopDone(error_t err) 
	{
    	//do nothing
  	}

  	void sleep(long int period)
  	{
  		if(cycles == 1)
  		{
  			cycles--;
  		}
  		else
  		{
  			sub_head = new_sub_head;
  		}
  		head = 0;
  		current = 1;
  		phase = 0;

  		int_send = (int)(1000*energy_send);
  		int_recv = (int)(1000*energy_rec);
  		int_dim = (int)(1000*energy_dim);
  		send_count = send_count_ts + send_count_data + send_count_ts_head + send_count_data_head;
  		recv_count = recv_count_ts + recv_count_data + recv_count_ts_head + recv_count_data_head;

  		total_send_count += send_count;
  		total_recv_count += recv_count;
  		total_int_send += int_send;
  		total_int_recv += int_recv;
  		total_int_dim += int_dim;

  		call AMControl.stop();
  		call SleepTimer.startPeriodic(period);
  	}

	event void SleepTimer.fired()
  	{
  		call AMControl.start();
  	}

  	void energy_cal()
  	{

//Energy_send_cal :

		energy_send = (8 * voltage / data_rate ) * ((send_count_ts*ps_ts*ival_send)+(send_count_ts_head*ps_ts_head*ival_send_head));
		if (head == 0)
		{
			energy_send += (8 * voltage / data_rate ) * (ps_data*ival_send) ;	
		}
		else
		{
			energy_send += (8 * voltage / data_rate ) * (ps_data_head*ival_send_head) ; 		

		}
//Energy_rec_cal :
		energy_rec =  (8 * voltage * ival_rec / data_rate) * ((recv_count_ts*ps_ts)+(recv_count_ts_head*ps_ts_head)+(recv_count_data*ps_data)+(recv_count_data_head*ps_data_head)) ; 		;		

		energy_dim += energy_rec + energy_send;
  	}


//------------------------------------------------------------------------------------------------------------------------------------------------------------------
//timers start

	event void Timer_ts.fired()
	{
		call Timer_ts.stop();

		send_count_ts++;

		if(phase == 0 && head == 1)
		{

			A4 = call LocalTime.get();
			msg = (ts_msg_t*)call Packet.getPayload(&pckt, sizeof(ts_msg_t));
			msg -> src = LVL*16 + ID;
			msg -> local_time = call LocalTime.get();
			msg -> recv_time = call LocalTime.get();
			msg -> msg_num = 1;
			msg -> current = current;
			msg -> dst = LVL*16 + current;
			msg -> new_sub_head = new_sub_head;
			msg -> nodes = nodes;

			if(current == 1)
			{
				call Send_1.send(AM_BROADCAST_ADDR, &pckt, sizeof(ts_msg_t));
			}
			else if(current == 2)
			{
				call Send_2.send(AM_BROADCAST_ADDR, &pckt, sizeof(ts_msg_t));
			}
			else if(current == 3)
			{
				call Send_3.send(AM_BROADCAST_ADDR, &pckt, sizeof(ts_msg_t));
			}
			else if(current == 4)
			{
				call Send_4.send(AM_BROADCAST_ADDR, &pckt, sizeof(ts_msg_t));
			}
			else if(current == 5)
			{
				call Send_5.send(AM_BROADCAST_ADDR, &pckt, sizeof(ts_msg_t));
			}
			else if(current == 6)
			{
				call Send_6.send(AM_BROADCAST_ADDR, &pckt, sizeof(ts_msg_t));
			}
			else if(current == 7)
			{
				call Send_7.send(AM_BROADCAST_ADDR, &pckt, sizeof(ts_msg_t));
			}
			else if(current == 8)
			{
				call Send_8.send(AM_BROADCAST_ADDR, &pckt, sizeof(ts_msg_t));
			}
			else if(current == 9)
			{
				call Send_9.send(AM_BROADCAST_ADDR, &pckt, sizeof(ts_msg_t));
			}
			else if(current == 10)
			{
				call Send_A.send(AM_BROADCAST_ADDR, &pckt, sizeof(ts_msg_t));
			}
			else if(current == 11)
			{
				call Send_B.send(AM_BROADCAST_ADDR, &pckt, sizeof(ts_msg_t));
			}
			else if(current == 12)
			{
				call Send_C.send(AM_BROADCAST_ADDR, &pckt, sizeof(ts_msg_t));
			}
			else if(current == 13)
			{
				call Send_D.send(AM_BROADCAST_ADDR, &pckt, sizeof(ts_msg_t));
			}
			else if(current == 14)
			{
				call Send_E.send(AM_BROADCAST_ADDR, &pckt, sizeof(ts_msg_t));
			}

			call Timer_ts.startPeriodic(timings2);
			return;
		}

		else if(phase == 1 && head == 0)
		{
			B2 = call LocalTime.get();
			tmsg -> local_time = B2;

			if(head_ID == ((LVL)*16+0))
			{
				//call Send_0.send(AM_BROADCAST_ADDR, &tpckt, sizeof(ts_msg_t));
				call Send_1.send(AM_BROADCAST_ADDR, &tpckt, sizeof(ts_msg_t));
			}
			else if(head_ID == ((LVL)*16+1))
			{
				call Send_2.send(AM_BROADCAST_ADDR, &tpckt, sizeof(ts_msg_t));
			}
			else if(head_ID == ((LVL)*16+2))
			{
				call Send_3.send(AM_BROADCAST_ADDR, &tpckt, sizeof(ts_msg_t));
			}
			else if(head_ID == ((LVL)*16+3))
			{
				call Send_4.send(AM_BROADCAST_ADDR, &tpckt, sizeof(ts_msg_t));
			}
			else if(head_ID == ((LVL)*16+4))
			{
				call Send_5.send(AM_BROADCAST_ADDR, &tpckt, sizeof(ts_msg_t));
			}
			else if(head_ID == ((LVL)*16+5))
			{
				call Send_6.send(AM_BROADCAST_ADDR, &tpckt, sizeof(ts_msg_t));
			}
			else if(head_ID == ((LVL)*16+6))
			{
			}
			else if(head_ID == ((LVL)*16+7))
			{
				call Send_7.send(AM_BROADCAST_ADDR, &tpckt, sizeof(ts_msg_t));
			}
			else if(head_ID == ((LVL)*16+8))
			{
				call Send_8.send(AM_BROADCAST_ADDR, &tpckt, sizeof(ts_msg_t));
			}
			else if(head_ID == ((LVL)*16+9))
			{
				call Send_9.send(AM_BROADCAST_ADDR, &tpckt, sizeof(ts_msg_t));
			}
			else if(head_ID == ((LVL)*16+10))
			{
				call Send_A.send(AM_BROADCAST_ADDR, &tpckt, sizeof(ts_msg_t));
			}
			else if(head_ID == ((LVL)*16+11))
			{
				call Send_B.send(AM_BROADCAST_ADDR, &tpckt, sizeof(ts_msg_t));
			}
			else if(head_ID == ((LVL)*16+12))
			{
				call Send_C.send(AM_BROADCAST_ADDR, &tpckt, sizeof(ts_msg_t));
			}
			else if(head_ID == ((LVL)*16+13))
			{
				call Send_D.send(AM_BROADCAST_ADDR, &tpckt, sizeof(ts_msg_t));
			}
			else if(head_ID == ((LVL)*16+14))
			{
				call Send_E.send(AM_BROADCAST_ADDR, &tpckt, sizeof(ts_msg_t));
			}

			return;
		}

		else if(phase == 2 && head == 1)
		{
			rmsg -> local_time = call LocalTime.get();

			if(current == 1)
			{
				call Send_1.send(AM_BROADCAST_ADDR, &rpckt, sizeof(ts_msg_t));
			}
			else if(current == 2)
			{
				call Send_2.send(AM_BROADCAST_ADDR, &rpckt, sizeof(ts_msg_t));
			}
			else if(current == 3)
			{
				call Send_3.send(AM_BROADCAST_ADDR, &rpckt, sizeof(ts_msg_t));
			}
			else if(current == 4)
			{
				call Send_4.send(AM_BROADCAST_ADDR, &rpckt, sizeof(ts_msg_t));
			}
			else if(current == 5)
			{
				call Send_5.send(AM_BROADCAST_ADDR, &rpckt, sizeof(ts_msg_t));
			}
			else if(current == 6)
			{
				call Send_6.send(AM_BROADCAST_ADDR, &rpckt, sizeof(ts_msg_t));
			}
			else if(current == 7)
			{
				call Send_7.send(AM_BROADCAST_ADDR, &rpckt, sizeof(ts_msg_t));
			}
			else if(current == 8)
			{
				call Send_8.send(AM_BROADCAST_ADDR, &rpckt, sizeof(ts_msg_t));
			}
			else if(current == 9)
			{
				call Send_9.send(AM_BROADCAST_ADDR, &rpckt, sizeof(ts_msg_t));
			}
			else if(current == 10)
			{
				call Send_A.send(AM_BROADCAST_ADDR, &rpckt, sizeof(ts_msg_t));
			}
			else if(current == 11)
			{
				call Send_B.send(AM_BROADCAST_ADDR, &rpckt, sizeof(ts_msg_t));
			}
			else if(current == 12)
			{
				call Send_C.send(AM_BROADCAST_ADDR, &rpckt, sizeof(ts_msg_t));
			}
			else if(current == 13)
			{
				call Send_D.send(AM_BROADCAST_ADDR, &rpckt, sizeof(ts_msg_t));
			}
			else if(current == 14)
			{
				call Send_E.send(AM_BROADCAST_ADDR, &rpckt, sizeof(ts_msg_t));
			}

			call Timer_ts.startPeriodic(timings2);
			return;
		}

		else if(phase == 3 && head == 0)
		{
			if(head_ID == ((LVL)*16+0))
			{
				//call Send_0.send(AM_BROADCAST_ADDR, &tpckt, sizeof(ts_msg_t));
				call Send_1.send(AM_BROADCAST_ADDR, &tpckt, sizeof(ts_msg_t));
			}
			else if(head_ID == ((LVL)*16+1))
			{
				call Send_2.send(AM_BROADCAST_ADDR, &tpckt, sizeof(ts_msg_t));
			}
			else if(head_ID == ((LVL)*16+2))
			{
				call Send_3.send(AM_BROADCAST_ADDR, &tpckt, sizeof(ts_msg_t));
			}
			else if(head_ID == ((LVL)*16+3))
			{
				call Send_4.send(AM_BROADCAST_ADDR, &tpckt, sizeof(ts_msg_t));
			}
			else if(head_ID == ((LVL)*16+4))
			{
				call Send_5.send(AM_BROADCAST_ADDR, &tpckt, sizeof(ts_msg_t));
			}
			else if(head_ID == ((LVL)*16+5))
			{
				call Send_6.send(AM_BROADCAST_ADDR, &tpckt, sizeof(ts_msg_t));
			}
			else if(head_ID == ((LVL)*16+6))
			{
			}
			else if(head_ID == ((LVL)*16+7))
			{
				call Send_7.send(AM_BROADCAST_ADDR, &tpckt, sizeof(ts_msg_t));
			}
			else if(head_ID == ((LVL)*16+8))
			{
				call Send_8.send(AM_BROADCAST_ADDR, &tpckt, sizeof(ts_msg_t));
			}
			else if(head_ID == ((LVL)*16+9))
			{
				call Send_9.send(AM_BROADCAST_ADDR, &tpckt, sizeof(ts_msg_t));
			}
			else if(head_ID == ((LVL)*16+10))
			{
				call Send_A.send(AM_BROADCAST_ADDR, &tpckt, sizeof(ts_msg_t));
			}
			else if(head_ID == ((LVL)*16+11))
			{
				call Send_B.send(AM_BROADCAST_ADDR, &tpckt, sizeof(ts_msg_t));
			}
			else if(head_ID == ((LVL)*16+12))
			{
				call Send_C.send(AM_BROADCAST_ADDR, &tpckt, sizeof(ts_msg_t));
			}
			else if(head_ID == ((LVL)*16+13))
			{
				call Send_D.send(AM_BROADCAST_ADDR, &tpckt, sizeof(ts_msg_t));
			}
			else if(head_ID == ((LVL)*16+14))
			{
				call Send_E.send(AM_BROADCAST_ADDR, &tpckt, sizeof(ts_msg_t));
			}

			call Timer_data.startPeriodic(datatimings);

			return;
		}


	}

	event void Timer_ts_head.fired()
	{
		call Timer_ts_head.stop();

		send_count_ts_head++;

		if(phase == 1)
		{
			B2 = call LocalTime.get();
			msg_super -> local_time = B2;
			call CC2420Packet.setPower(&pckt_super, 23);
			call Send_Super.send(AM_BROADCAST_ADDR, &pckt_super, sizeof(ts_msg_head_t));

			return;
		}

		else if(phase == 2)
		{
			rmsg_sub -> local_time = call LocalTime.get();
			call CC2420Packet.setPower(&rpckt_sub, 23);

			if(sub_head == ((LVL+1)*16+0))
			{
				call Send_Sub_0.send(AM_BROADCAST_ADDR, &rpckt_sub, sizeof(ts_msg_head_t));
			}
			else if(sub_head == ((LVL+1)*16+1))
			{
				call Send_Sub_1.send(AM_BROADCAST_ADDR, &rpckt_sub, sizeof(ts_msg_head_t));
			}
			else if(sub_head == ((LVL+1)*16+2))
			{
				call Send_Sub_2.send(AM_BROADCAST_ADDR, &rpckt_sub, sizeof(ts_msg_head_t));
			}
			else if(sub_head == ((LVL+1)*16+3))
			{
				call Send_Sub_3.send(AM_BROADCAST_ADDR, &rpckt_sub, sizeof(ts_msg_head_t));
			}
			else if(sub_head == ((LVL+1)*16+4))
			{
				call Send_Sub_4.send(AM_BROADCAST_ADDR, &rpckt_sub, sizeof(ts_msg_head_t));
			}
			else if(sub_head == ((LVL+1)*16+5))
			{
				call Send_Sub_5.send(AM_BROADCAST_ADDR, &rpckt_sub, sizeof(ts_msg_head_t));
			}
			else if(sub_head == ((LVL+1)*16+6))
			{
				call Send_Sub_6.send(AM_BROADCAST_ADDR, &rpckt_sub, sizeof(ts_msg_head_t));
			}
			else if(sub_head == ((LVL+1)*16+7))
			{
				call Send_Sub_7.send(AM_BROADCAST_ADDR, &rpckt_sub, sizeof(ts_msg_head_t));
			}
			else if(sub_head == ((LVL+1)*16+8))
			{
				call Send_Sub_8.send(AM_BROADCAST_ADDR, &rpckt_sub, sizeof(ts_msg_head_t));
			}
			else if(sub_head == ((LVL+1)*16+9))
			{
				call Send_Sub_9.send(AM_BROADCAST_ADDR, &rpckt_sub, sizeof(ts_msg_head_t));
			}
			else if(sub_head == ((LVL+1)*16+10))
			{
				call Send_Sub_A.send(AM_BROADCAST_ADDR, &rpckt_sub, sizeof(ts_msg_head_t));
			}
			else if(sub_head == ((LVL+1)*16+11))
			{
				call Send_Sub_B.send(AM_BROADCAST_ADDR, &rpckt_sub, sizeof(ts_msg_head_t));
			}
			else if(sub_head == ((LVL+1)*16+12))
			{
				call Send_Sub_C.send(AM_BROADCAST_ADDR, &rpckt_sub, sizeof(ts_msg_head_t));
			}
			else if(sub_head == ((LVL+1)*16+13))
			{
				call Send_Sub_D.send(AM_BROADCAST_ADDR, &rpckt_sub, sizeof(ts_msg_head_t));
			}
			else if(sub_head == ((LVL+1)*16+14))
			{
				call Send_Sub_E.send(AM_BROADCAST_ADDR, &rpckt_sub, sizeof(ts_msg_head_t));
			}

			call Timer_ts_head.startPeriodic(timings2);

			return;
		}

		else if(phase == 3)
		{
			call CC2420Packet.setPower(&pckt_super, 23);
			call Send_Super.send(AM_BROADCAST_ADDR, &pckt_super, sizeof(ts_msg_head_t));

			phase = 0;

			call Timer_ts_head.startPeriodic(timings);

			return;
		}

		else if(phase == 0)
		{
			msg_sub = (ts_msg_head_t*)call Packet.getPayload(&pckt_sub, sizeof(ts_msg_head_t));
			msg_sub -> recv_time = call LocalTime.get();
			msg_sub -> local_time = call LocalTime.get();
			msg_sub -> new_node = new_node;
			msg_sub -> msg_num = 1;
			msg_sub -> dst = sub_head;
			msg_sub -> src = LVL*16 + ID;
			call CC2420Packet.setPower(&pckt_sub, 23);

			
			if(sub_head == ((LVL+1)*16+0))
			{
				call Send_Sub_0.send(AM_BROADCAST_ADDR, &pckt_sub, sizeof(ts_msg_head_t));
			}
			else if(sub_head == ((LVL+1)*16+1))
			{
				call Send_Sub_1.send(AM_BROADCAST_ADDR, &pckt_sub, sizeof(ts_msg_head_t));
			}
			else if(sub_head == ((LVL+1)*16+2))
			{
				call Send_Sub_2.send(AM_BROADCAST_ADDR, &pckt_sub, sizeof(ts_msg_head_t));
			}
			else if(sub_head == ((LVL+1)*16+3))
			{
				call Send_Sub_3.send(AM_BROADCAST_ADDR, &pckt_sub, sizeof(ts_msg_head_t));
			}
			else if(sub_head == ((LVL+1)*16+4))
			{
				call Send_Sub_4.send(AM_BROADCAST_ADDR, &pckt_sub, sizeof(ts_msg_head_t));
			}
			else if(sub_head == ((LVL+1)*16+5))
			{
				call Send_Sub_5.send(AM_BROADCAST_ADDR, &pckt_sub, sizeof(ts_msg_head_t));
			}
			else if(sub_head == ((LVL+1)*16+6))
			{
				call Send_Sub_6.send(AM_BROADCAST_ADDR, &pckt_sub, sizeof(ts_msg_head_t));
			}
			else if(sub_head == ((LVL+1)*16+7))
			{
				call Send_Sub_7.send(AM_BROADCAST_ADDR, &pckt_sub, sizeof(ts_msg_head_t));
			}
			else if(sub_head == ((LVL+1)*16+8))
			{
				call Send_Sub_8.send(AM_BROADCAST_ADDR, &pckt_sub, sizeof(ts_msg_head_t));
			}
			else if(sub_head == ((LVL+1)*16+9))
			{
				call Send_Sub_9.send(AM_BROADCAST_ADDR, &pckt_sub, sizeof(ts_msg_head_t));
			}
			else if(sub_head == ((LVL+1)*16+10))
			{
				call Send_Sub_A.send(AM_BROADCAST_ADDR, &pckt_sub, sizeof(ts_msg_head_t));
			}
			else if(sub_head == ((LVL+1)*16+11))
			{
				call Send_Sub_B.send(AM_BROADCAST_ADDR, &pckt_sub, sizeof(ts_msg_head_t));
			}
			else if(sub_head == ((LVL+1)*16+12))
			{
				call Send_Sub_C.send(AM_BROADCAST_ADDR, &pckt_sub, sizeof(ts_msg_head_t));
			}
			else if(sub_head == ((LVL+1)*16+13))
			{
				call Send_Sub_D.send(AM_BROADCAST_ADDR, &pckt_sub, sizeof(ts_msg_head_t));
			}
			else if(sub_head == ((LVL+1)*16+14))
			{
				call Send_Sub_E.send(AM_BROADCAST_ADDR, &pckt_sub, sizeof(ts_msg_head_t));
			}

			call Timer_ts_head.startPeriodic(timings2);

			return;
		}
	}
	

	event void Timer_data.fired()
	{
		call Timer_data.stop();

		energy_cal();

		if(head == 0)
		{
			send_count_data++;

			if(cycle_count % send_cycle != 0)
			{
				length = sizeof(data_t);
				data_msg = (data_t*)call Packet.getPayload(&dpckt, length);
				
				data_msg -> timestamp = call LocalTime.get();
				data_msg -> src = LVL*16 + ID;
				data_msg -> dst = head_ID;
				data_msg -> data = (uint32_t) head_ID;
			}
			else
			{
				length = sizeof(data_t_energy);
				data_msg_energy = (data_t_energy*)call Packet.getPayload(&dpckt, length);

				energy_dim += 4 * 8 * ival_send * voltage / data_rate;

				data_msg_energy -> timestamp = call LocalTime.get();
				data_msg_energy -> src = LVL*16 + ID;
				data_msg_energy -> dst = head_ID;
				data_msg_energy -> data = (uint32_t) head_ID;
				data_msg_energy -> energy_dim = energy_dim;

				// energy_dim = 

			}

			if(head_ID == ((LVL)*16+0))
			{
				//call Send_0_Data.send(AM_BROADCAST_ADDR, &dpckt, length);
				call Send_1_Data.send(AM_BROADCAST_ADDR, &dpckt, length);
			}
			else if(head_ID == ((LVL)*16+1))
			{
				call Send_2_Data.send(AM_BROADCAST_ADDR, &dpckt, length);
			}
			else if(head_ID == ((LVL)*16+2))
			{
				call Send_3_Data.send(AM_BROADCAST_ADDR, &dpckt, length);
			}
			else if(head_ID == ((LVL)*16+3))
			{
				call Send_4_Data.send(AM_BROADCAST_ADDR, &dpckt, length);
			}
			else if(head_ID == ((LVL)*16+4))
			{
				call Send_5_Data.send(AM_BROADCAST_ADDR, &dpckt, length);
			}
			else if(head_ID == ((LVL)*16+5))
			{
				call Send_6_Data.send(AM_BROADCAST_ADDR, &dpckt, length);
			}
			else if(head_ID == ((LVL)*16+6))
			{
			}
			else if(head_ID == ((LVL)*16+7))
			{
				call Send_7_Data.send(AM_BROADCAST_ADDR, &dpckt, length);
			}
			else if(head_ID == ((LVL)*16+8))
			{
				call Send_8_Data.send(AM_BROADCAST_ADDR, &dpckt, length);
			}
			else if(head_ID == ((LVL)*16+9))
			{
				call Send_9_Data.send(AM_BROADCAST_ADDR, &dpckt, length);
			}
			else if(head_ID == ((LVL)*16+10))
			{
				call Send_A_Data.send(AM_BROADCAST_ADDR, &dpckt, length);
			}
			else if(head_ID == ((LVL)*16+11))
			{
				call Send_B_Data.send(AM_BROADCAST_ADDR, &dpckt, length);
			}
			else if(head_ID == ((LVL)*16+12))
			{
				call Send_C_Data.send(AM_BROADCAST_ADDR, &dpckt, length);
			}
			else if(head_ID == ((LVL)*16+13))
			{
				call Send_D_Data.send(AM_BROADCAST_ADDR, &dpckt, length);
			}
			else if(head_ID == ((LVL)*16+14))
			{
				call Send_E_Data.send(AM_BROADCAST_ADDR, &dpckt, length);
			}

			sleep(cyclesleep2);
			return;
		}

		else
		{
			send_count_data_head++;

			if(cycle_count % send_cycle != 0)
			{
				length = sizeof(data_head_t);
				data_msg_super = (data_head_t*)call Packet.getPayload(&dpckt_super, length);
				data_msg_super -> timestamp = call LocalTime.get();
				data_msg_super -> src = LVL*16 + ID;
				data_msg_super -> dst = super_head;
				data_msg_super -> data = (uint32_t) super_head;
			}
			else
			{
				length = sizeof(data_head_t_energy);
				data_msg_super_energy = (data_head_t_energy*)call Packet.getPayload(&dpckt_super, length);
				data_msg_super_energy -> timestamp = call LocalTime.get();
				data_msg_super_energy -> src = LVL*16 + ID;
				data_msg_super_energy -> dst = super_head;
				data_msg_super_energy -> data = (uint32_t) super_head;

				data_msg_super_energy -> new_head = new_head;

				energy_dim += 8 * voltage * ival_send_head / data_rate ;

			}
			call CC2420Packet.setPower(&dpckt_super, 23);
			call Send_Super_Data.send(AM_BROADCAST_ADDR, &dpckt_super, length);
			
			back_off_case = 0;
			sleep(cyclesleep2);

			return;
		}	
	}

//timers end
//------------------------------------------------------------------------------------------------------------------------------------------------------------------
//receives start

	event message_t* TSReceive.receive(message_t* bufPtr, void* payload, uint8_t len)
	{
		recv_count_ts++;
		send = 0;
		call Timer_ts.stop();

		rcm = (ts_msg_t*) payload;

		phase = rcm -> msg_num; 

		if(phase == 2)
		{
			B2 = call LocalTime.get();
			rmsg = (ts_msg_t*)call Packet.getPayload(&rpckt, sizeof(ts_msg_t));
			rmsg -> recv_time = B2;
			rmsg -> src = LVL*16 + ID;
			rmsg -> dst = rcm -> src;
			rmsg -> current = current;
			rmsg -> msg_num = 3;
			call Timer_ts.startPeriodic(timings);
		}

		else if(phase == 4 && current < nodes)
		{
			B4 = call LocalTime.get();
			C1 = B4 - A4;

			current++;
			phase = 0;
			back_off_case = 0; 
			if(back_off_case == 0)
			{
				call Timer_ts.startPeriodic(ts_duration - C1);	//starting time-sync of 4
			}
			if(back_off_case == 1)
			{
				call Timer_ts.startPeriodic(wait_time_3);	//starting time-sync of 4
			}
			if(back_off_case == 2)
			{
				call Timer_ts.startPeriodic(wait_time_3);	//starting time-sync of 4
			}
			if(back_off_case == 3)
			{
				call Timer_ts.startPeriodic(wait_time_4);	//starting time-sync of 4
			}
			send = 0;
			back_off_case = 0; 			//setting delay for send
		} 

		else if(phase == 1)
		{
			current = rcm -> current;
			B1 = call LocalTime.get();
			head_ID = rcm -> src;
			new_sub_head = rcm -> new_sub_head;
			nodes = rcm -> nodes;

			A1 = rcm -> local_time;
			tmsg = (ts_msg_t*) call Packet.getPayload(&tpckt, sizeof(ts_msg_t));
			if(tmsg == NULL)
			{
				return bufPtr;
			}
			tmsg -> recv_time = B1;
			tmsg -> src = LVL*16 + ID;
			tmsg -> dst = head_ID;
			tmsg -> msg_num = 2;
			tmsg -> current = current;

			call Timer_ts.startPeriodic(timings);
		}

		else if(phase == 3)
		{
			B3 = call LocalTime.get();

			A2 = rcm -> recv_time;
			A3 = rcm -> local_time;
			/*
			//Doing the math
			 skewfloat = (float)(((float)B3 - (float)B1)/((float)A3 - (float)A1));
			 offsetfloat =(float)(((float)B1 + (float)B2)/2 - ((float)A1 + (float)A2)*skewfloat/2);  

			 AC_slope_float = (float)(skewfloat*(float)AB_slope);
			 AC_offset_float = (float)(skewfloat*(float)AB_offset) + offsetfloat;		 

			 skewfloat = 100000000*skewfloat;
			 offsetfloat = 1000*offsetfloat;

			 AC_slope_float = 100000000*AC_slope_float;
			 AC_offset_float = 1000*AC_offset_float;

			 skew = (uint32_t)skewfloat;
			 offset = (uint32_t)offsetfloat;

			 AC_slope = (uint32_t)AC_slope_float;
			 AC_offset = (uint32_t)AC_offset_float;
			 */
			//Broadcasting the result to the terrestrial node
			bmsg = (ts_msg_t*)call Packet.getPayload(&tpckt, sizeof(ts_msg_t));

	        if (bmsg == NULL) {
	          return bufPtr;  // could not allocate packet
	        }
		    bmsg -> local_time = 4;//skew;
	        bmsg -> src = LVL*16 + ID;
			bmsg -> dst = head_ID;
	        bmsg -> recv_time = 4;//offset;
	        bmsg -> msg_num = 4;
	        bmsg -> current = current;

	        call Timer_ts.startPeriodic(timings);
		}

		return bufPtr;
	}

	event message_t* TSReceive_Head.receive(message_t* bufPtr, void* payload, uint8_t len)
	{
		recv_count_ts_head++;
		send = 0;

		rcm_head = (ts_msg_head_t*) payload;

		phase = rcm_head -> msg_num;

		if(phase == 1)
		{
			call Timer_ts_head.stop();
			new_node = rcm_head -> new_node;
			head = 1;
			super_head = rcm_head -> src;
			B1 = call LocalTime.get();
			A1 = rcm_head -> local_time;
			msg_super = (ts_msg_head_t*)call Packet.getPayload(&pckt_super, sizeof(ts_msg_head_t));
			if(msg_super == NULL)
			{
				return bufPtr;
			}
			msg_super -> recv_time = B1;
			msg_super -> msg_num = 2;
			msg_super -> src = LVL*16 + ID;
			msg_super -> dst = super_head;
			msg_super -> new_node = new_node;

			call  Timer_ts_head.startPeriodic(timings);
		}

		else if(phase == 3)
		{
			call Timer_ts_head.stop();
			B3 = call LocalTime.get();
			A2 = rcm_head -> recv_time;
			A3 = rcm_head -> local_time;

			if((new_node)%8 >= 1)
			{
				inc_val = (uint8_t)(new_node) % 8;
				nodes += inc_val;
			}
			//calculations for time-sync
			skewfloat = (float)(((float)B3 - (float)B1)/((float)A3 - (float)A1));
			offsetfloat =(float)(((float)B1 + (float)B2)/2 - ((float)A1 + (float)A2)*skewfloat/2);  

			skewfloat = 100000000 * skewfloat;
			offsetfloat = 1000 * offsetfloat;

			skew = (uint32_t)skewfloat;
			offset = (uint32_t)offsetfloat;

			rmsg_super = (ts_msg_head_t*)call Packet.getPayload(&pckt_super, sizeof(ts_msg_head_t));
			if(rmsg_super == NULL)
			{
				return bufPtr;
			}

			rmsg_super -> local_time = skew;
			rmsg_super -> src = LVL*16 + ID;
			rmsg_super -> dst = super_head;
			rmsg_super -> recv_time = offset;
			rmsg_super -> msg_num = 4;
			rmsg_super -> new_node = new_node;

			call Timer_ts_head.startPeriodic(timings);

		}

		else if(phase == 2)
		{
			call Timer_ts_head.stop();
			A2 = call LocalTime.get();

			rmsg_sub = (ts_msg_head_t*)call Packet.getPayload(&rpckt_sub, sizeof(ts_msg_head_t));
			rmsg_sub -> recv_time = A2;
			rmsg_sub -> msg_num = 3;
			rmsg_sub -> src = LVL*16 + ID;
			rmsg_sub -> dst = sub_head;
			//rmsg_sub -> new_node = new_node;

			call Timer_ts_head.startPeriodic(timings);
		}

		else if(phase == 4)
		{
			call Timer_ts_head.stop();
			phase = 0;
			current = 1;
			call Timer_ts.startPeriodic(timings + 70);
		}

		return bufPtr;
	}

	event message_t* DataReceive.receive(message_t* bufPtr, void* payload, uint8_t len)
	{
		recv_count_data++;
		if(len == 10)
		{
			data_msg = (data_t*)call Packet.getPayload(&dpckt, sizeof(data_t));
			data_in = (data_t*) payload;

			data_msg -> data = (data_in -> data) + 2;
			data_msg -> src = LVL*16 + ID;
		}
		else
		{
			data_msg_energy = (data_t_energy*)call Packet.getPayload(&dpckt, sizeof(data_t_energy));

			data_msg_energy = (data_t_energy*)call Packet.getPayload(&dpckt, sizeof(data_t));
			data_in_energy = (data_t_energy*) payload;

			data_msg_energy -> data = (data_in -> data) + 2;
			data_msg_energy -> src = LVL*16 + ID;

			energy_dim += voltage * ival_rec * 8 * 4 / data_rate ;

			if(min_energy > data_in_energy -> energy_dim)
			{
				min_energy = data_in_energy -> energy_dim;
				new_head = data_in_energy -> src;

			}

		}

		return bufPtr;
	}

	event message_t* DataReceive_Head.receive(message_t* bufPtr, void* payload, uint8_t len)
	{
		recv_count_data_head++;

		if(len == 11)
		{
			energy_dim += 1 * 8 * voltage * ival_rec / data_rate ; 	
			rcm_head_energy = (data_head_t_energy*) payload;

			new_sub_head = rcm_head_energy -> new_head;
			cycles = 1;

		}

		data_msg_sub = (data_head_t*)call Packet.getPayload(&dpckt_sub, sizeof(data_head_t));

		data_msg_sub -> timestamp = (data_in_sub -> timestamp) + 2;
		data_msg_sub -> src = LVL*16 + ID;

		call Timer_data.startPeriodic(50);

		return bufPtr;
	}

//receives end
//------------------------------------------------------------------------------------------------------------------------------------------------------------------
//sends start

	event void Send_1.sendDone(message_t* bufPtr, error_t error)
	{
		//send_count_ts++;
	}
	event void Send_2.sendDone(message_t* bufPtr, error_t error)
	{
		//send_count_ts++;
	}
	event void Send_3.sendDone(message_t* bufPtr, error_t error)
	{
		//send_count_ts++;
	}
	event void Send_4.sendDone(message_t* bufPtr, error_t error)
	{
		//send_count_ts++;
	}
	event void Send_5.sendDone(message_t* bufPtr, error_t error)
	{
		//send_count_ts++;
	}
	event void Send_6.sendDone(message_t* bufPtr, error_t error)
	{
		//send_count_ts++;
	}
	event void Send_7.sendDone(message_t* bufPtr, error_t error)
	{
		//send_count_ts++;
	}
	event void Send_8.sendDone(message_t* bufPtr, error_t error)
	{
		//send_count_ts++;
	}
	event void Send_9.sendDone(message_t* bufPtr, error_t error)
	{
		//send_count_ts++;
	}
	event void Send_A.sendDone(message_t* bufPtr, error_t error)
	{
		//send_count_ts++;
	}
	event void Send_B.sendDone(message_t* bufPtr, error_t error)
	{
		//send_count_ts++;
	}
	event void Send_C.sendDone(message_t* bufPtr, error_t error)
	{
		//send_count_ts++;
	}
	event void Send_D.sendDone(message_t* bufPtr, error_t error)
	{
		//send_count_ts++;
	}
	event void Send_E.sendDone(message_t* bufPtr, error_t error)
	{
		//send_count_ts++;
	}
	event void Send_1_Data.sendDone(message_t* bufPtr, error_t error)
	{
		//send_count_data++;
	}
	event void Send_2_Data.sendDone(message_t* bufPtr, error_t error)
	{
		//send_count_data++;
	}
	event void Send_3_Data.sendDone(message_t* bufPtr, error_t error)
	{
		//send_count_data++;
	}
	event void Send_4_Data.sendDone(message_t* bufPtr, error_t error)
	{
		//send_count_data++;
	}
	event void Send_5_Data.sendDone(message_t* bufPtr, error_t error)
	{
		//send_count_data++;
	}
	event void Send_6_Data.sendDone(message_t* bufPtr, error_t error)
	{
		//send_count_data++;
	}
	event void Send_7_Data.sendDone(message_t* bufPtr, error_t error)
	{
		//send_count_data++;
	}
	event void Send_8_Data.sendDone(message_t* bufPtr, error_t error)
	{
		//send_count_data++;
	}
	event void Send_9_Data.sendDone(message_t* bufPtr, error_t error)
	{
		//send_count_data++;
	}
	event void Send_A_Data.sendDone(message_t* bufPtr, error_t error)
	{
		//send_count_data++;
	}
	event void Send_B_Data.sendDone(message_t* bufPtr, error_t error)
	{
		//send_count_data++;
	}
	event void Send_C_Data.sendDone(message_t* bufPtr, error_t error)
	{
		//send_count_data++;
	}
	event void Send_D_Data.sendDone(message_t* bufPtr, error_t error)
	{
		//send_count_data++;
	}
	event void Send_E_Data.sendDone(message_t* bufPtr, error_t error)
	{
		//send_count_data++;
	}
	event void Send_Sub_0.sendDone(message_t* bufPtr, error_t error)
	{
		//send_count_ts_head++;
	}
	event void Send_Sub_1.sendDone(message_t* bufPtr, error_t error)
	{
		//send_count_ts_head++;
	}
	event void Send_Sub_2.sendDone(message_t* bufPtr, error_t error)
	{
		//send_count_ts_head++;
	}
	event void Send_Sub_3.sendDone(message_t* bufPtr, error_t error)
	{
		//send_count_ts_head++;
	}
	event void Send_Sub_4.sendDone(message_t* bufPtr, error_t error)
	{
		//send_count_ts_head++;
	}
	event void Send_Sub_5.sendDone(message_t* bufPtr, error_t error)
	{
		//send_count_ts_head++;
	}
	event void Send_Sub_6.sendDone(message_t* bufPtr, error_t error)
	{
		//send_count_ts_head++;
	}
	event void Send_Sub_7.sendDone(message_t* bufPtr, error_t error)
	{
		//send_count_ts_head++;
	}
	event void Send_Sub_8.sendDone(message_t* bufPtr, error_t error)
	{
		//send_count_ts_head++;
	}
	event void Send_Sub_9.sendDone(message_t* bufPtr, error_t error)
	{
		//send_count_ts_head++;
	}
	event void Send_Sub_A.sendDone(message_t* bufPtr, error_t error)
	{
		//send_count_ts_head++;
	}
	event void Send_Sub_B.sendDone(message_t* bufPtr, error_t error)
	{
		//send_count_ts_head++;
	}
	event void Send_Sub_C.sendDone(message_t* bufPtr, error_t error)
	{
		//send_count_ts_head++;
	}
	event void Send_Sub_D.sendDone(message_t* bufPtr, error_t error)
	{
		//send_count_ts_head++;
	}
	event void Send_Sub_E.sendDone(message_t* bufPtr, error_t error)
	{
		//send_count_ts_head++;
	}
	event void Send_Super.sendDone(message_t* bufPtr, error_t error)
	{
		//send_count_ts_head++;
	}
	event void Send_Super_Data.sendDone(message_t* bufPtr, error_t error)
	{
		//send_count_data_head++;
	}

}


