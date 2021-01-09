module DataPath(RD1, RD2, O_Mux_32bit, O_ALU, O_Mem, O_MemToReg, O_RegDst, O_INST, SignExtend, RegDst, RegWrite, ALUSrc, ALUControl, MemWrite, MemRead, MemtoReg, clk, reset, Branch, Addr1, Addr2);
	input[2:0] ALUControl;
	input RegDst, RegWrite, ALUSrc, MemWrite, MemRead, MemtoReg, clk, reset, Branch;	//
	output[4:0] O_RegDst;
	output[31:0] RD1, RD2, O_Mux_32bit, O_ALU, O_Mem, O_MemToReg, SignExtend, O_INST;
	output[4:0] Addr1, Addr2;
	
	
	wire[4:0] O_Mux_5bit;
	wire [31:0] reg_RD1, reg_RD2, reg_Mux_32bit, reg_ALU, reg_zeroFlag, reg_Mem, reg_MemToReg, reg_SignExtend, Shift2, O_ADD, AddPC;
	/*************/
	wire[31:0] Instruction;
	wire[31:0] InPCmem;
	wire Sel;
	wire[31:0] PC;
	wire zeroFlag;
	
	assign RD1 = reg_RD1;
	assign RD2 = reg_RD2;
	assign O_RegDst = O_Mux_5bit;
	assign O_Mux_32bit = reg_Mux_32bit;
	assign O_ALU = reg_ALU;
	assign O_Mem = reg_Mem;
	assign O_MemToReg = reg_MemToReg;
	assign SignExtend = reg_SignExtend;
	assign O_INST = Instruction;
	assign Addr1 = O_INST[25:21];
	assign Addr2 = O_INST[20:16];
	
	PCmem PC_MEM(PC, InPCmem, reset, clk);
	IMEM INST_MEM(Instruction, PC);
	AddPC ADD_PC(AddPC, PC);
	ADD ADD(O_ADD, AddPC, Shift2);
	Shift2 SHIFT2(Shift2, reg_SignExtend);
	MUX2to1_32bit MUX(InPCmem, AddPC, O_ADD, Sel);
	and(Sel, Branch, reg_zeroFlag);
	
	MUX2to1_5bit MUX_5bit(.Out_Mux_5bit(O_Mux_5bit), .InA(Instruction[20:16]), .InB(Instruction[15:11]), .Sel(RegDst));
	RegisterFile REG(.ReadData1(reg_RD1), .ReadData2(reg_RD2), .WriteData(reg_MemToReg), .ReadWriteEn(RegWrite), .WriteAddress(O_Mux_5bit), .ReadAddress1(Instruction[25:21]), .ReadAddress2(Instruction[20:16]), .CLK(clk));
	SignExtend SignExtend1(.Out_SignExtend(reg_SignExtend), .In_SignExtend(Instruction[15:0]));
	MUX2to1_32bit MUX_32bit(.Out_Mux_32bit(reg_Mux_32bit), .InA(reg_RD2), .InB(reg_SignExtend), .Sel(ALUSrc));
	ALU ALU(.Out_ALU(reg_ALU), .Zero(reg_zeroFlag), .InA(reg_RD1), .InB(reg_Mux_32bit), .S(ALUControl[1:0]), .M(ALUControl[2]));
	SRAM MEM(.ReadData(reg_Mem), .Address(reg_ALU), .WriteData(reg_RD2), .WriteEn(MemWrite), .ReadEn(MemRead), .clk(~clk));
	MUX2to1_32bit MEMTOREG(.Out_Mux_32bit(reg_MemToReg), .InA(reg_ALU), .InB(reg_Mem), .Sel(MemtoReg));
	
endmodule
