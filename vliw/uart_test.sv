module uart_test();
    logic clk,rst;
    logic rxd, txd;

    always #1 clk = ~clk;

    initial clk = 0;

    initial begin
        rst = 0;
        #12 rst = 1;
        # 7 rxd = 0;
        # 200 rxd = 1;
        # 200 rxd = 0;
        # 200 rxd = 1;
        # 200 rxd = 0;
        # 200 rxd = 1;
        # 200 rxd = 0;
        # 200 rxd = 1;
        # 200 rxd = 0;
        # 200 rxd = 1;
    end

    uart_loopback loopback(.*);
endmodule