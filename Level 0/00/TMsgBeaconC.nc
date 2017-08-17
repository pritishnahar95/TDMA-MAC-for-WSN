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

	    interface Receive as TSReceive_Head;
	    interface Receive as DataReceive_Head;

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
	    interface Timer<TMilli> as Timer_ts_head;
	}
}

//module ends here
//---------------------------------------------------------------------------------------------------------------------------------------------------------------------

implementation
{
	uint8_t ID = 0;
	uint8_t LVL = 0;

	uint8_t length;

	int cycle_count = 0 ;								//initial states
	long int cyclesleep2 = 900000;						//sleep timings
	long int timings = 10;							//delay timing
	long int timings2 = 50;

	uint8_t phase = 0;
	int head = 1;
	uint16_t new_node;
	uint8_t sub_head = 1*16 + 0;
	uint8_t new_sub_head = 1*16+0;

	int cycles = 0;


	//sub-level-specific messages starts
	message_t pckt_sub, rpckt_sub, dpckt_sub;
	data_head_t* data_msg_sub;
	data_head_t* data_in_sub;
	ts_msg_head_t* msg_sub;
	ts_msg_head_t* rmsg_sub;
	//sub-level-specific messages ends

	ts_msg_head_t* rcm_head;
	data_head_t_energy* rcm_head_energy;


	int send_count_ts_head = 0;
	
	int recv_count_ts_head = 0;
	int recv_count_data_head = 0;

	int recv_count, send_count;
	int total_recv_count, total_send_count;	


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
	  		head = 1;
	  		phase = 0;
			cycle_count++;


			send_count_ts_head = 0;
			
			recv_count_ts_head = 0;
			recv_count_data_head = 0;

			send_count = 0;
			recv_count = 0;

			call Timer_ts_head.startPeriodic(1000);
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


  		send_count = send_count_ts_head;
  		recv_count = recv_count_ts_head + recv_count_data_head;

  		total_send_count += send_count;
  		total_recv_count += recv_count;

  		head = 0;
  		phase = 0;
  		call AMControl.stop();
  		call SleepTimer.startPeriodic(period);
  	}

	event void SleepTimer.fired()
  	{
  		call AMControl.start();
  	}


//------------------------------------------------------------------------------------------------------------------------------------------------------------------
//timers start

event void Timer_ts_head.fired()
	{
		call Timer_ts_head.stop();
		send_count_ts_head++;

		if(phase == 2)
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

			//call Timer_ts_head.startPeriodic(timings2);

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

			if(cycle_count / 2 == 1 && cycle_count % 2 == 0)
			{
				new_node = 3 + 8*3 + 3*8*8;
			}
			else if(cycle_count / 2 == 2 && cycle_count % 2 == 0)
			{
				new_node = 2 + 8*2 + 2*8*8;
			}
			else
			{
				new_node = 0;
			}

			
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

//timers end
//------------------------------------------------------------------------------------------------------------------------------------------------------------------
//receives start

	event message_t* TSReceive_Head.receive(message_t* bufPtr, void* payload, uint8_t len)
	{
		recv_count_ts_head++;

		rcm_head = (ts_msg_head_t*) payload;

		phase = rcm_head -> msg_num;

		if(phase == 2)
		{
			call Timer_ts_head.stop();

			rmsg_sub = (ts_msg_head_t*)call Packet.getPayload(&rpckt_sub, sizeof(ts_msg_head_t));
			rmsg_sub -> recv_time = call LocalTime.get();
			rmsg_sub -> msg_num = 3;
			rmsg_sub -> src = LVL*16 + ID;
			rmsg_sub -> dst = sub_head;
			rmsg_sub -> new_node = new_node;

			call Timer_ts_head.startPeriodic(timings);
		}

		return bufPtr;
	}
	
	event message_t* DataReceive_Head.receive(message_t* bufPtr, void* payload, uint8_t len)
	{
		recv_count_data_head++;

		if(len == 11)
		{
			rcm_head_energy = (data_head_t_energy*) payload;

			new_sub_head = rcm_head_energy -> new_head;
			cycles = 1;

		}

		data_msg_sub = (data_head_t*)call Packet.getPayload(&dpckt_sub, sizeof(data_head_t));

		data_msg_sub -> timestamp = (data_in_sub -> timestamp) + 2;
		data_msg_sub -> src = LVL*16 + ID;

		//call Timer_data.startPeriodic(50);
		sleep(cyclesleep2);

		return bufPtr;
	}

//receives end
//------------------------------------------------------------------------------------------------------------------------------------------------------------------
//sends start

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
}