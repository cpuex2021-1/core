module fsqr(
    input  logic clk,rst,
    input  logic [31:0] a,b,
    output logic [31:0] c
);
    logic [35:0] init_grad[1023:0];
    logic s;
    logic [7:0] e;
    logic [7:0] e_;
    logic [22:0] m;
    logic [9:0] key;
    logic [13:0] diff;
    assign s = a[31];
    assign e_ = a[30:23];
    assign e = (e_+8'b01111111) >>1;
    assign key = a[23:14];
    assign diff = a[13:0];




    logic [35:0] init;
    logic [12:0] grad;
    assign init = {init_grad[key][35:13] , 13'b0};
    assign grad = init_grad[key][12:0];
    logic [35:0] m_;
    assign m_ = init + grad * diff;
    assign m = m_[35:13];

    assign c = {s, e, m};
    




    initial begin
init_grad[0] = 36'h6a09f1699;
init_grad[1] = 36'h6a6467693;
init_grad[2] = 36'h6abec968e;
init_grad[3] = 36'h6b1913688;
init_grad[4] = 36'h6b7347683;
init_grad[5] = 36'h6bcd6367d;
init_grad[6] = 36'h6c276b677;
init_grad[7] = 36'h6c815b672;
init_grad[8] = 36'h6cdb3566c;
init_grad[9] = 36'h6d34fb667;
init_grad[10] = 36'h6d8ea9661;
init_grad[11] = 36'h6de84165c;
init_grad[12] = 36'h6e41c3656;
init_grad[13] = 36'h6e9b31651;
init_grad[14] = 36'h6ef48764c;
init_grad[15] = 36'h6f4dc9646;
init_grad[16] = 36'h6fa6f5641;
init_grad[17] = 36'h70000b63b;
init_grad[18] = 36'h70590b636;
init_grad[19] = 36'h70b1f5631;
init_grad[20] = 36'h710acb62b;
init_grad[21] = 36'h71638b626;
init_grad[22] = 36'h71bc35621;
init_grad[23] = 36'h7214cb61b;
init_grad[24] = 36'h726d4b616;
init_grad[25] = 36'h72c5b7611;
init_grad[26] = 36'h731e0d60c;
init_grad[27] = 36'h73764f606;
init_grad[28] = 36'h73ce7b601;
init_grad[29] = 36'h7426915fc;
init_grad[30] = 36'h747e955f7;
init_grad[31] = 36'h74d6815f2;
init_grad[32] = 36'h752e5b5ec;
init_grad[33] = 36'h75861f5e7;
init_grad[34] = 36'h75ddcf5e2;
init_grad[35] = 36'h76356b5dd;
init_grad[36] = 36'h768cf15d8;
init_grad[37] = 36'h76e4635d3;
init_grad[38] = 36'h773bc15ce;
init_grad[39] = 36'h77930b5c9;
init_grad[40] = 36'h77ea3f5c4;
init_grad[41] = 36'h7841615bf;
init_grad[42] = 36'h78986d5ba;
init_grad[43] = 36'h78ef675b5;
init_grad[44] = 36'h79464b5b0;
init_grad[45] = 36'h799d1b5ab;
init_grad[46] = 36'h79f3d95a6;
init_grad[47] = 36'h7a4a815a1;
init_grad[48] = 36'h7aa11759c;
init_grad[49] = 36'h7af799597;
init_grad[50] = 36'h7b4e05592;
init_grad[51] = 36'h7ba45f58d;
init_grad[52] = 36'h7bfaa5588;
init_grad[53] = 36'h7c50d9583;
init_grad[54] = 36'h7ca6f757e;
init_grad[55] = 36'h7cfd0357a;
init_grad[56] = 36'h7d52fb575;
init_grad[57] = 36'h7da8e1570;
init_grad[58] = 36'h7dfeb356b;
init_grad[59] = 36'h7e5471566;
init_grad[60] = 36'h7eaa1d561;
init_grad[61] = 36'h7effb555d;
init_grad[62] = 36'h7f5539558;
init_grad[63] = 36'h7faaab553;
init_grad[64] = 36'h80000954e;
init_grad[65] = 36'h80555554a;
init_grad[66] = 36'h80aa8f545;
init_grad[67] = 36'h80ffb5540;
init_grad[68] = 36'h8154c753c;
init_grad[69] = 36'h81a9c9537;
init_grad[70] = 36'h81feb5532;
init_grad[71] = 36'h82539152e;
init_grad[72] = 36'h82a859529;
init_grad[73] = 36'h82fd0f524;
init_grad[74] = 36'h8351b3520;
init_grad[75] = 36'h83a64351b;
init_grad[76] = 36'h83fac3517;
init_grad[77] = 36'h844f2f512;
init_grad[78] = 36'h84a38750d;
init_grad[79] = 36'h84f7cf509;
init_grad[80] = 36'h854c05504;
init_grad[81] = 36'h85a027500;
init_grad[82] = 36'h85f4394fb;
init_grad[83] = 36'h8648374f7;
init_grad[84] = 36'h869c234f2;
init_grad[85] = 36'h86efff4ee;
init_grad[86] = 36'h8743c74e9;
init_grad[87] = 36'h87977d4e5;
init_grad[88] = 36'h87eb234e0;
init_grad[89] = 36'h883eb54dc;
init_grad[90] = 36'h8892374d7;
init_grad[91] = 36'h88e5a74d3;
init_grad[92] = 36'h8939054cf;
init_grad[93] = 36'h898c514ca;
init_grad[94] = 36'h89df8b4c6;
init_grad[95] = 36'h8a32b54c1;
init_grad[96] = 36'h8a85cb4bd;
init_grad[97] = 36'h8ad8d14b9;
init_grad[98] = 36'h8b2bc54b4;
init_grad[99] = 36'h8b7ea94b0;
init_grad[100] = 36'h8bd17b4ac;
init_grad[101] = 36'h8c243b4a7;
init_grad[102] = 36'h8c76eb4a3;
init_grad[103] = 36'h8cc98949f;
init_grad[104] = 36'h8d1c1549b;
init_grad[105] = 36'h8d6e91496;
init_grad[106] = 36'h8dc0fb492;
init_grad[107] = 36'h8e135548e;
init_grad[108] = 36'h8e659d48a;
init_grad[109] = 36'h8eb7d5485;
init_grad[110] = 36'h8f09fb481;
init_grad[111] = 36'h8f5c1147d;
init_grad[112] = 36'h8fae15479;
init_grad[113] = 36'h900009474;
init_grad[114] = 36'h9051ed470;
init_grad[115] = 36'h90a3bf46c;
init_grad[116] = 36'h90f581468;
init_grad[117] = 36'h914731464;
init_grad[118] = 36'h9198d1460;
init_grad[119] = 36'h91ea6145c;
init_grad[120] = 36'h923be1457;
init_grad[121] = 36'h928d4f453;
init_grad[122] = 36'h92deaf44f;
init_grad[123] = 36'h932ffb44b;
init_grad[124] = 36'h938139447;
init_grad[125] = 36'h93d267443;
init_grad[126] = 36'h94238343f;
init_grad[127] = 36'h94749143b;
init_grad[128] = 36'h94c58d437;
init_grad[129] = 36'h951679433;
init_grad[130] = 36'h95675542f;
init_grad[131] = 36'h95b82142b;
init_grad[132] = 36'h9608dd427;
init_grad[133] = 36'h965989423;
init_grad[134] = 36'h96aa2541f;
init_grad[135] = 36'h96fab141b;
init_grad[136] = 36'h974b2d417;
init_grad[137] = 36'h979b99413;
init_grad[138] = 36'h97ebf540f;
init_grad[139] = 36'h983c4140b;
init_grad[140] = 36'h988c7d407;
init_grad[141] = 36'h98dcab403;
init_grad[142] = 36'h992cc73ff;
init_grad[143] = 36'h997cd53fb;
init_grad[144] = 36'h99ccd33f7;
init_grad[145] = 36'h9a1cc13f3;
init_grad[146] = 36'h9a6c9f3f0;
init_grad[147] = 36'h9abc6f3ec;
init_grad[148] = 36'h9b0c2d3e8;
init_grad[149] = 36'h9b5bdf3e4;
init_grad[150] = 36'h9bab7f3e0;
init_grad[151] = 36'h9bfb113dc;
init_grad[152] = 36'h9c4a933d8;
init_grad[153] = 36'h9c9a053d5;
init_grad[154] = 36'h9ce9693d1;
init_grad[155] = 36'h9d38bd3cd;
init_grad[156] = 36'h9d88013c9;
init_grad[157] = 36'h9dd7373c5;
init_grad[158] = 36'h9e265d3c2;
init_grad[159] = 36'h9e75753be;
init_grad[160] = 36'h9ec47d3ba;
init_grad[161] = 36'h9f13773b6;
init_grad[162] = 36'h9f62613b3;
init_grad[163] = 36'h9fb13d3af;
init_grad[164] = 36'ha000093ab;
init_grad[165] = 36'ha04ec73a7;
init_grad[166] = 36'ha09d753a4;
init_grad[167] = 36'ha0ec153a0;
init_grad[168] = 36'ha13aa539c;
init_grad[169] = 36'ha18927399;
init_grad[170] = 36'ha1d79b395;
init_grad[171] = 36'ha225ff391;
init_grad[172] = 36'ha2745538e;
init_grad[173] = 36'ha2c29d38a;
init_grad[174] = 36'ha310d5386;
init_grad[175] = 36'ha35eff383;
init_grad[176] = 36'ha3ad1b37f;
init_grad[177] = 36'ha3fb2937b;
init_grad[178] = 36'ha44927378;
init_grad[179] = 36'ha49717374;
init_grad[180] = 36'ha4e4f9371;
init_grad[181] = 36'ha532cb36d;
init_grad[182] = 36'ha58091369;
init_grad[183] = 36'ha5ce47366;
init_grad[184] = 36'ha61bef362;
init_grad[185] = 36'ha6698935f;
init_grad[186] = 36'ha6b71535b;
init_grad[187] = 36'ha70493358;
init_grad[188] = 36'ha75201354;
init_grad[189] = 36'ha79f63351;
init_grad[190] = 36'ha7ecb534d;
init_grad[191] = 36'ha839fb34a;
init_grad[192] = 36'ha88731346;
init_grad[193] = 36'ha8d45b343;
init_grad[194] = 36'ha9217533f;
init_grad[195] = 36'ha96e8333c;
init_grad[196] = 36'ha9bb81338;
init_grad[197] = 36'haa0873335;
init_grad[198] = 36'haa5555331;
init_grad[199] = 36'haaa22b32e;
init_grad[200] = 36'haaeef132a;
init_grad[201] = 36'hab3bab327;
init_grad[202] = 36'hab8857323;
init_grad[203] = 36'habd4f5320;
init_grad[204] = 36'hac218531d;
init_grad[205] = 36'hac6e09319;
init_grad[206] = 36'hacba7d316;
init_grad[207] = 36'had06e5312;
init_grad[208] = 36'had533f30f;
init_grad[209] = 36'had9f8b30c;
init_grad[210] = 36'hadebc9308;
init_grad[211] = 36'hae37fb305;
init_grad[212] = 36'hae841f302;
init_grad[213] = 36'haed0352fe;
init_grad[214] = 36'haf1c3d2fb;
init_grad[215] = 36'haf68392f7;
init_grad[216] = 36'hafb4272f4;
init_grad[217] = 36'hb000092f1;
init_grad[218] = 36'hb04bdb2ed;
init_grad[219] = 36'hb097a12ea;
init_grad[220] = 36'hb0e35b2e7;
init_grad[221] = 36'hb12f072e4;
init_grad[222] = 36'hb17aa52e0;
init_grad[223] = 36'hb1c6352dd;
init_grad[224] = 36'hb211b92da;
init_grad[225] = 36'hb25d312d6;
init_grad[226] = 36'hb2a89b2d3;
init_grad[227] = 36'hb2f3f72d0;
init_grad[228] = 36'hb33f472cd;
init_grad[229] = 36'hb38a892c9;
init_grad[230] = 36'hb3d5bf2c6;
init_grad[231] = 36'hb420e92c3;
init_grad[232] = 36'hb46c052c0;
init_grad[233] = 36'hb4b7132bc;
init_grad[234] = 36'hb502152b9;
init_grad[235] = 36'hb54d0b2b6;
init_grad[236] = 36'hb597f32b3;
init_grad[237] = 36'hb5e2cd2b0;
init_grad[238] = 36'hb62d9d2ac;
init_grad[239] = 36'hb6785f2a9;
init_grad[240] = 36'hb6c3132a6;
init_grad[241] = 36'hb70dbd2a3;
init_grad[242] = 36'hb758572a0;
init_grad[243] = 36'hb7a2e729d;
init_grad[244] = 36'hb7ed69299;
init_grad[245] = 36'hb837df296;
init_grad[246] = 36'hb88249293;
init_grad[247] = 36'hb8cca5290;
init_grad[248] = 36'hb916f528d;
init_grad[249] = 36'hb9613928a;
init_grad[250] = 36'hb9ab71287;
init_grad[251] = 36'hb9f59b284;
init_grad[252] = 36'hba3fb9280;
init_grad[253] = 36'hba89cb27d;
init_grad[254] = 36'hbad3d127a;
init_grad[255] = 36'hbb1dc9277;
init_grad[256] = 36'hbb67b7274;
init_grad[257] = 36'hbbb197271;
init_grad[258] = 36'hbbfb6b26e;
init_grad[259] = 36'hbc453326b;
init_grad[260] = 36'hbc8eef268;
init_grad[261] = 36'hbcd89f265;
init_grad[262] = 36'hbd2241262;
init_grad[263] = 36'hbd6bd925f;
init_grad[264] = 36'hbdb56325c;
init_grad[265] = 36'hbdfee3259;
init_grad[266] = 36'hbe4855256;
init_grad[267] = 36'hbe91bb253;
init_grad[268] = 36'hbedb15250;
init_grad[269] = 36'hbf246524d;
init_grad[270] = 36'hbf6da724a;
init_grad[271] = 36'hbfb6dd247;
init_grad[272] = 36'hc00007244;
init_grad[273] = 36'hc04927241;
init_grad[274] = 36'hc0923923e;
init_grad[275] = 36'hc0db3f23b;
init_grad[276] = 36'hc1243b238;
init_grad[277] = 36'hc16d29235;
init_grad[278] = 36'hc1b60d232;
init_grad[279] = 36'hc1fee522f;
init_grad[280] = 36'hc247b122c;
init_grad[281] = 36'hc29071229;
init_grad[282] = 36'hc2d925226;
init_grad[283] = 36'hc321cd223;
init_grad[284] = 36'hc36a69220;
init_grad[285] = 36'hc3b2fb21d;
init_grad[286] = 36'hc3fb7f21b;
init_grad[287] = 36'hc443f9218;
init_grad[288] = 36'hc48c67215;
init_grad[289] = 36'hc4d4cb212;
init_grad[290] = 36'hc51d2120f;
init_grad[291] = 36'hc5656d20c;
init_grad[292] = 36'hc5adad209;
init_grad[293] = 36'hc5f5e1206;
init_grad[294] = 36'hc63e0b204;
init_grad[295] = 36'hc68627201;
init_grad[296] = 36'hc6ce391fe;
init_grad[297] = 36'hc716411fb;
init_grad[298] = 36'hc75e3b1f8;
init_grad[299] = 36'hc7a62b1f5;
init_grad[300] = 36'hc7ee111f2;
init_grad[301] = 36'hc835e91f0;
init_grad[302] = 36'hc87db71ed;
init_grad[303] = 36'hc8c57b1ea;
init_grad[304] = 36'hc90d311e7;
init_grad[305] = 36'hc954dd1e4;
init_grad[306] = 36'hc99c7f1e2;
init_grad[307] = 36'hc9e4151df;
init_grad[308] = 36'hca2b9f1dc;
init_grad[309] = 36'hca731f1d9;
init_grad[310] = 36'hcaba931d6;
init_grad[311] = 36'hcb01fb1d4;
init_grad[312] = 36'hcb49591d1;
init_grad[313] = 36'hcb90ad1ce;
init_grad[314] = 36'hcbd7f51cb;
init_grad[315] = 36'hcc1f311c9;
init_grad[316] = 36'hcc66631c6;
init_grad[317] = 36'hccad891c3;
init_grad[318] = 36'hccf4a51c0;
init_grad[319] = 36'hcd3bb51be;
init_grad[320] = 36'hcd82bb1bb;
init_grad[321] = 36'hcdc9b71b8;
init_grad[322] = 36'hce10a71b5;
init_grad[323] = 36'hce578b1b3;
init_grad[324] = 36'hce9e671b0;
init_grad[325] = 36'hcee5351ad;
init_grad[326] = 36'hcf2bfb1ab;
init_grad[327] = 36'hcf72b51a8;
init_grad[328] = 36'hcfb9631a5;
init_grad[329] = 36'hd000071a3;
init_grad[330] = 36'hd046a11a0;
init_grad[331] = 36'hd08d2f19d;
init_grad[332] = 36'hd0d3b319b;
init_grad[333] = 36'hd11a2d198;
init_grad[334] = 36'hd1609d195;
init_grad[335] = 36'hd1a701193;
init_grad[336] = 36'hd1ed59190;
init_grad[337] = 36'hd233a918d;
init_grad[338] = 36'hd279ed18b;
init_grad[339] = 36'hd2c027188;
init_grad[340] = 36'hd30655185;
init_grad[341] = 36'hd34c79183;
init_grad[342] = 36'hd39293180;
init_grad[343] = 36'hd3d8a317d;
init_grad[344] = 36'hd41ea917b;
init_grad[345] = 36'hd464a3178;
init_grad[346] = 36'hd4aa93176;
init_grad[347] = 36'hd4f079173;
init_grad[348] = 36'hd53653170;
init_grad[349] = 36'hd57c2516e;
init_grad[350] = 36'hd5c1eb16b;
init_grad[351] = 36'hd607a7169;
init_grad[352] = 36'hd64d59166;
init_grad[353] = 36'hd69301164;
init_grad[354] = 36'hd6d89d161;
init_grad[355] = 36'hd71e3115e;
init_grad[356] = 36'hd763b915c;
init_grad[357] = 36'hd7a937159;
init_grad[358] = 36'hd7eeab157;
init_grad[359] = 36'hd83415154;
init_grad[360] = 36'hd87975152;
init_grad[361] = 36'hd8becb14f;
init_grad[362] = 36'hd9041714d;
init_grad[363] = 36'hd9495714a;
init_grad[364] = 36'hd98e8f148;
init_grad[365] = 36'hd9d3bb145;
init_grad[366] = 36'hda18df142;
init_grad[367] = 36'hda5df7140;
init_grad[368] = 36'hdaa30713d;
init_grad[369] = 36'hdae80b13b;
init_grad[370] = 36'hdb2d05138;
init_grad[371] = 36'hdb71f7136;
init_grad[372] = 36'hdbb6dd133;
init_grad[373] = 36'hdbfbb9131;
init_grad[374] = 36'hdc408d12e;
init_grad[375] = 36'hdc855512c;
init_grad[376] = 36'hdcca1512a;
init_grad[377] = 36'hdd0ec9127;
init_grad[378] = 36'hdd5375125;
init_grad[379] = 36'hdd9815122;
init_grad[380] = 36'hdddcad120;
init_grad[381] = 36'hde213b11d;
init_grad[382] = 36'hde65bf11b;
init_grad[383] = 36'hdeaa39118;
init_grad[384] = 36'hdeeea9116;
init_grad[385] = 36'hdf330f113;
init_grad[386] = 36'hdf776b111;
init_grad[387] = 36'hdfbbbf10f;
init_grad[388] = 36'he0000710c;
init_grad[389] = 36'he0444710a;
init_grad[390] = 36'he0887d107;
init_grad[391] = 36'he0cca9105;
init_grad[392] = 36'he110cb102;
init_grad[393] = 36'he154e3100;
init_grad[394] = 36'he198f30fe;
init_grad[395] = 36'he1dcf90fb;
init_grad[396] = 36'he220f30f9;
init_grad[397] = 36'he264e70f7;
init_grad[398] = 36'he2a8cf0f4;
init_grad[399] = 36'he2ecaf0f2;
init_grad[400] = 36'he330830ef;
init_grad[401] = 36'he374510ed;
init_grad[402] = 36'he3b8130eb;
init_grad[403] = 36'he3fbcb0e8;
init_grad[404] = 36'he43f7b0e6;
init_grad[405] = 36'he483210e4;
init_grad[406] = 36'he4c6bf0e1;
init_grad[407] = 36'he50a510df;
init_grad[408] = 36'he54ddb0dc;
init_grad[409] = 36'he5915d0da;
init_grad[410] = 36'he5d4d30d8;
init_grad[411] = 36'he618410d5;
init_grad[412] = 36'he65ba50d3;
init_grad[413] = 36'he69f010d1;
init_grad[414] = 36'he6e2530ce;
init_grad[415] = 36'he7259b0cc;
init_grad[416] = 36'he768db0ca;
init_grad[417] = 36'he7ac110c8;
init_grad[418] = 36'he7ef3d0c5;
init_grad[419] = 36'he832610c3;
init_grad[420] = 36'he8757b0c1;
init_grad[421] = 36'he8b88d0be;
init_grad[422] = 36'he8fb930bc;
init_grad[423] = 36'he93e930ba;
init_grad[424] = 36'he981870b7;
init_grad[425] = 36'he9c4750b5;
init_grad[426] = 36'hea07570b3;
init_grad[427] = 36'hea4a310b1;
init_grad[428] = 36'hea8d030ae;
init_grad[429] = 36'heacfcb0ac;
init_grad[430] = 36'heb12890aa;
init_grad[431] = 36'heb553f0a8;
init_grad[432] = 36'heb97eb0a5;
init_grad[433] = 36'hebda8f0a3;
init_grad[434] = 36'hec1d290a1;
init_grad[435] = 36'hec5fbb09f;
init_grad[436] = 36'heca24309c;
init_grad[437] = 36'hece4c309a;
init_grad[438] = 36'hed2739098;
init_grad[439] = 36'hed69a7096;
init_grad[440] = 36'hedac0d093;
init_grad[441] = 36'hedee69091;
init_grad[442] = 36'hee30bb08f;
init_grad[443] = 36'hee730508d;
init_grad[444] = 36'heeb54708a;
init_grad[445] = 36'heef77f088;
init_grad[446] = 36'hef39ad086;
init_grad[447] = 36'hef7bd5084;
init_grad[448] = 36'hefbdf3082;
init_grad[449] = 36'hf0000707f;
init_grad[450] = 36'hf0421307d;
init_grad[451] = 36'hf0841707b;
init_grad[452] = 36'hf0c611079;
init_grad[453] = 36'hf10803077;
init_grad[454] = 36'hf149eb074;
init_grad[455] = 36'hf18bcd072;
init_grad[456] = 36'hf1cda3070;
init_grad[457] = 36'hf20f7306e;
init_grad[458] = 36'hf2513906c;
init_grad[459] = 36'hf292f706a;
init_grad[460] = 36'hf2d4ab067;
init_grad[461] = 36'hf31657065;
init_grad[462] = 36'hf357fb063;
init_grad[463] = 36'hf39995061;
init_grad[464] = 36'hf3db2905f;
init_grad[465] = 36'hf41cb305d;
init_grad[466] = 36'hf45e3305b;
init_grad[467] = 36'hf49fab058;
init_grad[468] = 36'hf4e11b056;
init_grad[469] = 36'hf52283054;
init_grad[470] = 36'hf563e3052;
init_grad[471] = 36'hf5a539050;
init_grad[472] = 36'hf5e68704e;
init_grad[473] = 36'hf627cd04c;
init_grad[474] = 36'hf6690904a;
init_grad[475] = 36'hf6aa3d047;
init_grad[476] = 36'hf6eb69045;
init_grad[477] = 36'hf72c8d043;
init_grad[478] = 36'hf76da9041;
init_grad[479] = 36'hf7aebb03f;
init_grad[480] = 36'hf7efc503d;
init_grad[481] = 36'hf830c703b;
init_grad[482] = 36'hf871c1039;
init_grad[483] = 36'hf8b2b3037;
init_grad[484] = 36'hf8f39b035;
init_grad[485] = 36'hf9347b033;
init_grad[486] = 36'hf97553030;
init_grad[487] = 36'hf9b62302e;
init_grad[488] = 36'hf9f6eb02c;
init_grad[489] = 36'hfa37ab02a;
init_grad[490] = 36'hfa7861028;
init_grad[491] = 36'hfab911026;
init_grad[492] = 36'hfaf9b7024;
init_grad[493] = 36'hfb3a55022;
init_grad[494] = 36'hfb7aeb020;
init_grad[495] = 36'hfbbb7901e;
init_grad[496] = 36'hfbfbff01c;
init_grad[497] = 36'hfc3c7d01a;
init_grad[498] = 36'hfc7cf1018;
init_grad[499] = 36'hfcbd5f016;
init_grad[500] = 36'hfcfdc3014;
init_grad[501] = 36'hfd3e21012;
init_grad[502] = 36'hfd7e75010;
init_grad[503] = 36'hfdbec100e;
init_grad[504] = 36'hfdff0500c;
init_grad[505] = 36'hfe3f4300a;
init_grad[506] = 36'hfe7f77008;
init_grad[507] = 36'hfebfa3006;
init_grad[508] = 36'hfeffc7004;
init_grad[509] = 36'hff3fe3001;
init_grad[510] = 36'hff7ff6fff;
init_grad[511] = 36'hffc002ffd;
init_grad[512] = 36'h6ffb;
init_grad[513] = 36'h3ffeff7;
init_grad[514] = 36'h7fe6ff3;
init_grad[515] = 36'hbfbefef;
init_grad[516] = 36'hff86feb;
init_grad[517] = 36'h13f40fe7;
init_grad[518] = 36'h17ee8fe3;
init_grad[519] = 36'h1be80fdf;
init_grad[520] = 36'h1fe0afdb;
init_grad[521] = 36'h23d84fd7;
init_grad[522] = 36'h27ceefd3;
init_grad[523] = 36'h2bc48fcf;
init_grad[524] = 36'h2fb94fcb;
init_grad[525] = 36'h33ad0fc8;
init_grad[526] = 36'h379fcfc4;
init_grad[527] = 36'h3b918fc0;
init_grad[528] = 36'h3f826fbc;
init_grad[529] = 36'h43724fb8;
init_grad[530] = 36'h47612fb5;
init_grad[531] = 36'h4b4f2fb1;
init_grad[532] = 36'h4f3c4fad;
init_grad[533] = 36'h53284fa9;
init_grad[534] = 36'h57138fa5;
init_grad[535] = 36'h5afdafa2;
init_grad[536] = 36'h5ee70f9e;
init_grad[537] = 36'h62cf4f9a;
init_grad[538] = 36'h66b6cf97;
init_grad[539] = 36'h6a9d2f93;
init_grad[540] = 36'h6e82cf8f;
init_grad[541] = 36'h72676f8b;
init_grad[542] = 36'h764b2f88;
init_grad[543] = 36'h7a2def84;
init_grad[544] = 36'h7e0fcf80;
init_grad[545] = 36'h81f0cf7d;
init_grad[546] = 36'h85d0cf79;
init_grad[547] = 36'h89b00f76;
init_grad[548] = 36'h8d8e4f72;
init_grad[549] = 36'h916b8f6e;
init_grad[550] = 36'h95480f6b;
init_grad[551] = 36'h99238f67;
init_grad[552] = 36'h9cfe2f64;
init_grad[553] = 36'ha0d7ef60;
init_grad[554] = 36'ha4b0cf5d;
init_grad[555] = 36'ha888cf59;
init_grad[556] = 36'hac5fef55;
init_grad[557] = 36'hb0360f52;
init_grad[558] = 36'hb40b6f4e;
init_grad[559] = 36'hb7dfef4b;
init_grad[560] = 36'hbbb36f47;
init_grad[561] = 36'hbf862f44;
init_grad[562] = 36'hc357ef40;
init_grad[563] = 36'hc728ef3d;
init_grad[564] = 36'hcaf90f3a;
init_grad[565] = 36'hcec82f36;
init_grad[566] = 36'hd2968f33;
init_grad[567] = 36'hd6640f2f;
init_grad[568] = 36'hda30af2c;
init_grad[569] = 36'hddfc8f28;
init_grad[570] = 36'he1c76f25;
init_grad[571] = 36'he5918f22;
init_grad[572] = 36'he95acf1e;
init_grad[573] = 36'hed232f1b;
init_grad[574] = 36'hf0eaaf17;
init_grad[575] = 36'hf4b14f14;
init_grad[576] = 36'hf8772f11;
init_grad[577] = 36'hfc3c2f0d;
init_grad[578] = 36'h100006f0a;
init_grad[579] = 36'h103c3cf07;
init_grad[580] = 36'h107864f03;
init_grad[581] = 36'h10b47ef00;
init_grad[582] = 36'h10f08cefd;
init_grad[583] = 36'h112c8cefa;
init_grad[584] = 36'h116880ef6;
init_grad[585] = 36'h11a466ef3;
init_grad[586] = 36'h11e040ef0;
init_grad[587] = 36'h121c0ceec;
init_grad[588] = 36'h1257caee9;
init_grad[589] = 36'h12937cee6;
init_grad[590] = 36'h12cf22ee3;
init_grad[591] = 36'h130abaee0;
init_grad[592] = 36'h134646edc;
init_grad[593] = 36'h1381c4ed9;
init_grad[594] = 36'h13bd36ed6;
init_grad[595] = 36'h13f89aed3;
init_grad[596] = 36'h1433f2ed0;
init_grad[597] = 36'h146f3eecc;
init_grad[598] = 36'h14aa7cec9;
init_grad[599] = 36'h14e5aeec6;
init_grad[600] = 36'h1520d2ec3;
init_grad[601] = 36'h155becec0;
init_grad[602] = 36'h1596f8ebd;
init_grad[603] = 36'h15d1f6eb9;
init_grad[604] = 36'h160ceaeb6;
init_grad[605] = 36'h1647d0eb3;
init_grad[606] = 36'h1682aaeb0;
init_grad[607] = 36'h16bd78ead;
init_grad[608] = 36'h16f838eaa;
init_grad[609] = 36'h1732eeea7;
init_grad[610] = 36'h176d96ea4;
init_grad[611] = 36'h17a832ea1;
init_grad[612] = 36'h17e2c2e9e;
init_grad[613] = 36'h181d46e9b;
init_grad[614] = 36'h1857bee98;
init_grad[615] = 36'h189228e95;
init_grad[616] = 36'h18cc88e92;
init_grad[617] = 36'h1906dae8e;
init_grad[618] = 36'h194122e8b;
init_grad[619] = 36'h197b5ce88;
init_grad[620] = 36'h19b58ce85;
init_grad[621] = 36'h19efaee82;
init_grad[622] = 36'h1a29c4e7f;
init_grad[623] = 36'h1a63d0e7d;
init_grad[624] = 36'h1a9dcee7a;
init_grad[625] = 36'h1ad7c2e77;
init_grad[626] = 36'h1b11a8e74;
init_grad[627] = 36'h1b4b84e71;
init_grad[628] = 36'h1b8554e6e;
init_grad[629] = 36'h1bbf18e6b;
init_grad[630] = 36'h1bf8d0e68;
init_grad[631] = 36'h1c327ce65;
init_grad[632] = 36'h1c6c1ce62;
init_grad[633] = 36'h1ca5b0e5f;
init_grad[634] = 36'h1cdf3ae5c;
init_grad[635] = 36'h1d18b8e59;
init_grad[636] = 36'h1d522ae56;
init_grad[637] = 36'h1d8b90e54;
init_grad[638] = 36'h1dc4ece51;
init_grad[639] = 36'h1dfe3ce4e;
init_grad[640] = 36'h1e3780e4b;
init_grad[641] = 36'h1e70b8e48;
init_grad[642] = 36'h1ea9e4e45;
init_grad[643] = 36'h1ee306e42;
init_grad[644] = 36'h1f1c1ce40;
init_grad[645] = 36'h1f5528e3d;
init_grad[646] = 36'h1f8e28e3a;
init_grad[647] = 36'h1fc71ce37;
init_grad[648] = 36'h200006e34;
init_grad[649] = 36'h2038e4e32;
init_grad[650] = 36'h2071b6e2f;
init_grad[651] = 36'h20aa7ee2c;
init_grad[652] = 36'h20e33ae29;
init_grad[653] = 36'h211bece26;
init_grad[654] = 36'h215492e24;
init_grad[655] = 36'h218d2ce21;
init_grad[656] = 36'h21c5bce1e;
init_grad[657] = 36'h21fe42e1b;
init_grad[658] = 36'h2236bce19;
init_grad[659] = 36'h226f2ae16;
init_grad[660] = 36'h22a78ee13;
init_grad[661] = 36'h22dfe8e10;
init_grad[662] = 36'h231836e0e;
init_grad[663] = 36'h235078e0b;
init_grad[664] = 36'h2388b2e08;
init_grad[665] = 36'h23c0dee06;
init_grad[666] = 36'h23f902e03;
init_grad[667] = 36'h24311ae00;
init_grad[668] = 36'h246926dfe;
init_grad[669] = 36'h24a12adfb;
init_grad[670] = 36'h24d922df8;
init_grad[671] = 36'h25110edf5;
init_grad[672] = 36'h2548f0df3;
init_grad[673] = 36'h2580c8df0;
init_grad[674] = 36'h25b896dee;
init_grad[675] = 36'h25f058deb;
init_grad[676] = 36'h262810de8;
init_grad[677] = 36'h265fbede6;
init_grad[678] = 36'h269760de3;
init_grad[679] = 36'h26cefade0;
init_grad[680] = 36'h270688dde;
init_grad[681] = 36'h273e0addb;
init_grad[682] = 36'h277584dd9;
init_grad[683] = 36'h27acf2dd6;
init_grad[684] = 36'h27e456dd3;
init_grad[685] = 36'h281bb0dd1;
init_grad[686] = 36'h285300dce;
init_grad[687] = 36'h288a46dcc;
init_grad[688] = 36'h28c180dc9;
init_grad[689] = 36'h28f8b2dc7;
init_grad[690] = 36'h292fd8dc4;
init_grad[691] = 36'h2966f4dc1;
init_grad[692] = 36'h299e06dbf;
init_grad[693] = 36'h29d50edbc;
init_grad[694] = 36'h2a0c0cdba;
init_grad[695] = 36'h2a4300db7;
init_grad[696] = 36'h2a79e8db5;
init_grad[697] = 36'h2ab0c8db2;
init_grad[698] = 36'h2ae79edb0;
init_grad[699] = 36'h2b1e68dad;
init_grad[700] = 36'h2b552adab;
init_grad[701] = 36'h2b8be0da8;
init_grad[702] = 36'h2bc28eda6;
init_grad[703] = 36'h2bf932da3;
init_grad[704] = 36'h2c2fcada1;
init_grad[705] = 36'h2c665ad9e;
init_grad[706] = 36'h2c9ce0d9c;
init_grad[707] = 36'h2cd35ad99;
init_grad[708] = 36'h2d09ccd97;
init_grad[709] = 36'h2d4034d94;
init_grad[710] = 36'h2d7692d92;
init_grad[711] = 36'h2dace6d90;
init_grad[712] = 36'h2de332d8d;
init_grad[713] = 36'h2e1972d8b;
init_grad[714] = 36'h2e4faad88;
init_grad[715] = 36'h2e85d6d86;
init_grad[716] = 36'h2ebbfad83;
init_grad[717] = 36'h2ef214d81;
init_grad[718] = 36'h2f2824d7f;
init_grad[719] = 36'h2f5e2ad7c;
init_grad[720] = 36'h2f9428d7a;
init_grad[721] = 36'h2fca1cd77;
init_grad[722] = 36'h300004d75;
init_grad[723] = 36'h3035e6d73;
init_grad[724] = 36'h306bbcd70;
init_grad[725] = 36'h30a18ad6e;
init_grad[726] = 36'h30d74cd6c;
init_grad[727] = 36'h310d08d69;
init_grad[728] = 36'h3142b8d67;
init_grad[729] = 36'h317860d64;
init_grad[730] = 36'h31adfed62;
init_grad[731] = 36'h31e392d60;
init_grad[732] = 36'h32191cd5d;
init_grad[733] = 36'h324e9ed5b;
init_grad[734] = 36'h328418d59;
init_grad[735] = 36'h32b986d56;
init_grad[736] = 36'h32eeecd54;
init_grad[737] = 36'h332448d52;
init_grad[738] = 36'h33599cd50;
init_grad[739] = 36'h338ee6d4d;
init_grad[740] = 36'h33c426d4b;
init_grad[741] = 36'h33f95ed49;
init_grad[742] = 36'h342e8cd46;
init_grad[743] = 36'h3463b2d44;
init_grad[744] = 36'h3498ced42;
init_grad[745] = 36'h34cde2d3f;
init_grad[746] = 36'h3502ecd3d;
init_grad[747] = 36'h3537ecd3b;
init_grad[748] = 36'h356ce4d39;
init_grad[749] = 36'h35a1d2d36;
init_grad[750] = 36'h35d6b8d34;
init_grad[751] = 36'h360b94d32;
init_grad[752] = 36'h364068d30;
init_grad[753] = 36'h367532d2d;
init_grad[754] = 36'h36a9f4d2b;
init_grad[755] = 36'h36deacd29;
init_grad[756] = 36'h37135cd27;
init_grad[757] = 36'h374802d25;
init_grad[758] = 36'h377ca0d22;
init_grad[759] = 36'h37b136d20;
init_grad[760] = 36'h37e5c2d1e;
init_grad[761] = 36'h381a46d1c;
init_grad[762] = 36'h384ec0d19;
init_grad[763] = 36'h388332d17;
init_grad[764] = 36'h38b79ad15;
init_grad[765] = 36'h38ebfad13;
init_grad[766] = 36'h392052d11;
init_grad[767] = 36'h3954a0d0f;
init_grad[768] = 36'h3988e6d0c;
init_grad[769] = 36'h39bd22d0a;
init_grad[770] = 36'h39f158d08;
init_grad[771] = 36'h3a2584d06;
init_grad[772] = 36'h3a59a6d04;
init_grad[773] = 36'h3a8dc0d02;
init_grad[774] = 36'h3ac1d2cff;
init_grad[775] = 36'h3af5dccfd;
init_grad[776] = 36'h3b29dccfb;
init_grad[777] = 36'h3b5dd4cf9;
init_grad[778] = 36'h3b91c4cf7;
init_grad[779] = 36'h3bc5aacf5;
init_grad[780] = 36'h3bf98acf3;
init_grad[781] = 36'h3c2d60cf0;
init_grad[782] = 36'h3c612ccee;
init_grad[783] = 36'h3c94f2cec;
init_grad[784] = 36'h3cc8aecea;
init_grad[785] = 36'h3cfc62ce8;
init_grad[786] = 36'h3d300ece6;
init_grad[787] = 36'h3d63b2ce4;
init_grad[788] = 36'h3d974cce2;
init_grad[789] = 36'h3dcadece0;
init_grad[790] = 36'h3dfe68cde;
init_grad[791] = 36'h3e31eacdb;
init_grad[792] = 36'h3e6564cd9;
init_grad[793] = 36'h3e98d4cd7;
init_grad[794] = 36'h3ecc3ecd5;
init_grad[795] = 36'h3eff9ecd3;
init_grad[796] = 36'h3f32f6cd1;
init_grad[797] = 36'h3f6646ccf;
init_grad[798] = 36'h3f998eccd;
init_grad[799] = 36'h3fccceccb;
init_grad[800] = 36'h400004cc9;
init_grad[801] = 36'h403334cc7;
init_grad[802] = 36'h40665acc5;
init_grad[803] = 36'h40997acc3;
init_grad[804] = 36'h40cc90cc1;
init_grad[805] = 36'h40ff9ecbf;
init_grad[806] = 36'h4132a4cbd;
init_grad[807] = 36'h4165a4cbb;
init_grad[808] = 36'h41989acb9;
init_grad[809] = 36'h41cb88cb7;
init_grad[810] = 36'h41fe6ecb5;
init_grad[811] = 36'h42314ccb3;
init_grad[812] = 36'h426422cb1;
init_grad[813] = 36'h4296f0caf;
init_grad[814] = 36'h42c9b6cad;
init_grad[815] = 36'h42fc74cab;
init_grad[816] = 36'h432f2aca9;
init_grad[817] = 36'h4361d8ca7;
init_grad[818] = 36'h43947eca5;
init_grad[819] = 36'h43c71cca3;
init_grad[820] = 36'h43f9b2ca1;
init_grad[821] = 36'h442c40c9f;
init_grad[822] = 36'h445ec8c9d;
init_grad[823] = 36'h449146c9b;
init_grad[824] = 36'h44c3bcc99;
init_grad[825] = 36'h44f62cc97;
init_grad[826] = 36'h452892c95;
init_grad[827] = 36'h455af2c93;
init_grad[828] = 36'h458d4ac91;
init_grad[829] = 36'h45bf9ac8f;
init_grad[830] = 36'h45f1e2c8d;
init_grad[831] = 36'h462422c8b;
init_grad[832] = 36'h46565ac89;
init_grad[833] = 36'h46888cc87;
init_grad[834] = 36'h46bab4c86;
init_grad[835] = 36'h46ecd6c84;
init_grad[836] = 36'h471ef0c82;
init_grad[837] = 36'h475102c80;
init_grad[838] = 36'h47830cc7e;
init_grad[839] = 36'h47b50ec7c;
init_grad[840] = 36'h47e70ac7a;
init_grad[841] = 36'h4818fec78;
init_grad[842] = 36'h484aeac76;
init_grad[843] = 36'h487ccec74;
init_grad[844] = 36'h48aeaac72;
init_grad[845] = 36'h48e080c71;
init_grad[846] = 36'h49124cc6f;
init_grad[847] = 36'h494414c6d;
init_grad[848] = 36'h4975d2c6b;
init_grad[849] = 36'h49a788c69;
init_grad[850] = 36'h49d938c67;
init_grad[851] = 36'h4a0ae0c65;
init_grad[852] = 36'h4a3c82c63;
init_grad[853] = 36'h4a6e1ac62;
init_grad[854] = 36'h4a9facc60;
init_grad[855] = 36'h4ad136c5e;
init_grad[856] = 36'h4b02bac5c;
init_grad[857] = 36'h4b3434c5a;
init_grad[858] = 36'h4b65a8c58;
init_grad[859] = 36'h4b9716c57;
init_grad[860] = 36'h4bc87ac55;
init_grad[861] = 36'h4bf9d8c53;
init_grad[862] = 36'h4c2b30c51;
init_grad[863] = 36'h4c5c80c4f;
init_grad[864] = 36'h4c8dc8c4d;
init_grad[865] = 36'h4cbf08c4c;
init_grad[866] = 36'h4cf042c4a;
init_grad[867] = 36'h4d2174c48;
init_grad[868] = 36'h4d529ec46;
init_grad[869] = 36'h4d83c2c44;
init_grad[870] = 36'h4db4dec43;
init_grad[871] = 36'h4de5f4c41;
init_grad[872] = 36'h4e1702c3f;
init_grad[873] = 36'h4e4808c3d;
init_grad[874] = 36'h4e7908c3b;
init_grad[875] = 36'h4eaa00c3a;
init_grad[876] = 36'h4edaf2c38;
init_grad[877] = 36'h4f0bdcc36;
init_grad[878] = 36'h4f3cc0c34;
init_grad[879] = 36'h4f6d9cc32;
init_grad[880] = 36'h4f9e70c31;
init_grad[881] = 36'h4fcf3ec2f;
init_grad[882] = 36'h500004c2d;
init_grad[883] = 36'h5030c4c2b;
init_grad[884] = 36'h50617cc2a;
init_grad[885] = 36'h50922ec28;
init_grad[886] = 36'h50c2d8c26;
init_grad[887] = 36'h50f37cc24;
init_grad[888] = 36'h512418c23;
init_grad[889] = 36'h5154acc21;
init_grad[890] = 36'h51853cc1f;
init_grad[891] = 36'h51b5c2c1d;
init_grad[892] = 36'h51e642c1c;
init_grad[893] = 36'h5216bcc1a;
init_grad[894] = 36'h52472ec18;
init_grad[895] = 36'h52779ac16;
init_grad[896] = 36'h52a7fec15;
init_grad[897] = 36'h52d85cc13;
init_grad[898] = 36'h5308b4c11;
init_grad[899] = 36'h533904c0f;
init_grad[900] = 36'h53694cc0e;
init_grad[901] = 36'h53998ec0c;
init_grad[902] = 36'h53c9cac0a;
init_grad[903] = 36'h53f9fec09;
init_grad[904] = 36'h542a2cc07;
init_grad[905] = 36'h545a52c05;
init_grad[906] = 36'h548a72c04;
init_grad[907] = 36'h54ba8cc02;
init_grad[908] = 36'h54ea9ec00;
init_grad[909] = 36'h551aaabfe;
init_grad[910] = 36'h554aaebfd;
init_grad[911] = 36'h557aacbfb;
init_grad[912] = 36'h55aaa4bf9;
init_grad[913] = 36'h55da94bf8;
init_grad[914] = 36'h560a7ebf6;
init_grad[915] = 36'h563a62bf4;
init_grad[916] = 36'h566a3ebf3;
init_grad[917] = 36'h569a14bf1;
init_grad[918] = 36'h56c9e4bef;
init_grad[919] = 36'h56f9acbee;
init_grad[920] = 36'h57296ebec;
init_grad[921] = 36'h575928bea;
init_grad[922] = 36'h5788debe9;
init_grad[923] = 36'h57b88cbe7;
init_grad[924] = 36'h57e832be5;
init_grad[925] = 36'h5817d4be4;
init_grad[926] = 36'h58476ebe2;
init_grad[927] = 36'h587702be1;
init_grad[928] = 36'h58a68ebdf;
init_grad[929] = 36'h58d614bdd;
init_grad[930] = 36'h590594bdc;
init_grad[931] = 36'h59350ebda;
init_grad[932] = 36'h596480bd8;
init_grad[933] = 36'h5993eebd7;
init_grad[934] = 36'h59c354bd5;
init_grad[935] = 36'h59f2b2bd3;
init_grad[936] = 36'h5a220cbd2;
init_grad[937] = 36'h5a515ebd0;
init_grad[938] = 36'h5a80aabcf;
init_grad[939] = 36'h5aafeebcd;
init_grad[940] = 36'h5adf2ebcb;
init_grad[941] = 36'h5b0e66bca;
init_grad[942] = 36'h5b3d98bc8;
init_grad[943] = 36'h5b6cc4bc7;
init_grad[944] = 36'h5b9beabc5;
init_grad[945] = 36'h5bcb08bc3;
init_grad[946] = 36'h5bfa22bc2;
init_grad[947] = 36'h5c2934bc0;
init_grad[948] = 36'h5c5840bbf;
init_grad[949] = 36'h5c8744bbd;
init_grad[950] = 36'h5cb644bbc;
init_grad[951] = 36'h5ce53cbba;
init_grad[952] = 36'h5d1430bb8;
init_grad[953] = 36'h5d431cbb7;
init_grad[954] = 36'h5d7202bb5;
init_grad[955] = 36'h5da0e2bb4;
init_grad[956] = 36'h5dcfbabb2;
init_grad[957] = 36'h5dfe8ebb1;
init_grad[958] = 36'h5e2d5abaf;
init_grad[959] = 36'h5e5c20bad;
init_grad[960] = 36'h5e8ae2bac;
init_grad[961] = 36'h5eb99cbaa;
init_grad[962] = 36'h5ee84eba9;
init_grad[963] = 36'h5f16fcba7;
init_grad[964] = 36'h5f45a4ba6;
init_grad[965] = 36'h5f7446ba4;
init_grad[966] = 36'h5fa2e0ba3;
init_grad[967] = 36'h5fd176ba1;
init_grad[968] = 36'h600004b9f;
init_grad[969] = 36'h602e8cb9e;
init_grad[970] = 36'h605d0eb9c;
init_grad[971] = 36'h608b8cb9b;
init_grad[972] = 36'h60ba02b99;
init_grad[973] = 36'h60e872b98;
init_grad[974] = 36'h6116dcb96;
init_grad[975] = 36'h614540b95;
init_grad[976] = 36'h61739cb93;
init_grad[977] = 36'h61a1f4b92;
init_grad[978] = 36'h61d046b90;
init_grad[979] = 36'h61fe92b8f;
init_grad[980] = 36'h622cd8b8d;
init_grad[981] = 36'h625b16b8c;
init_grad[982] = 36'h628950b8a;
init_grad[983] = 36'h62b784b89;
init_grad[984] = 36'h62e5b0b87;
init_grad[985] = 36'h6313d8b86;
init_grad[986] = 36'h6341fab84;
init_grad[987] = 36'h637014b83;
init_grad[988] = 36'h639e2ab81;
init_grad[989] = 36'h63cc3ab80;
init_grad[990] = 36'h63fa44b7e;
init_grad[991] = 36'h642846b7d;
init_grad[992] = 36'h645644b7b;
init_grad[993] = 36'h64843cb7a;
init_grad[994] = 36'h64b22eb78;
init_grad[995] = 36'h64e01ab77;
init_grad[996] = 36'h650e00b75;
init_grad[997] = 36'h653be0b74;
init_grad[998] = 36'h6569bab72;
init_grad[999] = 36'h65978eb71;
init_grad[1000] = 36'h65c55cb6f;
init_grad[1001] = 36'h65f324b6e;
init_grad[1002] = 36'h6620e8b6d;
init_grad[1003] = 36'h664ea4b6b;
init_grad[1004] = 36'h667c5ab6a;
init_grad[1005] = 36'h66aa0cb68;
init_grad[1006] = 36'h66d7b8b67;
init_grad[1007] = 36'h67055cb65;
init_grad[1008] = 36'h6732fcb64;
init_grad[1009] = 36'h676096b62;
init_grad[1010] = 36'h678e2ab61;
init_grad[1011] = 36'h67bbbab60;
init_grad[1012] = 36'h67e942b5e;
init_grad[1013] = 36'h6816c4b5d;
init_grad[1014] = 36'h684442b5b;
init_grad[1015] = 36'h6871b8b5a;
init_grad[1016] = 36'h689f2ab58;
init_grad[1017] = 36'h68cc96b57;
init_grad[1018] = 36'h68f9fcb55;
init_grad[1019] = 36'h69275eb54;
init_grad[1020] = 36'h6954b8b53;
init_grad[1021] = 36'h69820cb51;
init_grad[1022] = 36'h69af5cb50;
init_grad[1023] = 36'h69dca6b4e;

    end
endmodule