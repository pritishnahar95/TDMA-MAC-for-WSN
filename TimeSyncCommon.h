#ifndef TIME_SYNC_COMMON_H
#define TIME_SYNC_COMMON_H

typedef nx_struct ts_msg                        //20 bytes
{
	nx_uint8_t src;
	nx_uint8_t dst;
	nx_uint32_t local_time;
	nx_uint32_t recv_time;
	nx_uint16_t msg_num;
	nx_uint16_t current;
	nx_uint8_t new_sub_head;
	nx_uint8_t nodes;
}	ts_msg_t;

typedef nx_struct ts_msg_head 
{
	nx_uint8_t src;
	nx_uint8_t dst;
	nx_uint32_t local_time;
	nx_uint32_t recv_time;
	nx_uint16_t new_node;
	nx_uint16_t msg_num;
}	ts_msg_head_t;

typedef nx_struct ts_bc
{
	nx_uint8_t src;
	nx_uint8_t dst;
	nx_uint32_t slope;
	nx_uint32_t offset;
	nx_uint16_t msg_num;
}	ts_bc_t;

typedef nx_struct data_t                         //100 bytes total
{
	nx_uint8_t src;
	nx_uint8_t dst;
	nx_uint32_t timestamp;
	nx_uint32_t data;
}	data_t;

typedef nx_struct data_t_energy                         //100 bytes total
{
	nx_uint8_t src;
	nx_uint8_t dst;
	nx_uint32_t timestamp;
	nx_uint32_t data;
	nx_uint32_t energy_dim;
}	data_t_energy;

typedef nx_struct data_head
{
	nx_uint8_t src;
	nx_uint8_t dst;
	nx_uint32_t timestamp;
	nx_uint32_t data;	
}	data_head_t;

typedef nx_struct data_head_energy
{
	nx_uint8_t src;
	nx_uint8_t dst;
	nx_uint32_t timestamp;
	nx_uint32_t data;
	nx_uint8_t new_head;	
}	data_head_t_energy;

enum
{
	AM_TS_00 = 1,
	AM_D_00 = 200,

	AM_TS_10 = 2,
	AM_TS_11 = 3,
	AM_TS_12 = 4,
	AM_TS_13 = 5,
	AM_TS_14 = 6,
	AM_TS_15 = 7,
	AM_TS_16 = 8,
	AM_TS_17 = 9,
	AM_TS_18 = 10,
	AM_TS_19 = 11,
	AM_TS_1A = 12,
	AM_TS_1B = 13,
	AM_TS_1C = 14,
	AM_TS_1D = 15,
	AM_TS_1E = 16,
	AM_D_10 = 17,
	AM_D_11 = 18,
	AM_D_12 = 19,
	AM_D_13 = 20,
	AM_D_14 = 21,
	AM_D_15 = 22,
	AM_D_16 = 23,
	AM_D_17 = 24,
	AM_D_18 = 25,
	AM_D_19 = 26,
	AM_D_1A = 27,
	AM_D_1B = 28,
	AM_D_1C = 29,
	AM_D_1D = 30,
	AM_D_1E = 31,

	AM_TS_Head_10 = 32,
	AM_TS_Head_11 = 33,
	AM_TS_Head_12 = 34,
	AM_TS_Head_13 = 35,
	AM_TS_Head_14 = 36,
	AM_TS_Head_15 = 37,
	AM_TS_Head_16 = 38,
	AM_TS_Head_17 = 39,
	AM_TS_Head_18 = 40,
	AM_TS_Head_19 = 41,
	AM_TS_Head_1A = 42,
	AM_TS_Head_1B = 43,
	AM_TS_Head_1C = 44,
	AM_TS_Head_1D = 45,
	AM_TS_Head_1E = 46,
	AM_D_Head_10 = 47,
	AM_D_Head_11 = 48,
	AM_D_Head_12 = 49,
	AM_D_Head_13 = 50,
	AM_D_Head_14 = 51,
	AM_D_Head_15 = 52,
	AM_D_Head_16 = 53,
	AM_D_Head_17 = 54,
	AM_D_Head_18 = 55,
	AM_D_Head_19 = 56,
	AM_D_Head_1A = 57,
	AM_D_Head_1B = 58,
	AM_D_Head_1C = 59,
	AM_D_Head_1D = 50,
	AM_D_Head_1E = 51,

