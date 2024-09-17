module Transmetr #(
    parameter  DBIT= 8, SB_TICK=16
) (
    input [DBIT - 1 : 0] tx_din,
    input s_tick,clk,reset_n,tx_start,
    output  tx,
    output reg tx_done_tick
);
    localparam idle =0 , start =1 , data=2 , stop=3; 
    reg [1:0] state_next,state_reg;
    reg [$clog2(DBIT)  : 0 ] s_next,s_reg; 
    reg [$clog2(DBIT) - 1 : 0 ] n_next,n_reg; 
    reg [ DBIT - 1 : 0 ] b_next,b_reg;
    reg tx_next,tx_reg;

    always @(posedge clk , negedge reset_n) begin
        if(!reset_n) begin
          state_reg<=idle;  
          s_reg<=0;
          n_reg<=0;
          b_reg<=0;
          tx_reg<=1;
        end
        else begin
          state_reg<=state_next;
          s_reg<=s_next;
          n_reg<=n_next;
          b_reg<=b_next;
          tx_reg<=tx_next;
        end
    end
    
        always @(*) begin
        state_next=state_reg;
        s_next=s_reg;
        n_next=n_reg;
        b_next=b_reg;
        tx_done_tick=1'b0;    
            case (state_reg)
                idle : begin            
                    tx_next=1'b1;
                    if(tx_start) begin
                     s_next=1'b0;
                     b_next=tx_din;
                    state_next=start;  
                    end
                    else 
                    state_next=idle;
                end    
                start : begin
                    tx_next=1'b0;
                     if(s_tick) begin
                        if(s_reg==15) begin
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
                end        
                data : begin
                    tx_next=b_reg[0];
                    if(s_tick) begin
                        if(s_reg==15) begin
                        s_next=0;
                        b_next={ 1'b0 , b_reg[DBIT-1 : 1] } ;              //!ww
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
                end
              stop : begin
                    tx_next=1'b1;
                    if(s_tick) begin
                        if(s_reg==(SB_TICK-1)) begin
                        tx_done_tick=1'b1;
                        state_next=idle;   
                        end    
                        else begin
                        s_next=s_reg+1; 
                        state_next=stop;  
                        end                     
                    end
                    else
                    state_next=stop;  
              end               
                default: state_next=idle;
            endcase
    
        end
    assign tx=tx_reg;      
endmodule