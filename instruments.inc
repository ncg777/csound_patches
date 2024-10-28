  #include "my_udos.inc"
  
  instr ExpTrigger
    k_mean_delay inletk "MEAN_DELAY"
    seed 0
    k_trigger init 0
    k_exp init 0
    k_x init 0

    krnd unirand 1.0
    
    k_mean_delay = p4
    k_lambda = 1.0/(k_mean_delay)
    
    k_exp = (1.0/k_lambda)*(exp(-k_lambda*(k_x+1.0/kr)) - exp(-k_lambda*k_x))+(1.0/kr)
    
    k_trigger = (krnd < k_exp ? 1 : 0)
    
    k_x = (k_x+(1.0/kr))*((1.0-k_trigger))

    outletk "TRIGGER", k_trigger
  endin
  
  
  
  instr MonoIn
    a_in in
    outleta "MONOIN", a_in
  endin
  
  
  instr PrintTest
    a_in inleta "INPUT"
    k_trigger trigger k(a_in), 10000, 0
    k_switch trigger_activated_switch k_trigger
    printk 0, k_switch
    /*
    a_in inleta "INPUT"
    ;k_stat system k_trigger, "streamer -c /dev/video0 -b 16 -o /home/pi/capture.jpeg"
    k_active0 init 0.0
    k_trigger1 init 0.0
    k_trigger0 frequency_activation a_in, 500, 50, 0.98, 1000
    k_trigger1 frequency_activation a_in, 2200, 50, 0.98, 1000
    
    k_monitor0, k_activation0, k_active0, k_deactivation0 trigger_monitor k_trigger0 + k_active0*k_trigger1, p4
    
    
    k_stat system k_activation0, "echo UNLOCKED" 
    k_stat system k_deactivation0, "echo LOCKED" 
    
    k_stat system k_trigger1*k_active0, "echo PAF" 
    */
  endin
  
