module sensor_sync_detector(xxxx
		input wire 			sensor_pclk,
		input wire 			sensor_vs,
		input_wire			sensor_hs,
		input wire			sensor_din[11:0],
		
		output wire			sensor_startframe,
		output wire 		sensor_startline,
		output wire			sensor_endline,
		output wire			sensor_endframe,
		output wire       sensor_datavalid,
		
		input wire 			cam_clk,
		input wire 			cam_reset
		);
		
		always @(posedge sensor_pclk or posedge cam_reset)
		begin
			if (cam_reset)
				begin
					sensor_vs_reg <= 1'b0;
					sensor_hs_reg <= 1'b0;
					sensor_din_reg <= 12'b0;
				end
			else 
				begin 
					sensor_vs_reg <=sensor_vs;
					sensor_hs_reg <=sensor_hs;
					sensor_din_reg <=sensor_din;
				end
		end
	
// video receiver state machine;	
   always @(posedge sensor_pclk or posedge cam_reset)
		begin 
			if (cam_reset)
				begin 
					sensor_state <= SENSOR_NO_VIDEO;
				end
			else
				begin 
					if(sensor_vs_reg) 
						begin
							case (sensor_state) // x and z values are NOT treated as don't-care's
								SENSOR_NO_VIDEO: sensor_state <= SENSOR_VSYNC;
								SENSOR_VSYNC:	  sensor_state <= SENSOR_RECEIVING;
								SENSOR_RECEIVING: sensor_state <= SENSOR_RECEIVING;
								SENSOR_FRAMEEND:  sensor_state <= SENSOR_VSYNC;
							endcase
						end
					else
						begin
							case (sensor_state)
								SENSOR_NO_VIDEO: sensor_state <= SENSOR_NO_VIDEO;
								SENSOR_VSYNC:	  sensor_state <= SENSOR_RECEIVING;
								SENSOR_RECEIVING: sensor_state <= SENSOR_RECEIVING;
								SENSOR_FRAMEEND: sensor_state <= SENSOR_NO_VIDEO;
							endcase
						end
				end
			end
	 
	 // Generate start frame and end frame signal;
	 always @(posedge sensor_pclk or posedge cam_reset)
	begin
		if (cam_reset)
			begin
				sensor_startframe <= 0;
				sensor_endframe <= 0;
			end
		else
			begin
				case (sensor_state)
				SENSOR_NO_VIDEO: sensor_startframe <= 1'b0;
				SENSOR_VSYNC:	  sensor_startframe <= 1'b1;
				SENSOR_RECEIVING: sensor_startframe <= 1'b0;
				SENSOR_FRAMEEND: sensor_startframe <= 1'b0;
				endcase
				case (sensor_state)
				SENSOR_NO_VIDEO: sensor_endframe <= 1'b0;
				SENSOR_VSYNC:	  sensor_endframe <= 1'b0;
				SENSOR_RECEIVING: sensor_endframe <= 1'b0;
				SENSOR_FRAMEEND: sensor_startframe <= 1'b1;
				endcase
		 end
	end
endmodule
	