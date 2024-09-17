module receiver #(
    parameter  DBIT= 8, SB_TICK=16
) (
    input  rx,
    input s_tick,clk,reset_n,
    output [DBIT - 1 : 0] rx_dout,
    output reg rx_done_tick
);
    localparam idle =0 , start =1 , data=2 , stop=3; 
    reg [1:0] state_next,state_reg;
    reg [$clog2(DBIT)  : 0 ] s_next,s_reg; 
    reg [$clog2(DBIT) - 1 : 0 ] n_next,n_reg; 
    reg [ DBIT - 1 : 0 ] b_next,b_reg;

    always @(posedge clk , negedge reset_n) begin
        if(!reset_n) begin
          state_reg<=idle;  
          s_reg<=0;
          n_reg<=0;
          b_reg<=0;
        end
        else begin
          state_reg<=state_next;
          s_reg<=s_next;
          n_reg<=n_next;
          b_reg<=b_next;
        end
    end
    
        always @(*) begin
        state_next=state_reg;
        s_next=s_reg;
        n_next=n_reg;
        b_next=b_reg;
        rx_done_tick=1'b0;   
            case (state_reg)
                idle : 
                    if(~rx) begin
                     s_next=1'b0;
                    state_next=start;  
                    end
                    else 
                    state_next=idle;
                start : 
                     if(s_tick) begin
                        if(s_reg==7) begin
                          s_next=0;
                          n_next=0;
                          state_next=data; 
                        end
                        else begin
                        s_next=s_reg+1;
                        state_next=start;  
                        end
                     end
                     else
                        state_next=start;
                data :
                    if(s_tick) begin
                        if(s_reg==15) begin
                        s_next=0;
                        b_next={ rx , b_reg[DBIT-1 : 1] } ;              //!ww
                        if(n_reg==(DBIT - 1)) begin
                            state_next=stop;
                        end
                        else begin
                            n_next=n_reg+1;
                            state_next=data;
                        end
                        end
                        else begin
                        s_next=s_reg+1;
                        state_next=data;
                        end  
                    end
                    else 
                    state_next=data;
              stop :
                    if(s_tick) begin
                        if(s_reg==(SB_TICK-1)) begin
                        rx_done_tick=1'b1;
                        state_next=idle;   
                        end    
                        else begin
                        s_next=s_reg+1; 
                        state_next=stop;  
                        end                     
                    end
                    else
                    state_next=stop;             
                default: state_next=idle;
            endcase

        end
        assign rx_dout = b_reg;    
endmodule