	AM_TS_20 = 52,
	AM_TS_21 = 53,
	AM_TS_22 = 54,
	AM_TS_23 = 55,
	AM_TS_24 = 56,
	AM_TS_25 = 57,
	AM_TS_26 = 58,
	AM_TS_27 = 59,
	AM_TS_28 = 60,
	AM_TS_29 = 61,
	AM_TS_2A = 62,
	AM_TS_2B = 63,
	AM_TS_2C = 64,
	AM_TS_2D = 65,
	AM_TS_2E = 66,
	AM_D_20 = 67,
	AM_D_21 = 68,
	AM_D_22 = 69,
	AM_D_23 = 70,
	AM_D_24 = 71,
	AM_D_25 = 72,
	AM_D_26 = 73,
	AM_D_27 = 74,
	AM_D_28 = 75,
	AM_D_29 = 76,
	AM_D_2A = 77,
	AM_D_2B = 78,
	AM_D_2C = 79,
	AM_D_2D = 80,
	AM_D_2E = 81,

	AM_TS_Head_20 = 82,
	AM_TS_Head_21 = 83,
	AM_TS_Head_22 = 84,
	AM_TS_Head_23 = 85,
	AM_TS_Head_24 = 86,
	AM_TS_Head_25 = 87,
	AM_TS_Head_26 = 88,
	AM_TS_Head_27 = 89,
	AM_TS_Head_28 = 90,
	AM_TS_Head_29 = 91,
	AM_TS_Head_2A = 92,
	AM_TS_Head_2B = 93,
	AM_TS_Head_2C = 94,
	AM_TS_Head_2D = 95,
	AM_TS_Head_2E = 96,
	AM_D_Head_20 = 97,
	AM_D_Head_21 = 98,
	AM_D_Head_22 = 99,
	AM_D_Head_23 = 100,
	AM_D_Head_24 = 101,
	AM_D_Head_25 = 102,
	AM_D_Head_26 = 103,
	AM_D_Head_27 = 104,
	AM_D_Head_28 = 105,
	AM_D_Head_29 = 106,
	AM_D_Head_2A = 107,
	AM_D_Head_2B = 108,
	AM_D_Head_2C = 109,
	AM_D_Head_2D = 110,
	AM_D_Head_2E = 111,

	AM_TS_30 = 112,
	AM_TS_31 = 113,
	AM_TS_32 = 114,
	AM_TS_33 = 115,
	AM_TS_34 = 116,
	AM_TS_35 = 117,
	AM_TS_36 = 118,
	AM_TS_37 = 119,
	AM_TS_38 = 120,
	AM_TS_39 = 121,
	AM_TS_3A = 122,
	AM_TS_3B = 123,
	AM_TS_3C = 124,
	AM_TS_3D = 125,
	AM_TS_3E = 126,
	AM_D_30 = 127,
	AM_D_31 = 128,
	AM_D_32 = 129,
	AM_D_33 = 130,
	AM_D_34 = 131,
	AM_D_35 = 132,
	AM_D_36 = 133,
	AM_D_37 = 134,
	AM_D_38 = 135,
	AM_D_39 = 136,
	AM_D_3A = 137,
	AM_D_3B = 138,
	AM_D_3C = 139,
	AM_D_3D = 140,
	AM_D_3E = 141,

	AM_TS_Head_30 = 142,
	AM_TS_Head_31 = 143,
	AM_TS_Head_32 = 144,
	AM_TS_Head_33 = 145,
	AM_TS_Head_34 = 146,
	AM_TS_Head_35 = 147,
	AM_TS_Head_36 = 148,
	AM_TS_Head_37 = 149,
	AM_TS_Head_38 = 150,
	AM_TS_Head_39 = 151,
	AM_TS_Head_3A = 152,
	AM_TS_Head_3B = 153,
	AM_TS_Head_3C = 154,
	AM_TS_Head_3D = 155,
	AM_TS_Head_3E = 156,
	AM_D_Head_30 = 157,
	AM_D_Head_31 = 158,
	AM_D_Head_32 = 159,
	AM_D_Head_33 = 160,
	AM_D_Head_34 = 161,
	AM_D_Head_35 = 162,
	AM_D_Head_36 = 163,
	AM_D_Head_37 = 164,
	AM_D_Head_38 = 165,
	AM_D_Head_39 = 166,
	AM_D_Head_3A = 167,
	AM_D_Head_3B = 168,
	AM_D_Head_3C = 169,
	AM_D_Head_3D = 170,
	AM_D_Head_3E = 171
};

#endif