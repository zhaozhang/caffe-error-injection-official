int step_cur=-1;
__thread int deviceid=-1;
__thread int Active=0;
int mut_step=-1;
int mut_layer_fp=-1;
int mut_layer_bp=-1;
int mut_param_set=-1;
int mut_layer_fp_idx=-1;
int mut_layer_bp_idx=-1;
int mut_param_set_idx=-1;
int mut_bit=-1;
int bit_mask[32];
int Clamp_On=0;
float Data_Range=1.0E10;
__thread int Is_In_Test=0;
__thread int Is_In_LSTM=0;

